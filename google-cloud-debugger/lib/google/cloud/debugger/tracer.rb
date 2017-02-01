require "binding_of_caller"

module Google
  module Cloud
    module Debugger
      class Tracer
        attr_reader :breakpoint_manager

        def initialize breakpoint_manager
          @breakpoint_manager = breakpoint_manager
          @file_tracepoint = nil
          @return_tracepoint = nil
          @return_tracepoint_counter = nil
          # @b_call_tracepoint = nil
          # @b_return_tracepoint = nil
          # @fiber_switch_tracepoint = nil
          @line_tracepoint = nil
          @breakpoints_cache = {}
        end

        def update_breakpoints_cache
          @breakpoints_cache = breakpoint_manager.active_breakpoints.clone
        end

        def start
          update_breakpoints_cache
          register_tracepoints
        end

        def stop
          update_breakpoints_cache
          disable_tracepoints
        end
      end
    end
  end
end