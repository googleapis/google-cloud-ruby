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

if ENV["RUBY_COMMON_TOOLS"]
  common_tools_dir = File.expand_path ENV["RUBY_COMMON_TOOLS"]
  load File.join(common_tools_dir, "toys", "release")
else
  load_git remote: "https://github.com/googleapis/ruby-common-tools.git",
           path: "toys/release",
           update: true
end

tool "bootstrap" do
  desc "Add packages to the release-please manifest"

  static :config_name, "release-please-config.json"
  static :manifest_name, ".release-please-manifest.json"

  remaining_args :packages

  flag :all do
    desc "Add all packages to the manifest"
  end
  flag :branch_name, "--branch NAME" do
    desc "The name of the branch to use if opening a pull request. Defaults to gen/GEM-NAME."
  end
  flag :git_remote, "--remote NAME" do
    desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
  end

  include :exec, e: true
  include :terminal
  include "yoshi-pr-generator"

  def run
    require "json"
    Dir.chdir context_directory

    find_all_packages if all
    if packages.empty?
      puts "No packages found", :yellow
      exit 1
    end
    puts "Adding #{packages.size} packages..."

    date = Time.now.utc.strftime("%Y%m%d-%H%M%S")
    set :branch_name, "gen/bootstrap-release-#{date}" unless branch_name
    commit_message = "chore: Bootstrap release manifest for new packages"
    yoshi_utils.git_ensure_identity
    yoshi_pr_generator.capture enabled: !git_remote.nil?,
                               remote: git_remote,
                               branch_name: branch_name,
                               commit_message: commit_message do
      update_manifest_files
    end
  end

  def update_manifest_files
    config = JSON.parse File.read config_name
    manifest = JSON.parse File.read manifest_name

    already_present_count = added_count = 0
    package_info = get_package_info
    config_packages = config["packages"]
    packages.each do |package|
      if manifest[package] && config_packages[package]
        puts "Package #{package} is already in the manifest", :yellow
        already_present_count += 1
      else
        puts "Adding package #{package} to the manifest", :green
        added_count += 1
        manifest[package] = package_info[package][:version]
        config_packages[package] = {
          "component" => package,
          "version_file" => package_info[package][:version_file]
        }
      end
    end
    config["packages"] = sort_hash config_packages
    manifest = sort_hash add_fillers manifest
    puts "Added #{added_count} packages (#{already_present_count} already present)", :bold

    File.open config_name, "w" do |file|
      file.puts JSON.pretty_generate config
    end
    File.open manifest_name, "w" do |file|
      file.puts JSON.pretty_generate manifest
    end
  end

  def add_fillers manifest
    manifest.keys.each do |key|
      manifest["#{key}+FILLER"] = "0.0.0" unless key.end_with? "+FILLER"
    end
    manifest
  end

  def sort_hash original
    result = {}
    original.keys.sort.each do |key|
      result[key] = original[key]
    end
    result
  end

  def find_all_packages
    found = Dir.glob("*/*.gemspec").map { |path| File.dirname path }
    set :packages, found
  end

  def get_package_info
    package_info = {}
    packages.each do |package|
      logger.info "Getting info for #{package}..."
      package_info[package] = {
        version_file: gem_version_file(package),
        version: gem_version(package)
      }
    end
    package_info
  end

  def gem_version_file package
    version_path = package.tr "-", "/"
    version_file = File.join "lib", version_path, "version.rb"
    version_file_full = File.join package, version_file
    raise "Unable to find #{version_file_full}" unless File.file? version_file_full
    version_file
  end

  def gem_version package
    func = proc do
      Dir.chdir package do
        spec = Gem::Specification.load "#{package}.gemspec"
        puts spec.version.to_s
      end
    end
    capture_proc(func, log_level: false).strip
  end
end
