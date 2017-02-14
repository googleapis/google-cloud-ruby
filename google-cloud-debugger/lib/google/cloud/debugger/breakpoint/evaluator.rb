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


require "google/cloud/debugger/breakpoint/source_location"
require "google/cloud/debugger/breakpoint/stack_frame"
require "google/cloud/debugger/breakpoint/variable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        module Evaluator
          STACK_EVAL_DEPTH = 5
          EXPRESSION_TRACE_DEPTH = 1

          YARV_INS_BLACKLIST = %w{
            setglobal
          }

          class << self
            def eval_call_stack call_stack_bindings
              result = []
              call_stack_bindings.each_with_index do |frame_binding, i|
                frame_info = StackFrame.new.tap do |sf|
                  sf.function = frame_binding.eval("__method__").to_s
                  sf.location = SourceLocation.new.tap do |l|
                    l.path = frame_binding.eval("::File.absolute_path(__FILE__)")
                    l.line = frame_binding.eval("__LINE__")
                  end
                end

                if i < STACK_EVAL_DEPTH
                  frame_info.locals = eval_frame_variables frame_binding
                end

                result << frame_info
              end

              result
            end

            def eval_expressions binding, expressions
              expressions.map do |expression|
                eval_result = readonly_eval_expression binding, expression
                evaluated_var = Variable.from_rb_var eval_result
                evaluated_var.name = expression
                evaluated_var
              end
            end

            private

            def eval_frame_variables frame_binding
              result_variables = []

              result_variables << Variable.from_rb_var(frame_binding.receiver,
                                                       name: "self")

              result_variables += frame_binding.local_variables.map do |local_var_name|
                local_var = frame_binding.local_variable_get(local_var_name)

                Variable.from_rb_var(local_var, name: local_var_name)
              end

              result_variables
            end

            def readonly_eval_expression binding, expression
              yarv_instructions =
                RubyVM::InstructionSequence.compile(expression).disasm

              fail "Mutation detected!" unless
                immutable_yarv_instructions? yarv_instructions

              wrapped_expression = wrap_expression expression

              eval_result =
                begin
                  binding.eval wrapped_expression
                rescue
                  "Unable to evaluate expression"
                end

              eval_result

            end

            def immutable_yarv_instructions? yarv_instructions, allow_setlocal: false
              blacklist = YARV_INS_BLACKLIST

              blacklist << "setlocal" unless allow_setlocal

              blacklist_regex = blacklist.join '|'

              yarv_instructions.match(blacklist_regex) ? false : true
            end

            def wrap_expression expression
              return """
                tp = TracePoint.new(:call, :c_call) do |tp|
                  # immutable_trace_callback tp
                end.enable do
                  begin
                    #{expression}
                  rescue => e
                    e.message
                  end
                end
              """
            end

            def immutable_trace_callback tp
              case tp.event
                when :call
                  trace_func_callback tp
                when :c_call
                  trace_c_func_callback tp
              end
            end

            def trace_func_callback tp
              meth = tp.self.method tp.method_id
              yarv_instructions = RubyVM::InstructionSequence.disasm meth

              fail "Mutation detected!" unless
                immutable_yarv_instructions? yarv_instructions,
                                             allow_setlocal: true
            end

            def trace_c_func_callback tp
              nil
            end
          end
        end
      end
    end
  end
end

