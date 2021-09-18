desc "Run OwlBot on the given library"

optional_arg :gem_name do
  desc "The gem for which to run owlbot. Optional if run from within a gem subdirectory."
end
flag :postprocessor_tag, "--postprocessor-tag=TAG", default: "latest" do
  desc "The tag for the Ruby postprocessor image. Defaults to 'latest'."
end
flag :pull do
  desc "Pull the latest images before running"
end
flag :git_remote, "--remote NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :branch_name, "--branch NAME" do
  desc "The name of the branch to use if opening a pull request. Defaults to owlbot/GEM-NAME."
end

OWLBOT_CONFIG_FILE_NAME = ".OwlBot.yaml"

include :exec, e: true
include :terminal

def run
  require "pull_request_generator"
  extend PullRequestGenerator
  choose_gem
  set :branch_name, "owlbot/#{gem_name}" if branch_name.nil?
  Dir.chdir context_directory
  result = generate_pull_request gem_name: gem_name,
                                 git_remote: git_remote,
                                 branch_name: branch_name,
                                 commit_message: "[CHANGE ME] Manual run of OwlBot for #{gem_name}" do
    run_owlbot
  end
  case result
  when :opened
    puts "Created pull request", :bold
  when :unchanged
    puts "No pull request created because nothing changed", :bold
  when :disabled
    puts "Results left in the local directory", :bold
  end
end

def choose_gem
  curwd = Dir.getwd
  if context_directory == curwd
    error "gem name is required unless run from a gem directory" unless gem_name
  elsif !curwd.start_with? context_directory
    error "unexpected directory"
  elsif !gem_name
    diff = curwd.sub "#{context_directory}/", ""
    set :gem_name, diff.split("/").first
  end
  gem_dir = File.join context_directory, gem_name
  config_path = File.join gem_dir, OWLBOT_CONFIG_FILE_NAME
  error "no owlbot config #{config_path}" unless File.file? config_path
  gem_name
end

def run_owlbot
  owlbot_image = "gcr.io/cloud-devrel-public-resources/owlbot-cli:latest"
  postprocessor_image = "gcr.io/cloud-devrel-public-resources/owlbot-ruby:#{postprocessor_tag}"
  if pull
    exec ["docker", "pull", owlbot_image]
    exec ["docker", "pull", postprocessor_image]
  end
  docker_run owlbot_image, "copy-code", "--config-file", File.join(gem_name, OWLBOT_CONFIG_FILE_NAME)
  docker_run postprocessor_image
end

def docker_run *args
  cmd = [
    "docker", "run",
    "--rm",
    "--user", "#{Process.uid}:#{Process.gid}",
    "-v", "#{context_directory}:/repo",
    "-w", "/repo"
  ] + args
  exec cmd
end

def error str
  logger.error str
  exit 1
end
