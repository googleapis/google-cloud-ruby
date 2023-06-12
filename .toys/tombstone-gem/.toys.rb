# frozen_string_literal: true

# Copyright 2023 Google LLC
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

desc "Tombstone a gem in RubyGems after we think it's no longer useful"

required_arg :gem_name
optional_arg :gem_version
flag :info_url, "--info-url=URL", default: ""
flag :rubygems_api_token, "--rubygems-api-token=TOKEN"
flag :release, "--[no-]release"
flag :tmpdir, "--tmpdir=PATH"

include :exec, e: true
include :terminal
include :fileutils

DEFAULT_INFO_URL = "https://cloud.google.com/terms/deprecation"

def run
  cd context_directory
  load_kokoro_env
  ensure_gem_version
  set :tmpdir, "tmp" if !tmpdir && !release
  set :info_url, DEFAULT_INFO_URL if info_url.to_s.empty?
  if tmpdir
    mkdir_p tmpdir
    cd tmpdir do
      generate_files
      build_gem
      release_gem if release
    end
  else
    require "tmpdir"
    Dir.mktmpdir do |gem_dir|
      cd gem_dir do
        generate_files
        build_gem
        release_gem if release
      end
    end
  end
end

def load_kokoro_env
  kokoro_gfile_dir = ENV["KOKORO_GFILE_DIR"]
  return unless kokoro_gfile_dir
  filename = File.join kokoro_gfile_dir, "ruby_env_vars.json"
  raise "#{filename} is not a file" unless File.file? filename
  env_vars = JSON.parse File.read filename
  env_vars.each { |k, v| ENV[k] ||= v }
end

def ensure_gem_version
  return if gem_version
  require "json"
  content = capture ["curl", "https://rubygems.org/api/v1/gems/#{gem_name}.json"], err: :null
  last_version = JSON.parse(content)["version"]
  puts "Last released version for #{gem_name} was #{last_version}"
  last_version = last_version.split(".").first.to_i
  set :gem_version, "#{last_version + 1}.0.0"
  puts "Going to release #{gem_version}"
end

def generate_files
  require "erb"
  puts "Generating files for #{gem_name} in #{Dir.getwd}", :bold
  template = File.read find_data "readme-template.erb"
  File.write "README.md", ERB.new(template).result(binding)
  template = File.read find_data "license-template.erb"
  File.write "LICENSE.md", ERB.new(template).result(binding)
  template = File.read find_data "gemspec-template.erb"
  File.write "#{gem_name}.gemspec", ERB.new(template).result(binding)
  mkdir_p namespace_dir
  template = File.read find_data "version-template.erb"
  File.write "#{namespace_dir}/version.rb", ERB.new(template).result(binding)
end

def build_gem
  puts "Building #{gem_name}-#{gem_version}.gem", :bold
  exec ["gem", "build", "#{gem_name}.gemspec", "--output", "#{gem_name}-#{gem_version}.gem"]
end

def release_gem
  puts "Releasing #{gem_name}-#{gem_version}.gem", :bold
  env = {
    "GEM_HOST_API_KEY" => rubygems_api_token || ENV["RUBYGEMS_API_TOKEN"]
  }
  exec ["gem", "push", "#{gem_name}-#{gem_version}.gem"], env: env
end

def cur_year
  Time.now.year.to_s
end

def namespace_modules
  @namespace_modules ||= gem_name.split("-").map { |segment| segment.split("_").map(&:capitalize).join }
end

def namespace
  @namespace ||= namespace_modules.join "::"
end

def namespace_dir
  @namespace_dir ||= "lib-#{gem_name}".tr "-", "/"
end

def version_lines
  lines = []
  indent = 0
  namespace_modules.each do |mod|
    lines << "#{' ' * indent}module #{mod}"
    indent += 2
  end
  lines << "#{' ' * indent}VERSION = \"#{gem_version}\""
  while indent > 0
    indent -= 2
    lines << "#{' ' * indent}end"
  end
  lines.join "\n"
end
