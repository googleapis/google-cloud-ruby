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
      ##
      # # Logpoint
      #
      # A kind of {Google::Cloud::Debugger::Breakpoint} that can be evaluated
      # to generate a formatted log string, which later can be submitted to
      # Stackdriver Logging service
      #
      class Logpoint < Breakpoint
        ##
        # Evaluate the breakpoint unless it's already marked as completed.
        # Store evaluted expressions and stack frame variables in
        # `@evaluated_expressions` and `@evaluated_log_message`.
        #
        # @param [Array<Binding>] call_stack_bindings An array of Ruby Binding
        #   objects, from the call stack that leads to the triggering of the
        #   breakpoints.
        #
        # @return [Boolean] True if evaluated successfully; false otherwise.
        #
        def evaluate call_stack_bindings
          synchronize do
            binding = call_stack_bindings[0]

            return false if complete? || !check_condition(binding)

            begin
              evaluate_log_message binding
            rescue
              return false
            end
          end

          true
        end

        ##
        # @private Evaluate the expressions and log message. Store the result
        # in @evaluated_log_message
        def evaluate_log_message binding
          evaluated_expressions = expressions.map do |expression|
            Evaluator.readonly_eval_expression binding, expression
          end

          @evaluated_log_message =
            format_message log_message_format, evaluated_expressions
        end

        ##
        # @private Format log message by interpolate expressions.
        #
        # @example
        #   log_point = Google::Cloud::Debugger::Logpoint.new
        #   log_point.format_message(
        #     "Hello $0", ["World"]) #=> "Hello \"World\""
        #
        # @param [String] message_format The message with with
        #   expression placeholders such as `$0`, `$1`, etc.
        # @param [Array<Google::Cloud::Debugger::Breakpoint::Variable>]
        #   expressions An array of evaluated expression variables to be
        #   placed into message_format's placeholders. The variables need
        #   to have type equal String.
        #
        # @return [String] The formatted message string
        #
        def format_message message_format, expressions
          # Substitute placeholders with expressions
          message = message_format.gsub(/(?<!\$)\$\d+/) do |placeholder|
            index = placeholder.match(/\$(\d+)/)[1].to_i
            index < expressions.size ? expressions[index].inspect : ""
          end

          # Unescape "$" characters
          message.gsub(/\$\$/, "$")
        end
      end
    end
  end
end
