# frozen_string_literal: true

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

desc "A tool that updates wrapper-gapic dependencies"

long_desc \
  "Updates the versions of GAPICs required by the corresponding wrappers, " \
  "to the latest release in rubygems.org. This can be used when a wrapper " \
  "needs to ensure that a new service or capability is available in the " \
  "underlying GAPICs it delegates to.",
  "",
  "You must first create a piper client, and its name must be passed in " \
  "via the appropriate flag. Then you can either pass the specific GAPICs " \
  "to cover on the command line, or do all GAPICs by passing --all-gapics. " \
  "The tool will edit the BUILD.bazel files in the piper client to update " \
  "the relevant dependencies."

all_required do
  flag :piper_client, "--piper-client=NAME"
end
flag :dry_run
flag :all_gapics
remaining_args :requested_gapics

include :exec, e: true

def run
  require "net/http"
  require "psych"
  @gapic_count = 0
  @wrapper_count = 0
  Dir.chdir context_directory
  wrapper_info = find_wrappers_and_versions
  puts "GAPIC count: #{@gapic_count}"
  piper_dir = capture(["p4", "g4d", piper_client]).strip
  Dir.chdir piper_dir
  update_bazel wrapper_info
  puts "GAPIC count: #{@gapic_count}"
  puts "Wrapper count: #{@wrapper_count}"
end

def find_wrappers_and_versions
  logger.info "Analyzing GAPICs ..."
  wrappers = {}
  Dir.children(context_directory).sort.each do |gapic|
    next unless all_gapics || requested_gapics.include?(gapic)
    next unless File.directory? gapic
    next unless File.file? "#{gapic}/.OwlBot.yaml"
    matches = /^[\w-]+-(v\d+\w*)$/.match gapic
    next unless matches
    version = matches[1]
    path = wrapper_proto_path gapic
    versions = wrappers[path] ||= {}
    versions[version] = latest_gem_version gapic
    logger.info "... Handled #{gapic}"
    @gapic_count += 1
  end
  wrappers
end

def wrapper_proto_path gapic
  owlbot_config = Psych.load_file "#{gapic}/.OwlBot.yaml"
  source_regex = owlbot_config["deep-copy-regex"].first["source"]
  match = %r{/([\w/]+)/v\d}.match source_regex
  "third_party/googleapis/stable/#{match[1]}/BUILD.bazel"
end

def latest_gem_version name
  sleep 0.1
  response = Net::HTTP.get URI("https://rubygems.org/api/v1/gems/#{name}.json")
  version = JSON.parse(response)["version"]
  match = /^(\d+\.\d+)/.match version
  match[1]
end

def update_bazel wrapper_info
  logger.info "Updating Bazel files ..."
  wrapper_info.each do |path, versions|
    unless File.file? path
      logger.warn "No Bazel file #{path}"
      next
    end
    content = File.read path
    match = /"ruby-cloud-wrapper-of=.+"/.match content
    unless match
      logger.warn "No wrapper line in #{path}"
      next
    end
    orig_line = line = match[0]
    versions.each do |service_version, gem_version|
      line = line.sub(/(?<=[=;])#{service_version}:\d+\.\d+/, "#{service_version}:#{gem_version}")
    end
    if orig_line == line
      logger.warn "No changes in #{path}"
      next
    end
    content.sub! orig_line, line
    File.write path, content unless dry_run
    logger.info "... Updated #{path}"
    @wrapper_count += 1
  end
end
