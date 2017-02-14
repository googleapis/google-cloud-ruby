# Copyright 2016 Google Inc. All rights reserved.
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
      class Tracer
        attr_reader :agent

        attr_accessor :app_root

        attr_reader :file_tracepoint

        attr_reader :return_tracepoint

        attr_reader :line_tracepoint

        attr_reader :breapoints_cache

        def initialize agent, app_root: nil
          @agent = agent
          @file_tracepoint = nil
          @return_tracepoint = nil
          @return_tracepoint_counter = nil
          # @b_call_tracepoint = nil
          # @b_return_tracepoint = nil
          # @fiber_switch_tracepoint = nil
          @line_tracepoint = nil
          @breakpoints_cache = {}

          @app_root = app_root
          if defined? Rack::Directory
            @app_root ||= Rack::Directory.new("").root
          end

          fail "Unable to determine application root path" unless @app_root
        end

        def update_breakpoints_cache
          active_breakpoints = agent.breakpoint_manager.active_breakpoints
          breakpoints_hash = {}

          active_breakpoints.each do |active_breakpoint|
            breakpoint_line = active_breakpoint.line
            breakpoint_path = "#{app_root}/#{active_breakpoint.path}"
            breakpoints_hash[breakpoint_path] ||= {}
            breakpoints_hash[breakpoint_path][breakpoint_line] ||= []
            breakpoints_hash[breakpoint_path][breakpoint_line].push(
              active_breakpoint)
          end

          @breakpoints_cache = breakpoints_hash
        end

        def eval_breakpoint breakpoint, call_stack_bindings
          return if breakpoint.nil? || breakpoint.complete?

          puts "\n\n*********************TRACER EVAL CALLLLLED\n\n"

          breakpoint.eval_call_stack call_stack_bindings
          # TODO: disable tracepoints if all breakpoints complete, in a non-blocking way
          # disable_tracepoints if breakpoint_manager.all_complete?

          agent.submit_breakpoint breakpoint
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