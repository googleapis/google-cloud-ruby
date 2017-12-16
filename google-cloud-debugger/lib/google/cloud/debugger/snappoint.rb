# Copyright 2017 Google LLC
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
      ##
      # # Snappoint
      #
      # A kind of {Google::Cloud::Debugger::Breakpoint} that can be evaluated
      # to capture the state of the program at time of evaluation. This is
      # essentially a {Google::Cloud::Debugger::Breakpoint} with action attrubte
      # set to `:CAPTURE`
      #
      class Snappoint < Breakpoint
        ##
        # Max number of top stacks to collect local variables information
        STACK_EVAL_DEPTH = 5

        ##
        # Max size of payload a Snappoint collects
        MAX_PAYLOAD_SIZE = 32768 # 32KB

        ##
        # @private Max size an evaluated expression variable is allowed to be
        MAX_EXPRESSION_LIMIT = 32768 # 32KB

        ##
        # @private Max size a normal evaluated variable is allowed to be
        MAX_VAR_LIMIT = 1024 # 1KB

        ##
        # @private Construct a new Snappoint instance.
        def initialize *args
          super

          init_var_table
        end

        ##
        # @private Initialize the variable table by inserting a buffer full
        # variable at index 0. This variable will be shared by other variable
        # evaluations if this Snappoint exceeds size limit.
        def init_var_table
          return if @variable_table[0] &&
                    @variable_table[0].buffer_full_variable?

          buffer_full_var = Variable.buffer_full_variable
          @variable_table.variables.unshift buffer_full_var
        end

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
        # @param [Binding] bind The binding object from the context
        #
        def eval_expressions bind
          @evaluated_expressions = []

          expressions.each do |expression|
            eval_result = Evaluator.readonly_eval_expression bind, expression

            if eval_result.is_a?(Exception) &&
               eval_result.instance_variable_get(:@mutation_cause)
              evaluated_var = Variable.new
              evaluated_var.name = expression
              evaluated_var.set_error_state \
                "Error: #{eval_result.message}",
                refers_to: StatusMessage::VARIABLE_VALUE
            else
              evaluated_var = convert_variable eval_result,
                                               name: expression,
                                               limit: MAX_EXPRESSION_LIMIT
            end

            @evaluated_expressions << evaluated_var
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
          @stack_frames = []

          call_stack_bindings.each_with_index do |frame_binding, i|
            frame_info = StackFrame.new.tap do |sf|
              sf.function = frame_binding.eval("__method__").to_s
              sf.location = SourceLocation.new.tap do |l|
                l.path =
                  frame_binding.eval "::File.absolute_path(__FILE__)"
                l.line = frame_binding.eval "__LINE__"
              end
            end

            @stack_frames << frame_info

            next if i >= STACK_EVAL_DEPTH

            frame_binding.local_variables.each do |local_var_name|
              local_var = frame_binding.local_variable_get local_var_name
              var = convert_variable local_var, name: local_var_name,
                                                limit: MAX_VAR_LIMIT

              frame_info.locals << var
            end
          end
        end

        private

        ##
        # @private Compute the total size of all the evaluated variables in
        # this breakpoint.
        def calculate_total_size
          result = evaluated_expressions.inject(0) do |sum, exp|
            sum + exp.payload_size
          end

          stack_frames.each do |stack_frame|
            result = stack_frame.locals.inject(result) do |sum, local|
              sum + local.payload_size
            end
          end

          result = variable_table.variables.inject(result) do |sum, var|
            sum + var.payload_size
          end

          result
        end

        ##
        # @private Translate a Ruby variable into a {Breakpoint::Variable}.
        # If the existing evaluated variables already exceed maximum allowed
        # size, then return a buffer full warning variable instead.
        def convert_variable source, name: nil, limit: nil
          current_total_size = calculate_total_size
          var = Variable.from_rb_var source, name: name, limit: limit,
                                             var_table: variable_table

          if (current_total_size + var.payload_size <= MAX_PAYLOAD_SIZE) ||
             var.reference_variable?
            var
          else
            Breakpoint::Variable.buffer_full_variable variable_table, name: name
          end
        end
      end
    end
  end
end
