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

toys_version! ">= 0.14.7"

desc "Runs various analyses on client status and reports results."

ANALYSES = {
  unreleased: "List gems that have no releases.",
  unwrapped: "List gapic gems that have no corresponding wrapper.",
  gapic_prerelease: "List gapic gems whose service is GA but do not have a 1.0 release",
  wrapper_prerelease: "List wrapper gems whose service is GA but do not have a 1.0 release",
  outdated_wrappers: "List wrapper gems prioritizing an outdated gapic",
  wrapper_bazel: "List missing Ruby wrapper bazel configs",
  gapic_ready: "List complete Ruby bazel configs that haven't yet been generated",
}.freeze

at_least_one desc: "Analyses" do
  flag :all, desc: "Run all analyses except those explicitly disabled"
  ANALYSES.each do |analysis, desc|
    flag analysis, "--[no-]#{analysis.to_s.tr '_', '-'}", desc: desc.strip
  end
end

flag :googleapis_repo, "--googleapis-repo=PATH"

include :exec, e: true
include :terminal
include :git_cache

def run
  require "repo_info"
  require "fileutils"
  require "tmpdir"
  ANALYSES.each do |analysis, description|
    next unless all || self[analysis]
    name = "#{analysis}_analysis"
    puts "**** Running #{name} ... ****", :bold
    puts "(#{description})", :bold
    send name.to_sym
    puts
  end
end

def googleapis_path
  return googleapis_repo if googleapis_repo
  @googleapis_path ||= git_cache.get "https://github.com/googleapis/googleapis.git", update: true
end

def all_gems
  @all_gems ||= Dir.glob("*/*.gemspec").map { |path| File.dirname path }.sort
end

def all_generated_gems
  @all_generated_gems ||= Dir.glob("*/.OwlBot.yaml").map { |path| File.dirname path }.sort
end

def all_versioned_gems
  @all_versioned_gems ||= all_gems.find_all { |name| /-v\d\w*$/.match? name }
end

def all_wrapper_gems
  @all_wrapper_gems ||= all_gems - all_versioned_gems - RepoInfo::SPECIAL_GEMS
end

def expected_wrapper_of gem_name
  transform_gem_name gem_name.sub(/-v\d\w*$/, "")
end

def transform_gem_name name
  name = RepoInfo::MULTI_WRAPPERS[name] || name
  RepoInfo::UNUSUAL_NAMES[name] || name
end

def gem_version gem_name
  @gem_versions ||= {}
  @gem_versions[gem_name] ||= begin
    func = proc do
      Dir.chdir gem_name do
        spec = Gem::Specification.load "#{gem_name}.gemspec"
        puts spec.version
      end
    end
    capture_proc(func).strip
  end
end

def gem_age gem_name
  now = Time.now.to_i
  @gem_ages ||= {}
  @gem_ages[gem_name] ||= begin
    content = File.read File.join gem_name, "CHANGELOG.md"
    date = content.scan(/### \d+\.\d+\.\d+ (?:\/ |\()(\d\d\d\d)-(\d\d)-(\d\d)/).last
    if date
      (now - Time.new(*date.map(&:to_i)).to_i) / 86_400
    else
      0
    end
  end
end

def unreleased_analysis
  count = 0
  puts "Results:", :cyan
  all_gems.each do |gem_name|
    if gem_version(gem_name) == "0.0.1"
      puts gem_name
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def unwrapped_analysis
  count = 0
  puts "Results:", :cyan
  all_versioned_gems.each do |gem_name|
    expected_wrapper = expected_wrapper_of gem_name
    unless expected_wrapper.is_a?(Symbol) || all_wrapper_gems.include?(expected_wrapper)
      puts gem_name
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def wrapper_prerelease_analysis
  gem_names = all_versioned_gems.map do |gem_name|
    next unless /-v\d+$/.match? gem_name
    wrapper_name = expected_wrapper_of gem_name
    all_wrapper_gems.include?(wrapper_name) ? wrapper_name : nil
  end.compact.uniq
  generic_prerelease_analysis gem_names
end

def gapic_prerelease_analysis
  gem_names = all_versioned_gems.find_all { |gem_name| /-v\d+$/.match? gem_name }
  generic_prerelease_analysis gem_names
end

def generic_prerelease_analysis gem_names
  results = []
  gem_names.each do |name|
    next if RepoInfo::PINNED_PRERELEASE_GEMS.include? name
    version = gem_version name
    next unless version.start_with? "0."
    age = gem_age name
    results << [name, version, age] if age && age > 30
  end
  results.sort_by! { |elem| elem[2] }

  puts "Results:", :cyan
  results.reverse_each do |(name, version, age)|
    puts "#{name} #{version} (#{age} days)"
  end
  puts "Total: #{results.size}", :cyan
end

def outdated_wrappers_analysis
  count = 0
  puts "Results:", :cyan
  all_wrapper_gems.each do |gem_name|
    pre_versions = []
    ga_versions = []
    all_versioned_gems.each do |versioned_name|
      match = /^#{gem_name}-(v\d+[a-z]\w*)$/.match versioned_name
      pre_versions << match[1] if match
      match = /^#{gem_name}-(v\d+)$/.match versioned_name
      ga_versions << match[1] if match
    end
    expected_version = (ga_versions.empty? ? pre_versions : ga_versions).max
    unless expected_version
      puts "#{gem_name}: No expected version"
      next
    end
    path = gem_name.tr "-", "/"
    content = File.read "#{gem_name}/lib/#{path}.rb"
    match = / version: :(v\d\w*), /.match content
    unless match
      puts "#{gem_name}: No version found"
      next
    end
    version = match[1]
    unless version == expected_version
      puts "#{gem_name}: Expected #{expected_version} but found #{version}", :yellow
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def wrapper_bazel_analysis
  count = 0
  puts "Results:", :cyan
  Dir.chdir googleapis_path do
    Dir.glob "**/BUILD.bazel" do |build_file|
      dir = File.dirname build_file
      next unless dir =~ /v\d\w+$/
      wrapper_bazel_path = File.join File.dirname(dir), "BUILD.bazel"
      if File.file? wrapper_bazel_path
        content = File.read wrapper_bazel_path
        next if content.include? "ruby-cloud-wrapper-of="
      end
      puts wrapper_bazel_path
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def gapic_ready_analysis
  count = 0
  puts "Results:", :cyan
  Dir.chdir googleapis_path do
    Dir.glob "**/BUILD.bazel" do |build_file|
      content = File.read build_file
      next unless content.include? "ruby_cloud_gapic_library"
      match = /ruby-cloud-gem-name=([\w-]+)/.match content
      next unless match
      gem_name = transform_gem_name match[1]
      next unless gem_name.is_a? String
      gemspec_path = File.join context_directory, gem_name, "#{gem_name}.gemspec"
      next if File.file? gemspec_path
      puts "#{gem_name} (#{File.dirname build_file})"
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end
