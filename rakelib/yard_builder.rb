require "tmpdir"
require "fileutils"
require "erb"
require "ostruct"

class YardBuilder
  attr_reader :master_dir

  def initialize master_dir = "."
    @master_dir = Pathname.new master_dir
  end

  def build_master
    git_ref = current_git_commit master_dir
    determine_gems(master_dir).each do |gem|
      build_gem_docs gem, "master", master_dir, gh_pages_dir
      ensure_gem_latest_dir gem
      ensure_gem_index_file gem
      commit_changes gh_pages_dir, "Build #{gem} documentation for commit #{git_ref}"
    end
    push_changes gh_pages_dir
  end

  def publish_tag tag
    gem, version = split_tag tag
    add_release gem, version
    build_docs_for_tag tag
    ensure_gem_latest_dir gem
    ensure_gem_index_file gem
    commit_changes gh_pages_dir, "Add #{gem} documentation for #{version} release"
    push_changes gh_pages_dir
  end

  def rebuild_tag *tags
    tags.flatten.each do |tag|
      gem, version = split_tag tag
      build_docs_for_tag tag
      ensure_gem_latest_dir gem
      ensure_gem_index_file gem
      commit_changes gh_pages_dir, "Rebuild #{gem} documentation for #{version} version"
    end
    push_changes gh_pages_dir
  end

  def rebuild_all
    git_ref = current_git_commit master_dir
    load_releases.each do |gem, versions|
      versions.each do |version|
        tag = "#{gem}/#{version}"
        build_docs_for_tag tag
      end
      build_gem_docs gem, "master", master_dir, gh_pages_dir
      ensure_gem_latest_dir gem
      ensure_gem_index_file gem
      commit_changes gh_pages_dir, "Rebuild all #{gem} documentation (all tags and master)"
    end
    push_changes gh_pages_dir
  end

  protected

  def cmd line
    puts line
    output = `#{line}`
    puts output
    output
  end

  def build_docs_for_tag tag
    gem, version = split_tag tag
    checkout_branch tag do |tag_repo|
      build_gem_docs gem, version, tag_repo, gh_pages_dir
    end
  end

  def gh_pages_dir
    # memoize this so all commits happen on the same checkout
    @gh_pages_dir ||= begin
      dir = create_tmp_dir "gh-pages"
      clone_branch "gh-pages", dir
      dir
    end
  end

  def checkout_branch tag
    dir = create_tmp_dir tag
    clone_branch tag, dir
    yield dir
    safe_remove_dir dir
    nil
  end

  def ensure_gem_latest_dir gem
    current_version = latest_release gem

    Dir.chdir gh_pages_dir + "docs" + gem do
      FileUtils.remove_file "latest" if File.symlink? "latest"
      File.symlink "./#{current_version}", "latest"
    end
  end

  def ensure_gem_index_file gem
    template_path = gh_pages_dir + "_yard_templates" + "index.html.erb"
    index_path = gh_pages_dir + "docs" + gem + "index.html"

    template_contents = File.read template_path, mode: "r"
    erb = ERB.new template_contents
    erb_binding = OpenStruct.new(gem: gem).instance_eval { binding }
    index_contents = erb.result erb_binding

    FileUtils.remove_file index_path if File.exists? index_path
    File.write index_path, index_contents, mode: "w"
  end

  def latest_release gem
    # versions should always be sorted most recent first
    # if there is no release use master
    return "master" if !load_releases.key? gem

    load_releases[gem].first || "master"
  end

  def add_release gem, version
    data = load_releases
    data[gem] ||= []
    data[gem] << version
    store_releases data
  end

  def releases_file
    gh_pages_dir + "_data" + "releases.yaml"
  end

  def load_releases
    require "yaml"
    YAML.load_file releases_file
  end

  def store_releases data
    require "yaml"
    sorted_data_pairs = data.each.sort.map do |gem, versions|
      # Sort in descending order
      versions.uniq!.sort! do |a, b|
        Gem::Version.new(b.sub(/^v/,"")) <=> Gem::Version.new(a.sub(/^v/,""))
      end
      [gem, versions]
    end
    File.write releases_file, YAML.dump(Hash[sorted_data_pairs])
  end

  def current_git_commit path = "."
    Dir.chdir path do
      cmd "git rev-parse --short HEAD"
    end
  end

  def determine_gems path = "."
    Dir.chdir path do
      raw_gems = cmd "git ls-files -- */*.gemspec"
      raw_gems.split("\n").map { |gem| gem.split("/").first }.sort
    end
  end

  def split_tag tag
    fail "'tag' must be in the format <gem>/<version> Actual: #{tag}" unless tag.include?("/")
    parts = tag.split("/")
    fail "'tag' must be in the format <gem>/<version>. Actual: #{tag}" unless parts.length == 2
    parts
  end

  def build_gem_docs gem, version, source_repo_dir, gh_pages_repo_dir
    # remove any existing docs before we build new docs
    safe_remove_dir(gh_pages_repo_dir + "docs" + gem + version)

    # specify markup and provider in case a gem is missing this
    markup = "--markup markdown --markup-provider redcarpet"
    # specify the template path to get all customizations
    template = "--template default --template-path #{gh_pages_repo_dir + "_yard_templates"}"
    # # specify the .yardopts file
    # yardopts = "--yardopts #{source_repo_dir + gem + ".yardopts"}"
    # readme = "--readme #{source_repo_dir + gem + "README.md"}"
    output_dir = "-o #{gh_pages_repo_dir + "docs" + gem + version}"
    target_dir = "#{source_repo_dir + gem + "lib" + "**" + "*.rb"}"
    # command_opts = [output_dir, markup, template, yardopts, readme, target_dir]

    puts "cd #{source_repo_dir + gem}"
    Dir.chdir(source_repo_dir + gem) do
      cmds = [output_dir, markup, template]
      cmd "yard --verbose #{cmds.join " "}"

      # Manually move js and css assets.
      # I'm sure there is an asset API to do this,
      # but I can't figure it out and YARD makes no sense to me.
      docs_dir = gh_pages_repo_dir + "docs"

      FileUtils.remove_dir(docs_dir + "css") if Dir.exists?(docs_dir + "css")
      FileUtils.remove_dir(docs_dir + "js") if Dir.exists?(docs_dir + "js")

      FileUtils.mv(docs_dir + gem + version + "css", docs_dir)
      FileUtils.mv(docs_dir + gem + version + "js", docs_dir)
    end
    fix_gem_docs gem, gh_pages_repo_dir
  end

  def fix_gem_docs gem, gh_pages_repo_dir
    if gem == "google-cloud-trace"
      puts "cd #{gh_pages_repo_dir + "docs" + gem} [google-cloud-trace fixes]"
      Dir.chdir(gh_pages_repo_dir + "docs" + gem) do
        Dir.glob(File.join("**","*.html")).each do |file_path|
          file_contents = File.read file_path
          file_contents.gsub! "dynamic print site_values.console_name %",
                              "Google Cloud Platform Console"
          file_contents.gsub! "{% dynamic print site_values.console_name %}",
                              "Google Cloud Platform Console"
          File.write file_path, file_contents
        end
      end
    end
  end

  def create_tmp_dir dir_name
    tmp_dir = ENV["GCLOUD_TMP_DIR"] || Dir.tmpdir
    dir = Pathname.new(tmp_dir) + dir_name

    safe_remove_dir dir
    FileUtils.mkdir_p dir

    dir
  end

  def safe_remove_dir dir
    FileUtils.remove_dir dir if Dir.exists? dir
  end

  def clone_branch branch, dir
    # Creates a shallow clone
    puts "cloning #{branch} to #{dir}"
    `git clone --quiet --branch=#{branch} --depth=1 --single-branch #{git_repository} #{dir} > /dev/null`
  end

  def git_repository
    if ENV["GH_OAUTH_TOKEN"]
      # This will allow commits to be made with authentication, for CI
      "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
    else
      # default repo, uses local auth, for developers
      "git@github.com:GoogleCloudPlatform/google-cloud-ruby.git"
    end
  end

  def commit_changes repo, message
    Dir.chdir repo do
      puts `git add -A .`
      unless `git status --porcelain`.chomp.empty?
        if ENV["GH_OAUTH_TOKEN"]
          `git config --global user.email "google-cloud+ruby@google.com"`
          `git config --global user.name "google-cloud-ruby"`
        end
        cmd "git commit -m '#{message}'"
      end
    end

    def push_changes repo
      Dir.chdir repo do
        if ENV["GH_OAUTH_TOKEN"]
          `git pull -q --rebase #{git_repository} gh-pages`
          `git push -q #{git_repository} gh-pages`
        else
          `git pull -q --rebase origin gh-pages`
          `git push -q origin gh-pages`
        end
      end
    end
  end
end
