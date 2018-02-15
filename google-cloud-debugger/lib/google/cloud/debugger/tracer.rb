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


require "binding_of_caller"

module Google
  module Cloud
    module Debugger
      ##
      # # Tracer
      #
      # When active breakpoints are set for the debugger, the tracer monitors
      # the running Ruby application and triggers evaluation when the code is
      # executed at the breakpoint locations.
      #
      # The tracer tracks the running application using several Ruby TracePoints
      # and C level Ruby debugging API.
      #
      class Tracer
        ##
        # The debugger agent this tracer belongs to
        # @return [Google::Cloud::Debugger::Agent]
        attr_reader :agent

        ##
        # @private File tracing point that enables line tracing when program
        # counter enters a file that contains breakpoints
        attr_reader :file_tracepoint

        ##
        # @private Fiber tracing point that enables line tracing when program
        # counter enters a file that contains breakpoints through fiber
        # switching
        attr_reader :fiber_tracepoint

        ##
        # @private A nested hash structure represent all the active breakpoints.
        # The structure is optimized for fast access. For example:
        # {
        #   "path/to/file.rb" => {                     # The absolute file path
        #     123 => [                                 # The line number in file
        #       <Google::Cloud::Debugger::Breakpoint>  # List of breakpoints
        #     ]
        #   }
        # }
        attr_reader :breakpoints_cache

        ##
        # @private Construct a new instance of Tracer
        def initialize agent
          @agent = agent
          @file_tracepoint = nil
          @fiber_tracepoint = nil
          @breakpoints_cache = {}
        end

        ##
        # Update tracer's private breakpoints cache with the list of active
        # breakpoints from BreakpointManager.
        #
        # This methood is atomic for thread safety purpose.
        def update_breakpoints_cache
          active_breakpoints = agent.breakpoint_manager.active_breakpoints.dup
          breakpoints_hash = {}

          active_breakpoints.each do |active_breakpoint|
            breakpoint_line = active_breakpoint.line
            breakpoint_path = active_breakpoint.full_path
            breakpoints_hash[breakpoint_path] ||= {}
            breakpoints_hash[breakpoint_path][breakpoint_line] ||= []
            breakpoints_hash[breakpoint_path][breakpoint_line].push(
              active_breakpoint
            )
          end

          # Tracer is explicitly designed to not have a lock. This should be the
          # only place writing @breakpoints_cache to ensure thread safety.
          @breakpoints_cache = breakpoints_hash
        end

        ##
        # Callback function when a set of breakpoints are hit. Handover the hit
        # breakpoint to breakpoint_manager to be evaluated.
        def breakpoints_hit breakpoints, call_stack_bindings
          breakpoints.each do |breakpoint|
            # Stop evaluating breakpoints if we have quotas and the quotas are
            # met.
            break if agent.quota_manager && !agent.quota_manager.more?

            next if breakpoint.nil? || breakpoint.complete?

            time_begin = Time.now

            agent.breakpoint_manager.breakpoint_hit breakpoint,
                                                    call_stack_bindings

            # Report time and resource consumption to quota manager
            if agent.quota_manager.respond_to? :consume
              agent.quota_manager.consume time: Time.now - time_begin
            end
          end

          update_breakpoints_cache

          # Disable all trace points and tracing if all breakpoints are complete
          disable_traces if @breakpoints_cache.empty?
        end

        ##
        # Get the sync the breakpoints cache with BreakpointManager. Start
        # tracing and monitoring if there are any breakpoints.
        def start
          update_breakpoints_cache
          enable_traces unless breakpoints_cache.empty?
        end

        ##
        # Stops all tracing.
        def stop
          disable_traces
        end
      end
    end
  end
end
