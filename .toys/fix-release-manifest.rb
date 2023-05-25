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

remaining_args :input_packages do
  desc "Check the specified packages. If no specific packages are provided, all are checked."
end

include :terminal

def run
  Dir.chdir context_directory
  load_data
  update_data
end

def load_data
  require "json"
  config = JSON.parse File.read "release-please-config.json"
  @correct_versions = config["packages"].map do |package, info|
    version_path = "#{package}/#{info["version_file"]}"
    if File.file? version_path
      version_file = File.read "#{package}/#{info["version_file"]}"
      match = /VERSION = "(\d+\.\d+\.\d+)"/.match version_file
      [package, match[1]]
    else
      puts "Not found: #{version_path}", :red, :bold
      nil
    end
  end.compact.to_h
  @correct_versions.delete_if { |package, _version| !input_packages.include? package } unless input_packages.empty?
end

def update_data
  manifest = File.read ".release-please-manifest.json"
  @correct_versions.each do |package, version|
    manifest.sub!(/"#{package}": "\d+\.\d+\.\d+"/, "\"#{package}\": \"#{version}\"")
  end
  File.write ".release-please-manifest.json", manifest
end
