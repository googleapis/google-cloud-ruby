require "binding_of_caller"

module Google
  module Cloud
    module Debugger
      class Tracer
        attr_reader :breakpoint_manager

        def initialize breakpoint_manager
          @breakpoint_manager = breakpoint_manager
          @file_tracepoint = nil
          @line_tracepoint = nil
          # @file_tp = TracePoint.new(:call, :class) do |tp|
          #   file_trace_callback tp
          # end
          # @line_tp = TracePoint.new(:line) do |tp|
          #   line_trace_callback tp
          # end
        end
        #
        # def old_start caller_file_path = nil
        #   @file_tp.enable
        #   # Enable line TracePoint immediately if we're already in right file
        #   caller_file_path ||= caller[0][/[^:]+/]
        #   right_file = false
        #   breakpoint_manager.active_breakpoints.each do |breakpoint|
        #     # Enable line TracePoint if in same file. Otherwise disable it.
        #     if breakpoint.path_hit? caller_file_path
        #       # puts "hitting path: #{caller_file_path}"
        #       @line_tp.enable
        #       right_file = true
        #       break
        #     end
        #   end
        #
        #   if !right_file && @line_tp.enabled?
        #     @line_tp.disable
        #   end
        # end
        #
        # def old_started?
        #   @file_tp.enabled?
        # end
        #
        # def old_stop
        #   @line_tp.disable
        #   @file_tp.disable
        # end
        #
        # def old_file_trace_callback tp
        #   all_paths_regex = breakpoint_manager.breakpoints_regex
        #
        #   if tp.path.match(all_paths_regex)
        #     @line_tp.enable
        #   else
        #     @line_tp.disable
        #   end
        # end
        #
        # def old_line_trace_callback tp
        #   breakpoint_manager.active_breakpoints.each do |breakpoint|
        #     if breakpoint.line_hit? tp.path, tp.lineno
        #       # Call tp.binding and set stack_frames here, so it's fixed to
        #       # correct starting frame
        #       call_stack_bindings = tp.binding.callers.drop(3)
        #
        #       breakpoint.eval_call_stack call_stack_bindings
        #     end
        #   end
        #
        #   # Auto stop if enabled
        #   stop if breakpoint_manager.all_complete?
        # end
      end
    end
  end
end