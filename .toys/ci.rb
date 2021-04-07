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

flag :github_event_name, "--github-event-name PATH"
flag :github_event_payload, "--github-event-payload PATH"
flag :from_commit, "--from COMMIT"
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

  base_sha = find_base_sha
  if base_sha.nil?
    puts "No base SHA. Using local diff.", :bold
  else
    puts "Base SHA: #{base_sha}", :bold
  end

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

def find_base_sha
  case github_event_name
  when "pull_request"
    payload = JSON.load File.read github_event_payload
    payload["pull_request"]["base"]["sha"]
  when "push"
    payload = JSON.load File.read github_event_payload
    payload["before"]
  else
    from_commit
  end
end

def find_changed_files base_sha
  if base_sha.nil?
    capture(["git", "status", "--porcelain"]).split("\n").map { |line| line.split.last }
  else
    result = exec(["git", "show", "--no-patch", "--format=%H", base_sha], out: :capture, err: :capture)
    if result.error?
      exec(["git", "fetch", "--depth=1", "origin", base_sha], e: true)
      base_sha = capture(["git", "show", "--no-patch", "--format=%H", base_sha], e: true).strip
    else
      base_sha = result.captured_out
    end
    capture(["git", "diff", "--name-only", base_sha], e: true).split("\n").map(&:strip)
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
