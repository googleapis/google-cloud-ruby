# frozen_string_literal: true

# Copyright 2021 Google LLC
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

require "json"
require "set"

TASKS = ["test", "rubocop", "build", "yard", "linkinator", "acceptance", "samples-master", "samples-latest"]

desc "Run CI tasks."

flag :github_event_name, "--github-event-name=EVENT" do |f|
  f.default ""
  f.desc "Name of the github event triggering this job. Optional."
end
flag :github_event_payload, "--github-event-payload=PATH" do |f|
  f.default ""
  f.desc "Path to the github event payload JSON file. Optional."
end
flag :head_commit, "--head=COMMIT" do |f|
  f.desc "Ref or SHA of the head commit when analyzing changes. Defaults to the current commit."
end
flag :base_commit, "--base=COMMIT" do |f|
  f.desc "Ref or SHA of the base commit when analyzing changes. If omitted, uses uncommitted diffs."
end
flag :bundle_update do |f|
  f.desc "Update rather than install gem bundles. This can take longer."
end
flag :gems, "--gems=NAMES" do |f|
  f.accept Array
  f.desc "Test the given gems (comma-delimited) instead of analyzing changes."
end
flag :all_gems, "--all-gems[=FILES]" do |f|
  f.accept Array
  f.desc "Test all gems, or all that include at least one of the given files (comma-delimited)."
end
flag :project, "--project=NAME" do |f|
  f.accept String
  f.desc "The project to use for acceptance/sample tests."
end
flag :keyfile, "--keyfile=PATH" do |f|
  f.accept String
  f.desc "Path to the credentials to use for acceptance/sample tests."
end
flag :max_gem_count do |f|
  f.accept Integer
  f.default 0
  f.desc "The max number of gems to test. If more gems are detected, no tests are run."
end
flag :load_kokoro_context do |f|
  f.desc "Load Kokoro credentials and environment info"
end

flag_group desc: "Tasks" do
  TASKS.each do |task|
    task_underscore = task.tr "-", "_"
    flag "task_#{task_underscore}", "--[no-]#{task}", desc: "Run the #{task} task"
  end
end

include :exec
include :terminal, styled: true

def run
  if load_kokoro_context
    require "repo_context"
    RepoContext.load_kokoro_env
  end

  @auth_env = setup_auth_env
  @run_tasks = TASKS.find_all do |task|
    task_underscore = task.tr "-", "_"
    get "task_#{task_underscore}"
  end
  @errors = []
  @cur_dir = Dir.getwd
  Dir.chdir context_directory
  dirs = determine_dirs

  if max_gem_count > 0 && dirs.size > max_gem_count
    puts "CI skipped because the limit of #{max_gem_count} libraries was exceeded.", :bold, :yellow
    puts "Modified libraries found:"
    dirs.each { |dir| puts "  #{dir}" }
    exit
  end

  dirs.shuffle.each { |dir| run_in_dir dir }
  puts
  if @errors.empty?
    puts "CI passed", :bold, :green
  else
    puts "FAILURES:", :bold, :red
    @errors.each { |err| puts err, :yellow }
    exit 1
  end
end

def setup_auth_env
  final_project = project || ENV["GCLOUD_TEST_PROJECT"] || ENV["GOOGLE_CLOUD_PROJECT"]
  final_keyfile = keyfile || ENV["GCLOUD_TEST_KEYFILE"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]
  puts "Project for integration tests: #{final_project.inspect}"
  puts "Set keyfile for integration tests." if final_keyfile
  {
    "GCLOUD_TEST_PROJECT" => final_project,
    "GOOGLE_CLOUD_PROJECT" => final_project,
    "GCLOUD_TEST_KEYFILE" => final_keyfile,
    "GOOGLE_APPLICATION_CREDENTIALS" => final_keyfile
  }
end

def determine_dirs
  return gems if gems
  return all_gem_dirs(all_gems || true) if all_gems || github_event_name == "schedule"
  cur_gem_dir || gem_dirs_from_changes
end

def all_gem_dirs which_files
  dirs = Dir.glob("*/*.gemspec").map { |file| File.dirname file }
  if which_files == true
    puts "Running for all gems", :bold
  else
    puts "Running for all gems with the following files: #{which_files}", :bold
    dirs.delete_if do |dir|
      which_files.all? { |name| !File.exist? File.join(dir, name) }
    end
  end
  filter_gem_dirs dirs
end

def cur_gem_dir
  root_dir = context_directory
  if @cur_dir != root_dir && @cur_dir.start_with?(root_dir)
    dir = @cur_dir.sub "#{root_dir}/", ""
    dirs = find_changed_directories ["#{dir}/."]
    unless dirs.empty?
      puts "Running in current directory: #{dirs.first}", :bold
      return dirs
    end
  end
  nil
end

