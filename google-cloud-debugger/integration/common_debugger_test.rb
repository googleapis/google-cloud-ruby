# Copyright 2017 Google Inc. All rights reserved.
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


require "debugger_helper"

describe Google::Cloud::Debugger, :debugger do
  it "catches and evaluates snappoint" do
    debuggee_id = nil
    agent_version = nil
    breakpoint_file_path = nil
    breakpoint_line = nil

    keep_trying_till_true do
      debugger_info_json = send_request "test_debugger_info"
      debugger_info = JSON.parse debugger_info_json

      debuggee_id = debugger_info["debuggee_id"]
      agent_version = debugger_info["agent_version"]
      breakpoint_file_path = debugger_info["breakpoint_file_path"]
      breakpoint_line = debugger_info["breakpoint_line"]

      !debuggee_id.nil?
    end

    breakpoint_id = set_test_snappoint debuggee_id, agent_version, breakpoint_file_path, breakpoint_line

    breakpoint = nil
    keep_trying_till_true 60 do
      # Send request to trigger debugger
      send_request "test_debugger"

      response = @vtk_debugger_client.get_breakpoint(debuggee_id, breakpoint_id, agent_version)
      breakpoint = response.breakpoint

      breakpoint.is_final_state
    end

    stack_frame = breakpoint.stack_frames[0]
    stack_frame.function.must_equal "trigger_breakpoint"
    stack_frame.locals.size.must_equal 1
    stack_frame.locals.first.name.must_equal "local_var"
    stack_frame.locals.first.value.must_equal "42"

    breakpoint.evaluated_expressions.size.must_equal 1
    breakpoint.evaluated_expressions.first.name.must_equal "local_var"
    breakpoint.evaluated_expressions.first.value.must_equal "42"
  end

  it "catches and evaluates logpoint" do
    debuggee_id = nil
    agent_version = nil
    breakpoint_file_path = nil
    breakpoint_line = nil
    monitored_resource_type = nil

    keep_trying_till_true do
      debugger_info_json = send_request "test_debugger_info"
      debugger_info =
        begin
          JSON.parse debugger_info_json
        rescue
          nil
        end

      debuggee_id = debugger_info["debuggee_id"]
      agent_version = debugger_info["agent_version"]
      breakpoint_file_path = debugger_info["breakpoint_file_path"]
      breakpoint_line = debugger_info["breakpoint_line"]
      monitored_resource_type = debugger_info["logger_monitored_resource_type"]

      !debuggee_id.nil?
    end

    token = rand 0x10000000000

    set_test_logpoint debuggee_id, agent_version, breakpoint_file_path, breakpoint_line, token

    project_id = gcloud_project_id
    logging = Google::Cloud::Logging.new project: project_id
    timestamp = (Time.now - 60).utc.strftime('%FT%TZ')

    filter = "resource.type=\"#{monitored_resource_type}\" AND textPayload:#{token} AND timestamp > \"#{timestamp}\""

    entries = nil
    send_request "test_debugger"

    # Logs can take up to a minute before they become avaiable for read.
    # Directly sleep 45 seconds before even trying to find log entries.
    sleep 45

    keep_trying_till_true do
      # Send request to trigger debugger
      send_request "test_debugger"

      entries = logging.entries filter: filter
      !entries.empty?
    end

    entries.first.payload.must_match "LOGPOINT"
    entries.first.payload.must_match "local_var is 42"
    entries.first.payload.must_match token.to_s
  end
end
