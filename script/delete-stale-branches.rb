#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "optparse"
require "json"
require "open3"
require "time"

class StaleBranchCleaner
  DEFAULT_REPO = "googleapis/google-cloud-ruby"
  DEFAULT_REMOTE = "origin"
  DEFAULT_MIN_AGE_DAYS = 30
  DEFAULT_BATCH_SIZE = 50
  DEFAULT_PROTECTED_BRANCHES = %w[main master gh-pages].freeze
  DEFAULT_PROTECTED_PATTERNS = [/^(main|master|gh-pages)$/, /^STABLE_/].freeze

  def initialize(options = {})
    @options = {
      dry_run: true,
      repo: DEFAULT_REPO,
      remote: DEFAULT_REMOTE,
      target: "all",
      min_age_days: DEFAULT_MIN_AGE_DAYS,
      batch_size: DEFAULT_BATCH_SIZE,
      limit: nil,
      method: "git",
      exclude: nil,
      include: nil,
      report: nil,
      verbose: false,
      concurrency: 4
    }.merge(options)

    @stats = Hash.new(0)
    @branches_data = {}
    @open_prs = {}
  end

  def run
    banner
    validate_environment
    fetch_open_prs
    fetch_remote_branches
    inspect_branch_metadata
    classify_branches
    report_summary
    execute_deletions if !options[:dry_run]
    export_report if options[:report]
  end

  private

  attr_reader :options

  def banner
    mode = options[:dry_run] ? "\e[33m[DRY RUN - SAFE MODE]\e[0m" : "\e[31m[MUTATING EXECUTION MODE]\e[0m"
    puts "\n======================================================="
    puts "  Google Cloud Ruby - Stale Branch Cleanup Tool"
    puts "  Mode: #{mode}"
    puts "  Target Repo: #{options[:repo]}"
    puts "  Target Category: #{options[:target].upcase}"
    puts "  Min Age: #{options[:min_age_days]} days"
    puts "=======================================================\n"
  end

  def validate_environment
    # Verify gh CLI is available and authenticated
    out, err, st = Open3.capture3("gh", "auth", "status")
    unless st.success?
      fatal_error("GitHub CLI (gh) authentication check failed: #{err}")
    end

    # Check git identity or repository
    unless Dir.exist?(".git")
      fatal_error("Must be executed from inside a git repository root.")
    end
  end

  def fetch_open_prs
    puts "--> Fetching open pull requests from #{options[:repo]}..."
    cmd = [
      "gh", "pr", "list",
      "-R", options[:repo],
      "--state", "open",
      "--limit", "500",
      "--json", "number,title,headRefName,headRepositoryOwner,updatedAt"
    ]
    stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success?
      fatal_error("Failed to query open PRs via gh CLI: #{stderr}")
    end

    prs = JSON.parse(stdout)
    prs.each do |pr|
      # Note: We track headRefName regardless of fork owner to be extra safe
      @open_prs[pr["headRefName"]] = {
        number: pr["number"],
        title: pr["title"],
        updated_at: pr["updatedAt"],
        owner: pr.dig("headRepositoryOwner", "login")
      }
    end
    puts "    Discovered #{@open_prs.size} open PRs across repository.\n"
  end

  def fetch_remote_branches
    puts "--> Discovering remote branches via git ls-remote..."
    cmd = ["git", "ls-remote", "--heads", options[:remote]]
    stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success?
      # Fallback to https url if remote name fails
      cmd = ["git", "ls-remote", "--heads", "https://github.com/#{options[:repo]}.git"]
      stdout, stderr, status = Open3.capture3(*cmd)
      unless status.success?
        fatal_error("Failed to fetch remote branches: #{stderr}")
      end
    end

    branch_names = stdout.lines.map do |line|
      line.split("\t").last&.strip&.sub(%r{^refs/heads/}, "")
    end.compact

    puts "    Found #{branch_names.size} remote branches on #{options[:repo]}.\n"

    branch_names.each do |name|
      @branches_data[name] = {
        name: name,
        status: :unclassified,
        reason: nil,
        commit_date: nil,
        commit_headline: nil,
        pr_number: nil,
        pr_state: nil,
        pr_title: nil
      }
    end
  end

  def inspect_branch_metadata
    # Separate already protected branches (base branches & open PRs)
    candidates_to_query = []

    @branches_data.each do |name, data|
      if DEFAULT_PROTECTED_BRANCHES.include?(name)
        data[:status] = :protected
        data[:reason] = "Protected base/docs branch"
      elsif @open_prs.key?(name)
        pr = @open_prs[name]
        data[:status] = :protected
        data[:reason] = "Active Open PR ##{pr[:number]} (#{pr[:title]})"
        data[:pr_number] = pr[:number]
        data[:pr_state] = "OPEN"
        data[:pr_title] = pr[:title]
      elsif options[:exclude] && name =~ Regexp.new(options[:exclude])
        data[:status] = :protected
        data[:reason] = "Matched explicit exclude regex: #{options[:exclude]}"
      elsif DEFAULT_PROTECTED_PATTERNS.any? { |pat| name =~ pat }
        data[:status] = :protected
        data[:reason] = "Matched protected pattern"
      else
        candidates_to_query << name
      end
    end

    puts "--> Evaluating metadata for #{candidates_to_query.size} candidate branches..."
    puts "    (Exempted #{@branches_data.size - candidates_to_query.size} branches via base/open PR/exclude protections)"

    # Batch query GraphQL for commit date and associated PR info
    batch_size = 50
    slices = candidates_to_query.each_slice(batch_size).to_a
    total_slices = slices.size
    # Concurrency Clarity:
    # 1. `work_queue` (Thread::Queue): Thread-safe FIFO queue distributing candidate branch slices
    #    (up to 50 branches per GraphQL query) across worker threads. Ensures work is evenly pulled
    #    without duplicate queries or race conditions.
    # 2. `mutex` (Thread::Mutex): Serializes writes to the shared `@branches_data` in-memory hash
    #    and increments `completed_slices` progress counter to prevent race conditions during concurrent
    #    GraphQL response parsing across worker threads.
    completed_slices = 0
    mutex = Mutex.new
    work_queue = Queue.new
    slices.each_with_index { |s, idx| work_queue << [s, idx] }

    workers = [options[:concurrency], total_slices].min.times.map do
      Thread.new do
        until work_queue.empty?
          begin
            slice, idx = work_queue.pop(true)
          rescue ThreadError
            break
          end

          fields = slice.each_with_index.map do |b, i|
            escaped = b.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
            <<~GQL
              b#{i}: ref(qualifiedName: "refs/heads/#{escaped}") {
                name
                target {
                  ... on Commit {
                    committedDate
                    messageHeadline
                  }
                }
                associatedPullRequests(first: 1) {
                  nodes {
                    number
                    state
                    title
                  }
                }
              }
            GQL
          end.join("\n")

          query = "query { repository(owner: \"#{options[:repo].split('/').first}\", name: \"#{options[:repo].split('/').last}\") { #{fields} } }"
          stdout, stderr, status = Open3.capture3("gh", "api", "graphql", "-F", "query=@-", stdin_data: query)

          if status.success?
            begin
              parsed = JSON.parse(stdout).dig("data", "repository") || {}
              mutex.synchronize do
                parsed.each_value do |node|
                  next unless node && node["name"]
                  name = node["name"]
                  rec = @branches_data[name]
                  next unless rec

                  rec[:commit_date] = node.dig("target", "committedDate")
                  rec[:commit_headline] = node.dig("target", "messageHeadline")
                  pr_node = node.dig("associatedPullRequests", "nodes", 0)
                  if pr_node
                    rec[:pr_number] = pr_node["number"]
                    rec[:pr_state] = pr_node["state"]
                    rec[:pr_title] = pr_node["title"]
                  else
                    rec[:pr_state] = "NO_PR"
                  end
                end
                completed_slices += 1
                print "\r    Progress: #{completed_slices}/#{total_slices} batches queried (#{(completed_slices.to_f / total_slices * 100).round}%)"
              end
            rescue JSON::ParserError => e
              warn "\nFailed to parse GraphQL batch #{idx}: #{e.message}"
            end
          else
            warn "\nGraphQL batch #{idx} failed: #{stderr}"
          end
        end
      end
    end

    workers.each(&:join)
    puts "\n    Metadata fetching complete.\n"
  end

  def classify_branches
    now = Time.now
    min_age_cutoff = now - (options[:min_age_days] * 86_400)

    @branches_data.each do |name, data|
      next if data[:status] == :protected

      commit_time = data[:commit_date] ? Time.parse(data[:commit_date]) : nil
      is_bot = name =~ /^(owl-?bot|autosynth)/
      pr_state = data[:pr_state]

      # 1. Check Recency: If commit is newer than min_age_days, protect it
      if commit_time && commit_time > min_age_cutoff
        data[:status] = :protected
        data[:reason] = "Active work: commit within last #{options[:min_age_days]} days (#{commit_time.strftime('%Y-%m-%d')})"
        next
      end

      # 2. Check Inclusion regex if specified
      if options[:include] && name !~ Regexp.new(options[:include])
        data[:status] = :skipped
        data[:reason] = "Does not match include regex: #{options[:include]}"
        next
      end

      # 3. Categorize stale branch
      if is_bot
        data[:category] = :bot
        data[:status] = :stale
        data[:reason] = "Stale automated bot branch (#{pr_state == 'NO_PR' ? 'No PR' : "PR #{pr_state}"})"
      elsif pr_state == "MERGED"
        data[:category] = :merged
        data[:status] = :stale
        data[:reason] = "Merged PR ##{data[:pr_number]} (#{commit_time ? commit_time.strftime('%Y-%m-%d') : 'unknown date'})"
      elsif pr_state == "CLOSED"
        data[:category] = :closed
        data[:status] = :stale
        data[:reason] = "Closed/unmerged PR ##{data[:pr_number]} (#{commit_time ? commit_time.strftime('%Y-%m-%d') : 'unknown date'})"
      else
        data[:category] = :no_pr
        data[:status] = :stale
        data[:reason] = "Abandoned branch with no PR (#{commit_time ? commit_time.strftime('%Y-%m-%d') : 'unknown date'})"
      end
    end
  end

  def report_summary
    total = @branches_data.size
    protected_branches = @branches_data.values.select { |b| b[:status] == :protected }
    stale_branches = @branches_data.values.select { |b| b[:status] == :stale }

    by_category = Hash.new(0)
    stale_branches.each { |b| by_category[b[:category]] += 1 }

    # Filter by user target selection
    target_stale = stale_branches.select do |b|
      case options[:target]
      when "bot" then b[:category] == :bot
      when "merged" then b[:category] == :merged
      when "closed" then b[:category] == :closed
      when "no-pr" then b[:category] == :no_pr
      when "all" then true
      else true
      end
    end

    if options[:limit] && options[:limit] > 0
      target_stale = target_stale.first(options[:limit])
    end

    @selected_for_action = target_stale

    puts "======================================================="
    puts "                  EVALUATION SUMMARY                   "
    puts "======================================================="
    puts "Total remote branches evaluated: #{total}"
    puts "\e[32mProtected / Preserved branches:\e[0m  #{protected_branches.size}"
    puts "  - Base / Hardcoded:           #{protected_branches.count { |b| b[:reason]&.start_with?('Protected') }}"
    puts "  - Active Open PR Heads:       #{protected_branches.count { |b| b[:reason]&.start_with?('Active Open PR') }}"
    puts "  - Recent Commit (<#{options[:min_age_days]}d):       #{protected_branches.count { |b| b[:reason]&.start_with?('Active work') }}"
    puts ""
    puts "\e[33mStale Candidate Breakdown (all categories):\e[0m #{stale_branches.size}"
    puts "  - Bot branches (owl-bot/autosynth): #{by_category[:bot]}"
    puts "  - Merged PR branches:              #{by_category[:merged]}"
    puts "  - Closed PR branches:              #{by_category[:closed]}"
    puts "  - No PR branches:                  #{by_category[:no_pr]}"
    puts "-------------------------------------------------------"
    puts "\e[1mSelected for action (--target #{options[:target]}):\e[0m \e[36m#{@selected_for_action.size} branches\e[0m"
    if options[:limit]
      puts "  (Capped by --limit #{options[:limit]})"
    end
    puts "=======================================================\n"

    # Sample table of selected branches
    sample_size = [15, @selected_for_action.size].min
    if sample_size > 0
      puts "Sample Candidates Selected for #{options[:dry_run] ? 'Simulated Deletion' : 'Deletion'} (first #{sample_size} shown):"
      puts format("%-45s | %-8s | %-10s | %s", "BRANCH NAME", "CATEGORY", "LAST DATE", "DETAILS")
      puts "-" * 90
      @selected_for_action.first(sample_size).each do |b|
        date_str = b[:commit_date] ? b[:commit_date][0..9] : "unknown"
        cat_str = b[:category].to_s.upcase
        puts format("%-45s | %-8s | %-10s | %s", b[:name][0..44], cat_str, date_str, (b[:reason] || "")[0..40])
      end
      if @selected_for_action.size > sample_size
        puts "... and #{@selected_for_action.size - sample_size} more branches."
      end
      puts ""
    end

    # List protected open PR branches explicitly for safety audit
    open_pr_list = protected_branches.select { |b| b[:pr_state] == "OPEN" }
    puts "Explicitly Protected Active Open PR Branches (#{open_pr_list.size} total):"
    open_pr_list.each do |b|
      puts "  \e[32m✓\e[0m #{b[:name].ljust(45)} | PR ##{b[:pr_number]} | #{b[:pr_title]}"
    end
    puts ""
  end

  def execute_deletions
    if @selected_for_action.empty?
      puts "No branches match the selection criteria. Nothing to delete."
      return
    end

    count = @selected_for_action.size
    puts "\e[31m[DANGER]\e[0m Preparing to DELETE #{count} branches from #{options[:repo]} via #{options[:method]}..."

    if options[:method] == "git"
      execute_deletions_git
    else
      execute_deletions_api
    end
  end

  def execute_deletions_git
    branches_to_delete = @selected_for_action.map { |b| b[:name] }
    batches = branches_to_delete.each_slice(options[:batch_size]).to_a
    total_batches = batches.size

    puts "Executing deletion in #{total_batches} git push batches (batch size: #{options[:batch_size]})..."

    batches.each_with_index do |batch, idx|
      puts "  Deleting batch #{idx + 1}/#{total_batches} (#{batch.size} branches)..."
      cmd = ["git", "push", options[:remote], "--delete"] + batch
      stdout, stderr, status = Open3.capture3(*cmd)
      if status.success?
        puts "  \e[32m✓\e[0m Batch #{idx + 1} deleted successfully."
      else
        warn "  \e[31m✗\e[0m Batch #{idx + 1} push failed: #{stderr}"
        # Fallback to individual branch deletion for resilience
        puts "    Falling back to individual deletions for this batch..."
        batch.each do |b|
          single_cmd = ["git", "push", options[:remote], "--delete", b]
          _sout, serr, sstat = Open3.capture3(*single_cmd)
          if sstat.success?
            puts "    \e[32m✓\e[0m Deleted #{b}"
          else
            warn "    \e[31m✗\e[0m Failed to delete #{b}: #{serr.strip}"
          end
        end
      end
    end
    puts "\nDeletion complete."
  end

  def execute_deletions_api
    total = @selected_for_action.size
    @selected_for_action.each_with_index do |b, idx|
      name = b[:name]
      print "\rDeleting branch #{idx + 1}/#{total}: #{name}..."
      cmd = [
        "gh", "api",
        "-X", "DELETE",
        "repos/#{options[:repo]}/git/refs/heads/#{name}"
      ]
      _stdout, stderr, status = Open3.capture3(*cmd)
      if status.success?
        # success
      else
        warn "\nFailed to delete #{name} via API: #{stderr}"
      end
    end
    puts "\nAPI deletions complete."
  end

  def export_report
    path = options[:report]
    puts "--> Exporting audit report to #{path}..."
    report_data = {
      timestamp: Time.now.iso8601,
      repo: options[:repo],
      mode: options[:dry_run] ? "dry_run" : "execute",
      target_category: options[:target],
      total_evaluated: @branches_data.size,
      total_protected: @branches_data.values.count { |b| b[:status] == :protected },
      total_selected: @selected_for_action.size,
      branches: @branches_data.values
    }

    File.write(path, JSON.pretty_generate(report_data))
    puts "    Report written successfully.\n"
  end

  def fatal_error(msg)
    warn "\e[31m[ERROR]\e[0m #{msg}"
    exit 1
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{$PROGRAM_NAME} [options]"

    opts.on("-d", "--[no-]dry-run", "Simulate deletions without executing (default: true)") do |v|
      options[:dry_run] = v
    end

    opts.on("-e", "--execute", "Execute actual branch deletions (mutating action)") do
      options[:dry_run] = false
    end

    opts.on("-t", "--target CATEGORY", "Target category: bot, merged, closed, no-pr, all (default: all)") do |v|
      options[:target] = v.downcase
    end

    opts.on("-a", "--min-age-days DAYS", Integer, "Minimum branch age in days to be considered stale (default: 30)") do |v|
      options[:min_age_days] = v
    end

    opts.on("-l", "--limit COUNT", Integer, "Maximum number of branches to delete in this run") do |v|
      options[:limit] = v
    end

    opts.on("-b", "--batch-size SIZE", Integer, "Branches per git push batch (default: 50)") do |v|
      options[:batch_size] = v
    end

    opts.on("-m", "--method METHOD", "Deletion method: git or api (default: git)") do |v|
      options[:method] = v.downcase
    end

    opts.on("--exclude REGEX", "Regex pattern of branch names to protect") do |v|
      options[:exclude] = v
    end

    opts.on("--include REGEX", "Regex pattern of branch names to target") do |v|
      options[:include] = v
    end

    opts.on("-r", "--report FILE", "Path to export JSON audit report") do |v|
      options[:report] = v
    end

    opts.on("-v", "--verbose", "Enable verbose debug logging") do
      options[:verbose] = true
    end

    opts.on("-h", "--help", "Show this help banner") do
      puts opts
      exit 0
    end
  end

  parser.parse!
  StaleBranchCleaner.new(options).run
end
