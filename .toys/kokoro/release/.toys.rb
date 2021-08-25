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

optional_arg :package
flag :dry_run, default: ::ENV["RELEASE_DRY_RUN"] == "true"
flag :base_dir, "--base-dir=PATH"
flag :all, "--all=REGEX"
flag :enable_docs
flag :enable_rad
flag :enable_ghpages

include :exec, e: true
include :gems

def run
  gem "gems", "~> 1.2"
  Dir.chdir context_directory
  Dir.chdir base_dir if base_dir
  require "releaser"
  Releaser.load_env

  determine_packages.each do |name, version|
    releaser = Releaser.new gem_name: name,
                            last_version: version,
                            dry_run: dry_run,
                            logger: logger,
                            enable_docs: enable_docs,
                            enable_rad: enable_rad,
                            enable_ghpages: enable_ghpages
    releaser.run
  end
end

def determine_packages
  packages = {}
  if all
    current_versions = Releaser.lookup_current_versions all
    regex = Regexp.new all
    Dir.glob("*/*.gemspec") do |path|
      name = File.dirname path
      packages[name] = cuurent_versions[name] if regex.match? name
    end
  else
    packages[package] = nil
  end
  packages
end
