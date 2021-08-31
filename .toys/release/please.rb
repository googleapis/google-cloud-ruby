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

flag :install
flag :use_fork, "--fork"
flag :base_dir, "--base-dir=PATH"
flag :release_type, "--release-type=TYPE", default: "ruby"
flag :version_file, "--version-file=PATH"
flag :repo_url, "--repo-url=NAME"
flag :retries, "--retries=TIMES", default: 1, accept: Integer
flag :delay, "--delay=SECS", default: 2, accept: Numeric
flag :retry_delay, "--retry-delay=SECS", default: 4, accept: Numeric
flag :github_event_name, "--github-event-name=NAME"
flag :github_token, "--github-token=TOKEN", default: ENV["GITHUB_TOKEN"]

remaining_args :input_gems, desc: "Release the specified gems. If no specific gem is provided, all gems are checked."

include :exec, e: true
include :terminal, styled: true

def run
  check_github_context
  Dir.chdir context_directory
  handle_install
  set :repo_url, default_repo_url unless repo_url
  gem_info = input_gems.empty? ? find_all_gems : interpret_input_gems

  @errors = []
  gem_info.each do |name, version, dir|
    release_please name, version, dir
  end

  unless @errors.empty?
    logger.error "**** FINAL ERRORS: ****"
    @errors.each { |msg| logger.error msg }
    exit 1
  end
end

def check_github_context
  return if github_event_name == "workflow_dispatch"
  return if ENV["RELEASE_PLEASE_DISABLE"].to_s.empty?
  logger.warn "Scheduled release-please jobs have been disabled"
  exit 0
end

def handle_install
  return unless install
  exec ["npm", "install", "release-please"]
  exit 0
end

def find_all_gems
  prefix = base_dir ? "#{base_dir}/" : ""
  (Dir.glob("#{prefix}*.gemspec") + Dir.glob("#{prefix}*/*.gemspec")).map do |path|
    [File.basename(path, ".gemspec"), nil, File.dirname(path)]
  end
end

def interpret_input_gems
  prefix = base_dir ? "#{base_dir}/" : ""
  input_gems.map do |input_gem|
    name, version = input_gem.split ":"
    paths = Dir.glob("#{prefix}#{name}.gemspec") + Dir.glob("#{prefix}*/#{name}.gemspec")
    if paths.empty?
      logger.error "Unable to find gem #{name} in the repo"
      exit 1
    elsif paths.size > 1
      logger.error "Found multiple gemspecs for gem #{name} in the repo"
      exit 1
    end
    [name, version, File.dirname(paths.first)]
  end
end

def release_please gem_name, release_as, dir
  cur_version = gem_version gem_name, dir
  job_name = "release-please for #{gem_name} from version #{cur_version}"
  job_name = "#{job_name} as version #{release_as}" if release_as
  logger.info "Running #{job_name}"

  cmd = build_command dir, gem_name, cur_version, release_as
  log_cmd = cmd.inspect
  log_cmd.sub! github_token, "****" if github_token

  cur_retry_delay = retry_delay
  cur_retries = retries
  error_msg = nil
  loop do
    result = exec cmd, log_cmd: log_cmd, e: false
    break if result.success?
    error_msg = "Error running #{job_name}"
    logger.error error_msg
    break if cur_retries <= 0
    sleep cur_retry_delay
    logger.warn "Retrying..."
    cur_retries -= 1
    cur_retry_delay *= 2
  end
  @errors << error_msg if error_msg
  sleep delay
end

def gem_version gem_name, dir
  func = proc do
    Dir.chdir dir do
      spec = Gem::Specification.load "#{gem_name}.gemspec"
      puts spec.version.to_s
    end
  end
  version = capture_proc(func).strip
  version == "0.0.1alpha" ? nil : version
end

def build_command dir, gem_name, cur_version, release_as
  cmd = [
    "npx", "release-please", "release-pr",
    "--package-name", gem_name,
    "--path", dir,
    "--release-type", release_type,
    "--repo-url", repo_url,
    "--bump-minor-pre-major",
    "--monorepo-tags",
    "--debug"
  ]
  cmd += ["--fork"] if use_fork
  cmd += ["--last-package-version", cur_version] if cur_version && cur_version >= "0.1"
  cmd += ["--release-as", release_as] if release_as
  cmd += ["--token", github_token] if github_token
  version_path = version_file || default_version_path(dir, gem_name)
  cmd += ["--version-file", version_path] if version_path
  cmd
end

def default_repo_url
  url = capture(["git", "remote", "get-url", "origin"]).strip
  if url =~ %r{github\.com[:/]([\w-]+/[\w-]+)(?:\.git|/)?$}
    return Regexp.last_match[1]
  else
    logger.error "Unable to determine current github repo"
    exit 1
  end
end

def default_version_path dir, gem_name
  gem_path = gem_name.gsub "-", "/"
  File.join "lib", gem_path, "version.rb"
end
