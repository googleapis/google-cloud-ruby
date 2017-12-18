# Copyright 2017 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/debugger"
require "grpc"

# Create shared debugger clients so we don't create new for each test
$debugger = Google::Cloud::Debugger.new
debugger_credentials = $debugger.service.credentials
debugger_channel_cred = GRPC::Core::ChannelCredentials.new.compose \
  GRPC::Core::CallCredentials.new debugger_credentials.client.updater_proc
$vtk_debugger_client = Google::Cloud::Debugger::V2::Debugger2Client.new credentials: debugger_channel_cred

module Acceptance
  class DebuggerTest < Minitest::Test
    MIN_DELAY = 2
    MAX_DELAY = 11

    attr_accessor :debugger

    ##
    # Setup project based on available ENV variables
    def setup
      $debugger.start

      @debugger = $debugger
      @agent_version = @debugger.agent.debuggee.send :agent_version
      @vtk_debugger_client = $vtk_debugger_client

      refute_nil @debugger, "You do not have an active debugger to run the tests."
      refute_nil @vtk_debugger_client, "You do not have an active debugger vtk client to run the tests."
      super
    end

    ##
    # Code where the sample breakpoints will be pointing at. Calling the
    # function may trigger breakpoints if set correctly.
    def trigger_breakpoint
      local_var = 6 * 7
      local_var
    end

    ##
    # Create a test gRPC Snappoing
    def sample_snappoint
      file_path = "acceptance/debugger_helper.rb"
      line = method(:trigger_breakpoint).source_location.last + 2

      breakpoint_hash = {
        "location" => {
          "path" => file_path,
          "line" => line
        },
        "create_time" => {
          "seconds" => Time.now.to_i,
          "nanos"   => Time.now.nsec
        },
        "expressions" => ["local_var"]
      }

      Google::Devtools::Clouddebugger::V2::Breakpoint.decode_json breakpoint_hash.to_json
    end

    ##
    # Create a test gRPC logpoint
    def sample_logpoint token = nil
      file_path = "acceptance/debugger_helper.rb"
      line = method(:trigger_breakpoint).source_location.last + 2

      breakpoint_hash = {
        "action" => :LOG,
        "log_level" => :INFO,
        "location" => {
          "path" => file_path,
          "line" => line
        },
        "create_time" => {
          "seconds" => Time.now.to_i,
          "nanos"   => Time.now.nsec
        },
        "log_message_format" => "local_var is $0. #{token}",
        "expressions" => ["local_var"]
      }

      Google::Devtools::Clouddebugger::V2::Breakpoint.decode_json breakpoint_hash.to_json
    end

    ##
    # Submit a test Snappoint through VTK client
    def set_test_snappoint
      debuggee_id = nil

      wait_until do
        debuggee_id = @debugger.agent.debuggee.id
        !debuggee_id.nil?
      end

      breakpoint = sample_snappoint

      response = @vtk_debugger_client.set_breakpoint debuggee_id, breakpoint, @agent_version
      response.breakpoint.id
    end

    ##
    # Submit a test Logpoint through VTK client
    def set_test_logpoint token
      debuggee_id = nil

      wait_until do
        debuggee_id = @debugger.agent.debuggee.id
        !debuggee_id.nil?
      end

      breakpoint = sample_logpoint token

      response = @vtk_debugger_client.set_breakpoint debuggee_id, breakpoint, @agent_version
      response.breakpoint.id
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    def wait_until
      delay = MIN_DELAY
      while delay <= MAX_DELAY
        sleep delay
        result = yield
        return result if result
        delay += 1
      end
      nil
    end

    # Register this spec type for when :trace is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :debugger
    end
  end
end

##
# Stop the debugger after the whole test suite is finished.
Minitest.after_run do
  $debugger.stop
end
