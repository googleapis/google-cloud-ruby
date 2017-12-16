# Copyright 2017 Google LLC
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

require "helper"
require "digest"

describe Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator do
  describe ".generate_app_uniquifier" do
    it "uses the app_path passed it" do
      stubbed_process_directory = ->(sha = nil, path = nil, depth = 1) {
        path.must_equal "utest_path"
      }
      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.stub :process_directory, stubbed_process_directory do
        Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.generate_app_uniquifier "sha", "utest_path"
      end
    end

    it "first defaults to use Rack::Directory.new("").root" do
      stubbed_process_directory = ->(sha = nil, path = nil, depth = 1) {
        path.must_equal "utest_rack_path"
      }
      stubbed_rack_directory = ->(path) {
        OpenStruct.new(root: "utest_rack_path")
      }

      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.stub :process_directory, stubbed_process_directory do
        Rack::Directory.stub :new, stubbed_rack_directory do
          Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.generate_app_uniquifier "sha"
        end
      end
    end
  end

  describe ".process_directory" do
    it "return if depth exceeds MAX_DEPTH" do
      exceeded_depth = Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator::MAX_DEPTH + 1
      sha = Digest::SHA1.new
      original_sha_digest = sha.to_s
      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.process_directory sha, ".", exceeded_depth
      sha.to_s.must_equal original_sha_digest
    end

    it "computes sha of a directory" do
      expected_sha = Digest::SHA1.new
      sha = Digest::SHA1.new

      sha.to_s.must_equal expected_sha.to_s

      test_file = Pathname.new File.join(File.dirname(__FILE__), "test_dir", "test_ruby_file.rb")
      expected_sha << "#{test_file.expand_path}:#{test_file.stat.size}"

      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.process_directory sha, "#{File.dirname(__FILE__)}/test_dir"
      sha.to_s.must_equal expected_sha.to_s
    end
  end
end
