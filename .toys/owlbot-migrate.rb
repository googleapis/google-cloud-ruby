desc "Migrate gems from autosynth to owlbot"

remaining_args :gem_names do
  desc "The gems for which to run owlbot-migrate."
end
flag :all do
  desc "Run owlbot-migrate on all gems in this repo."
end
flag :except, "--except=GEM", default: [], handler: :push
flag :pull do
  desc "Pull the latest images before running"
end
flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :commit_message, "--message=MESSAGE" do
  desc "The conventional commit message"
end
flag :branch_name, "--branch=NAME" do
  desc "The branch name"
end

OWLBOT_CONFIG_FILE_NAME = ".OwlBot.yaml"
SYNTH_CONFIG_FILE_NAME = "synth.py"
SYNTH_METADATA_FILE_NAME = "synth.metadata"

include :exec, e: true

def run
  require "erb"
  require "fileutils"
  require "pull_request_generator"
  extend PullRequestGenerator

  gems_and_paths = choose_gems
  logger.info "Gems: #{gems_and_paths.keys}"
  Dir.chdir context_directory

  default_commit_stuff gems_and_paths.keys
  result = generate_pull_request gem_name: nil,
                                 git_remote: git_remote,
                                 branch_name: branch_name,
                                 commit_message: commit_message do
    gems_and_paths.each_with_index do |(name, proto_base), index|
      logger.info "Editing #{name} (#{index}/#{gems_and_paths.size})"
      switch_files name, proto_base
    end
    logger.info "Running owlbot..."
    run_owlbot gems_and_paths.keys
  end
end

def choose_gems
  auto_gems = false
  gems = gem_names
  if gems.empty?
    if all
      gems = Dir.glob("*/#{SYNTH_CONFIG_FILE_NAME}", base: context_directory).map { |path| File.dirname path }
      gems -= except
      auto_gems = true
    else
      curwd = Dir.getwd
      error "You must specify at least one gem name" if context_directory == curwd
      error "unexpected current directory #{curwd}" unless curwd.start_with? context_directory
      gems = Array(curwd.sub("#{context_directory}/", "").split("/").first)
    end
  end
  gems_and_paths = {}
  gems.each do |name|
    unless File.file? File.join(context_directory, name, "#{name}.gemspec")
      next if auto_gems
      error "No gemspec found for #{name}"
    end
    content = File.read File.join(context_directory, name, SYNTH_CONFIG_FILE_NAME)
    unless content.include? "gapic = gcp.GAPICBazel()\n"
      next if auto_gems
      error "Synth script for #{name} doesn't seem to invoke bazel"
    end
    proto_path = proto_path_from_synth_content name, content
    unless proto_path
      next if auto_gems
      error "Unable to determine proto path for #{name}"
    end
    gems_and_paths[name] = proto_path
  end
  gems_and_paths
end

def proto_path_from_synth_content name, content
  match = %r{proto_path="([^"]+)/v\d\w*"}.match content
  return match[1] if match
  match = %r{gapic\.ruby_library\(\s*"([^"]+)",}.match content
  return "google/cloud/#{match[1]}" if match
  nil
end

def default_commit_stuff gems
  if branch_name.nil?
    timestamp = Time.now.utc.strftime "%Y%m%d-%H%H%S"
    set :branch_name, "pr/owlbot-migration-#{timestamp}"
  end
  if commit_message.nil?
    if gems.size == 1
      set :commit_message, "chore(#{gems.first}): Migrate from autosynth to owlbot"
    else
      set :commit_message, "chore: Migrate #{gems.size} gems from autosynth to owlbot"
    end
  end
end

def switch_files name, proto_base
  Dir.chdir name do
    b = OwlBotParams.new(name, proto_base)._binding
    template_path = find_data "owlbot-config-template.erb"
    template = File.read template_path
    erb = ERB.new template
    content = erb.result b
    File.open OWLBOT_CONFIG_FILE_NAME, "w" do |f|
      f.write content
    end
    FileUtils.rm SYNTH_CONFIG_FILE_NAME
    FileUtils.rm SYNTH_METADATA_FILE_NAME
  end
end

def run_owlbot names
  cmd = ["owlbot"]
  cmd << "--pull" if pull
  if verbosity < 0
    cmd << "-#{'q' * (-verbosity)}"
  elsif verbosity > 0
    cmd << "-#{'v' * verbosity}"
  end
  cmd.append names
  exec_tool cmd
end

def error str
  logger.error str
  exit 1
end

class OwlBotParams
  def initialize name, proto_base
    @gem_name = name
    @proto_path_base = proto_base
    @api_version = name.split("-").last
  end

  def _binding
    binding
  end
end
