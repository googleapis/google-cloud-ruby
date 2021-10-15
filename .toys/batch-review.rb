# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "json"
require "tempfile"

CONFIGS = {
  "gapics" => {
    title_regexp: /^\[CHANGE ME\] Re-generated [\w-]+-v\d\w* to pick up changes in the API or client/,
    message_type: :shared,
    detail_type: :none,
    omit_path: ["/synth\\.metadata$"]
  },
  "wrappers" => {
    title_regexp: /^\[CHANGE ME\] Re-generated (\w+-)*(v[a-z_]|[a-uw-z])\w* to pick up changes in the API or client/,
    message_type: :shared,
    detail_type: :none,
    omit_path: ["/synth\\.metadata$"]
  },
  "all" => {
    title_regexp: //,
    message_type: :pr_title,
    detail_type: :none,
    omit_path: ["/synth\\.metadata$"]
  },
  "releases-gapics" => {
    title_regexp: /^chore: release [\w-]+-v\d\w* \d+\.\d+\.\d+/,
    message_type: :pr_title_number,
    detail_type: :none,
  },
  "releases-wrappers" => {
    title_regexp: /^chore: release (\w+-)*(v[a-z_]|[a-uw-z])\w* \d+\.\d+\.\d+/,
    message_type: :pr_title_number,
    detail_type: :none,
  },
  "releases-all" => {
    title_regexp: /^chore: release [\w-]+ \d+\.\d+\.\d+/,
    message_type: :pr_title_number,
    detail_type: :none,
  },
  "obsolete-tracker" => {
    title_regexp: /^chore: start tracking obsolete files/,
    message_type: :pr_title_number,
    detail_type: :none,
    omit_path: ["/synth\\.metadata$"]
  },
}

REPO = "googleapis/google-cloud-ruby"
BOT_USERS = ["yoshi-code-bot", "yoshi-automation", "gcf-owl-bot[bot]"]

desc "Interactive mass code review"

optional_arg :config_name, accept: CONFIGS.keys, default: "all"

flag :title_regexp, accept: Regexp
flag :title_exact, accept: String
flag :message, accept: String, default: ""
flag :message_type, accept: [:shared, :pr_title, :pr_title_number]
flag :detail_type, accept: [:shared, :none]
flag :omit_path, accept: String, handler: :push
flag :omit_diff, accept: String, handler: :push
flag :max_line_count, accept: Integer
flag :editor, accept: String
flag :disable_edit
flag :enable_automerge
flag :dry_run

include :exec
include :terminal

def run
  ensure_prerequisites
  init_config
  find_prs.each do |pr_data|
    puts
    next if check_automerge pr_data
    display_default pr_data
    handle_input pr_data
  end
end

def ensure_prerequisites
  unless exec(["gh", "--version"]).success?
    puts "Could not find the GitHub CLI.", :bold, :red
    puts "See https://cli.github.com/manual/ for install instructions."
    exit 1
  end
  unless exec(["ydiff", "--version"]).success?
    puts "Could not find the ydiff command.", :bold, :red
    puts "See https://github.com/ymattw/ydiff/ for install instructions."
    exit 1
  end
end

def init_config
  CONFIGS[config_name].each { |k, v| set k, v if get(k).nil? }
  set :title_regexp, Regexp.new("^#{Regexp.quote title_exact}$") if title_exact
  @commit_message = message
  @commit_detail = ""
  @edit_enabled = !disable_edit
  @automerge_enabled = enable_automerge && !@edit_enabled
  @editor = editor || ENV["EDITOR"] || "/bin/nano"
  @max_line_count = max_line_count
  @omits = Array(omit_path).map do |path|
    regexp = path.is_a?(Regexp) ? path : Regexp.new(path.to_s)
    Omit.new "Any file path matching #{regexp}" do |file|
      regexp =~ file.path
    end
  end
  Array(omit_diff).each do |expr|
    handle_suppress(*expr.split)
  end
end

