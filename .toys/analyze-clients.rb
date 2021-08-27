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

desc "Runs various analyses on client status and reports results."

ANALYSES = {
  unreleased: "List gems that have no releases.",
  unwrapped: "List gapic gems that have no corresponding wrapper.",
  gapic_prerelease: "List gapic gems whose service is GA but do not have a 1.0 release",
  wrapper_prerelease: "List wrapper gems whose service is GA but do not have a 1.0 release"
}

at_least_one desc: "Analyses" do
  flag :all, desc: "Run all analyses except those explicitly disabled"
  ANALYSES.each do |analysis, desc|
    flag analysis, "--[no-]#{analysis.to_s.tr '_', '-'}", desc: desc.strip
  end
end

include :exec, e: true
include :terminal

def run
  require "repo_info"
  ANALYSES.keys.each do |analysis|
    next unless all || self[analysis]
    name = "#{analysis}_analysis"
    puts "**** Running #{name} ... ****", :bold
    send name.to_sym
    puts
  end
end

def all_gems
  @all_gems ||= Dir.glob("*/*.gemspec").map { |path| File.dirname path }.sort
end

def all_generated_gems
  @all_generated_gems ||= Dir.glob("*/synth.py").map { |path| File.dirname path }.sort
end

def all_versioned_gems
  @all_versioned_gems ||= all_gems.find_all { |name| /-v\d\w*$/.match? name }
end

def all_wrapper_gems
  @all_wrapper_gems ||= all_gems - all_versioned_gems - RepoInfo::SPECIAL_GEMS
end

def expected_wrapper_of gem_name
  RepoInfo::UNUSUAL_WRAPPERS[gem_name] || gem_name.sub(/-v\d\w*$/, "")
end

def gem_version gem_name
  @gem_versions ||= {}
  @gem_versions[gem_name] ||= begin
    func = proc do
      Dir.chdir gem_name do
        spec = Gem::Specification.load "#{gem_name}.gemspec"
        puts spec.version.to_s
      end
    end
    capture_proc(func).strip
  end
end

def unreleased_analysis
  count = 0
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
  all_versioned_gems.each do |gem_name|
    unless all_wrapper_gems.include? expected_wrapper_of gem_name
      puts gem_name
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def wrapper_prerelease_analysis
  count = 0
  all_versioned_gems.each do |gem_name|
    next unless /-v\d+$/.match? gem_name
    wrapper_name = expected_wrapper_of gem_name
    next unless all_wrapper_gems.include? wrapper_name
    version = gem_version wrapper_name
    if version.start_with? "0."
      puts "#{wrapper_name} #{version}"
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end

def gapic_prerelease_analysis
  count = 0
  all_versioned_gems.each do |gem_name|
    next unless /-v\d+$/.match? gem_name
    version = gem_version gem_name
    if version.start_with? "0."
      puts "#{gem_name} #{version}"
      count += 1
    end
  end
  puts "Total: #{count}", :cyan
end
