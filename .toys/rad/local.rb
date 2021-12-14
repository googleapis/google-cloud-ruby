desc "Run cloud-rad locally for testing"

remaining_args :gem_names

flag :keep_temp_dir
flag :build_docfx
flag :doc_templates_path, "--doc-templates-path=PATH"
flag :piper_client, "--piper-client=NAME"

include :exec, e: true
include :fileutils
include :terminal
include :git_cache

def run
  @original_working_directory = Dir.getwd
  Dir.chdir context_directory
  effective_gem_names.each do |gem_name|
    run_yard gem_name
    run_docfx gem_name if build_docfx
  end
  return unless build_docfx && piper_client
  update_piper
  output_piper_results
end

def run_yard gem_name
  Dir.chdir gem_name do
    rm_rf "doc"
    rm_rf ".yardoc"
    cmd = ["release", "build-rad", "--gem-name", gem_name]
    cmd << "-#{'q' * (-verbosity)}" if verbosity < 0
    cmd << "-#{'v' * verbosity}" if verbosity > 0
    exec_tool cmd
  end
end

def run_docfx gem_name
  update_docfx_json gem_name
  Dir.chdir gem_name do
    rm_rf doc_templates_obj_path
    cp_r "doc", doc_templates_obj_path
    rm_rf doc_templates_site_output_path
    Dir.chdir doc_templates_ruby_path do
      exec ["docfx", "build", "--debug", "-t", doc_templates_devsite_path]
      File.rename "site/api/toc.yaml", "site/api/_toc.yaml"
    end
    rm_rf doc_templates_site_gem_path(gem_name)
    mv doc_templates_site_output_path, doc_templates_site_gem_path(gem_name)
  end
end

def update_docfx_json gem_name
  require "json"
  content = File.read doc_templates_json_path
  orig_data = JSON.parse! content
  data = JSON.parse! content
  global_metadata = data["build"]["globalMetadata"]
  global_metadata["_appTitle"] = gem_name
  global_metadata["_rootPath"] = "/ruby/docs/reference/#{gem_name}/latest"
  unless content == data
    File.open doc_templates_json_path, "w" do |file|
      file.puts JSON.pretty_generate data
    end
  end
end

def update_piper
  Dir.chdir piper_client_dir do
    toc_path = "googledata/devsite/site-cloud/en/ruby/docs/_apis_libraries_toc.yaml"
    File.open toc_path, "w" do |file|
      file.puts "toc:"
      file.puts "- heading: API Reference Docs"
      effective_gem_names.each do |gem_name|
        file.puts "- include: /ruby/docs/reference/#{gem_name}/latest/_toc.yaml"
      end
    end
    effective_gem_names.each do |gem_name|
      dir = "googledata/devsite/site-cloud/en/ruby/docs/reference/#{gem_name}"
      rm_rf dir
      mkdir_p dir
      cp_r doc_templates_site_gem_path(gem_name), "#{dir}/latest"
    end
  end
end

def output_piper_results
  puts "Stage:", :bold
  paths = effective_gem_names.map { |gem_name| "googledata/devsite/site-cloud/en/ruby/docs/reference/#{gem_name}/latest" }
  paths << "googledata/devsite/site-cloud/en/ruby/_book.yaml"
  paths = paths.join ", "
  puts "PATHS: #{paths}"
  puts "WORKSPACE: #{piper_client}"
  puts "FLAGS: --upload_safety_check_mode=ignore"
  puts
  puts "Links:", :bold
  effective_gem_names.each do |gem_name|
    puts "  https://cloud.devsite.corp.google.com/ruby/docs/reference/#{gem_name}/latest"
  end
end

def effective_gem_names
  @effective_gem_names ||=
    if gem_names.empty?
      error "gem name not provided" if context_directory == @original_working_directory
      unless @original_working_directory.start_with? context_directory
        error "unexpected current directory #{@original_working_directory}"
      end
      name = @original_working_directory.sub("#{context_directory}/", "").split("/").first
      [validate_gem_name(name)]
    else
      gem_names.map { |name| validate_gem_name name }
    end
end

def validate_gem_name name
  error "gem name not provided" if name.to_s.empty?
  path = File.join name, ".yardopts"
  error "no #{path} file" unless File.file? path
  name
end

def effective_doc_templates_path
  @effective_doc_templates_path ||=
    if doc_templates_path
      File.expand_path doc_templates_path, @original_working_directory
    else
      require "tmpdir"
      src_path = git_cache.find "https://github.com/googleapis/doc-templates.git", update: true
      tmp_dir = Dir.mktmpdir
      templates_dir = File.join tmp_dir, "doc-templates"
      if keep_temp_dir
        logger.warn "Copying into directory: #{templates_dir}"
      else
        at_exit { FileUtils.rm_rf tmp_dir }
      end
      cp_r src_path, templates_dir
      templates_dir
    end
end

def doc_templates_ruby_path
  File.join effective_doc_templates_path, "testdata", "ruby"
end

def doc_templates_obj_path
  File.join doc_templates_ruby_path, "obj", "api"
end

def doc_templates_site_output_path
  File.join doc_templates_ruby_path, "site", "api"
end

def doc_templates_site_gem_path gem_name
  File.join doc_templates_ruby_path, "site", gem_name
end

def doc_templates_json_path
  File.join doc_templates_ruby_path, "docfx.json"
end

def doc_templates_devsite_path
  File.join effective_doc_templates_path, "third_party", "docfx", "templates", "devsite"
end

def piper_client_dir
  @piper_client_dir ||= capture("p4 g4d #{piper_client}").strip
end

def error str
  logger.error str
  exit 1
end