def find_prs
  paged_api("repos/#{REPO}/pulls")
    .find_all do |pr_resource|
      title_regexp =~ pr_resource["title"] &&
        pr_resource["labels"].all? { |label| label["name"] != "do not merge" } &&
        BOT_USERS.include?(pr_resource["user"]["login"])
    end
    .map { |pr_resource| PrData.new self, pr_resource }
end

def check_automerge pr_data
  return false unless @automerge_enabled
  return false unless pr_data.diff_files.all? { |file| @omits.any? { |omit| omit.call file } }
  display_pr_title pr_data
  puts "Automerging..."
  handle_merge pr_data
  true
end

def handle_input pr_data
  loop do
    puts
    display_pr_title pr_data
    cmd = ask "? ", :bold
    case cmd
    when "c"
      show_config
    when "h"
      show_help
    when "s"
      puts "... skipping this PR."
      return
    when "m"
      handle_merge pr_data
      return
    when "q"
      puts "... quitting."
      exit 0
    when /^e\s*([+-])$/
      handle_edit Regexp.last_match[1]
    when /^a\s*([+-])$/
      handle_automerge Regexp.last_match[1]
    when /^d\s*(\S+)$/
      handle_display Regexp.last_match[1], pr_data
    when /^o\s*(\S(?:.*\S)?)$/
      handle_omit(*Regexp.last_match[1].split)
    when /^s\s*(\S(?:.*\S)?)$/
      handle_suppress(*Regexp.last_match[1].split)
      puts "... added omit based on content regex"
    else
      puts "Unknown command.", :red, :bold
      show_help
    end
  end
end

def handle_merge pr_data
  get_commit_message pr_data
  get_commit_detail pr_data if detail_type
  do_approve pr_data
  do_merge pr_data
end

def handle_edit arg
  case arg
  when "+"
    if @automerge_enabled
      puts "Automerge must be disabled to enable edit"
    else
      @edit_enabled = true
      puts "... enabling editing"
    end
  when "-"
    @edit_enabled = false
    puts "... disabling editing"
  end
end

def handle_automerge arg
  case arg
  when "+"
    if @edit_enabled
      puts "Edit must be disabled to enable automerge"
    else
      @automerge_enabled = true
      puts "... enabling automerge"
    end
  when "-"
    @automerge_enabled = false
    puts "... disabling automerge"
  end
end

def handle_display arg, pr_data
  case arg
  when "a"
    display_all_diffs pr_data
  when "A"
    display_all_diffs pr_data, force_all: true
  when "f"
    display_filenames pr_data
  when /^\d+$/
    display_file arg.to_i
  else
    puts "Don't know how to display: #{arg.inspect}", :red, :bold
  end
end

def handle_omit arg, *extra_args
  case arg
  when /^x/
    @omits = []
    puts "... cleared omits"
  when /^p/
    extra_args.each do |exp|
      regexp = Regexp.new exp
      omit = Omit.new "Any file path matching #{regexp}" do |file|
        regexp =~ file.path
      end
      @omits << omit
      puts "... added omit for all file paths: #{regexp}"
    end
  when /^c/
    extra_args.each do |exp|
      regexp = Regexp.new exp
      omit = Omit.new "Any changed file path matching #{regexp}" do |file|
        file.type == "C" && regexp =~ file.path
      end
      @omits << omit
      puts "... added omit for changed file paths: #{regexp}"
    end
  when /^a/
    extra_args.each do |exp|
      regexp = Regexp.new exp
      omit = Omit.new "Any added file path matching #{regexp}" do |file|
        file.type == "A" && regexp =~ file.path
      end
      @omits << omit
      puts "... added omit for added file paths: #{regexp}"
    end
  when /^d/
    extra_args.each do |exp|
      regexp = Regexp.new exp
      omit = Omit.new "Any deleted file path matching #{regexp}" do |file|
        file.type == "D" && regexp =~ file.path
      end
      @omits << omit
      puts "... added omit for deleted file paths: #{regexp}"
    end
  when /^i/
    omit = Omit.new "All changes affect indentation only" do |file|
      file.only_indentation
    end
    @omits << omit
    puts "... added omit for indentation-only diffs"
  else
    puts "Unknown omit arg: #{arg.inspect}", :red, :bold
  end
