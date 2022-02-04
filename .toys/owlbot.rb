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
flag :source_path, "--source-path=PATH" do
  desc "Path to the googleapis-gen source repo"
end
flag :protos_path, "--protos-path=PATH" do
  desc "Path to the googleapis protos repo or third_party directory"
end
flag :piper_client, "--piper-client=NAME" do
  desc "Generate by running Bazel from the given piper client rather than using googleapis-gen"
end
flag :combined_prs do
  desc "Combine all changes into a single pull request"
end
flag :enable_tests, "--test" do
  desc "Run CI on each library"
end
flag :googleapis_gen_github_token, "--googleapis-gen-github-token=TOKEN" do
  default(ENV["GOOGLEAPIS_GEN_GITHUB_TOKEN"] || ENV["GITHUB_TOKEN"])
  desc "GitHub token for cloning the googleapis-gen repository"
end

OWLBOT_CONFIG_FILE_NAME = ".OwlBot.yaml"
OWLBOT_CLI_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-cli"
POSTPROCESSOR_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-ruby"
STAGING_DIR_NAME = "owl-bot-staging"
TMP_DIR_NAME = "tmp"

include :exec, e: true
include :terminal
include :fileutils

def run
  require "psych"
  require "fileutils"
  require "tmpdir"
  require "pull_request_generator"
  extend PullRequestGenerator
  ensure_docker

  set :source_path, File.expand_path(source_path) if source_path
  ensure_source_path
  gems = choose_gems
  Dir.chdir context_directory
  gem_info = collect_gem_info gems

  pull_images
  run_bazel gem_info if piper_client || protos_path
  run_owlbot gem_info
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
  exec ["docker", "pull", "#{POSTPROCESSOR_IMAGE}:#{postprocessor_tag}"]
end

def collect_gem_info gems
  gem_info = {}
  gems.each do |name|
    deep_copy_regexes = load_deep_copy_regexes name
    gem_info[name] = { deep_copy_regexes: deep_copy_regexes }
    next unless piper_client || protos_path
    library_paths = deep_copy_regexes.map { |dcr| extract_library_path dcr["source"] }.uniq
    bazel_targets = {}
    library_paths.each do |library_path|
      bazel_targets[library_path] = determine_bazel_target library_path
    end
    gem_info[name][:bazel_targets] = bazel_targets
  end
  gem_info
end

def load_deep_copy_regexes name
  config_path = File.join name, OWLBOT_CONFIG_FILE_NAME
  error "Gem #{name} has no #{OWLBOT_CONFIG_FILE_NAME}" unless File.file? config_path
  config = Psych.load_file config_path
  config["deep-copy-regex"]
end

def extract_library_path source_regex
  separator = "/[^/]+-ruby/"
  error "Unexpected source: #{source_regex}" unless source_regex.include? separator
  source_regex.split(separator).first.sub(%r{^/}, "")
end

