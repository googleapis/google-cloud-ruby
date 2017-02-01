
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
            def eval_call_stack breakpoint, call_stack_bindings
              result = []
              call_stack_bindings.each_with_index do |frame_binding, i|
                frame_info = {
                  file_name: frame_binding.eval("__FILE__"),
                  line: frame_binding.eval("__LINE__"),
                  method_id: frame_binding.eval("__method__")
                }
                if i < STACK_EVAL_DEPTH
                  frame_info.merge! eval_frame(frame_binding)
                end

                if i < EXPRESSION_TRACE_DEPTH
                  frame_info.merge! \
                    eval_expressions(frame_binding, breakpoint.expressions)
                end

                result << frame_info
              end

              result
            end

            def eval_frame frame_binding
              result = {
                # self: frame_binding.eval("self.to_s"),
                local_variables: {}
              }

              frame_binding.local_variables.each do |local_var|
                result[:local_variables][local_var] =
                  frame_binding.local_variable_get(local_var).to_s
              end

              result
            end

            def eval_expressions binding, expressions
              result = {
                expressions: {}
              }

              expressions.each do |expression|
                result[:expressions][expression] =
                  readonly_eval_expression binding, expression
              end

              result
            end

            def readonly_eval_expression binding, expression
              yarv_instructions =
                RubyVM::InstructionSequence.compile(expression).disasm

              fail "Mutation detected!" unless
                immutable_yarv_instructions? yarv_instructions

              wrapped_expression = wrap_expression expression

              binding.eval wrapped_expression
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
                  immutable_trace_callback tp
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

            def self.trace_c_func_callback tp
              nil
            end
          end
        end
      end
    end
  end
end

