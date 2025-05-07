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

toys_version! ">= 0.15.6"

desc "Runs various analyses on client status and reports results."

ANALYSES = {
  unreleased: "List gems that have no releases.",
  unwrapped: "List gapic gems that have no corresponding wrapper.",
  gapic_prerelease: "List gapic gems whose service is GA but do not have a 1.0 release",
  wrapper_prerelease: "List wrapper gems whose service is GA but do not have a 1.0 release",
  wrapper_dependencies: "List wrapper gems with outdated dependencies",
  wrapper_bazel: "List missing Ruby wrapper bazel configs",
  gapic_ready: "List complete Ruby bazel configs that haven't yet been generated",
  handwritten: "List gems that are fully handwritten",
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
  Dir.chdir context_directory
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

def all_handwritten_gems
  @all_handwritten_gems ||= all_gems.find_all { |name| !File.file? "#{name}/.OwlBot.yaml" }
end

def all_normal_gems
  @all_normal_gems ||= all_gems - RepoInfo::SPECIAL_GEMS
end

def all_generated_gems
  @all_generated_gems ||= Dir.glob("*/.OwlBot.yaml").map { |path| File.dirname path }.sort
end

def all_versioned_gems
  @all_versioned_gems ||= all_gems.find_all { |name| /-v\d\w*$/.match? name } - RepoInfo::SPECIAL_GEMS
end

def all_wrapper_gems
  @all_wrapper_gems ||= all_gems - all_versioned_gems - RepoInfo::SPECIAL_GEMS
end

def expected_wrapper_of gem_name
  transform_gem_name gem_name.sub(/-v\d\w*$/, "")
end

def transform_gem_name name
  RepoInfo::WRAPPER_MAPPING[name] || name
end

def wrapper_reverse_mapping
  @wrapper_reverse_mapping ||= begin
    mapping = {}
    RepoInfo::WRAPPER_MAPPING.each do |from, to|
      (mapping[to] ||= []) << from
    end
    mapping
  end
end

def original_wrapper_names gem_name
  wrapper_reverse_mapping[gem_name] || [gem_name]
end

def expected_gapics_for gem_name
  gem_names = original_wrapper_names gem_name
  all_versioned_gems.find_all do |vname|
    !RepoInfo::SPECIAL_GEMS.include?(vname) &&
      gem_names.any? { |wname| /^#{wname}-v\d+\w*$/ =~ vname }
  end
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
  @gem_ages ||= {}
  @gem_ages[gem_name] ||= begin
    content = File.read File.join gem_name, "CHANGELOG.md"
    date = content.scan(date_regexp).last
    if date
      date_to_age date
    else
      0
    end
  end
end

def gem_last_breaking_change_age gem_name
  @gem_breaking_change_ages ||= {}
  @gem_breaking_change_ages[gem_name] ||= begin
    date = nil
    has_breaking_change = false
    File.open(File.join(gem_name, "CHANGELOG.md")).each do |line|
      if line =~ date_regexp
        match = Regexp.last_match
        date = [match[:year], match[:month], match[:day]]
      end
      if line =~ /BREAKING CHANGE/
        has_breaking_change = true
        break
      end
    end
    date && has_breaking_change ? date_to_age(date) : 0
  end
end

def date_regexp
  %r{### \d+\.\d+\.\d+ (?:/ |\()(?<year>\d\d\d\d)-(?<month>\d\d)-(?<day>\d\d)}
end

def date_to_age date
  (Time.now.to_i - Time.new(*date.map(&:to_i)).to_i) / 86_400
end

def handwritten_analysis
  count = 0
  all_handwritten_gems.each do |name|
    puts name
    count += 1
  end
  puts "Total: #{count}", :cyan
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
    breaking_change_age = gem_last_breaking_change_age name
    results << [name, version, age, breaking_change_age] if age && age > 30
  end
  results.sort_by! { |elem| elem[2] }

  puts "Results:", :cyan
  results.reverse_each do |(name, version, age, breaking_change_age)|
    result = "#{name} #{version} (#{age} days)"
    if breaking_change_age.positive? && breaking_change_age < 90
      result += " !!! LAST BREAKING CHANGE: #{breaking_change_age} days ago !!!"
    end
    puts result
  end
  puts "Total: #{results.size}", :cyan
end

def wrapper_dependencies_analysis
  require "set"
  wrapper_list = Set.new
  puts "Results:", :cyan
  all_wrapper_gems.each do |gem_name|
    gapic_names = expected_gapics_for gem_name
    if gapic_names.empty?
      puts "#{gem_name}: No gapics"
      next
    end
    gapic_gem_versions, pre_service_versions, ga_service_versions = wda_analyze_gapic_versions gapic_names
    deps_requirements = wda_get_requirements gem_name, gapic_names
    wda_analyze_service_versions gem_name, ga_service_versions, pre_service_versions, deps_requirements, wrapper_list
    wda_analyze_best_service_version gem_name, ga_service_versions, pre_service_versions, wrapper_list
    wda_analyze_deps_requirements gem_name, deps_requirements, gapic_gem_versions, wrapper_list
  end
  puts "Total: #{wrapper_list.size}", :cyan
end

def wda_analyze_gapic_versions gapic_names
  gapic_gem_versions = {}
  pre_service_versions = {}
  ga_service_versions = {}
  gapic_names.each do |name|
    gapic_gem_versions[name] = gem_version name
    match = /-(v\d+[a-z]\w*)$/.match name
    pre_service_versions[name] = match[1] if match
    match = /-(v\d+)$/.match name
    ga_service_versions[name] = match[1] if match
  end
  [gapic_gem_versions, pre_service_versions, ga_service_versions]
end

def wda_get_requirements gem_name, gapic_names
  deps_requirements = {}
  gemspec_content = File.read "#{gem_name}/#{gem_name}.gemspec"
  gemspec_content.scan(/gem\.add_dependency\s+"([^"]+)",\s*("[^"]+"(?:,\s*"[^"]+")*)$/).each do |(name, versions)|
    if gapic_names.include? name
      requirements = versions.split(/,\s*/).map { |s| s[1..-2] }
      deps_requirements[name] = Gem::Dependency.new name, *requirements
    end
  end
  deps_requirements
end

def wda_get_default_service_version gem_name, wrapper_list
  unless RepoInfo::NON_GENERATED_WRAPPERS.include? gem_name
    factory_path = original_wrapper_names(gem_name).first.tr "-", "/"
    factory_content = File.read "#{gem_name}/lib/#{factory_path}.rb"
    match = / version: :(v\d\w*), /.match factory_content
    return match[1] if match
    puts "#{gem_name}: No default version found in factory file #{factory_path}!?", :red
    wrapper_list.add gem_name
  end
  nil
end

def wda_analyze_service_versions gem_name, ga_service_versions, pre_service_versions, deps_requirements, wrapper_list
  ga_service_versions.each_key do |ga_gapic_name|
    next if deps_requirements[ga_gapic_name]
    puts "#{gem_name}: Does not depend on GA gapic #{ga_gapic_name}", :yellow
    wrapper_list.add gem_name
  end
  return if ga_service_versions.empty?
  pre_service_versions.each_key do |pre_gapic_name|
    next unless deps_requirements[pre_gapic_name]
    puts "#{gem_name}: Depends on prerelease gapic #{pre_gapic_name} " \
         "when GA available: #{ga_service_versions.values.inspect}"
    wrapper_list.add gem_name
  end
end

def wda_analyze_best_service_version gem_name, ga_service_versions, pre_service_versions, wrapper_list
  default_service_version = nil
  unless RepoInfo::NON_GENERATED_WRAPPERS.include? gem_name
    factory_path = original_wrapper_names(gem_name).first.tr "-", "/"
    factory_content = File.read "#{gem_name}/lib/#{factory_path}.rb"
    match = / version: :(v\d\w*), /.match factory_content
    if match
      default_service_version = match[1]
    else
      puts "#{gem_name}: No default version found in factory file #{factory_path}!?", :red
      wrapper_list.add gem_name
    end
  end
  best_service_version = ga_service_versions.empty? ? pre_service_versions.values.max : ga_service_versions.values.max

  if best_service_version.nil?
    puts "#{gem_name}: No gapics found!?", :red
    wrapper_list.add gem_name
  elsif default_service_version && best_service_version != default_service_version
    puts "#{gem_name}: Default service version is #{default_service_version} " \
         "but #{best_service_version} is available", :yellow
    wrapper_list.add gem_name
  end
end

def wda_analyze_deps_requirements gem_name, deps_requirements, gapic_gem_versions, wrapper_list
  deps_requirements.each_value do |dependency|
    name = dependency.name
    version = gapic_gem_versions[name]
    if !dependency.match? name, version
      puts "#{gem_name}: Dep #{dependency} fails current version #{version}", :yellow
      wrapper_list.add gem_name
    elsif dependency.requirements_list.size > 1 && version !~ /^0\./
      puts "#{gem_name}: Dep #{dependency} not necessary for version #{version}"
      wrapper_list.add gem_name
    end
  end
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
