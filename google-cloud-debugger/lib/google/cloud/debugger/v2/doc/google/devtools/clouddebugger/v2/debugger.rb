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
        # Request to set a breakpoint
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     ID of the debuggee where the breakpoint is to be set.
        # @!attribute [rw] breakpoint
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint]
        #     Breakpoint specification to set.
        #     The field +location+ of the breakpoint must be set.
        # @!attribute [rw] client_version
        #   @return [String]
        #     The client version making the call.
        #     Schema: +domain/type/version+ (e.g., +google.com/intellij/v1+).
        class SetBreakpointRequest; end

        # Response for setting a breakpoint.
        # @!attribute [rw] breakpoint
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint]
        #     Breakpoint resource.
        #     The field +id+ is guaranteed to be set (in addition to the echoed fileds).
        class SetBreakpointResponse; end

        # Request to get breakpoint information.
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     ID of the debuggee whose breakpoint to get.
        # @!attribute [rw] breakpoint_id
        #   @return [String]
        #     ID of the breakpoint to get.
        # @!attribute [rw] client_version
        #   @return [String]
        #     The client version making the call.
        #     Schema: +domain/type/version+ (e.g., +google.com/intellij/v1+).
        class GetBreakpointRequest; end

        # Response for getting breakpoint information.
        # @!attribute [rw] breakpoint
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint]
        #     Complete breakpoint state.
        #     The fields +id+ and +location+ are guaranteed to be set.
        class GetBreakpointResponse; end

        # Request to delete a breakpoint.
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     ID of the debuggee whose breakpoint to delete.
        # @!attribute [rw] breakpoint_id
        #   @return [String]
        #     ID of the breakpoint to delete.
        # @!attribute [rw] client_version
        #   @return [String]
        #     The client version making the call.
        #     Schema: +domain/type/version+ (e.g., +google.com/intellij/v1+).
        class DeleteBreakpointRequest; end

        # Request to list breakpoints.
        # @!attribute [rw] debuggee_id
        #   @return [String]
        #     ID of the debuggee whose breakpoints to list.
        # @!attribute [rw] include_all_users
        #   @return [true, false]
        #     When set to +true+, the response includes the list of breakpoints set by
        #     any user. Otherwise, it includes only breakpoints set by the caller.
        # @!attribute [rw] include_inactive
        #   @return [true, false]
        #     When set to +true+, the response includes active and inactive
        #     breakpoints. Otherwise, it includes only active breakpoints.
        # @!attribute [rw] action
        #   @return [Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest::BreakpointActionValue]
        #     When set, the response includes only breakpoints with the specified action.
        # @!attribute [rw] strip_results
        #   @return [true, false]
        #     This field is deprecated. The following fields are always stripped out of
        #     the result: +stack_frames+, +evaluated_expressions+ and +variable_table+.
        # @!attribute [rw] wait_token
        #   @return [String]
        #     A wait token that, if specified, blocks the call until the breakpoints
        #     list has changed, or a server selected timeout has expired.  The value
        #     should be set from the last response. The error code
        #     +google.rpc.Code.ABORTED+ (RPC) is returned on wait timeout, which
        #     should be called again with the same +wait_token+.
        # @!attribute [rw] client_version
        #   @return [String]
        #     The client version making the call.
        #     Schema: +domain/type/version+ (e.g., +google.com/intellij/v1+).
        class ListBreakpointsRequest
          # Wrapper message for +Breakpoint.Action+. Defines a filter on the action
          # field of breakpoints.
          # @!attribute [rw] value
          #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint::Action]
          #     Only breakpoints with the specified action will pass the filter.
          class BreakpointActionValue; end
        end

        # Response for listing breakpoints.
        # @!attribute [rw] breakpoints
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Breakpoint>]
        #     List of breakpoints matching the request.
        #     The fields +id+ and +location+ are guaranteed to be set on each breakpoint.
        #     The fields: +stack_frames+, +evaluated_expressions+ and +variable_table+
        #     are cleared on each breakpoint regardless of its status.
        # @!attribute [rw] next_wait_token
        #   @return [String]
        #     A wait token that can be used in the next call to +list+ (REST) or
        #     +ListBreakpoints+ (RPC) to block until the list of breakpoints has changes.
        class ListBreakpointsResponse; end

        # Request to list debuggees.
        # @!attribute [rw] project
        #   @return [String]
        #     Project number of a Google Cloud project whose debuggees to list.
        # @!attribute [rw] include_inactive
        #   @return [true, false]
        #     When set to +true+, the result includes all debuggees. Otherwise, the
        #     result includes only debuggees that are active.
        # @!attribute [rw] client_version
        #   @return [String]
        #     The client version making the call.
        #     Schema: +domain/type/version+ (e.g., +google.com/intellij/v1+).
        class ListDebuggeesRequest; end

        # Response for listing debuggees.
        # @!attribute [rw] debuggees
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Debuggee>]
        #     List of debuggees accessible to the calling user.
        #     The fields +debuggee.id+ and +description+ are guaranteed to be set.
        #     The +description+ field is a human readable field provided by agents and
        #     can be displayed to users.
        class ListDebuggeesResponse; end
      end
    end
  end
end