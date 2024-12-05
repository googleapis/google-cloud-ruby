# frozen_string_literal: true

# Copyright 2022 Google LLC
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

desc "Reserve a gem name in RubyGems so no one hijacks it before we release it for real"

required_arg :gem_name
flag :gem_version, "--version=VERSION", default: "0.a"
flag :rubygems_api_token, "--rubygems-api-token=TOKEN", default: ENV["RUBYGEMS_API_TOKEN"]
flag :release, "--[no-]release"
flag :tmpdir, "--tmpdir=PATH"

include :exec, e: true
include :terminal
include :fileutils

def run
  cd context_directory
  load_kokoro_env
  set :tmpdir, "tmp" if !tmpdir && !release
  if tmpdir
    mkdir_p tmpdir
    cd tmpdir
    generate_files
    build_gem
    release_gem if release
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
  return if rubygems_api_token
  keystore_dir = ENV["KOKORO_KEYSTORE_DIR"]
  raise "No rubygems token given, and no Kokoro keystore dir found." unless keystore_dir
  token_filename = File.join keystore_dir, "73713_rubygems-publish-key"
  raise "No rubygems token given, and #{token_filename} not found." unless File.file? token_filename
  token_data = File.read token_filename
  set :rubygems_api_token, token_data
  puts "Rubygems API token acquired from keystore."
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
    "GEM_HOST_API_KEY" => rubygems_api_token
  }
  exec ["gem", "push", "#{gem_name}-#{gem_version}.gem"], env: env
end

def cur_date
  Time.now.strftime "%Y-%m-%d"
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
