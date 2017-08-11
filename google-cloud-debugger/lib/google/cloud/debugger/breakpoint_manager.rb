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


require "google/cloud/debugger/snappoint"
require "google/cloud/debugger/logpoint"

module Google
  module Cloud
    module Debugger
      ##
      # # BreakpointManager
      #
      # Responsible for querying Stackdriver Debugger service for any active
      # breakpoints and keep an accurate local copies of the breakpoints.
      #
      # It correctly remembers which breakpoints are currently active and
      # watched by the debugger agent, and which breakpoints are already
      # completed. The BreakpointManager holds the record of truth for debugger
      # breakpoints
      #
      class BreakpointManager
        include MonitorMixin

        ##
        # The debugger agent this tracer belongs to
        # @return [Google::Cloud::Debugger::Agent]
        attr_reader :agent

        ##
        # @private The gRPC Service object.
        attr_reader :service

        ##
        # Application root directory, in absolute file path form.
        # @return [String]
        attr_reader :app_root

        ##
        # Callback function invoked when new breakpoints are added or removed
        # @return [Method]
        attr_accessor :on_breakpoints_change

        ##
        # @private The wait token from Stackdriver Debugger service used
        # for breakpoints long polling
        attr_reader :wait_token

        ##
        # @private Construct new instance of BreakpointManager
        def initialize agent, service
          super()

          @agent = agent
          @service = service

          @completed_breakpoints = []
          @active_breakpoints = []

          @wait_token = :init
        end

        ##
        # Sync active breakpoints with Stackdriver Debugger service for a given
        # debuggee application. Each request to the debugger service returns
        # the full list of all active breakpoints. This method makes sure the
        # local cache of active breakpoints is consistent with server
        # breakpoints set.
        #
        # @param [String] debuggee_id Debuggee application ID
        #
        # @return [Boolean] True if synced successfully; otherwise false.
        #
        def sync_active_breakpoints debuggee_id
          begin
            response = service.list_active_breakpoints debuggee_id, @wait_token
          rescue
            return false
          end

          return true if response.wait_expired

          @wait_token = response.next_wait_token

          server_breakpoints =
            convert_grpc_breakpoints response.breakpoints || []

          update_breakpoints server_breakpoints

          true
        end

        ##
        # Update the local breakpoints cache with a list of server active
        # breakpoints. New breakpoints will be added to local cache, and deleted
        # breakpoints will be removed from local cache.
        #
        # It also correctly identifies evaluated active breakpoints from the
        # server set of breakpoints, and does not re-add such evaluated
        # breakpoints to the active list again.
        #
        # @param [Array<Google::Cloud::Debugger::Breakpoint>] server_breakpoints
        #   List of active breakpoints from Stackdriver Debugger service
        #
        def update_breakpoints server_breakpoints
          synchronize do
            new_breakpoints =
              filter_breakpoints server_breakpoints - breakpoints

            before_breakpoints_count = breakpoints.size

            # Remember new active breakpoints from server
            @active_breakpoints += new_breakpoints unless new_breakpoints.empty?

            # Forget old breakpoints
            @completed_breakpoints &= server_breakpoints
            @active_breakpoints &= server_breakpoints
            after_breakpoints_acount = breakpoints.size

            breakpoints_updated =
              !new_breakpoints.empty? ||
              (before_breakpoints_count != after_breakpoints_acount)

            on_breakpoints_change.call(@active_breakpoints) if
              on_breakpoints_change.respond_to?(:call) && breakpoints_updated
          end
        end

        ##
        # Evaluates a hit breakpoint, and submit the breakpoint to
        # Transmitter if this breakpoint is evaluated successfully.
        #
        # See {Snappoint#evaluate} and {Logpoint#evaluate} for evaluation
        # details.
        #
        # @param [Google::Cloud::Debugger::Breakpoint] breakpoint The breakpoint
        #   to be evaluated
        # @param [Array<Binding>] call_stack_bindings An array of Ruby Binding
        #   objects, from the each frame of the call stack that leads to the
        #   triggering of the breakpoints.
        #
        def breakpoint_hit breakpoint, call_stack_bindings
          breakpoint.evaluate call_stack_bindings

          case breakpoint.action
          when :CAPTURE
            # Take this completed breakpoint off manager's active breakpoints
            # list, submit the breakpoint snapshot, and update Tracer's
            # breakpoints_cache.

            return unless breakpoint.complete?

            # Remove this breakpoint from active list
            mark_off breakpoint
            # Signal transmitter to submit this breakpoint
            agent.transmitter.submit breakpoint
          when :LOG
            log_logpoint breakpoint
          end
        end

        ##
        # Assume the given logpoint is successfully evaluated, log the
        # evaluated log message via logger
        #
        # @param [Google::Cloud::Debugger::Breakpoint] logpoint The evaluated
        #   logpoint.
        def log_logpoint logpoint
          return unless agent.logger && logpoint.evaluated_log_message

          message = "LOGPOINT: #{logpoint.evaluated_log_message}"

          case logpoint.log_level
          when :INFO
            agent.logger.info message
          when :WARNING
            agent.logger.warn message
          when :ERROR
            agent.logger.error message
          end
        end

        ##
        # Mark a given active breakpoint as completed. Meaning moving it from
        # list of active breakpoints to completed breakpoints.
        #
        # @param [Google::Cloud::Debugger::Breakpoint] breakpoint The breakpoint
        #   to remove from local cache
        #
        # @return [Google::Cloud::Debugger::Breakpoint, NilClass] The same
        #   breakpoint if successfully marked off as completed. Nil if
        #   this breakpoint isn't found in the list of active breakpoints or
        #   failed to mark off as completed.
        #
        def mark_off breakpoint
          synchronize do
            breakpoint = @active_breakpoints.delete breakpoint

            if breakpoint.nil?
              nil
            else
              @completed_breakpoints << breakpoint
              breakpoint
            end
          end
        end

        ##
        # Get a list of all breakpoints, both active and completed.
        #
        # @return [Array<Google::Cloud::Debugger::Breakpoint>] A list of all
        #   breakpoints.
        def breakpoints
          synchronize do
            @active_breakpoints | @completed_breakpoints
          end
        end

        ##
        # Get a list of all completed breakpoints.
        #
        # @return [Array<Google::Cloud::Debugger::Breakpoint>] A list of all
        #   completed breakpoints.
        def completed_breakpoints
          synchronize do
            @completed_breakpoints
          end
        end

        ##
        # Get a list of all active breakpoints.
        #
        # @return [Array<Google::Cloud::Debugger::Breakpoint>] A list of all
        #   active breakpoints.
        def active_breakpoints
          synchronize do
            @active_breakpoints
          end
        end

        ##
        # Check whether any active breakpoints haven't been completed yet.
        #
        # @return [Boolean] True if no more active breakpoints are left. False
        #   otherwise.
        def all_complete?
          synchronize do
            @active_breakpoints.empty?
          end
        end

        ##
        # Clear local breakpoints cache. Remove all active and completed
        # breakpoints
        def clear_breakpoints
          synchronize do
            @active_breakpoints.clear
            @completed_breakpoints.clear
          end
        end

        private

        ##
        # @private Convert the list of grpc breakpoints from Debugger service to
        # {Google::Cloud::Debugger::Breakpoint}.
        def convert_grpc_breakpoints grpc_breakpoints
          grpc_breakpoints.map do |grpc_b|
            breakpoint = Breakpoint.from_grpc grpc_b
            breakpoint.app_root = agent.app_root
            breakpoint.init_var_table if breakpoint.is_a? Debugger::Snappoint
            breakpoint
          end
        end

        ##
        # @private Varify a list of given breakpoints. Filter out those
        # aren't valid and submit them directly.
        def filter_breakpoints breakpoints
          valid_breakpoints = []
          invalid_breakpoints = []

          breakpoints.each do |breakpoint|
            if breakpoint.valid?
              valid_breakpoints << breakpoint
            else
              invalid_breakpoints << breakpoint
            end
          end

          invalid_breakpoints.each do |breakpoint|
            agent.transmitter.submit breakpoint if breakpoint.complete?
          end

          valid_breakpoints
        end
      end
    end
  end
end
