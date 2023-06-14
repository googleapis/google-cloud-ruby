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


require "minitest/autorun"
require "minitest/rg"
require "minitest/focus"
require "net/http"
require "json"
require "google/cloud/debugger"
require_relative "../../integration/helper"

$vtk_debugger_client = Google::Cloud::Debugger::V2::Debugger::Client.new

module Integration
  class DebuggerTest < Minitest::Test
    attr_accessor :debugger

    ##
    # Setup project based on available ENV variables
    def setup
      @vtk_debugger_client = $vtk_debugger_client

      refute_nil @vtk_debugger_client, "You do not have an active debugger vtk client to run the tests."
      super
    end

    ##
    # Create a test gRPC Snappoint
    def sample_snappoint file_path, line
      breakpoint_hash = {
        "location" => {
          "path" => file_path,
          "line" => line
        },
        "create_time" => {
          "seconds" => Time.now.to_i,
          "nanos" => Time.now.nsec
        },
        "expressions" => ["local_var"]
      }

      Google::Cloud::Debugger::V2::Breakpoint.new breakpoint_hash
    end

    ##
    # Create a test gRPC logpoint
    def sample_logpoint file_path, line, token = nil
      breakpoint_hash = {
        "action" => :LOG,
        "log_level" => :INFO,
        "location" => {
          "path" => file_path,
          "line" => line
        },
        "create_time" => {
          "seconds" => Time.now.to_i,
          "nanos" => Time.now.nsec
        },
        "log_message_format" => "local_var is $0. #{token}",
        "expressions" => ["local_var"]
      }

      Google::Cloud::Debugger::V2::Breakpoint.new breakpoint_hash
    end

    ##
    # Submit a test Snappoint through VTK client
    def set_test_snappoint debuggee_id, agent_version, file_path, line
      breakpoint = sample_snappoint file_path, line

      response = @vtk_debugger_client.set_breakpoint debuggee_id: debuggee_id,
                                                     breakpoint: breakpoint,
                                                     client_version: agent_version
      response.breakpoint.id
    end

    ##
    # Submit a test Logpoint through VTK client
    def set_test_logpoint debuggee_id, agent_version, file_path, line, token
      breakpoint = sample_logpoint file_path, line, token

      response = @vtk_debugger_client.set_breakpoint debuggee_id: debuggee_id,
                                                     breakpoint: breakpoint,
                                                     client_version: agent_version
      response.breakpoint.id
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :trace is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :debugger
    end
  end
end
