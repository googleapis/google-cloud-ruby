# frozen_string_literal: true

# Copyright 2020 Google LLC
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

desc "A tool that generates a new client library"

long_desc \
  "A tool that generates a new client library.",
  "",
  "Use this tool to automate the process of generating a new gapic or" \
    " wrapper client. You provide, on the command line, the name of the gem" \
    " to generate. This tool will determine what kind of library is being" \
    " requested, create an appropriate synth script, run the generator to" \
    " generate the library itself, ensure the tests pass, update the kokoro" \
    " configs, and optionally open a pull request for the new library.",
  "",
  "Fields such as description and product URL are filled in from existing" \
    " libraries for the same API, if any are present; otherwise, they are" \
    " given default values. The tool also invokes your editor with the" \
    " generated synth script before running it, so you can make adjustments." \
    " In general, for the first library for any given API, you'll need to" \
    " fill in a number of fields in the script in your editor, but for most" \
    " subsequent libraries, this tool will be able to generate the correct" \
    " synth script using previous scripts as a model."

required_arg :gem_name do
  desc "The full gem name. The type (gapic or wrapper) is inferred from whether the name includes a version."
end

flag :editor do
  default ENV["EDITOR"]
  desc "The path to your editor. Uses the EDITOR environment variable by default."
end
flag :branch_name, "--branch NAME" do
  desc "The name of the branch to use if opening a pull request. Defaults to gen/GEM-NAME."
end
flag :git_remote, "--remote NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :yes, "--yes", "-y", desc: "Auto-confirm prompts"
flag :proto_base, "--proto-base PATH" do
  desc "The base directory in the proto path (excluding the version)"
end
flag :use_synth do
  desc "Force use of synthtool over owlbot"
end
flag :pull do
  desc "Pull the latest images before running"
end
flag :source_repo, "--source-repo=PATH" do
  desc "Path to the googleapis-gen source repo"
end

static :replace_me_text, "(REPLACE ME)"
static :synth_script_name, "synth.py"
static :owlbot_config_name, ".OwlBot.yaml"
static :owlbot_script_name, ".owlbot.rb"
static :repo_metadata_name, ".repo-metadata.json"

include :exec, e: true
include :fileutils
include :terminal

def run
  require "erb"
  require "fileutils"
  require "json"
  require "psych"
  require "pull_request_generator"
  extend PullRequestGenerator

  startup
  gather_info
  result = generate
  final_result result
end

def startup
  @gem_name = gem_name
  @branch_name = branch_name || "gen/#{@gem_name}"
  @year = Time.now.year

  ensure_pull_request_generation_dependencies

  logger.info "Clearing out directory #{@gem_name}"
  FileUtils.rm_rf @gem_name
end

def gather_info
  puts "\nGathering info...", :bold
  analyze_gem_name
  determine_defaults
  determine_existing_versions
  lookup_precedents
  fill_type_specific_fields
  create_optional_sections
end

def generate
  generate_pull_request gem_name: @gem_name,
                        git_remote: git_remote,
                        branch_name: @branch_name,
                        commit_message: "feat: Initial generation of #{@gem_name}" do
    case @gen_type
    when "wrapper"
      generate_synth
    when "gapic"
      if use_synth
        generate_synth
      else
        generate_owlbot
      end
    else
      error "Unexpected gen_type #{@gen_type.inspect}"
    end
    puts "\nTesting library...", :bold
    test_lib
  end
end

def generate_synth
  ensure_synthtool
  puts "\nGenerating synth script...", :bold
  populate_file synth_script_name, "synth-#{@gen_type}-template.erb", "synth script"
  edit_file synth_script_name
  puts "\nGenerating library...", :bold
  Dir.chdir @gem_name do
    exec ["python", "-m", "synthtool"]
  end
end

def generate_owlbot
  puts "\nGenerating owlbot script...", :bold
  populate_file owlbot_config_name, "owlbot-config-template.erb", "owlbot config"
  populate_file owlbot_script_name, "owlbot-script-template.erb", "owlbot script"
  edit_file owlbot_script_name
  delete_owlbot_script_if_not_needed
  puts "\nGenerating library...", :bold
  cmd = ["owlbot", @gem_name]
  cmd << "--pull" if pull
  cmd << "--source-repo" << source_repo if source_repo
  if verbosity < 0
    cmd << "-#{'q' * (-verbosity)}"
  elsif verbosity > 0
    cmd << "-#{'v' * verbosity}"
  end
  exec_tool cmd
end

def final_result result
  case result
  when :opened
    puts "\nCreated pull request", :bold, :green
  when :disabled
    puts "\nGenerated client locally", :bold, :green
  else
    puts "\nUnexpected result: #{result.inspect}", :bold, :red
  end