def determine_bazel_target library_path
  build_file_path = File.join bazel_base_dir, library_path, "BUILD.bazel"
  error "Unable to find #{build_file_path}" unless File.file? build_file_path
  build_content = File.read build_file_path
  match = /ruby_gapic_assembly_pkg\(\n\s+name\s*=\s*"([\w-]+-ruby)",/.match build_content
  error "Unable to find ruby build rule in #{build_file_path}" unless match
  match[1]
end

def run_bazel gem_info
  gem_info.each do |name, info|
    info[:bazel_targets].each do |library_path, bazel_target|
      exec ["bazel", "build", "//#{library_path}:#{bazel_target}"], chdir: bazel_base_dir
      generated_dir = File.join bazel_base_dir, "bazel-bin", library_path, bazel_target
      source_dir = File.join source_path, library_path, bazel_target
      rm_rf source_dir
      mkdir_p File.dirname source_dir
      cp_r generated_dir, source_dir
    end
  end
end

def ensure_source_path
  return if source_path
  temp_dir = Dir.mktmpdir
  at_exit { FileUtils.rm_rf temp_dir }
  Dir.chdir temp_dir do
    exec ["git", "init"]
    if ensure_googleapis_gen_github_token
      hostname = "#{ensure_googleapis_gen_github_token}@github.com"
      log_hostname = "xxxxxxxx@github.com"
    else
      hostname = log_hostname = "github.com"
    end
    add_origin_cmd = ["git", "remote", "add", "origin", "https://#{hostname}/googleapis/googleapis-gen.git"]
    add_origin_log = ["git", "remote", "add", "origin", "https://#{log_hostname}/googleapis/googleapis-gen.git"]
    exec add_origin_cmd, log_cmd: add_origin_log.inspect
    exec ["git", "fetch", "--depth=1", "origin", "HEAD"]
    exec ["git", "branch", "github-head", "FETCH_HEAD"]
    exec ["git", "switch", "github-head"]
  end
  set :source_path, temp_dir
end

def environment_github_token
  @environment_github_token ||= begin
    result = exec ["gh", "auth", "status", "-t"], e: false, out: :capture, err: [:child, :out]
    if result.success? && result.captured_out =~ /Token: (\w+)/
      puts "**** found token of size #{Regexp.last_match[1].size}"
      Regexp.last_match[1]
    end
  end
end

def ensure_googleapis_gen_github_token
  @googleapis_gen_github_token ||= googleapis_gen_github_token || environment_github_token
end

def run_owlbot gem_info
  FileUtils.mkdir_p TMP_DIR_NAME
  temp_config = File.join TMP_DIR_NAME, OWLBOT_CONFIG_FILE_NAME
  FileUtils.rm_f temp_config
  combined_deep_copy_regex = gem_info.values.map { |info| info[:deep_copy_regexes] }.flatten
  combined_config = {"deep-copy-regex" => combined_deep_copy_regex}
  File.open temp_config, "w" do |file|
    file.puts Psych.dump combined_config
  end
  cmd = [
    "-v", "#{source_path}:/googleapis-gen",
    "#{OWLBOT_CLI_IMAGE}:#{owlbot_cli_tag}", "copy-code",
    "--config-file", temp_config,
    "--source-repo", "/googleapis-gen"
  ]
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
  if combined_prs
    process_gems_combined_pr gems, temp_staging_dir
  else
    process_gems_separate_prs gems, temp_staging_dir
  end
end

def process_gems_separate_prs gems, temp_staging_dir
  results = {}
  gems.each_with_index do |name, index|
    timestamp = Time.now.utc.strftime("%Y%m%d-%H%M%S")
    branch_name = "owlbot/#{name}-#{timestamp}"
    message = build_commit_message name
    result = generate_pull_request gem_name: name,
                                   git_remote: git_remote,
                                   branch_name: branch_name,
                                   commit_message: message do
      process_single_gem name, temp_staging_dir
    end
    puts "Results for #{name} (#{index}/#{gems.size})..."
    results[name] = output_result name, result, :bold
  end
  results
end

def process_gems_combined_pr gems, temp_staging_dir
  timestamp = Time.now.utc.strftime("%Y%m%d-%H%M%S")
  branch_name = "owlbot/all-#{timestamp}"
  message = build_commit_message "all gems"
  result = generate_pull_request git_remote: git_remote,
                                 branch_name: branch_name,
                                 commit_message: message do
    gems.each_with_index do |name, index|
      process_single_gem name, temp_staging_dir
      puts "Completed #{name} (#{index}/#{gems.size})..."
    end
  end
  output_result "all gems", result, :bold
end

def build_commit_message name
  if commit_message
    match = /^(\w+)(?:\([^)]+\))?(!?):(.*)/.match commit_message
    return "#{match[1]}(#{name})#{match[2]}:#{match[3]}" if match
  end
  "[CHANGE ME] OwlBot on-demand for #{name}"
end

def process_single_gem name, temp_staging_dir
  FileUtils.mkdir_p STAGING_DIR_NAME
  FileUtils.mv File.join(temp_staging_dir, name), File.join(STAGING_DIR_NAME, name)
  docker_run "#{POSTPROCESSOR_IMAGE}:#{postprocessor_tag}", "--gem", name
  if enable_tests
    Dir.chdir name do
      exec ["bundle", "install"]
      exec ["bundle", "exec", "rake", "ci"]
    end
  end
end

def final_output results
  puts
  puts "Final results:", :bold
  if results.is_a? Hash
    results.each do |name, result|
      output_result name, result
    end
  else
    output_result "all gems", results
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

def bazel_base_dir
  @bazel_base_dir ||=
    if piper_client
      piper_client_dir = capture(["p4", "g4d", piper_client]).strip
      File.join piper_client_dir, "third_party", "googleapis", "stable"
    elsif protos_path
      File.expand_path protos_path
    else
      error "No protos directory"
    end
end

def error str
  logger.error str
  exit 1
end
