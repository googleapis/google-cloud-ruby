# frozen_string_literal: true

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Yoshi
  ##
  # Implementation of a batch review tool.
  #
  class BatchReviewer
    def self.well_known_presets
      @well_known_presets ||= begin
        releases_preset = Preset.new do |preset|
          preset.desc = "Selects all release pull requests, and expect diffs appropriate to a release pull request"
          preset.pull_request_filter.only_titles(/^chore\(main\): release [\w-]+ \d+\.\d+\.\d+/)
          preset.pull_request_filter.only_users(["release-please[bot]"])
          preset.diff_expectations.expect_changed_paths(/\.release-please-manifest\.json$/)
          preset.diff_expectations.expect_changed_paths(/\/CHANGELOG\.md$/)
          preset.diff_expectations.expect_changed_paths(/\/version\.rb$/)
        end
        {
          basic_releases: releases_preset
        }
      end
    end

    def initialize repo
      @repo = repo
      @presets = {}
    end

    def define_preset name, based_on: nil
      if based_on
        preset = @presets[based_on] || BatchReviewer.well_known_presets[based_on]
        raise "Unknown based_on #{based_on.inspect}" unless preset
        preset = preset.clone
      else
        preset = Preset.new
      end
      @presets[name.to_s] = preset
      yield preset if block_given?
    end

    def preset_names
      @presets.keys
    end

    def lookup_preset name
      @presets[name]
    end

    def config preset_name: nil,
               only_titles: nil,
               omit_titles: nil,
               only_users: nil,
               omit_users: nil,
               only_labels: nil,
               omit_labels: nil,
               only_ids: nil,
               omit_ids: nil,
               expect_paths: nil,
               expect_changed_paths: nil,
               expect_added_paths: nil,
               expect_deleted_paths: nil,
               expect_indented_paths: nil,
               expect_diffs: nil,
               message: nil,
               detail: nil,
               automerge: false,
               edit_message: false,
               edit_detail: false,
               assert_diffs_clean: false,
               merge_delay: 0,
               max_diff_size: nil,
               editor: nil,
               dry_run: false
      preset = @presets[preset_name] || Preset.new
      @pull_request_filter = preset.pull_request_filter
      @pull_request_filter.only_titles only_titles
      @pull_request_filter.omit_titles omit_titles
      @pull_request_filter.only_users only_users
      @pull_request_filter.omit_users omit_users
      @pull_request_filter.only_labels only_labels
      @pull_request_filter.omit_labels omit_labels
      @pull_request_filter.only_ids Array(only_ids).map{ |spec| parse_ids spec }
      @pull_request_filter.omit_ids Array(omit_ids).map{ |spec| parse_ids spec }
      @diff_expectations = preset.diff_expectations
      Array(expect_paths).each { |expr| @diff_expectations.expect_paths expr }
      Array(expect_changed_paths).each { |expr| @diff_expectations.expect_changed_paths expr }
      Array(expect_added_paths).each { |expr| @diff_expectations.expect_added_paths expr }
      Array(expect_deleted_paths).each { |expr| @diff_expectations.expect_deleted_paths expr }
      Array(expect_indented_paths).each { |expr| @diff_expectations.expect_indented_paths expr }
      Array(expect_diffs).each do |expr|
        params = parse_diff_expectations expr
        @diff_expectations.expect_diffs(**params)
      end
      message = message[1..].to_sym if message.to_s.start_with? ":"
      @message = message || preset.message
      detail = detail[1..].to_sym if detail.to_s.start_with? ":"
      @detail = detail || preset.detail
      @automerge = automerge
      @edit_message = edit_message
      @edit_detail = edit_detail
      @assert_diffs_clean = assert_diffs_clean
      @merge_delay = merge_delay
      @max_diff_size = max_diff_size
      @editor = editor || ENV["EDITOR"] || "/bin/nano"
      @dry_run = dry_run
      validate_config
    end

    def run context
      @context = context
      @last_message = ""
      @last_detail = ""
      @next_timestamp = Process.clock_gettime Process::CLOCK_MONOTONIC
      @merged_count = 0
      @skipped_count = 0
      check_runtime_environment
      @pull_requests = PullRequest.find context: @context,
                                        repo: @repo,
                                        pull_request_filter: @pull_request_filter,
                                        diff_expectations: @diff_expectations
      @context.logger.info "Found #{@pull_requests.size} pull requests"
      check_assert_diffs_clean if @assert_diffs_clean
      @pull_requests.each_with_index { |pr, index| handle_pr pr, index + 1 }
      @context.puts
      @context.puts "Totals: #{@merged_count} merged and #{@skipped_count} skipped out of #{@pull_requests.size}", :bold
    end

    private

    def parse_ids expr
      case expr
      when /^(\d+)$/
        num = Regexp.last_match[1].to_i
        num..num
      when /^(\d+)-(\d+)$/
        num1 = Regexp.last_match[1].to_i
        num2 = Regexp.last_match[2].to_i
        num1..num2
      when Range
        expr
      when Integer
        expr..expr
      else
        raise "Unknown IDs format: #{expr.inspect}"
      end
    end

    def parse_diff_expectations expr
      path_exprs = []
      additions = []
      removals = []
      desc = nil
      expr.split(/\t|\n/).each do |line|
        prefix = line[0]
        line = line[1..]
        case prefix
        when "$"
          path_exprs << Regexp.new(line)
        when "#"
          desc = line
        when "+"
          additions << Regexp.new(line)
        when "-"
          removals << Regexp.new(line)
        else
          raise "Unknown prefix code #{prefix.inspect} when parsing expect-diffs"
        end
      end
      {path_patterns: path_exprs, additions: additions, removals: removals, desc: desc}
    end

    def validate_config
      if (@edit_message || @edit_detail) && @automerge
        raise "Automerge must be off to support editing messages or details"
      end
      if @message == :shared && !@edit_message
        raise "Edit messages must be active to support shared messages"
      end
      if @detail == :shared && !@edit_detail
        raise "Edit detail must be active to support shared details"
      end
    end

    def check_runtime_environment
      unless @context.exec(["gh", "--version"]).success?
        raise "Could not find the GitHub CLI. See https://cli.github.com/manual/ for install instructions."
      end
      return if @automerge
      unless @context.exec(["ydiff", "--version"]).success?
        raise "Could not find the ydiff command. See https://github.com/ymattw/ydiff/ for install instructions."
      end
    end

    def check_assert_diffs_clean
      failure = false
      @pull_requests.each do |pr|
        next if pr.fully_expected?
        pr.diff_files.each do |file|
          next if file.matching_expectation
          @context.puts "PR##{pr.id}: File #{file.path} not expected.", :red, :bold
        end
        failure = true
      end
      @context.exit 1 if failure
    end

    def handle_pr pr, index
      if @automerge
        if pr.fully_expected?
          resolve_message_and_detail pr do |message, detail|
            do_merge pr, index, message, detail
          end
          @merged_count += 1
        else
          @context.puts "Skipping PR##{pr.id} #{pr.title.inspect} (#{index}/#{@pull_requests.size})", :bold, :yellow
          @skipped_count += 1
        end
      else
        display_pr pr, index
        confirm_pr pr, index do |message, detail|
          do_merge pr, index, message, detail
        end
      end
    end

    def resolve_message_and_detail pr
      message =
        case @message
        when :shared
          @last_message
        when :pr_title
          pr.title
        when :pr_title_number
          "#{pr.title} (##{pr.id})"
        when String
          @message.dup
        else
          ""
        end
      detail =
        case @detail
        when :shared
          @last_detail
        when String
          @detail.dup
        else
          ""
        end
      yield message, detail
    end

    def display_pr pr, index
      @context.puts
      @context.puts "PR##{pr.id} #{pr.title.inspect} (#{index}/#{@pull_requests.size})", :cyan, :bold
      diff_text = []
      pr.diff_files.each do |file|
        if file.matching_expectation
          @context.puts "Diff expected: #{file.path} (#{file.matching_expectation.desc})"
        else
          diff_text << file.text
        end
      end
      if diff_text.empty?
        @context.puts "All diffs expected for this pull request!", :green
      elsif pr.unexpected_diff_line_count > @max_diff_size
        @context.puts "Too many unexpected diffs to display (#{pr.unexpected_diff_line_count} lines)", :yellow
      else
        @context.puts "Unexpected diffs:", :yellow
        @context.puts "--------", :yellow, :bold
        run_ydiff diff_text
        @context.puts "--------", :yellow, :bold
      end
    end

    def run_ydiff diff_text
      require "toys/utils/pager"
      command = ["ydiff", "--width=0", "-s", "--wrap"]
      Toys::Utils::Pager.start(command: command) { |io| io.puts diff_text }
    end

    def confirm_pr pr, index
      resolve_message_and_detail pr do |message, detail|
        @context.puts "Message: #{message.inspect}" unless @edit_message
        @context.puts "Detail: #{detail.inspect}" unless @edit_detail
        if @context.confirm "Merge? ", default: true
          message = @context.ask("Message: ", default: message) if @edit_message
          detail = detail_editor detail if @edit_detail
          yield message, detail
          @merged_count += 1
        else
          @context.puts "Skipped: PR##{pr.id} #{pr.title.inspect} (#{index}/#{@pull_requests.size})", :bold, :yellow
          @skipped_count += 1
        end
      end
    end

    def detail_editor detail
      require "tempfile"
      file = Tempfile.new "commit-detail"
      begin
        file.write "#{detail.strip}\n\n# Edit the commit details here.\n# Lines beginning with a hash are stripped.\n"
        file.rewind
        @context.exec [@editor, file.path]
        detail = file.read.gsub(/^#[^\n]*\n?/, "").strip
      ensure
        file.close
        file.unlink
      end
      detail
    end

    def do_merge pr, index, message, detail
      message = pr.custom_message message
      @last_message = message
      @last_detail = detail
      if @dry_run
        @context.puts "Dry run: PR##{pr.id} #{pr.title.inspect} (#{index}/#{@pull_requests.size})", :bold, :green
        return
      end
      cur_time = Process.clock_gettime Process::CLOCK_MONOTONIC
      if cur_time < @next_timestamp
        @context.logger.info "Delaying #{@next_timestamp - cur_time}s before next merge..."
        sleep(@next_timestamp - cur_time)
      end
      @context.logger.info "Approving PR #{pr.id}..."
      retry_gh ["repos/#{@repo}/pulls/#{pr.id}/reviews",
                "--field", "event=APPROVE",
                "--field", "body=Approved using batch-review"],
               name: "gh pull request approval"
      @context.logger.info "Merging PR #{pr.id}..."
      retry_gh ["-XPUT", "repos/#{@repo}/pulls/#{pr.id}/merge",
                "--field", "merge_method=squash",
                "--field", "commit_title=#{message}",
                "--field", "commit_message=#{detail}"],
               name: "gh pull request merge"
      @context.puts "Merged PR##{pr.id} #{pr.title.inspect} (#{index}/#{@pull_requests.size})", :bold, :green
      @next_timestamp = Process.clock_gettime(Process::CLOCK_MONOTONIC) + @merge_delay
    end

    def retry_gh args, tries: 3, name: nil
      cmd = ["gh", "api"] + args
      name ||= cmd.inspect
      result = nil
      tries.times do |num|
        result = @context.exec cmd, out: :capture, err: :capture
        return if result.success?
        break unless result.error?
        @context.logger.info "waiting to retry..."
        sleep 2 * (num + 1)
      end
      @context.puts "Repeatedly failed to call #{name}", :red, :bold
      @context.puts result&.captured_out
      @context.puts result&.captured_err
      @context.exit 1
    end

    class Preset
      def initialize
        @pull_request_filter = PullRequestFilter.new
        @diff_expectations = DiffExpectations.new
        @message = :pr_title_number
        @detail = :none
        @desc = "(no description provided)"
        yield self if block_given?
      end

      def clone
        copy = Preset.new
        copy.pull_request_filter = @pull_request_filter.clone
        copy.diff_expectations = @diff_expectations.clone
        copy.message = @message.dup
        copy.detail = @detail.dup
        copy.desc = @desc.dup
        copy
      end

      attr_accessor :pull_request_filter
      attr_accessor :diff_expectations
      attr_accessor :message
      attr_accessor :detail
      attr_accessor :desc
    end

    class PullRequestFilter
      def initialize
        clear_only_titles!
        clear_omit_titles!
        clear_only_users!
        clear_omit_users!
        clear_only_labels!
        clear_omit_labels!
        clear_only_ids!
        clear_omit_ids!
        omit_labels "do not merge"
        yield self if block_given?
      end

      def only_titles titles
        @only_titles += Array(titles)
        self
      end

      def omit_titles titles
        @omit_titles += Array(titles)
        self
      end

      def only_users users
        @only_users += Array(users)
        self
      end

      def omit_users users
        @omit_users += Array(users)
        self
      end

      def only_labels labels
        @only_labels += Array(labels)
        self
      end

      def omit_labels labels
        @omit_labels += Array(labels)
        self
      end

      def only_ids ids
        @only_ids += Array(ids)
        self
      end

      def omit_ids ids
        @omit_ids += Array(ids)
        self
      end

      def clear_only_titles!
        @only_titles = []
        self
      end

      def clear_omit_titles!
        @omit_titles = []
        self
      end

      def clear_only_users!
        @only_users = []
        self
      end

      def clear_omit_users!
        @omit_users = []
        self
      end

      def clear_only_labels!
        @only_labels = []
        self
      end

      def clear_omit_labels!
        @omit_labels = []
        self
      end

      def clear_only_ids!
        @only_ids = []
        self
      end

      def clear_omit_ids!
        @omit_ids = []
        self
      end

      def clone
        copy = PullRequestFilter.new
        copy.clear_omit_labels!
        copy.only_titles @only_titles
        copy.omit_titles @omit_titles
        copy.only_users @only_users
        copy.omit_users @omit_users
        copy.only_labels @only_labels
        copy.omit_labels @omit_labels
        copy.only_ids @only_ids
        copy.omit_ids @omit_ids
        copy
      end

      def match? pr_resource
        number = pr_resource["number"].to_i
        return false if !@only_ids.empty? && !@only_ids.any? { |range| range === number }
        return false if !@omit_ids.empty? && @omit_ids.any? { |range| range === number }
        title = pr_resource["title"]
        return false if !@only_titles.empty? && !@only_titles.any? { |pattern| pattern === title }
        return false if !@omit_titles.empty? && @omit_titles.any? { |pattern| pattern === title }
        user = pr_resource["user"]["login"]
        return false if !@only_users.empty? && !@only_users.any? { |pattern| pattern === user }
        return false if !@omit_users.empty? && @omit_users.any? { |pattern| pattern === user }
        labels = Array(pr_resource["labels"]).map { |label| label["name"] }
        return false if !@only_labels.empty? && !@only_labels.intersect?(labels)
        return false if !@omit_labels.empty? && @omit_labels.intersect?(labels)
        true
      end
    end

    class DiffExpectations
      def initialize
        @expected = []
        yield self if block_given?
      end

      def expect_paths path_pattern, desc: nil
        desc ||= "Any file path matching: #{path_pattern}"
        @expected << Expectation.new(desc) { |file| path_pattern === file.path }
        self
      end

      def expect_changed_paths path_pattern, desc: nil
        desc ||= "Any changed file path matching: #{path_pattern}"
        @expected << Expectation.new(desc) { |file| file.type == "C" && path_pattern === file.path }
        self
      end

      def expect_added_paths path_pattern, desc: nil
        desc ||= "Any added file path matching: #{path_pattern}"
        @expected << Expectation.new(desc) { |file| file.type == "A" && path_pattern === file.path }
        self
      end

      def expect_deleted_paths path_pattern, desc: nil
        desc ||= "Any deleted file path matching: #{path_pattern}"
        @expected << Expectation.new(desc) { |file| file.type == "D" && path_pattern === file.path }
        self
      end

      def expect_indented_paths path_pattern, desc: nil
        desc ||= "Any file with only indentation changes and path matching: #{path_pattern}"
        @expected << Expectation.new(desc) { |file| file.only_indentation && path_pattern === file.path }
        self
      end

      def expect_diffs path_patterns: nil, additions: nil, removals: nil, desc: nil
        additions = Array additions
        removals = Array removals
        path_patterns = Array(path_patterns)
        desc ||= "Any file with certain specific changes"
        @expected << Expectation.new(desc) do |file|
          (path_patterns.empty? || path_patterns.any? { |pattern| pattern === file.path }) &&
            file.reduce_hunks(true) do |val, hunk|
              next false unless val
              hunk.all? do |line|
                line_without_mark = line[1..]
                if line.start_with? "+"
                  additions.any? { |regex| regex.match? line_without_mark }
                elsif line.start_with? "-"
                  removals.any? { |regex| regex.match? line_without_mark }
                else
                  true
                end
              end
            end
        end
        self
      end

      def expect_generic expectation
        @expected << expectation
        self
      end

      def clone
        DiffExpectations.new do |copy|
          @expected.each do |expectation|
            copy.expect_generic expectation
          end
        end
      end

      def matching_expectation diff_file
        @expected.each do |expectation|
          return expectation if expectation.match? diff_file
        end
        nil
      end

      class Expectation
        def initialize desc, &block
          raise "Block required" unless block
          @desc = desc
          @block = block
        end
  
        attr_reader :desc
  
        def match? pr_file
          @block.call pr_file
        end
      end
    end

    class PullRequest
      def self.find context:,
                    repo:,
                    pull_request_filter:,
                    diff_expectations:
        require "json"
        results = []
        page = 1
        loop do
          path = "repos/#{repo}/pulls?per_page=80&page=#{page}"
          results_page = JSON.parse context.capture(["gh", "api", path], e: true)
          break if results_page.empty?
          results_page.each do |pr_resource|
            next unless pull_request_filter.match? pr_resource
            results << PullRequest.new(context, repo, pr_resource, diff_expectations)
          end
          page += 1
        end
        results
      end

      def initialize context, repo, pr_resource, diff_expectations
        @context = context
        @repo = repo
        @id = pr_resource["number"]
        @title = pr_resource["title"]
        @diff_expectations = diff_expectations
      end

      attr_reader :id
      attr_reader :title

      def raw_diff_data
        @raw_diff_data ||= begin
          cmd = ["curl", "-s", "https://patch-diff.githubusercontent.com/raw/#{@repo}/pull/#{id}.diff"]
          @context.capture cmd, e: true
        end
      end

      def diff_files
        @diff_files ||= begin
          "\n#{raw_diff_data.chomp}"
            .split("\ndiff --git ")
            .slice(1..-1)
            .map { |text| DiffFile.new "diff --git #{text}\n", @diff_expectations }
        end
      end

      def fully_expected?
        diff_files.all? { |file| file.matching_expectation }
      end

      def unexpected_diff_line_count
        @unexpected_diff_line_count ||=
          diff_files.reduce 0 do |count, file|
            if file.matching_expectation
              count
            else
              count + file.hunk_lines_count
            end
          end
      end

      def lib_name
        unless defined? @lib_name
          @lib_name =
            case title
            when /^\[CHANGE ME\] Re-generated google-cloud-(?<basename>[\w-]+) to pick up changes in the API or client/
              Regexp.last_match[:basename]
            when /^\[CHANGE ME\] Re-generated (?<fullname>[\w-]+) to pick up changes in the API or client/
              Regexp.last_match[:fullname]
            else
              interpret_lib_name
            end
        end
        @lib_name
      end

      def custom_message message
        if lib_name && message =~ /^(\w+):\s+(\S.*)$/
          "#{Regexp.last_match[1]}(#{lib_name}): #{Regexp.last_match[2]}"
        else
          message
        end
      end

      private

      def interpret_lib_name
        name = nil
        diff_files.each do |diff_file|
          return nil unless %r{^([^/]+)/} =~ diff_file.path
          possible_name = Regexp.last_match[1]
          if name.nil?
            name = possible_name
          elsif name != possible_name
            return nil
          end
        end
        name
      end
    end

    class DiffFile
      def initialize text, diff_expectations
        @text = text
        @lines = text.split "\n"
        @path =
          if @lines.first =~ %r{^diff --git a/(\S+) b/\S+$}
            Regexp.last_match[1]
          else
            ""
          end
        @type =
          case @lines[1].to_s
          when /^new file/
            "N"
          when /^deleted file/
            "D"
          else
            "C"
          end
        initial_analysis
        @matching_expectation = diff_expectations.matching_expectation self
      end

      attr_reader :text
      attr_reader :path
      attr_reader :type
      attr_reader :only_indentation
      attr_reader :added_lines_count
      attr_reader :deleted_lines_count
      attr_reader :hunk_lines_count
      attr_reader :matching_expectation

      def reduce_hunks value
        analyze_changes do |hunk|
          value = yield value, hunk
        end
        value
      end

      private

      def initial_analysis
        @only_indentation = true
        @common_directory = nil
        @added_lines_count = 0
        @deleted_lines_count = 0
        @hunk_lines_count = 0
        analyze_changes do |hunk|
          analyze_only_indentation hunk
          analyze_counts hunk
        end
      end

      def analyze_changes
        hunk = nil
        @lines.each do |line|
          if line.start_with? "@@"
            yield hunk if hunk && !hunk.empty?
            hunk = []
          elsif hunk
            hunk << line
          end
        end
        yield hunk if hunk && !hunk.empty?
      end

      def analyze_only_indentation hunk
        return unless @only_indentation
        minuses = [""]
        pos = 1
        @only_indentation = false
        catch :fail do
          hunk.each do |line|
            if line.start_with? "-"
              if pos == minuses.length
                minuses = [line]
                pos = 0
              elsif pos.zero?
                minuses << line
              else
                throw :fail
              end
            elsif line.start_with? "+"
              throw :fail unless pos < minuses.length && minuses[pos].sub(/^-\s*/, "") == line.sub(/^\+\s*/, "")
              pos += 1
            elsif line.start_with? " "
              throw :fail unless pos == minuses.length
            else
              throw :fail
            end
          end
          @only_indentation = true
        end
      end

      def analyze_counts hunk
        hunk.each do |line|
          @hunk_lines_count += 1
          if line.start_with? "-"
            @deleted_lines_count += 1
          elsif line.start_with? "+"
            @added_lines_count += 1
          end
        end
      end
    end

    class Template
      include Toys::Template

      def initialize batch_reviewer
        @batch_reviewer = batch_reviewer
      end

      attr_reader :batch_reviewer

      on_expand do |template|
        desc "Mass code review tool"

        long_desc \
          "batch-reviewer is a mass code review tool. It can be used to " \
            "analyze, approve, and merge large numbers of pull requests " \
            "with similar properties or diffs.",
          "",
          "In a nutshell, batch-reviewer:",
          "* Selects a set of pull requests based on criteria that can " \
            "include title, user, and labels",
          "* Analyzes the diffs in the selected pull requests and compares " \
            "then to a set of configurable expected diffs",
          "* Either autoapproves and automerges pull requests whose diffs " \
            "conform to expectations, or interactively displays unexpected " \
            "diffs and prompts whether to merge or skip",
          "",
          "In many cases, you can use a preset configuration by passing its " \
            "name as an argument. Presets generally set a particular filter " \
            "on the selected pull requests and a particular set of expected " \
            "diffs for those pulls. See the description of PRESET_NAME for a " \
            "list of supported preset names. Otherwise you can configure the " \
            "pull request selectors and diff expectations explicitly by " \
            "passing flags.",
          "",
          "To automerge pull requests with expected diffs, pass --automerge. " \
            "This mode will skip any pull requests with unexpected diffs. " \
            "It is also recommended to set --merge-delay=15 or greater to " \
            "avoid GitHub quotas on the rate of pull request merges. " \
            "If --automerge is not passed, merges are done interactively; " \
            "any unexpected diffs are displayed, and the tool prompts for " \
            "confirmation on each merge."

        optional_arg :preset_name, accept: template.batch_reviewer.preset_names do |arg|
          arg.desc "The name of an optional preset configuration"
          value_descs = template.batch_reviewer.preset_names.map do |name|
            "* #{name}: #{template.batch_reviewer.lookup_preset(name).desc}"
          end
          arg.long_desc \
            "The name of an optional preset configuration. Supported values are:",
            "", *value_descs
        end

        flag_group desc: "Pull request selectors" do
          flag :only_title_re, accept: Regexp, handler: :push, default: [],
               desc: "a regex that matches pull request titles to select"
          flag :only_title, accept: String, handler: :push, default: [],
               desc: "an exact pull request title to select"
          flag :omit_title_re, accept: Regexp, handler: :push, default: [],
               desc: "a regex that matches pull request titles to omit"
          flag :omit_title, accept: String, handler: :push, default: [],
               desc: "an exact pull request title to omit"
          flag :only_user, accept: String, handler: :push, default: [],
               desc: "pull request opener username to select"
          flag :omit_user, accept: String, handler: :push, default: [],
               desc: "pull request opener username to omit"
          flag :only_label, accept: String, handler: :push, default: [],
               desc: "pull request label to select"
          flag :omit_label, accept: String, handler: :push, default: [],
               desc: "pull request label to omit"
          flag :only_ids, accept: String, handler: :push, default: [],
               desc: "pull request ID or range of IDs to select"
          flag :omit_ids, accept: String, handler: :push, default: [],
               desc: "pull request ID or range of IDs to omit"
        end

        flag_group desc: "Diff expectations" do
          flag :expect_path, accept: Regexp, handler: :push, default: [],
               desc: "expect diffs in files matching the given path regex"
          flag :expect_changed_path, accept: Regexp, handler: :push, default: [],
               desc: "expect changes in files matching the given path regex"
          flag :expect_added_path, accept: Regexp, handler: :push, default: [],
               desc: "expect added files matching the given path regex"
          flag :expect_deleted_path, accept: Regexp, handler: :push, default: [],
               desc: "expect deleted files matching the given path regex"
          flag :expect_indented_path, accept: Regexp, handler: :push, default: [],
               desc: "expect indentation changes in files matching the given path regex"
          flag :expect_diffs, accept: String, handler: :push, default: [],
               desc: "expect diffs by content"
        end

        flag_group desc: "Commit messages" do
          flag :message, accept: String,
               desc: "custom commit message, or :pr_title, :pr_title_number, or :shared"
          flag :detail, accept: String,
               desc: "custom commit message detail, or :none or :shared"
          flag :edit_message,
               desc: "edit the commit message"
          flag :edit_detail,
               desc: "edit the commit message detail"
          flag :editor, accept: String,
               desc: "path to the editor program to use for editing commit message details"
        end

        flag :automerge,
             desc: "automatically merge pull requests whose diffs satisfy expectations"
        flag :assert_diffs_clean,
             desc: "assert that all selected pull request diffs satisfy expectations"
        flag :merge_delay, accept: Integer, default: 0,
             desc: "delay in seconds between subsequent merges"
        flag :max_diff_size, accept: Integer, default: 500,
             desc: "maximum size in lines for displaying unexpected diffs"
        flag :dry_run,
             desc: "execute in dry run mode, which does not approve or merge pull requests"

        static :batch_reviewer, template.batch_reviewer

        include :exec
        include :terminal

        def run
          batch_reviewer.config preset_name: preset_name,
                                only_titles: only_title_re + only_title,
                                omit_titles: omit_title_re + omit_title,
                                only_users: only_user,
                                omit_users: omit_user,
                                only_labels: only_label,
                                omit_labels: omit_label,
                                only_ids: only_ids,
                                omit_ids: omit_ids,
                                expect_paths: expect_path,
                                expect_changed_paths: expect_changed_path,
                                expect_added_paths: expect_added_path,
                                expect_deleted_paths: expect_deleted_path,
                                expect_indented_paths: expect_indented_path,
                                expect_diffs: expect_diffs,
                                message: message,
                                detail: detail,
                                automerge: automerge,
                                edit_message: edit_message,
                                edit_detail: edit_detail,
                                assert_diffs_clean: assert_diffs_clean,
                                merge_delay: merge_delay,
                                max_diff_size: max_diff_size,
                                editor: editor,
                                dry_run: dry_run
          batch_reviewer.run self
        end
      end
    end
  end
end
