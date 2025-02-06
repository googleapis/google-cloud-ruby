# frozen_string_literal: true

# Copyright 2025 Google LLC
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

if ENV["RUBY_COMMON_TOOLS"]
  common_tools_dir = File.expand_path ENV["RUBY_COMMON_TOOLS"]
  load File.join(common_tools_dir, "toys", "gapic")
else
  load_git remote: "https://github.com/googleapis/ruby-common-tools.git",
           path: "toys/gapic",
           update: true
end

expand :minitest do |t|
  t.name = "conformance"
  t.libs = ["lib", "test", "conformance"]
  t.use_bundler
  t.files = "conformance/**/*_test.rb"
end

tool "conformance" do
  tool "gen-protos" do
    include :exec, e: true
    include :gems
    include :git_cache

    def run
      setup
      generate_conformance
    end

    def setup
      gem "grpc-tools", "~> 1.65"
      @googleapis_dir = git_cache.get "https://github.com/googleapis/googleapis.git", update: true
      Dir.chdir context_directory
    end

    def generate_conformance
      Dir.chdir "conformance/v1/proto" do
        cmd = [
          "grpc_tools_ruby_protoc",
          "--ruby_out", ".",
          "-I", ".",
          "-I", @googleapis_dir,
          "google/cloud/conformance/storage/v1/tests.proto"
        ]
        exec cmd
      end
    end
  end
end
