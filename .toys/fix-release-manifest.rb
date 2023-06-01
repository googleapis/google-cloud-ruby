# frozen_string_literal: true

# Copyright 2023 Google LLC
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

desc "Fixes the current manifest to match the versions."

flag :dry_run
flag :read_versions, "--read-versions=PATH"
flag :write_versions, "--write-versions=PATH"

remaining_args :input_packages do
  desc "Check the specified packages. If no specific packages are provided, all are checked."
end

include :terminal
include :exec, e: true

GemData = Struct.new :package,
                     :version_path,
                     :declared_version,
                     :canonical_version,
                     :existing_tags,
                     :manifest_version

def run
  Dir.chdir context_directory
  read_canonical_versions_file
  load_data
  update_data
  write_canonical_versions_file
end

def read_canonical_versions_file
  @canonical_versions =
    if read_versions
      JSON.parse File.read read_versions
    else
      {}
    end
end

def write_canonical_versions_file
  return unless write_versions
  File.write write_versions, "#{JSON.pretty_generate(@canonical_versions)}\n"
end

def load_data
  require "json"
  @gem_data = []
  exec ["git", "fetch", "--tags", "--force"]
  all_tags = capture(["git", "tag", "--list"]).split "\n"
  config = JSON.parse File.read "release-please-config.json"
  config["packages"].each do |package, info|
    next if !input_packages.empty? && !input_packages.include?(package)
    version_path = "#{package}/#{info["version_file"]}"
    declared_version = load_declared_version version_path
    canonical_version = load_canonical_version package
    existing_tags = load_existing_tags all_tags, package
    @gem_data << GemData.new(package, version_path, declared_version, canonical_version, existing_tags)
  end
  load_manifest_versions
end

def load_declared_version version_path
  unless File.file? version_path
    puts "Not found: #{version_path}", :red, :bold
    exit 1
  end
  version_file = File.read version_path
  match = /VERSION = "(\d+\.\d+\.\d+)"/.match version_file
  unless match
    puts "Bad format: #{version_path}", :red, :bold
    exit 1
  end
  match[1]
end

def load_canonical_version package
  return @canonical_versions[package] if @canonical_versions.key? package
  content = capture ["curl", "https://rubygems.org/api/v1/gems/#{package}.json"], err: :null
  version = JSON.parse(content)["version"]
  @canonical_versions[package] ||= version
  version
end

def load_existing_tags all_tags, package
  all_tags.find_all { |tag| tag.start_with? package }
          .map { |tag| tag.sub "#{package}/v", "" }
end

def load_manifest_versions
  manifest = JSON.parse File.read ".release-please-manifest.json"
  @gem_data.each do |gem_data|
    package = gem_data.package
    manifest_version = manifest[package]
    unless manifest_version
      puts "No manifest entry found for #{package}", :red, :bold
      exit 1
    end
    gem_data.manifest_version = manifest_version
  end
end

def update_data
  update_manifest
  update_version_file
  update_changelog
  update_tags
end

def update_manifest
  puts "UPDATING MANIFEST FILE", :bold
  manifest = File.read ".release-please-manifest.json"
  @gem_data.each do |gem_data|
    package = gem_data.package
    canonical_version = gem_data.canonical_version
    manifest_version = gem_data.manifest_version
    changed = manifest.sub "\"#{package}\": \"#{manifest_version}\"", "\"#{package}\": \"#{canonical_version}\""
    unless changed == manifest
      if dry_run
        puts "#{package}: manifest version updated from #{manifest_version} to #{canonical_version}"
      else
        manifest = changed
      end
    end
  end
  File.write ".release-please-manifest.json", manifest unless dry_run
end

def update_version_file
  puts "UPDATING VERSION FILES", :bold
  @gem_data.each do |gem_data|
    package = gem_data.package
    declared_version = gem_data.declared_version
    canonical_version = gem_data.canonical_version
    version_file = File.read gem_data.version_path
    changed = version_file.sub "VERSION = \"#{declared_version}\"", "VERSION = \"#{canonical_version}\""
    unless changed == version_file
      if dry_run
        puts "#{package}: version file updated from #{declared_version} to #{canonical_version}"
      else
        File.write gem_data.version_path, changed
      end
    end
  end
end

def update_changelog
  puts "UPDATING CHANGELOGS", :bold
  @gem_data.each do |gem_data|
    declared_version = gem_data.declared_version
    next if declared_version == gem_data.canonical_version
    package = gem_data.package
    changelog_path = "#{package}/CHANGELOG.md"
    changelog = File.read changelog_path
    changed = changelog.sub(/\n### #{declared_version} (((####|[^\n#])[^\n]*)?\n)+(### \d)/, "\n\\4")
    unless changed == changelog
      if dry_run
        puts "#{package}: changelog updated to remove #{declared_version}"
      else
        File.write changelog_path, changed
      end
    end
  end
end

def update_tags
  puts "UPDATING TAGS", :bold
  @gem_data.each do |gem_data|
    declared_version = gem_data.declared_version
    canonical_version = gem_data.canonical_version
    next if declared_version == canonical_version
    package = gem_data.package
    if gem_data.existing_tags.include? declared_version
      if dry_run
        puts "#{package}: Deleting tag for #{declared_version} (should be #{canonical_version})"
      else
        exec ["git", "tag", "--delete", "#{package}/v#{declared_version}"]
        exec ["gh", "release", "delete", "#{package}/v#{declared_version}", "--yes"]
        exec ["git", "push", "--delete", "origin", "#{package}/v#{declared_version}"]
      end
    end
  end
end
