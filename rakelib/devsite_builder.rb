require_relative "repo_metadata.rb"
require_relative "gem_version_doc.rb"
require_relative "repo_metadata.rb"

class DevsiteBuilder < YardBuilder
  def initialize master_dir = "."
    @master_dir = Pathname.new master_dir
    collect_metadata
  end

  def build_master
    return if case_insensitive_check!

    git_ref = current_git_commit master_dir
    determine_gems(master_dir).each do |gem|
      input_dir = "#{master_dir + gem}"
      output_dir = "#{gh_pages_dir + 'docs' + gem + 'master'}"
      build_gem_docs input_dir, output_dir
      puts "Built #{gem} documentation for commit #{git_ref}"
    end
  end

  def build_gem_docs input_dir, output_dir, gem = nil, version = "master"
    gem ||= File.basename input_dir
    gem_metadata = @metadata[gem]
    gem_metadata["version"] = version
    docs = GemVersionDoc.new input_dir, output_dir, gem_metadata
    docs.build
    docs
  end

  def publish_tag tag
    return if case_insensitive_check!

    gem, version = split_tag tag
    add_release gem, version
    publish_docs_for_tag tag
    puts "Added #{gem} documentation for #{version} release"
  end

  def rebuild_tag *tags
    return if case_insensitive_check!

    tags.flatten.each do |tag|
      gem, version = split_tag tag
      publish_docs_for_tag tag
      puts "Rebuilt #{gem} documentation for #{version} version"
    end
  end

  def republish_all
    return if case_insensitive_check!

    current_git_commit master_dir
    load_releases.each do |gem, versions|
      versions.each do |version|
        publish_docs_for_tag "#{gem}/#{version}"
      end
      puts "Republished all #{gem} documentation (all tags)"
    end
  end

  private

  def publish_docs_for_tag tag
    gem, version = split_tag tag
    checkout_branch tag do |tag_repo|
      input_dir = "#{tag_repo + gem}"
      output_dir = "#{gh_pages_dir + 'docs' + gem + version}"
      docs = build_gem_docs input_dir, output_dir, gem, version
      docs.upload
    end
  end

  def collect_metadata
    @metadata = {}
    determine_gems.each do |gem|
      source = "#{master_dir + gem}/.repo-metadata.json"
      @metadata[gem] = RepoMetadata.from_source source
    end
  end
end
