desc "Runs OwlBot for one or more gems."

long_desc \
  "Runs OwlBot for one or more gems.",
  "",
  "Gems are chosen as follows:",
  "* If one or more gem names are provided on the command line, they are selected.",
  "* Otherwise, if the --all flag is given, all gems covered by OwlBot are selected.",
  "* Otherwise, if run from a gem subdirectory, that gem is selected.",
  "* Otherwise, an error is raised."

remaining_args :gem_names do
  desc "The gems for which to run owlbot."
end
flag :all do
  desc "Run owlbot on all gems in this repo."
end
flag :postprocessor_tag, "--postprocessor-tag=TAG", default: "latest" do
  desc "The tag for the Ruby postprocessor image. Defaults to 'latest'."
end
flag :owlbot_cli_tag, "--owlbot-cli-tag=TAG", default: "latest" do
  desc "The tag for the OwlBot CLI image. Defaults to 'latest'."
end
flag :pull do
  desc "Pull the latest images before running"
end
flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :commit_message, "--message=MESSAGE" do
  desc "The conventional commit message"
end
flag :source_repo, "--source-repo=PATH" do
  desc "Path to the googleapis-gen source repo"
end

OWLBOT_CONFIG_FILE_NAME = ".OwlBot.yaml"
OWLBOT_CLI_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-cli"
POSTPROCESSOR_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-ruby"
STAGING_DIR_NAME = "owl-bot-staging"
TMP_DIR_NAME = "tmp"

include :exec, e: true
include :terminal

def run
  require "psych"
  require "fileutils"
  require "pull_request_generator"
  extend PullRequestGenerator
  ensure_docker

  set :source_repo, File.expand_path(source_repo) if source_repo
  gems = choose_gems
  Dir.chdir context_directory
  sources = collect_sources gems

  pull_images
  run_owlbot sources
  verify_staging gems
  results = process_gems gems
  final_output results
end

def ensure_docker
  result = exec ["docker", "--version"], out: :capture, e: false
  error "Docker not installed" unless result.success?
  logger.info "Verified docker present"
end

def choose_gems
  gems = gem_names
  gems = all ? all_gems : gems_from_subdirectory if gems.empty?
  error "You must specify at least one gem name" if gems.empty?
  logger.info "Gems: #{gems}"
  gems
end

def gems_from_subdirectory
  curwd = Dir.getwd
  return [] if context_directory == curwd
  error "unexpected current directory #{curwd}" unless curwd.start_with? context_directory
  Array(curwd.sub("#{context_directory}/", "").split("/").first)
end

def all_gems
  Dir.chdir context_directory do
    gems = Dir.glob("*/#{OWLBOT_CONFIG_FILE_NAME}").map { |path| File.dirname path }
    gems.delete_if do |name|
      !File.file? File.join(context_directory, name, "#{name}.gemspec")
    end
    gems
  end
end

def pull_images
  return unless pull
  exec ["docker", "pull", "#{OWLBOT_CLI_IMAGE}:#{owlbot_cli_tag}"]
  exec ["docker", "pull", "#{POSTPROCESSOR_IMAGE}:#{owlbot_cli_tag}"]
end

def collect_sources gems
  sources = {}
  gems.each do |name|
    config_path = File.join name, OWLBOT_CONFIG_FILE_NAME
    error "Gem #{name} has no #{OWLBOT_CONFIG_FILE_NAME}" unless File.file? config_path
    config = Psych.load_file config_path
    deep_copy_regexes = config["deep-copy-regex"]
    error "Expected exactly one deep-copy-regex for gem #{name}" unless deep_copy_regexes.size == 1
    deep_copy_regex = deep_copy_regexes.first
    unless deep_copy_regex["dest"] == "/#{STAGING_DIR_NAME}/#{name}/$1"
      error "Wrong dest deep-copy-regex for gem #{name}"
    end
    error "Source missing in deep-copy-regex for gem #{name}" unless deep_copy_regex["source"]
    sources[name] = deep_copy_regex["source"]
  end
  sources
end

def run_owlbot sources
  FileUtils.mkdir_p TMP_DIR_NAME
  temp_config = File.join TMP_DIR_NAME, OWLBOT_CONFIG_FILE_NAME
  FileUtils.rm_f temp_config
  combined_deep_copy_regex = sources.map do |name, source|
    {
      "source" => source,
      "dest" => "/#{STAGING_DIR_NAME}/#{name}/$1"
    }
  end
  combined_config = {"deep-copy-regex" => combined_deep_copy_regex}
  File.open temp_config, "w" do |file|
    file.puts Psych.dump combined_config
  end
  cmd = ["#{OWLBOT_CLI_IMAGE}:#{owlbot_cli_tag}", "copy-code", "--config-file", temp_config]
  if source_repo
    cmd = ["-v", "#{source_repo}:/googleapis-gen"] + cmd + ["--source-repo", "/googleapis-gen"]
  end
  docker_run(*cmd)
end

def verify_staging gems
  gems.each do |name|
    staging_dir = File.join STAGING_DIR_NAME, name
    error "Gem #{name} did not output a staging directory" unless File.directory? staging_dir
    error "Gem #{name} staging directory is empty" if Dir.children(staging_dir).empty?
  end
end

def process_gems gems
  temp_staging_dir = File.join TMP_DIR_NAME, STAGING_DIR_NAME
  FileUtils.rm_rf temp_staging_dir
  FileUtils.mv STAGING_DIR_NAME, temp_staging_dir
  results = {}
  gems.each_with_index do |name, index|
    timestamp = Time.now.utc.strftime("%Y%m%d-%H%M%S")
    branch_name = "owlbot/#{name}-#{timestamp}"
    message = build_commit_message name
    result = generate_pull_request gem_name: name,
                                   git_remote: git_remote,
                                   branch_name: branch_name,
                                   commit_message: message do
      FileUtils.mkdir_p STAGING_DIR_NAME
      FileUtils.mv File.join(temp_staging_dir, name), File.join(STAGING_DIR_NAME, name)
      docker_run "#{POSTPROCESSOR_IMAGE}:#{owlbot_cli_tag}", "--gem", name
    end
    puts "Results for #{name} (#{index}/#{gems.size})..."
    results[name] = output_result name, result, :bold
  end
  results
end

def build_commit_message name
  if commit_message
    match = /^(\w+)(?:\([^)]+\))?(!?):(.*)/.match commit_message
    return "#{match[1]}(#{name})#{match[2]}:#{match[3]}" if match
  end
  "[CHANGE ME] OwlBot on-demand for #{name}"
end

def final_output results
  puts
  puts "Final results:", :bold
  results.each do |name, result|
    output_result name, result
  end
end

def output_result name, result, *style
  case result
  when :opened
    puts "#{name}: Created pull request", *style
  when :unchanged
    puts "#{name}: No pull request created because nothing changed", *style
  when :disabled
    puts "#{name}: Results left in the local directory", *style
  else
    puts "#{name}: Unknown result #{result.inspect}", *style
  end
  result
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
