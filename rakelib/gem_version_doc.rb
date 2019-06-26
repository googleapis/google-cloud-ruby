require_relative "repo_metadata.rb"
require_relative "repo_doc_common.rb"

class GemVersionDoc < RepoDocCommon
  def initialize input_dir, output_dir, metadata = nil
    @input_dir = input_dir
    @output_dir = output_dir
    if metadata.nil?
      @metadata = RepoMetadata.from_source "#{input_dir}/.repo-metadata.json"
    else
      @metadata = RepoMetadata.from_source metadata
    end
  end

  def build
    FileUtils.remove_dir @output_dir if Dir.exists? @output_dir
    markup = "--markup markdown --markup-provider redcarpet"

    Dir.chdir @input_dir do
      cmds = ["-o #{@output_dir}", markup]
      cmd "yard --verbose #{cmds.join ' '}"
    end
    @metadata.build @output_dir
    fix_gem_docs
  end

  def fix_gem_docs
    return unless @input_dir.to_s.include? "google-cloud-trace"

    puts "cd #{@output_dir} [google-cloud-trace fixes]"
    Dir.chdir @output_dir do
      Dir.glob(File.join("**","*.html")).each do |file_path|
        file_contents = File.read file_path
        file_contents.gsub! "{% dynamic print site_values.console_name %}",
                            "Google Cloud Platform Console"
        file_contents.gsub! "dynamic print site_values.console_name %",
                            "Google Cloud Platform Console"
        File.write file_path, file_contents
      end
    end
  end

  def upload
    Dir.chdir @output_dir do
      opts = [
        "--credentials #{ENV['DOCS_CREDENTIALS']}",
        "--staging-bucket #{ENV['STAGING_BUCKET']}",
        "--metadata-file ./docs.metadata"
      ]
      cmd "python3 -m docuploader upload . #{opts.join ' '}"
    end
  end

  def publish
    build
    upload
  end
end
