require_relative "yard_builder.rb"

class DevsiteBuilder < YardBuilder

  def build_master
    return if case_insensitive_check!

    git_ref = current_git_commit master_dir
    determine_gems(master_dir).each do |gem|
      build_gem_docs gem, "master", master_dir, gh_pages_dir
      ensure_gem_latest_dir gem
      ensure_gem_index_file gem
      commit_changes gh_pages_dir, "Build #{gem} documentation for commit #{git_ref}"
    end
  end

  def build_gem_docs gem, version, source_repo_dir, gh_pages_repo_dir
    # remove any existing docs before we build new docs
    safe_remove_dir(gh_pages_repo_dir + "docs" + gem + version)

    # specify markup and provider in case a gem is missing this
    markup = "--markup markdown --markup-provider redcarpet"

    output_dir = "#{gh_pages_repo_dir + "docs" + gem + version}"
    repo_metadata_path = "#{source_repo_dir + gem + '.repo-metadata.json'}"
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
    fields = data.to_a.map { |kv| "--#{kv[0]} #{kv[1]}"}

    Dir.chdir(source_repo_dir + gem) do
      cmds = ["-o #{output_dir}", markup]
      cmd "yard --verbose #{cmds.join ' '}"
      docs_dir = gh_pages_repo_dir + "docs"
    end
    fix_gem_docs gem, gh_pages_repo_dir
    Dir.chdir output_dir do
      cmd "python3 -m docuploader create-metadata #{fields.join ' '}"
    end
    push_changes output_dir
  end

  def publish_tag tag
    return if case_insensitive_check!

    gem, version = split_tag tag
    add_release gem, version
    build_docs_for_tag tag
    ensure_gem_latest_dir gem
    ensure_gem_index_file gem
    commit_changes gh_pages_dir, "Add #{gem} documentation for #{version} release"
  end

  def ensure_gem_index_file gem
  end

  def commit_changes repo, message
  end

  def push_changes dir
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
