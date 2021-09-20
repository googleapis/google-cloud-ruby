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
required_arg :bazel_target
flag :output_dir, "--output=PATH", "-o PATH"

include :exec, e: true
include :fileutils
include :terminal

def run
  piper_client_dir = capture("p4 g4d #{piper_client}").strip
  bazel_base_dir = File.join piper_client_dir, "third_party", "googleapis", "stable"
  generated_dir = File.join bazel_base_dir, "bazel-bin", library_path, bazel_target
  exec ["bazel", "build", "#{library_path}:#{bazel_target}"], chdir: bazel_base_dir
  set :output_dir, File.join(Dir.mktmpdir, "client") unless output_dir
  rm_rf output_dir
  cp_r generated_dir, output_dir
  exec ["bundle", "install"], chdir: output_dir
  exec ["bundle", "exec", "rake", "ci"], chdir: output_dir
  puts output_dir, :bold
end
