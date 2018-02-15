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

require "debugger_helper"

describe Google::Cloud::Debugger, :debugger do
  it "catches and evaluates snappoint" do
    breakpoint_id = set_test_snappoint

    debuggee_id = @debugger.agent.debuggee.id

    breakpoint = nil
    wait_until do
      trigger_breakpoint

      response = @vtk_debugger_client.get_breakpoint(debuggee_id, breakpoint_id, @agent_version)
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
    token = rand 0x10000000000

    set_test_logpoint token

    project_id = @debugger.project
    credentials = @debugger.service.credentials
    logging = Google::Cloud::Logging::Project.new(
      Google::Cloud::Logging::Service.new(
        project_id, credentials))

    log_name = @debugger.agent.logger.log_name
    time_stamp = (Time.now - 120).to_datetime.rfc3339
    filter = "logName=projects/#{project_id}/logs/#{log_name} AND resource.type=\"global\" AND textPayload:#{token} AND timestamp>=#{time_stamp.inspect}"
    entries = nil
    wait_until do
      trigger_breakpoint
      entries = logging.entries filter: filter
      !entries.empty?
    end

    entries.first.payload.must_match "LOGPOINT"
    entries.first.payload.must_match "local_var is 42"
    entries.first.payload.must_match token.to_s
  end
end