end

def handle_suppress *args
  adds = []
  removes = []
  args.each do |arg|
    if arg =~ /^-(.+)$/
      removes << Regexp.new(Regexp.last_match[1])
    elsif arg =~ /^\+(.+)$/
      adds << Regexp.new(Regexp.last_match[1])
    end
  end
  omit = Omit.new "All changes match given regexes" do |file|
    adds.all? do |regex|
      file.reduce_hunks true do |val, hunk|
        val && hunk.all? do |line|
          !line.start_with?("+") || regex.match?(line[1..-1])
        end
      end
    end && removes.all? do |regex|
      file.reduce_hunks true do |val, hunk|
        val && hunk.all? do |line|
          !line.start_with?("-") || regex.match?(line[1..-1])
        end
      end
    end
  end
  @omits << omit
end

def show_help
end

def show_config
end

def display_default pr_data
  if @max_line_count && pr_data.diff_line_count > @max_line_count
    display_filenames pr_data
  else
    display_all_diffs pr_data
  end
end

def display_pr_title pr_data
  write "##{pr_data.id}", :bold, :yellow
  write " "
  puts pr_data.title, :bold
end

def display_filenames pr_data
  pr_data.diff_files.each_with_index do |file, index|
    write "%3d " % index
    write file.type, :bold, :yellow
    write " "
    puts file.path
  end
end

def display_all_diffs pr_data, force_all: false
  files = pr_data.diff_files
  unless force_all
    disp_files, omit_files = files.partition { |file| !@omits.any? { |omit| omit.call file } }
  end
  omit_files.each do |file|
    puts "Omitting display of #{file.path}"
  end
  diff_text = disp_files.map(&:text).join
  return if diff_text.empty?
  exec ["ydiff", "--width=0", "-s", "--wrap"],
       in: [:string, diff_text]
end

def display_file pr_data, index
  diff_text = pr_data.diff_files[index].text
  return if diff_text.empty?
  exec ["ydiff", "--width=0", "-s", "--wrap"],
       in: [:string, diff_text]
end

def get_commit_message pr_data
  @commit_message =
    case message_type
    when :shared
      @commit_message
    when :pr_title
      pr_data.title
    when :pr_title_number
      "#{pr_data.title} (##{pr_data.id})"
    else
      ""
    end
  @commit_message = ask("Message: ", default: @commit_message) if @edit_enabled
end

def get_commit_detail pr_data
  return unless @edit_enabled
  case detail_type
  when :shared
    file = Tempfile.new("commit-default")
    begin
      file.write @commit_detail
      file.rewind
      exec [@editor, file.path]
      @commit_detail = file.read.strip
    ensure
      file.close
      file.unlink
    end
  else
    @commit_detail = ""
  end
end

def do_approve pr_data
  puts "... approving PR #{pr_data.id}..."
  if dry_run
    puts "(dry run)"
  else
    retry_gh ["repos/#{REPO}/pulls/#{pr_data.id}/reviews",
              "--field", "event=APPROVE",
              "--field", "body=Approved using toys batch-review"]
  end
  puts "... approved."
end

def do_merge pr_data
  message = pr_data.custom_message @commit_message
  puts "... merging PR #{pr_data.id}..."
  if dry_run
    puts "message: #{message}", :bold
    puts "details: #{@commit_detail}", :bold unless @commit_detail.empty?
    sleep 1
  else
    retry_gh ["-XPUT", "repos/#{REPO}/pulls/#{pr_data.id}/merge",
              "--field", "merge_method=squash",
              "--field", "commit_title=#{message}",
              "--field", "commit_message=#{@commit_detail}"]
  end
  puts "... merged."
end

def retry_gh args, tries: 3
  tries.times do |num|
    result = exec ["gh", "api"] + args
    return if result.success?
    break unless result.error?
    puts "waiting to retry..."
    sleep 2 * (num + 1)
  end
  puts "Repeatedly failed to call gh", :red, :bold
  exit 1
end

