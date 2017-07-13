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


require "google/cloud/debugger/breakpoint"

module Google
  module Cloud
    module Debugger
      class Snappoint < Breakpoint
        ##
        # Max number of top stacks to collect local variables information
        STACK_EVAL_DEPTH = 5

        ##
        # Evaluate the breakpoint unless it's already marked as completed.
        # Store evaluted expressions and stack frame variables in
        # @evaluated_expressions, @stack_frames. Mark breakpoint complete if
        # successfully evaluated.
        #
        # @param [Array<Binding>] call_stack_bindings An array of Ruby Binding
        #   objects, from the call stack that leads to the triggering of the
        #   breakpoints.
        #
        # @return [Boolean] True if evaluated successfully; false otherwise.
        #
        def evaluate call_stack_bindings
          synchronize do
            top_binding = call_stack_bindings[0]

            return false if complete? || !check_condition(top_binding)

            begin
              eval_expressions top_binding
              eval_call_stack call_stack_bindings

              complete
            rescue
              return false
            end
          end

          true
        end

        ##
        # @private Evaluates the breakpoint expressions at the point that
        # triggered the breakpoint. The expressions subject to the read-only
        # rules. If the expressions do any write operations, the evaluations
        # abort and show an error message in place of the real result.
        #
        # @param [Binding] binding The binding object from the context
        #
        def eval_expressions binding
          @evaluated_expressions = expressions.map do |expression|
            eval_result = Evaluator.readonly_eval_expression binding, expression
            evaluated_var = Variable.from_rb_var eval_result,
                                                 var_table: variable_table
            evaluated_var.name = expression
            evaluated_var
          end
        end

        ##
        # @private Evaluates call stack. Collects function name and location of
        # each frame from given binding objects. Collects local variable
        # information from top frames.
        #
        # @param [Array<Binding>] call_stack_bindings A list of binding
        #   objects that come from each of the call stack frames.
        # @return [Array<Google::Cloud::Debugger::Breakpoint::StackFrame>]
        #   A list of StackFrame objects that represent state of the
        #   call stack
        #
        def eval_call_stack call_stack_bindings
          call_stack_bindings.each_with_index do |frame_binding, i|
            frame_info = StackFrame.new.tap do |sf|
              sf.function = frame_binding.eval("__method__").to_s
              sf.location = SourceLocation.new.tap do |l|
                l.path =
                  frame_binding.eval "::File.absolute_path(__FILE__)"
                l.line = frame_binding.eval "__LINE__"
              end
            end

            if i < STACK_EVAL_DEPTH
              frame_info.locals =
                frame_binding.local_variables.map do |local_var_name|
                  local_var = frame_binding.local_variable_get local_var_name

                  Variable.from_rb_var local_var, name: local_var_name,
                                                  var_table: variable_table
                end
            end

            @stack_frames << frame_info
          end
        end
      end
    end
  end
end