end

def ensure_synthtool
  result = exec ["python", "--version"], out: :capture, e: false
  match = /^Python (\d+)\.(\d+)\.(\d+)/.match result.captured_out.to_s
  error "Python 3 not installed." if !result.success? || !match
  version_val = match[1].to_i * 1_000_000 + match[2].to_i * 1000 + match[3].to_i
  version_str = "#{match[1]}.#{match[2]}.#{match[3]}"
  error "Python 3.6 or later required but #{version_str} found." if version_val < 3_6_000
  result = exec ["python", "-m", "pip", "list", "--user", "--format=freeze"], out: :capture, e: false
  error "Pip doesn't seem to be present" unless result.success?
  lines = result.captured_out.to_s.split "\n"
  unless lines.any? { |line| line.start_with? "gcp-synthtool==" }
    error "Synthtool not found.",
          "To install: python -m pip install --user --upgrade git+https://github.com/googleapis/synthtool.git"
  end
  logger.info "Verified synthtool present"
end

def analyze_gem_name
  error "Bad gem name #{@gem_name.inspect}" unless @gem_name.to_s =~ /^[a-z]([a-z0-9_-]*[a-z0-9])?$/
  if @gem_name =~ /^([a-z][a-z0-9_-]*)-(v\d[a-z0-9]*)$/
    @base_gem_name = Regexp.last_match 1
    @api_version = Regexp.last_match 2
    @gen_type = "gapic"
    logger.info "Generating gapic gem #{@base_gem_name}-#{@api_version}"
  else
    @base_gem_name = @gem_name
    @api_version = nil
    @gen_type = "wrapper"
    logger.info "Generating wrapper gem #{@base_gem_name}"
  end
end

def determine_defaults
  gem_shortname = @base_gem_name.sub(/^google-cloud-/, "")
  @api_name = gem_shortname.tr("-", "/").tr "_", ""
  @proto_path_base = proto_base || "google/cloud/#{@api_name}"
  @bazel_target_base = "google-cloud-#{@api_name.tr '/', '-'}"
  @api_shortname = @api_name.tr "/", ""
  @api_id = "#{@api_shortname}.googleapis.com"
  @service_display_name = gem_shortname.split("_").map(&:capitalize).join " "
  @env_prefix = nil
  @description = replace_me_text
  @product_url = replace_me_text
  @service_override = nil
  @path_override = nil
  @namespace_override = nil
end

def determine_existing_versions
  dirs = Dir.glob "#{@base_gem_name}-v*"
  dirs.delete_if do |dir|
    dir !~ /^#{@base_gem_name}-v\d[a-z0-9]*$/ ||
      !File.file?("#{dir}/#{dir}.gemspec") ||
      !File.file?("#{dir}/#{synth_script_name}") && !File.file?("#{dir}/#{owlbot_config_name}")
  end
  @existing_versions = dirs.map { |dir| dir.sub "#{@base_gem_name}-", "" }.sort
  default_version_candidates = @existing_versions.find_all { |v| v =~ /^v\d+$/ }
  default_version_candidates = @existing_versions if default_version_candidates.empty?
  default_gem_version = default_version_candidates.last
  @existing_versions.delete default_gem_version
  @existing_versions.unshift default_gem_version if default_gem_version
  logger.info "Found existing versions: #{@existing_versions}"
end

def lookup_precedents
  @existing_versions.reverse_each do |version|
    precedent_gem = "#{@base_gem_name}-#{version}"
    path = File.join precedent_gem, owlbot_config_name
    lookup_precedents_in_owlbot path, version if File.file? path
    path = File.join precedent_gem, synth_script_name
    lookup_precedents_in_synth path, version if File.file? path
    path = File.join precedent_gem, repo_metadata_name
    lookup_precedents_in_repo_metadata path if File.file? path
  end
end

