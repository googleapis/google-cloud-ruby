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
        # Ruby application root directory, in absolute path form. The
        # Stackdriver Debugger Service only knows the relative application file
        # path. So the tracer needs to combine relative file path with
        # application root directory to get full file path for tracing purpose
        # @return [String]
        attr_accessor :app_root

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
        def initialize agent, app_root: nil
          @agent = agent
          @file_tracepoint = nil
          @fiber_tracepoint = nil
          @breakpoints_cache = {}

          @app_root = app_root
          @app_root ||= Rack::Directory.new("").root if defined? Rack::Directory

          fail "Unable to determine application root path" unless @app_root
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
            breakpoint_path = full_breakpoint_path active_breakpoint.path
            breakpoints_hash[breakpoint_path] ||= {}
            breakpoints_hash[breakpoint_path][breakpoint_line] ||= []
            breakpoints_hash[breakpoint_path][breakpoint_line].push(
              active_breakpoint)
          end

          # Tracer is explicitly designed to not have a lock. This should be the
          # only place writing @breakpoints_cache to ensure thread safety.
          @breakpoints_cache = breakpoints_hash
        end

        ##
        # Evaluates a hit breakpoint, and signal BreakpointManager and
        # Transmitter if this breakpoint is evaluated successfully.
        #
        # See {Breakpoint#eval_call_stack} for evaluation details.
        #
        # @param [Google::Cloud::Debugger::Breakpoint] breakpoint The breakpoint
        #   to be evaluated
        # @param [Array<Binding>] call_stack_bindings An array of Ruby Binding
        #   objects, from the each frame of the call stack that leads to the
        #   triggering of the breakpoints.
        #
        def eval_breakpoint breakpoint, call_stack_bindings
          return if breakpoint.nil? || breakpoint.complete?

          breakpoint.eval_call_stack call_stack_bindings

          # Take this completed breakpoint off manager's active breakpoints
          # list, submit the breakpoint snapshot, and update Tracer's
          # breakpoints_cache.
          return unless breakpoint.complete?

          # Signal breakpoint_manager that this breakpoint is evaluated
          agent.breakpoint_manager.mark_off breakpoint
          # Signal transmitter to submit this breakpoint
          agent.transmitter.submit breakpoint

          update_breakpoints_cache

          # Disable all trace points and tracing if all breakpoints are complete
          disable_traces if @breakpoints_cache.empty?
        end

        ##
        # @private Covert breakpoint's relative file path to absolute file
        # path by combining it with application root directory path.
        def full_breakpoint_path breakpoint_path
          if app_root.nil? || app_root.empty?
            breakpoint_path
          else
            "#{app_root}/#{breakpoint_path}"
          end
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
