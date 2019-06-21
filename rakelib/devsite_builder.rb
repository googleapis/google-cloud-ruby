require_relative "yard_builder.rb"

class DevsiteBuilder < YardBuilder

  def build_gem_docs gem, version, source_repo_dir, gh_pages_repo_dir
    # remove any existing docs before we build new docs
    safe_remove_dir(gh_pages_repo_dir + "docs" + gem + version)

    # specify markup and provider in case a gem is missing this
    markup = "--markup markdown --markup-provider redcarpet"

    output_dir = "#{gh_pages_repo_dir + "docs" + gem + version}"
    repo_metadata_path = "#{source_repo_dir + gem + '.repo-metadata.json'}"
    puts repo_metadata_path
    require "json"
    data = JSON.parse File.read(repo_metadata_path)
    data["version"] = version
    data.delete_if do |k, _|
      ![
        "name", "version", "language", "distribution_name",
        "product-page", "github-repository", "issue-tracker"
      ].include? k
    end
    # Correct distribution_name
    data.transform_keys! { |k| k.sub "_", "-" }

    puts "cd #{source_repo_dir + gem}"
    Dir.chdir(source_repo_dir + gem) do
      cmds = ["-o #{output_dir}", markup]
      cmd "yard --verbose #{cmds.join ' '}"
      docs_dir = gh_pages_repo_dir + "docs"
    end
    fix_gem_docs gem, gh_pages_repo_dir
    File.write "#{output_dir + "/.repo-metadata.json"}", data.to_json
    Dir.chdir output_dir do
      cmd "python3 -m docuploader create-metadata #{fields.join ' '}"
    end
    push_changes output_dir
  end

  def ensure_gem_index_file gem
  end

  def commit_changes repo, message
  end

  def push_changes dir
    puts dir
    Dir.chdir dir do
      opts = [
        "--credentials #{ENV['DOCS_CREDENTIALS']}",
        "--staging-bucket #{ENV['STAGING_BUCKET']}",
        "--metadata-file ./docs.metadata"
      ]
      cmd "python3 -m docuploader upload . #{opts.join ' '}"
    end
  end
end