def lookup_precedents_in_owlbot file_path, version
  logger.info "Looking for existing settings in #{file_path}..."
  config = Psych.load_file file_path

  deep_copy_regex = Array(config["deep-copy-regex"]).first
  if deep_copy_regex&.include? "source"
    source = deep_copy_regex["source"]
    if source =~ %r{^/([\w/-]+)/#{version}/\[\^/\]\+-ruby/\(\.\*\)$}
      @proto_path_base = Regexp.last_match 1
    end
  end
end

def lookup_precedents_in_synth file_path, version
  logger.info "Looking for existing settings in #{file_path}..."
  script = File.read file_path

  if script =~ /gapic\.ruby_library\(\n\s+"([^"]*)",/
    @api_name = Regexp.last_match 1
  end
  if script =~ %r{proto_path="([^"]*)/#{version}",}
    @proto_path_base = Regexp.last_match 1
  end
  if script =~ %r{bazel_target="//[^":]+:([^"]*)-#{version}-ruby",}
    @bazel_target_base = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-title":\s*"(.+)",\n/
    name = Regexp.last_match 1
    @service_display_name = name.end_with?(" #{version.capitalize}") ? name[0..-(version.length + 2)] : name
  end
  if script =~ /"ruby-cloud-description":\s*"(.+)",\n/
    @description = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-env-prefix":\s*"([A-Z0-9_]+)",\n/
    @env_prefix = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-product-url":\s*"(.+)",\n/
    @product_url = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-api-id":\s*"([a-z0-9._-]+)",\n/
    @api_id = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-api-shortname":\s*"([a-z0-9_-]+)",\n/
    @api_shortname = Regexp.last_match 1
  end
  if script =~ /"ruby-cloud-service-override":\s*"(.+)",\n/
    @service_override = Regexp.last_match 1
  end
end

def lookup_precedents_in_repo_metadata file_path
  repo_metadata = JSON.parse File.read file_path

  if repo_metadata.include? "name_pretty"
    @service_display_name = repo_metadata["name_pretty"].sub(/\s+API$/, "").sub(/\s+V\d[a-z0-9]*$/, "")
  end
  if repo_metadata.include? "ruby-cloud-description"
    versioned_suffix = /\sNote that [a-z0-9_-]+ is a version-specific client library\. For most uses, we recommend installing the main client library [a-z0-9_-]+ instead\. See the readme for more details\./
    @description = repo_metadata["ruby-cloud-description"].sub(versioned_suffix, "")
  end
  if repo_metadata.include? "ruby-cloud-env-prefix"
    @env_prefix = repo_metadata["ruby-cloud-env-prefix"]
  end
  if repo_metadata.include? "ruby-cloud-product-url"
    @product_url = repo_metadata["ruby-cloud-product-url"]
  end
  if repo_metadata.include? "ruby-cloud-service-override"
    @service_override = repo_metadata["ruby-cloud-service-override"]
  end
  if repo_metadata.include? "ruby-cloud-path-override"
    @path_override = repo_metadata["ruby-cloud-path-override"]
  end
  if repo_metadata.include? "ruby-cloud-namespace-override"
    @namespace_override = repo_metadata["ruby-cloud-namespace-override"]
  end
  if repo_metadata.include? "name"
    @api_shortname = repo_metadata["name"]
  end
  if repo_metadata.include? "api_id"
    @api_id = repo_metadata["api_id"]
  end
end

def fill_type_specific_fields
  if @gen_type == "wrapper"
    @api_version = @existing_versions.first
    @wrapper_expr = @existing_versions.map{ |ver| "#{ver}:0.0" }.join ";"
  end
end

def create_optional_sections
  @service_override_section = @path_override_section = @namespace_override_section = ""
  if @service_override
    @service_override_section = "\n        \"ruby-cloud-service-override\": \"#{@service_override}\","
    logger.info "Creating optional section for ruby-cloud-service-override"
  end
  if @path_override
    @path_override_section = "\n        \"ruby-cloud-path-override\": \"#{@path_override}\","
    logger.info "Creating optional section for ruby-cloud-path-override"
  end
  if @namespace_override
    @namespace_override_section = "\n        \"ruby-cloud-namespace-override\": \"#{@namespace_override}\","
    logger.info "Creating optional section for ruby-cloud-namespace-override"
  end
end

def populate_file file_name, template_name, description
  b = _binding
  output_path = "#{@gem_name}/#{file_name}"
  logger.info "Generating initial #{description} #{output_path} ..."
  FileUtils.mkdir_p @gem_name
  template_path = find_data template_name
  template = File.read template_path
  erb = ERB.new template
  content = erb.result b
  File.open output_path, "w" do |f|
    f.write content
  end
end

def edit_file file_name
  error "No EDITOR set" unless editor
  file_path = "#{@gem_name}/#{file_name}"
  exec [editor, file_path]
  new_content = File.read file_path
  error "Aborted" if new_content.to_s.strip.empty?
end

def delete_owlbot_script_if_not_needed
  path = File.join @gem_name, owlbot_script_name
  return unless File.file? path
  File.readlines(path).each do |line|
    line = line.strip
    return if !line.empty? && !line.start_with?("#") && line != "OwlBot.move_files"
  end
  FileUtils.rm path
end

def test_lib
  Dir.chdir @gem_name do
    exec ["bundle", "install"]
    exec ["bundle", "exec", "rake", "ci"]
  end
end

def error *messages
  messages.each do |message|
    puts message, :red, :bold
  end
  exit 1
end

def _binding
  binding
end
