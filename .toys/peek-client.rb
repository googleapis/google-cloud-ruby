# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "tmpdir"

required_arg :piper_client
required_arg :library_path
flag :output_dir, "--output=PATH", "-o PATH"
flag :bazel_target, "--bazel-target=TARGET"
flag :owl_bot
flag :test
flag :pull
flag :postprocessor_tag, "--postprocessor-tag=TAG", default: "latest"

include :exec, e: true
include :fileutils
include :terminal

static :postprocessor_image, "gcr.io/cloud-devrel-public-resources/owlbot-ruby"

def run
  set :bazel_target, default_bazel_target unless bazel_target
  set :output_dir, updated_output_dir
  run_bazel
  final_dir = output_dir
  final_dir = run_owl_bot if owl_bot
  run_test final_dir if test
  puts final_dir, :bold
end

def run_bazel
  exec ["bazel", "build", "#{library_path}:#{bazel_target}"], chdir: bazel_base_dir
  rm_rf output_dir
  mkdir_p File.dirname output_dir
  cp_r generated_dir, output_dir
end

def run_owl_bot
  gemspecs = Dir.glob "*.gemspec", base: output_dir
  error "Unable to find gemspec in #{output_dir}" unless gemspecs.size == 1
  gem_name = File.basename gemspecs.first, ".gemspec"
  staging_base_dir = File.join context_directory, "owl-bot-staging"
  staging_dir = File.join staging_base_dir, gem_name
  rm_rf staging_base_dir
  mkdir_p staging_base_dir
  mv output_dir, staging_dir
  exec ["docker", "pull", "#{postprocessor_image}:#{postprocessor_tag}"] if pull
  docker_run "#{postprocessor_image}:#{postprocessor_tag}", "--gem", gem_name
  File.join context_directory, gem_name
end

def run_test dir
  exec ["bundle", "install"], chdir: dir
  exec ["bundle", "exec", "rake", "ci"], chdir: dir
end

def piper_client_dir
  @piper_client_dir ||= capture(["p4", "g4d", piper_client]).strip
end

def bazel_base_dir
  @bazel_base_dir ||= File.join piper_client_dir, "third_party", "googleapis", "stable"
end

def generated_dir
  @generated_dir ||= File.join bazel_base_dir, "bazel-bin", library_path, bazel_target
end

def default_bazel_target
  build_file_path = File.join bazel_base_dir, library_path, "BUILD.bazel"
  error "Unable to find #{build_file_path}" unless File.file? build_file_path
  build_content = File.read build_file_path
  match = /ruby_gapic_assembly_pkg\(\n\s+name\s*=\s*"([\w-]+-ruby)",/.match build_content
  error "Unable to find ruby build rule in #{build_file_path}" unless match
  match[1]
end

def updated_output_dir
  if output_dir
    File.expand_path output_dir
  else
    File.join context_directory, "tmp", "owl-bot-staging"
  end
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

def error msg
  puts msg, :red, :bold
  exit 1
end
