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

desc "Backfill reference documentation upload"

remaining_args :specified_releases

include :exec, e: true
include :terminal

def run
  Dir.chdir context_directory
  analyze_git_info
  interpret_releases
  error "Unable to find any releases to backfill" if @jobs.empty?
  @jobs.each do |(gem_name, gem_version)|
    backfill_one gem_name, gem_version
  end
end

def analyze_git_info
  if capture(["git", "rev-parse", "--is-shallow-repository"]).strip == "true"
    exec ["git", "fetch", "--unshallow", "--tags"]
  else
    exec ["git", "fetch", "--tags"]
  end
  cli.loader.lookup_specific ["release", "perform"]
  @releases = {}
  tags = capture(["git", "tag", "-l"]).split("\n")
  tags.each do |tag|
    match = %r{^([\w-]+)/v(\d+\.\d+\.\d+)$}.match tag
    next unless match
    (@releases[match[1]] ||= []) << ::Gem::Version.new(match[2])
  end
  @releases.each_value(&:sort!)
end

def interpret_releases
  @jobs = []
  specified_releases.each do |release_spec|
    segments = release_spec.split(/[:,;]/)
    gem_name = segments.shift
    existing_versions = @releases[gem_name]
    error "No such gem #{gem_name}" unless existing_versions
    if segments.empty?
      @jobs << [gem_name, existing_versions.last]
      next
    end
    segments.each do |segment|
      seg_parts = segment.split "-", -1
      if seg_parts.empty? || seg_parts.size > 2
        error "Segment #{segment.inspect} malformed in #{release_spec.inspect}"
      end
      seg_parts << seg_parts.first if seg_parts.size == 1
      seg_parts[0] = "0.0.0" if seg_parts[0].empty?
      seg_parts[1] = "99.99.99" if seg_parts[1].empty?
      seg_parts.map! { |part| ::Gem::Version.new part }
      existing_versions.each do |vers|
        @jobs << [gem_name, vers] if vers >= seg_parts.first && vers <= seg_parts.last
      end
    end
  end
end

def backfill_one gem_name, gem_version
  puts "#{gem_name} #{gem_version}", :bold
  cur_branch = capture(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip
  exec ["git", "checkout", "--detach", "#{gem_name}/v#{gem_version}"]
  begin
    cli.run "release", "perform", "--force-republish", "--enable-rad", gem_name, verbosity: verbosity
  ensure
    exec ["git", "checkout", cur_branch] unless cur_branch == "HEAD"
  end
end

def error msg
  logger.fatal msg
  exit 1
end
