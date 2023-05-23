include :exec, e: true
include :fileutils

required_arg :piper_client
flag :dry_run

def run
  require "erb"
  Dir.chdir context_directory
  template_path = find_data "wrapper-bazel-template.erb"
  template = File.read template_path
  each_library do |library_data|
    erb = ERB.new template
    content = erb.result library_data.erb_binding
    unless dry_run
      File.open library_data.bazel_path, "w" do |file|
        file.write content
      end
    end
  end
end

def each_library
  piper_client_dir = capture("p4 g4d #{piper_client}").strip
  LibraryData.googleapis_base_dir = File.join piper_client_dir, "third_party", "googleapis", "stable"
  Dir.glob("*/synth.py") do |path|
    full_path = File.expand_path path, context_directory
    library_data = LibraryData.new full_path
    errors = library_data.errors
    unless errors.empty?
      errors.each { |msg| logger.warn "#{msg} in #{path}"}
      next
    end
    logger.info "Handling #{path}..."
    yield library_data
  end
end

class LibraryData
  class << self
    attr_accessor :googleapis_base_dir
  end

  def initialize synth_path
    synth_content = File.read synth_path
    interpret_proto_path synth_content
    interpret_generator_args synth_content
    return unless @generator_args && @proto_path
    @bazel_path = File.join LibraryData.googleapis_base_dir, @proto_path, "BUILD.bazel"
    @versioned_bazel_path = File.join LibraryData.googleapis_base_dir, @versioned_proto_path, "BUILD.bazel"
    interpret_versioned_bazel File.read @versioned_bazel_path
    @description = @generator_args.delete "ruby-cloud-description"
    @title = @generator_args.delete "ruby-cloud-title"
    @gem_name = @generator_args["ruby-cloud-gem-name"]
    @api_shortname = @generator_args["ruby-cloud-api-shortname"]
    @api_shortname ||= @gem_name.split("-").first.tr("_", "")
    @assembly_package_name = @gem_name.tr "_", ""
  end

  attr_reader :versioned_proto_path
  attr_reader :proto_path
  attr_reader :service_version
  attr_reader :description
  attr_reader :title
  attr_reader :api_shortname
  attr_reader :gem_name
  attr_reader :generator_args
  attr_reader :assembly_package_name
  attr_reader :bazel_path
  attr_reader :versioned_bazel_path
  attr_reader :proto_with_info_target

  def errors
    result = []
    result << "no proto path found" unless @proto_path
    result << "no generator args found" unless @generator_args
    result << "no gem name found" unless @gem_name
    result << "no shortname found" unless @api_shortname
    result << "no proto_with_info target found" unless @proto_with_info_target
    result
  end

  def erb_binding
    binding
  end

  def render_protoc_parameters ext_indent, int_indent
    list = ["["]
    ext_indent = " " * ext_indent
    int_indent = " " * int_indent
    @generator_args.each do |k, v|
      list << "#{int_indent}\"#{k}=#{v}\","
    end
    list << "#{ext_indent}]"
    list.join "\n"
  end

  private

  def interpret_proto_path content
    @versioned_proto_path = @proto_path = @service_version = nil
    if content =~ /proto_path\s*=\s*"([^"]+)"/
      raw_proto_path = Regexp.last_match[1]
      if raw_proto_path =~ %r{^(.+)/(v\d\w*)$}
        @proto_path = Regexp.last_match[1]
        @service_version = Regexp.last_match[2]
        @versioned_proto_path = raw_proto_path
      end
    elsif content =~ /gapic\.ruby_library\(\s*"([^"]+)",\s*"(v\d\w*)"/
      @proto_path = "google/cloud/#{Regexp.last_match[1]}"
      @service_version = Regexp.last_match[2]
      @versioned_proto_path = "#{@proto_path}/#{@service_version}"
    end
  end

  def interpret_generator_args content
    @generator_args = nil
    return unless content =~ /\n    generator_args\s*=\s*{(.*\n)    }/m
    content = Regexp.last_match[1]
    @generator_args = {}
    content.scan(/"([^"]+)"\s*:\s*"(.+)",?\n/) do |k, v|
      @generator_args[k] = v
    end
  end

  def interpret_versioned_bazel content
    @proto_with_info_target = nil
    if content =~ /:(\w+_proto_with_info)/
      @proto_with_info_target = Regexp.last_match[1]
    end
  end
end