def gem_dirs_from_changes
  puts "Evaluating changes.", :bold
  base_ref, head_ref = interpret_github_event
  ensure_checkout head_ref unless head_ref.nil?
  files = find_changed_files base_ref
  if files.empty?
    puts "No files changed.", :bold
  else
    puts "Files changed:", :bold
    files.each { |file| puts "  #{file}" }
  end

  dirs = find_changed_directories files
  if dirs.empty?
    puts "No gem directories changed.", :bold
  else
    puts "Gem directories changed:", :bold
    dirs.each { |dir| puts "  #{dir}" }
  end
  dirs
end

def interpret_github_event
  payload = JSON.load File.read github_event_payload unless github_event_payload.empty?
  base_ref, head_ref =
    case github_event_name
    when "pull_request"
      puts "Getting commits from pull_request event"
      [payload["pull_request"]["base"]["ref"], nil]
    when "push"
      puts "Getting commits from push event"
      [payload["before"], nil]
    when "workflow_dispatch"
      puts "Getting inputs from workflow_dispatch event"
      [payload["inputs"]["base"], payload["inputs"]["head"]]
    else
      [base_commit, head_commit]
    end
  base_ref = nil if base_ref&.empty?
  head_ref = nil if head_ref&.empty?
  [base_ref, head_ref]
end

def ensure_checkout head_ref
  puts "Checking for head ref: #{head_ref}"
  head_sha = ensure_fetched head_ref
  current_sha = capture(["git", "rev-parse", "HEAD"], e: true).strip
  if head_sha == current_sha
    puts "Already at head SHA: #{head_sha}"
  else
    puts "Checking out head SHA: #{head_sha}"
    exec(["git", "checkout", head_sha], e: true)
  end
end

def find_changed_files base_ref
  if base_ref.nil?
    puts "No base ref. Using local diff."
    capture(["git", "status", "--porcelain"]).split("\n").map { |line| line.split.last }
  else
    puts "Diffing from base ref: #{base_ref}"
    base_sha = ensure_fetched base_ref
    capture(["git", "diff", "--name-only", base_sha], e: true).split("\n").map(&:strip)
  end
end

def ensure_fetched ref
  result = exec(["git", "show", "--no-patch", "--format=%H", ref], out: :capture, err: :capture)
  if result.success?
    result.captured_out.strip
  elsif ref == "HEAD^"
    # Common special case
    current_sha = capture(["git", "rev-parse", "HEAD"], e: true).strip
    exec(["git", "fetch", "--depth=2", "origin", current_sha], e: true)
    capture(["git", "rev-parse", "HEAD^"], e: true).strip
  else
    puts "Fetching ref: #{ref}"
    exec(["git", "fetch", "--depth=1", "origin", "#{ref}:refs/temp/#{ref}"], e: true)
    capture(["git", "show", "--no-patch", "--format=%H", "refs/temp/#{ref}"], e: true).strip
  end
end

def find_changed_directories files
  dirs = Set.new
  files.each do |file|
    if file =~ %r{^([^/]+)/.+$}
      dirs << Regexp.last_match[1]
    end
  end
  filter_gem_dirs dirs.to_a
end

def filter_gem_dirs dirs
  dirs.find_all do |dir|
    if ["Rakefile", "Gemfile", "#{dir}.gemspec"].all? { |file| File.file?(File.join(dir, file)) }
      if ::Toys::Compat.allow_fork?
        func = proc do
          Dir.chdir dir do
            spec = Gem::Specification.load "#{dir}.gemspec"
            puts spec.required_ruby_version.satisfied_by?(Gem::Version.new(RUBY_VERSION)).to_s
          end
        end
        capture_proc(func).strip == "true"
      else
        true
      end
    else
      false
    end
  end.sort
end

def run_in_dir dir
  Dir.chdir dir do
    bundle_task = bundle_update ? "update" : "install"
    puts
    puts "#{dir}: bundle ...", :bold
    result = exec ["bundle", bundle_task]
    unless result.success?
      @errors << "#{dir}: bundle"
      next
    end
    @run_tasks.each do |task|
      puts
      puts "#{dir}: #{task} ...", :bold
      success = if task == "linkinator"
        run_linkinator
      else
        exec(["bundle", "exec", "rake", task.tr("-", ":")], env: @auth_env).success?
      end
      @errors << "#{dir}: #{task}" unless success
    end
  end
end

def run_linkinator
  linkinator_cmd = ["npx", "linkinator", "./doc", "--skip", "\\w+\\.md$"]
  result = exec linkinator_cmd, out: :capture, err: [:child, :out]
  puts result.captured_out
  checked_links = result.captured_out.split "\n"
  checked_links.select! { |link| link =~ /^\[(\d+)\]/ && ::Regexp.last_match[1] != "200" }
  checked_links.each do |link|
    puts link, :yellow
  end
  checked_links.empty?
end