def api path, *args
  JSON.parse capture(["gh", "api", path, *args], e: true)
end

def paged_api path
  results = []
  page = 1
  loop do
    results_page = api "#{path}?per_page=80&page=#{page}"
    return results if results_page.empty?
    results.concat results_page
    page += 1
  end
end

def error *messages
  messages.each { |msg| STDERR.puts msg }
  exit 1
end

class DiffFile
  def initialize text
    @text = text
    @lines = text.split "\n"
    @path =
      if @lines.first =~ %r{^diff --git a/(\S+) b/\S+$}
        Regexp.last_match[1]
      else
        ""
      end
    @type =
      case @lines[1].to_s
      when /^new file/
        "N"
      when /^deleted file/
        "D"
      else
        "C"
      end
    initial_analysis
  end

  attr_reader :text
  attr_reader :path
  attr_reader :type
  attr_reader :only_indentation

  def reduce_hunks value
    analyze_changes do |hunk|
      value = yield value, hunk
    end
    value
  end

  private

  def initial_analysis
    @only_indentation = true
    @common_directory = nil
    analyze_changes do |hunk|
      analyze_only_indentation hunk
    end
  end

  def analyze_changes
    hunk = nil
    from_path = to_path = nil
    @lines.each do |line|
      if line.start_with? "@@"
        yield hunk if hunk && !hunk.empty?
        hunk = []
      elsif hunk
        hunk << line
      end
    end
    yield hunk if hunk && !hunk.empty?
  end

  def analyze_only_indentation hunk
    return unless @only_indentation
    minuses = [""]
    pos = 1
    @only_indentation = false
    catch :fail do
      hunk.each do |line|
        if line.start_with? "-"
          if pos == minuses.length
            minuses = [line]
            pos = 0
          elsif pos == 0
            minuses << line
          else
            throw :fail
          end
        elsif line.start_with? "+"
          throw :fail unless pos < minuses.length && minuses[pos].sub(/^-\s*/, "") == line.sub(/^\+\s*/, "")
          pos += 1
        elsif line.start_with? " "
          throw :fail unless pos == minuses.length
        else
          throw :fail
        end
      end
      @only_indentation = true
    end
  end
end

class Omit
  def initialize desc, &block
    raise "Block required" unless block
    @desc = desc
    @block = block
  end

  attr_reader :desc

  def call pr_file
    @block.call pr_file
  end
end

class PrData
  def initialize context, pr_resource
    @context = context
    @id = pr_resource["number"]
    @title = pr_resource["title"]
  end

  attr_reader :id
  attr_reader :title

  def raw_diff_data
    @raw_diff_data ||= @context.capture(["curl", "-s", "https://patch-diff.githubusercontent.com/raw/#{REPO}/pull/#{id}.diff"], e: true)
  end

  def diff_files
    @diff_files ||= begin
      "\n#{raw_diff_data.chomp}"
        .split("\ndiff --git ")
        .slice(1..-1)
        .map{ |text| DiffFile.new("diff --git #{text}\n") }
    end
  end

  def diff_line_count
    @diff_line_count ||= raw_diff_data.count("\n")
  end

  def lib_name
    unless defined? @lib_name
      @lib_name =
        case title
        when /^\[CHANGE ME\] Re-generated google-cloud-([\w-]+) to pick up changes in the API or client/
          Regexp.last_match[1]
        when /^\[CHANGE ME\] Re-generated ([\w-]+) to pick up changes in the API or client/
          Regexp.last_match[1]
        else
          interpret_lib_name
        end
    end
    @lib_name
  end

  def custom_message message
    if lib_name && message =~ /^(\w+):\s+(\S.*)$/
      "#{$1}(#{lib_name}): #{$2}"
    else
      message
    end
  end

  private

  def interpret_lib_name
    name = nil
    diff_files.each do |diff_file|
      if %r{^([^/]+)/} =~ diff_file.path
        possible_name = Regexp.last_match[1]
        if name.nil?
          name = possible_name
        elsif name != possible_name
          return nil
        end
      else
        return nil
      end
    end
    name
  end
end
