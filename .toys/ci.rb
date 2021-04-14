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
flag :gems, accept: Array
flag :all_gems

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
  @cur_dir = Dir.getwd
  Dir.chdir context_directory
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
  return gems if gems
  return all_gem_dirs if all_gems
  cur_gem_dir || gem_dirs_from_changes
end

def all_gem_dirs
  puts "Running for all gems", :bold
  dirs = Dir.glob("*/*.gemspec").map { |file| File.dirname file }
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
end

def interpret_github_event
  payload = JSON.load File.read github_event_payload unless github_event_payload.empty?
  base_ref, head_ref =
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
        exec(["bundle", "exec", "rake", task]).success?
      end
      @errors << "#{dir}: #{task}" unless success
    end
  end
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
