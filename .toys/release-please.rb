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
remaining_args :gems, desc: "Release the specified gems. If no specific gem is provided, all gems are checked."

include :exec, e: true
include :terminal, styled: true

def run
  Dir.chdir context_directory
  if install
    exec ["npm", "install", "release-please"]
    exit
  end
  if gems.empty?
    set :gems, Dir.glob("*/*.gemspec").map { |path| File.dirname path }
  end
  gems.each { |gem_name| release_please gem_name }
end

def release_please gem_name
  version = gem_version gem_name
  puts "Running release-please for #{gem_name} from version #{version.inspect}", :bold
  cmd = [
    "npx", "release-please", "release-pr",
    "--package-name", gem_name,
    "--release-type", "ruby-yoshi",
    "--repo-url", "googleapis/google-cloud-ruby",
    "--bump-minor-pre-major", "--debug"
  ]
  cmd += ["--fork"] if use_fork
  cmd += ["--last-package-version", version] if version && version >= "0.1"
  cmd += ["--token", github_token] if github_token
  log_cmd = cmd.inspect
  log_cmd.sub! github_token, "****" if github_token
  result = exec cmd, log_cmd: log_cmd, e: false
  if result.success?
    sleep 1
  else
    puts "Error running release-please for #{gem_name} from version #{version.inspect}", :bold, :red
    sleep 2
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
