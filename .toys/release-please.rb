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

desc "Runs release-please."

flag :github_token, "--github-token=TOKEN", default: ENV["GITHUB_TOKEN"]
flag :install
flag :use_fork, "--fork"
flag :delay, "--delay=SECS", default: "2"
flag :retries, "--retry=TIMES", default: ""
flag :retry_delay, "--retry-delay=SECS", default: "4"
flag :github_event_name, "--github-event-name=NAME"
remaining_args :gems, desc: "Release the specified gems. If no specific gem is provided, all gems are checked."

include :exec, e: true
include :terminal, styled: true

def run
  check_github_context
  Dir.chdir context_directory
  if install
    exec ["npm", "install", "release-please"]
    exit
  end
  if gems.empty?
    set :gems, Dir.glob("*/*.gemspec").map { |path| File.dirname path }.shuffle
  end
  if retries.empty?
    set :retries, 1
  end
  @errors = []
  gems.each do |gem_name|
    release_please gem_name,
                   cur_delay: delay.to_f,
                   cur_retries: retries.to_i,
                   cur_retry_delay: retry_delay.to_f
  end
  unless @errors.empty?
    puts "**** FINAL ERRORS: ****"
    @errors.each { |msg| puts msg, :bold, :red }
    exit 1
  end
end

def check_github_context
  return if github_event_name == "workflow_dispatch"
  return if ENV["DISABLE_RELEASE_PLEASE"].to_s.empty?
  puts "Scheduled release-please jobs have been disabled", :bold
  exit 0
end

def release_please orig_gem_name, cur_delay:, cur_retries:, cur_retry_delay:
  gem_name, release_as = orig_gem_name.split ":"
  version = gem_version gem_name
  job_name = "release-please for #{gem_name} from version #{version}"
  job_name = "#{job_name} as version #{release_as}" if release_as
  puts "Running #{job_name}", :bold
  cmd = [
    "npx", "release-please", "release-pr",
    "--package-name", gem_name,
    "--release-type", "ruby-yoshi",
    "--repo-url", "googleapis/google-cloud-ruby",
    "--bump-minor-pre-major", "--debug"
  ]
  cmd += ["--fork"] if use_fork
  cmd += ["--last-package-version", version] if version && version >= "0.1"
  cmd += ["--release-as", release_as] if release_as
  cmd += ["--token", github_token] if github_token
  log_cmd = cmd.inspect
  log_cmd.sub! github_token, "****" if github_token
  result = exec cmd, log_cmd: log_cmd, e: false
  if result.success?
    sleep cur_delay
  else
    msg = "Error running #{job_name}"
    puts msg, :bold, :red
    if cur_retries <= 0
      @errors << msg
      sleep cur_delay
    else
      sleep cur_retry_delay
      puts "Retrying..."
      release_please orig_gem_name,
                     cur_delay: cur_delay,
                     cur_retries: cur_retries - 1,
                     cur_retry_delay: cur_retry_delay * 2
    end
  end
end

def gem_version gem_name
  func = proc do
    Dir.chdir gem_name do
      spec = Gem::Specification.load "#{gem_name}.gemspec"
      puts spec.version.to_s
    end
  end
  version = capture_proc(func).strip
  version == "0.0.1alpha" ? nil : version
end
