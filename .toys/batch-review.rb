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
  gapics: {
    title_regexp: /^\[CHANGE ME\] Re-generated [\w-]+-v\d+\w* to pick up changes in the API or client/,
    message_type: :shared,
    detail_type: :none,
    omit_paths: ["/synth\\.metadata$"]
  },
  wrappers: {
    title_regexp: /^\[CHANGE ME\] Re-generated (\w+-)*(v[a-z_]|[a-uw-z])\w* to pick up changes in the API or client/,
    message_type: :shared,
    detail_type: :none,
    omit_paths: ["/synth\\.metadata$"]
  },
  releases: {
    title_regexp: /^chore: release [\w-]+ \d+\.\d+\.\d+/,
    message_type: :pr_title_number,
    detail_type: :none,
    omit_paths: ["/synth\\.metadata$"]
  },
  all: {
    title_regexp: //,
    message_type: :pr_title,
    detail_type: :none,
    omit_paths: ["/synth\\.metadata$"]
  }
}

REPO = "googleapis/google-cloud-ruby"

desc "Interactive mass code review"

required_arg :config_name do
  accept [:gapics, :wrappers, :releases, :all]
  desc "The config that determines which PRs to review. Values: gapics, wrappers, releases"
end

flag :title_regexp, accept: Regexp
flag :message_type, accept: [:shared, :pr_title, :pr_title_number]
flag :detail_type, accept: [:shared, :none]
flag :omit_paths, accept: Array
flag :max_line_count, accept: Integer
flag :editor, accept: String
flag :dry_run

include :exec
include :terminal

def run
  ensure_prerequisites
  init_config
  find_prs.each do |pr_data|
    puts
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
  config = CONFIGS[config_name]
  config.each { |k, v| set k, v if get(k).nil? }
  @commit_message = ""
  @commit_detail = ""
  @edit_enabled = true
  @editor = editor || ENV["EDITOR"] || "/bin/nano"
  @max_line_count = max_line_count
  @omit_paths = omit_paths.map do |path|
    path.is_a?(Regexp) ? path : Regexp.new(path.to_s)
  end
end

def find_prs
  paged_api("repos/#{REPO}/pulls")
    .find_all do |pr_resource|
      title_regexp =~ pr_resource["title"] &&
        pr_resource["labels"].all? { |label| label["name"] != "do not merge" }  
    end
    .map { |pr_resource| PrData.new self, pr_resource }
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
      get_commit_message pr_data
      get_commit_detail pr_data if detail_type
      do_approve pr_data
      do_merge pr_data
      return
    when "q"
      puts "... quitting."
      exit 0
    when /^e\s*\+$/
      @edit_enabled = true
      puts "... enabling editing"
    when /^e\s*-$/
      @edit_enabled = false
      puts "... disabling editing"
    when /^d\s*a$/
      display_all_diffs pr_data
    when /^d\s*f$/
      display_filenames pr_data
    when /^d\s*(\d+)$/
      display_file Regexp.last_match[1].to_i
    when /^o\s*-$/
      puts "... cleared omit paths"
      @omit_paths = []
    when /^o\s*(\S+)$/
      regexp = Regexp.new Regexp.last_match[1]
      @omit_paths << regexp
      puts "... added omit path: #{regexp}"
    else
      puts "Unknown command.", :red, :bold
      show_help
    end
  end
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

def display_all_diffs pr_data
  diff_text = pr_data.diff_files
    .find_all { |file| !@omit_paths.any? { |omit| omit =~ file.path } }
    .map(&:text)
    .join
  exec ["ydiff", "--width=0", "-s", "--wrap"],
       in: [:string, diff_text],
       e: true
end

def display_file pr_data, index
  file = pr_data.diff_files[index]
  exec ["ydiff", "--width=0", "-s", "--wrap"],
       in: [:string, file.text],
       e: true
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
    exec ["gh", "api", "repos/#{REPO}/pulls/#{pr_data.id}/reviews",
          "--field", "event=APPROVE",
          "--field", "body=Approved using toys batch-review"],
         e: true
  end
  puts "... approved."
end

def do_merge pr_data
  message = pr_data.custom_message @commit_message
  puts "... merging PR #{pr_data.id}..."
  if dry_run
    puts "(message: #{message})", :bold
    puts "(details: #{@commit_detail})", :bold unless @commit_detail.empty?
  else
    exec ["gh", "api", "-XPUT", "repos/#{REPO}/pulls/#{pr_data.id}/merge",
          "--field", "merge_method=squash",
          "--field", "commit_title=#{message}",
          "--field", "commit_message=#{@commit_detail}"],
         e: true
  end
  puts "... merged."
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
    @path =
      if @text =~ %r{^diff --git a/(\S+) b/\S+$}
        $1
      else
        ""
      end
    second_line = @text.split("\n", 3)[1].to_s
    @type =
      case second_line
      when /^new file/
        "N"
      when /^deleted file/
        "D"
      else
        "C"
      end
  end

  attr_reader :text
  attr_reader :path
  attr_reader :type
end

class PrData
  def initialize context, pr_resource
    @context = context
    @id = pr_resource["number"]
    @title = pr_resource["title"]
    @lib_name =
      case title
      when /^\[CHANGE ME\] Re-generated google-cloud-([\w-]+) to pick up changes in the API or client/
        $1
      when /^\[CHANGE ME\] Re-generated ([\w-]+) to pick up changes in the API or client/
        $1
      else
        nil
      end
  end

  attr_reader :id
  attr_reader :title
  attr_reader :lib_name

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

  def custom_message(message)
    if @lib_name && message =~ /^(\w+):\s+(\S.*)$/
      "#{$1}(#{@lib_name}): #{$2}"
    else
      message
    end
  end
end
