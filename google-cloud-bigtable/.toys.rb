# frozen_string_literal: true

# Copyright 2024 Google LLC
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

toys_version! ">= 0.15.6"

if ENV["RUBY_COMMON_TOOLS"]
  common_tools_dir = File.expand_path ENV["RUBY_COMMON_TOOLS"]
  load File.join(common_tools_dir, "toys", "gapic")
else
  load_git remote: "https://github.com/googleapis/ruby-common-tools.git",
           path: "toys/gapic",
           update: true
end

tool "conformance" do
  tool "test" do
    flag :port, "--port=VAL", default: ENV["PORT"] || "9999"
    flag :focus, "--run=REGEXP", "--focus=REGEXP"

    include :git_cache
    include :exec
    include :terminal

    def run
      Dir.chdir context_directory
      known_failures = File.read("conformance/known_failures.txt").split.join("|")
      test_dir = git_cache.get "https://github.com/googleapis/cloud-bigtable-clients-test.git", update: true
      result = nil
      exec_tool ["conformance", "run-proxy", "--port", port],
                out: [:tee, :controller, :inherit], in: :null do |controller|
        logger.info "Waiting for server to start..."
        loop do
          break if controller.out.readline.strip == "SERVER STARTED"
        end
        logger.info "Got server start signal. Running test suite..."
        Dir.chdir "#{test_dir}/tests" do
          which_tests = focus ? "-run=#{focus}" : "-skip=#{known_failures}"
          result = exec ["go", "test", "-v", "-proxy_addr=:#{port}", which_tests]
        end
        controller.kill "SIGINT"
      end
      if result.success?
        puts "PASSED", :green, :bold
      else
        puts "FAILED", :red, :bold
      end
      exit result.exit_code
    end
  end

  tool "run-proxy" do
    flag :port, "--port=VAL", default: ENV["PORT"] || "9999"

    include :bundler, gemfile_path: "#{context_directory}/conformance/test_proxy/Gemfile"

    def run
      ENV["PORT"] = port
      require "#{context_directory}/conformance/test_proxy/test_proxy"
    end
  end

  tool "gen-protos" do
    include :exec, e: true
    include :gems
    include :git_cache

    def run
      setup
      generate_conformance
      generate_test_proxy
    end

    def setup
      gem "grpc-tools", "~> 1.65"
      @googleapis_dir = git_cache.get "https://github.com/googleapis/googleapis.git", update: true
      Dir.chdir context_directory
    end

    def generate_conformance
      Dir.chdir "conformance/v2/proto" do
        cmd = [
          "grpc_tools_ruby_protoc",
          "--ruby_out", ".",
          "-I", ".",
          "-I", @googleapis_dir,
          "google/cloud/conformance/bigtable/v2/tests.proto"
        ]
        exec cmd
      end
    end

    def generate_test_proxy
      Dir.chdir "conformance/test_proxy/proto" do
        cmd = [
          "grpc_tools_ruby_protoc",
          "--ruby_out", ".",
          "--grpc_out", ".",
          "-I", ".",
          "-I", @googleapis_dir,
          "google/bigtable/testproxy/test_proxy.proto"
        ]
        exec cmd
      end
    end
  end
end
