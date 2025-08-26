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

desc "Create _access.yaml files"

required_arg :piper_client

include :exec, e: true
include :terminal
include :fileutils

def run
  each_gem do |gem_name|
    puts gem_name
    gem_dir = File.join reference_base_dir, gem_name
    access_file = File.join gem_dir, "_access.yaml"
    mkdir_p gem_dir
    File.open access_file, "w" do |file|
      file.puts "acl:"
      file.puts "- group: cloud-rad-users@googlegroups.com"
    end
  end
end

def each_gem(&)
  omit_list = [
    "gcloud",
    "google-cloud",
    "google-cloud-asset-v1beta1",
    "grafeas-client",
    "stackdriver",
  ]
  extra_list = [
    "google-cloud-ids",
    "google-cloud-ids-v1",
    "google-cloud-vmmigration",
    "google-cloud-vmmigration-v1",
  ]
  Dir.glob "*/*.gemspec" do |path|
    name = File.dirname path
    yield name unless omit_list.include? name
  end
  extra_list.each(&)
end

def piper_client_dir
  @piper_client_dir ||= capture(["p4", "g4d", piper_client]).strip
end

def reference_base_dir
  File.join piper_client_dir, "googledata", "devsite", "site-cloud", "en", "ruby", "docs", "reference"
end

def error str
  logger.error str
  exit 1
end
