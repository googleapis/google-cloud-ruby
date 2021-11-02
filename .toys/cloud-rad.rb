desc "Run cloud-rad"

flag :gem_name, "--gem=NAME"
flag :keep_temp_dir
flag :build_docfx
flag :doc_templates_path, "--doc-templates-path=PATH"
flag :piper_client, "--piper-client=NAME"

include :exec, e: true
include :fileutils
include :git_cache

def run
  @original_working_directory = Dir.getwd
  Dir.chdir context_directory
  run_yard
  return unless build_docfx
  update_docfx_json
  run_docfx
  return unless piper_client
  update_piper
  output_piper_results
end

def run_yard
  Dir.chdir effective_gem_name do
    rm_rf "doc"
    cmd = [
      "bundle", "exec", "yard", "doc",
      "--yardopts", ".yardopts-cloudrad"
    ]
    env = { "CLOUDRAD_GEM_NAME" => effective_gem_name }
    exec cmd, env: env
  end
end

def update_docfx_json
  require "json"
  content = File.read doc_templates_json_path
  orig_data = JSON.parse! content
  data = JSON.parse! content
  global_metadata = data["build"]["globalMetadata"]
  global_metadata["_appTitle"] = effective_gem_name
  global_metadata["_rootPath"] = "/ruby/docs/reference/#{effective_gem_name}/latest"
  unless content == data
    File.open doc_templates_json_path, "w" do |file|
      file.puts JSON.pretty_generate data
    end
  end
end

def run_docfx
  Dir.chdir effective_gem_name do
    rm_rf doc_templates_obj_path
    cp_r "doc", doc_templates_obj_path
    Dir.chdir doc_templates_ruby_path do
      exec ["docfx", "build", "--debug", "-t", doc_templates_devsite_path]
      File.rename "site/api/toc.yaml", "site/api/_toc.yaml"
    end
  end
end

def update_piper
  Dir.chdir piper_client_dir do
    toc_path = "googledata/devsite/site-cloud/en/ruby/docs/_apis_libraries_toc.yaml"
    File.open toc_path, "w" do |file|
      file.puts <<~YAML
        toc:
        - heading: "API Reference Docs"
        - include: /ruby/docs/reference/#{effective_gem_name}/latest/_toc.yaml
      YAML
    end
    dir = "googledata/devsite/site-cloud/en/ruby/docs/reference/#{effective_gem_name}"
    rm_rf dir
    mkdir_p dir
    cp_r doc_templates_site_path, "#{dir}/latest"
  end
end

def output_piper_results
  puts "Stage:"
  puts "PATHS: googledata/devsite/site-cloud/en/ruby/docs/reference/#{effective_gem_name}/latest, googledata/devsite/site-cloud/en/ruby/_book.yaml"
  puts "WORKSPACE: #{piper_client}"
  puts "LINK: https://cloud.devsite.corp.google.com/ruby/docs/reference/#{effective_gem_name}/latest"
end

def effective_gem_name
  @effective_gem_name ||= validate_gem_name(gem_name || gem_from_subdirectory)
end

def gem_from_subdirectory
  return nil if context_directory == @original_working_directory
  unless @original_working_directory.start_with? context_directory
    error "unexpected current directory #{@original_working_directory}"
  end
  @original_working_directory.sub("#{context_directory}/", "").split("/").first
end

def validate_gem_name name
  error "gem name not provided" unless name
  path = File.join name, ".yardopts-cloudrad"
  error "no #{path} file" unless File.file? path
  name
end

def effective_doc_templates_path
  @effective_doc_templates_path ||= begin
    File.expand_path doc_templates_path, @original_working_directory
  end if doc_templates_path
  @effective_doc_templates_path ||= begin
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

def doc_templates_site_path
  File.join doc_templates_ruby_path, "site", "api"
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
