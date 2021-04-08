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

TASKS = ["test", "rubocop", "build", "yard", "linkinator"]

desc "Run CI tasks, not including integration tests."

flag :github_event_name, "--github-event-name PATH", default: ""
flag :github_event_payload, "--github-event-payload PATH", default: ""
flag :head_commit, "--head COMMIT"
flag :base_commit, "--base COMMIT"
flag :bundle_update, "--bundle-update", desc: "Update rather than install gem bundles"
flag :only, "--only", desc: "Run only the specified tasks (i.e. tasks are opt-in rather than opt-out)"

TASKS.each do |task|
  flag "task_#{task}", "--[no-]#{task}", desc: "Run the #{task} task"
end

include :exec
include :terminal, styled: true

def run
  @run_tasks = TASKS.find_all do |task|
    val = get "task_#{task}"
    val.nil? ? !only : val
  end
  @errors = []
  determine_dirs.each { |dir| run_in_dir dir }
  puts
  if @errors.empty?
    puts "CI passed", :bold, :green
  else
    puts "FAILURES:", :bold, :red
    @errors.each { |err| puts err, :yellow }
    exit 1
  end
end

def determine_dirs
  cur_dir = Dir.getwd
  base_dir = context_directory
  Dir.chdir base_dir

  if cur_dir != base_dir && cur_dir.start_with?(base_dir)
    cur_dir = cur_dir.sub "#{base_dir}/", ""
    dirs = find_changed_directories ["#{cur_dir}/."]
    unless dirs.empty?
      puts "Running in current directory: #{dirs.first}", :bold
      return dirs
    end
  end

  puts "Evaluating changes.", :bold
  base_sha, head_sha = interpret_github_event
  ensure_head head_sha unless head_sha.nil?
  files = find_changed_files base_sha
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
        exec(["bundle", "exec", "rake", task]).success?
      end
      @errors << "#{dir}: #{task}" unless success
    end
  end
end

def interpret_github_event
  payload = JSON.load File.read github_event_payload unless github_event_payload.empty?
  base_sha, head_sha =
    case github_event_name
    when "pull_request"
      puts "Getting commits from pull_request event"
      [payload["pull_request"]["base"]["sha"], nil]
    when "push"
      puts "Getting commits from push event"
      [payload["before"], nil]
    when "workflow_dispatch"
      puts "Getting inputs from workflow_dispatch event"
      [payload["inputs"]["base"], payload["inputs"]["head"]]
    else
      [base_commit, head_commit]
    end
  base_sha = nil if base_sha&.empty?
  head_sha = nil if head_sha&.empty?
  [base_sha, head_sha]
end

def ensure_head head_sha
  current_sha = capture(["git", "rev-parse", "HEAD"], e: true).strip
  if head_sha == current_sha
    puts "Already at head SHA: #{head_sha}"
  else
    puts "Checking out head SHA: #{head_sha}"
    head_sha = ensure_sha head_sha
    exec(["git", "checkout", head_sha], e: true)
  end
end

def find_changed_files base_sha
  if base_sha.nil?
    puts "No base SHA. Using local diff."
    capture(["git", "status", "--porcelain"]).split("\n").map { |line| line.split.last }
  else
    puts "Checking out base SHA: #{base_sha}"
    base_sha = ensure_sha base_sha
    capture(["git", "diff", "--name-only", base_sha], e: true).split("\n").map(&:strip)
  end
end

def ensure_sha sha
  result = exec(["git", "show", "--no-patch", "--format=%H", sha], out: :capture, err: :capture)
  if result.error?
    exec(["git", "fetch", "--depth=1", "origin", sha], e: true)
    capture(["git", "show", "--no-patch", "--format=%H", sha], e: true).strip
  else
    result.captured_out.strip
  end
end

def find_changed_directories files
  dirs = Set.new
  files.each do |file|
    if file =~ %r{^([^/]+)/.+$}
      dirs << Regexp.last_match[1]
    end
  end
  dirs.to_a.find_all do |dir|
    File.file?(File.join(dir, "Rakefile")) &&
      File.file?(File.join(dir, "Gemfile")) &&
      File.file?(File.join(dir, "#{dir}.gemspec"))
  end.sort
end

def run_linkinator
  result = exec ["npx", "linkinator", "./doc"], out: :capture, err: [:child, :out]
  puts result.captured_out
  checked_links = result.captured_out.split "\n"
  checked_links.select! { |link| link =~ /^\[(\d+)\]/ && ::Regexp.last_match[1] != "200" }
  checked_links.each do |link|
    puts link, :yellow
  end
  checked_links.empty?
end
