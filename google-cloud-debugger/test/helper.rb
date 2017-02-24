# Copyright 2016 Google Inc. All rights reserved.
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/debugger"

class MockDebugger < Minitest::Spec
  let(:project) { "test" }
  # let(:default_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:module_name) { "test-service" }
  let(:module_version) { "vTest" }
  let(:debugger) {
    Google::Cloud::Debugger::Project.new(
      Google::Cloud::Debugger::Service.new(project, credentials),
      module_name: module_name,
      module_version: module_version
    )
  }
  let(:breakpoint_manager) {
    manager = debugger.agent.breakpoint_manager
    manager.on_breakpoints_change = nil
    manager
  }

  # Register this spec type for when :speech is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_debugger
  end
end

# Mock Rack::Directory
module Rack
  class Directory
    def initialize arg
    end

    # Spoof with current test directory
    def root
      File.expand_path "."
    end
  end
end

##
# Helper method to loop until block yields true or timeout.
def wait_until_true timeout = 5
  begin_t = Time.now

  until yield
    return :timeout if Time.now - begin_t > timeout
    sleep 0.1
  end

  :completed
end
