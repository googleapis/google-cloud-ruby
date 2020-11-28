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

require "erb"
require "fileutils"

class NewClientGenerator
  REPLACE_ME_TEXT = "(REPLACE ME)"

  def initialize context:,
                 gem_name:,
                 editor: nil,
                 git_remote: nil,
                 branch_name: nil
    @context = context
    @gem_name = gem_name
    @editor = editor || ENV["EDITOR"]
    @git_remote = git_remote
    @branch_name = branch_name || "gen/#{@gem_name}"
    @year = Time.now.year
  end

  def generate
    clean_output_directory
    @context.puts "\nAnalyzing...", :bold
    analyze_gem_name
    determine_defaults
    determine_existing_versions
    lookup_precedents
    finish_analysis
    create_optional_sections
    @context.puts "\nGenerating synth script...", :bold
    start_branch if @git_remote
    populate_initial_synth_script
    edit_synth_script
    @context.puts "\nGenerating library...", :bold
    generate_lib
    @context.puts "\nTesting library...", :bold
    test_lib
    @context.puts "\nGenerating configs...", :bold
    update_configs
    finish_branch if @git_remote
    @context.puts "\nSuccessful", :bold, :green
  end

  private

  def analyze_gem_name
    error "Bad gem name #{@gem_name.inspect}" unless @gem_name.to_s =~ /^[a-z]([a-z0-9_-]*[a-z0-9])?$/
    if @gem_name =~ /^([a-z][a-z0-9_-]*)-(v\d[a-z0-9]*)$/
      @base_gem_name = Regexp.last_match 1
      @api_version = Regexp.last_match 2
      @gen_type = "gapic"
      @context.logger.info "Generating gapic gem #{@base_gem_name}-#{@api_version}"
    else
      @base_gem_name = @gem_name
      @api_version = nil
      @gen_type = "wrapper"
      @context.logger.info "Generating wra[[er]] gem #{@base_gem_name}"
    end
  end

  def determine_defaults
    gem_shortname = @base_gem_name.sub(/^google-cloud-/, "")
    @api_name = gem_shortname.gsub(/[-_]/, "")
    @api_shortname = @api_name.dup
    @api_id = "#{@api_name}.googleapis.com"
    @service_display_name = gem_shortname.split("_").map(&:capitalize).join " "
    @env_prefix = gem_shortname.gsub("-", "_").upcase
    @service_config_name = "#{@api_name}_grpc_service_config.json"
    @description = REPLACE_ME_TEXT
    @product_url = REPLACE_ME_TEXT
    @proto_path_base = nil
    @service_override = nil
    @extra_proto_files = ['"google/cloud/common_resources.proto"']
  end

  def determine_existing_versions
    dirs = Dir.glob "#{@base_gem_name}-v*"
    dirs.delete_if { |dir| dir !~ /^#{@base_gem_name}-v\d[a-z0-9]*$/ }
    dirs.delete_if { |dir| !File.file?("#{dir}/#{dir}.gemspec") || !File.file?("#{dir}/synth.py") }
    @existing_versions = dirs.map { |dir| dir.sub "#{@base_gem_name}-", "" }.sort
    default_version_candidates = @existing_versions.find_all { |v| v =~ /^v\d+$/ }
    default_version_candidates = @existing_versions if default_version_candidates.empty?
    default_gem_version = default_version_candidates.last
    @existing_versions.delete default_gem_version
    @existing_versions.unshift default_gem_version if default_gem_version
    @context.logger.info "Found existing versions: #{@existing_versions}"
  end

  def lookup_precedents
    @existing_versions.reverse_each do |version|
      script = File.read "#{@base_gem_name}-#{version}/synth.py"
      if script =~ /gapic\.ruby_library\(\n\s+"([^"]*)",/
        @api_name = Regexp.last_match 1
      end
      if script =~ %r{proto_path="([^"]*)/#{version}",}
        @proto_path_base = Regexp.last_match 1
      end
      if script =~ /extra_proto_files=\[([^\]]*)\],/
        @extra_proto_files = Regexp.last_match(1).strip.split(/,\s*|\s+/)
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
      if script =~ /"ruby-cloud-grpc-service-config":\s*"(.+)",\n/
        path = Regexp.last_match 1
        @service_config_name = File.basename path
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
  end

  def finish_analysis
    case @gen_type
    when "gapic"
      @title_version = @api_version.capitalize
      @service_config_path = @proto_path_base || "google/cloud/#{@api_name}"
      @service_config_path += "/#{@api_version}/#{@service_config_name}"
    when "wrapper"
      @api_version = @existing_versions.first
      @wrapper_expr = @existing_versions.map{ |ver| "#{ver}:0.0" }.join ";"
      @extra_proto_files.delete '"google/cloud/common_resources.proto"'
    else
      error "Unknown generation type"
    end
  end

  def create_optional_sections
    @extra_proto_files_section = @proto_path_section = @service_override_section = ""
    unless @extra_proto_files.empty?
      lines = ["\n    extra_proto_files=["]
      @extra_proto_files.each { |entry| lines << "\n        #{entry}," }
      lines << "\n    ],"
      @extra_proto_files_section = lines.join
      @context.logger.info "Creating optional section for extra_proto_files"
    end
    if @proto_path_base
      @proto_path_section = "\n    proto_path=\"#{@proto_path_base}/#{@api_version}\","
      @context.logger.info "Creating optional section for proto_path"
    end
    if @service_override
      @service_override_section = "\n        \"ruby-cloud-service-override\": \"#{@service_override}\","
      @context.logger.info "Creating optional section for ruby-cloud-service-override"
    end
  end

  def clean_output_directory
    @context.logger.info "Clearing out directory #{@gem_name}"
    FileUtils.rm_rf @gem_name
  end

  def start_branch
    output = @context.capture(["git", "status", "-s"]).strip
    error "Git checkout is not clean" unless output.empty?
    @orig_branch_name = @context.capture(["git", "branch", "--show-current"]).strip
    @context.exec ["git", "checkout", "-b", @branch_name]
  end

  def populate_initial_synth_script
    b = binding
    FileUtils.mkdir_p @gem_name
    template_path = @context.find_data "synth-#{@gen_type}-template.erb"
    template = File.read template_path
    erb = ERB.new template
    script = erb.result b
    File.open "#{@gem_name}/synth.py", "w" do |f|
      f.write script
    end
  end

  def edit_synth_script
    error "No EDITOR set" unless @editor
    @context.exec [@editor, "#{@gem_name}/synth.py"]
    new_content = File.read "#{@gem_name}/synth.py"
    error "Aborted" if new_content.to_s.strip.empty?
  end

  def generate_lib
    Dir.chdir @gem_name do
      @context.exec ["python3", "-m", "synthtool"]
    end
  end

  def update_configs
    @context.exec ["bundle", "update"]
    @context.exec ["bundle", "exec", "rake", "kokoro:build"]
  end

  def test_lib
    Dir.chdir @gem_name do
      @context.exec ["bundle", "install"]
      @context.exec ["bundle", "exec", "rake", "ci"]
    end
  end

  def finish_branch
    unless @context.confirm "Push PR for new #{@gen_type} client #{@gem_name.inspect}? ", :bold, default: true
      error "Aborted"
    end
    @context.exec ["git", "add", ".kokoro", @gem_name]
    @context.exec ["git", "commit", "-m", "feat: Initial generation of #{@gem_name}"]
    @context.exec ["git", "push", "-u", @git_remote, @branch_name]
    @context.exec ["gh", "pr", "create",
                   "--title", "feat: Initial generation of #{@gem_name}",
                   "--body", "Pull request auto-created by library generation script.",
                   "--repo", "googleapis/google-cloud-ruby"]
    @context.exec ["git", "checkout", @orig_branch_name]
  end

  def error *messages
    messages.each do |message|
      @context.puts message, :red, :bold
    end
    @context.exit 1
  end
end
