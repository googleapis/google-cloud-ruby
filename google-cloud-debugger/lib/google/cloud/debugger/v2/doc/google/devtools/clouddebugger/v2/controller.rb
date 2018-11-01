# Copyright 2018 Google LLC
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


module Google
  module Devtools
    module Clouddebugger
      module V2
        # Request to register a debuggee.
        # @!attribute [rw] debuggee
        #   @return [Google::Devtools::Clouddebugger::V2::Debuggee]
        #     Debuggee information to register.
        #     The fields `project`, `uniquifier`, `description` and `agent_version`
        #     of the debuggee must be set.
        class RegisterDebuggeeRequest; end

        # Response for registering a debuggee.
        # @!attribute [rw] debuggee
        #   @return [Google::Devtools::Clouddebugger::V2::Debuggee]
        #     Debuggee resource.
        #     The field `id` is guaranteed to be set (in addition to the echoed fields).
        #     If the field `is_disabled` is set to `true`, the agent should disable
        #     itself by removing all breakpoints and detaching from the application.
        #     It should however continue to poll `RegisterDebuggee` until reenabled.
        class RegisterDebuggeeResponse; end

        # Request to list active breakpoints.
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     Identifies the debuggee.
        # @!attribute [rw] wait_token
        #   @return [String]
        #     A token that, if specified, blocks the method call until the list
        #     of active breakpoints has changed, or a server-selected timeout has
        #     expired. The value should be set from the `next_wait_token` field in
        #     the last response. The initial value should be set to `"init"`.
        # @!attribute [rw] success_on_timeout
        #   @return [true, false]
        #     If set to `true` (recommended), returns `google.rpc.Code.OK` status and
        #     sets the `wait_expired` response field to `true` when the server-selected
        #     timeout has expired.
        #
        #     If set to `false` (deprecated), returns `google.rpc.Code.ABORTED` status
        #     when the server-selected timeout has expired.
        class ListActiveBreakpointsRequest; end

        # Response for listing active breakpoints.
        # @!attribute [rw] breakpoints
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Breakpoint>]
        #     List of all active breakpoints.
        #     The fields `id` and `location` are guaranteed to be set on each breakpoint.
        # @!attribute [rw] next_wait_token
        #   @return [String]
        #     A token that can be used in the next method call to block until
        #     the list of breakpoints changes.
        # @!attribute [rw] wait_expired
        #   @return [true, false]
        #     If set to `true`, indicates that there is no change to the
        #     list of active breakpoints and the server-selected timeout has expired.
        #     The `breakpoints` field would be empty and should be ignored.
        class ListActiveBreakpointsResponse; end

        # Request to update an active breakpoint.
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     Identifies the debuggee being debugged.
        # @!attribute [rw] breakpoint
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint]
        #     Updated breakpoint information.
        #     The field `id` must be set.
        #     The agent must echo all Breakpoint specification fields in the update.
        class UpdateActiveBreakpointRequest; end

        # Response for updating an active breakpoint.
        # The message is defined to allow future extensions.
        class UpdateActiveBreakpointResponse; end
      end
    end
  end
end