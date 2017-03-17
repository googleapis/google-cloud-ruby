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

          BYTE_CODE_BLACKLIST = %w{
            setinstancevariable
            setclassvariable
            setconstant
            setglobal
            defineclass
            opt_ltlt
            opt_aset
            opt_aset_with
          }.freeze

          LOCAL_BYTE_CODE_BLACKLIST = %w{
            setlocal
          }.freeze

          FUNC_CALL_FLAG_BLACKLIST = %w{
            ARGS_BLOCKARG
          }.freeze

          CATCH_TABLE_TYPE_BLACKLIST = %w{
            rescue
          }.freeze

          BYTE_CODE_BLACKLIST_REGEX = /^\d+ #{BYTE_CODE_BLACKLIST.join '|'}/

          FULL_BYTE_CODE_BLACKLIST_REGEX = /^\d+ #{
              [*BYTE_CODE_BLACKLIST, *LOCAL_BYTE_CODE_BLACKLIST].join '|'
          }/

          FUNC_CALL_FLAG_BLACKLIST_REGEX =
            /<callinfo!.+#{FUNC_CALL_FLAG_BLACKLIST.join '|'}/

          CATCH_TABLE_BLACKLIST_REGEX =
            /catch table.*catch type: #{CATCH_TABLE_TYPE_BLACKLIST.join '|'}/m

          private_constant :BYTE_CODE_BLACKLIST_REGEX,
                           :FULL_BYTE_CODE_BLACKLIST_REGEX,
                           :FUNC_CALL_FLAG_BLACKLIST_REGEX,
                           :CATCH_TABLE_BLACKLIST_REGEX

          IMMUTABLE_CLASSES = [
            Complex,
            FalseClass,
            Float,
            MatchData,
            NilClass,
            Numeric,
            Proc,
            Range,
            Regexp,
            Struct,
            Symbol,
            TrueClass,
            Comparable,
            Enumerable,
            Math
          ].concat(
            RUBY_VERSION.to_f >= 2.4 ? [Integer] : [Bignum, Fixnum]
          ).freeze

          def self.hashify ary
            ary.each.with_index(1).to_h
          end
          private_class_method :hashify

          C_CLASS_METHOD_WHITELIST = {
            # Classes
            Array => hashify(%I{
              new
              []
              try_convert
            }).freeze,
            BasicObject => hashify(%I{
              new
            }).freeze,
            Exception => hashify(%I{
              exception
              new
            }).freeze,
            Enumerator => hashify(%I{
              new
            }).freeze,
            Fiber => hashify(%I{
              current
            }).freeze,
            File => hashify(%I{
              basename
              dirname
              extname
              join
              path
              split
            }).freeze,
            Hash => hashify(%I{
              []
              new
              try_convert
            }).freeze,
            Module => hashify(%I{
              constants
              nesting
              used_modules
            }).freeze,
            Object => hashify(%I{
              new
            }).freeze,
            String => hashify(%I{
              new
              try_convert
            }).freeze,
            Thread => hashify(%I{
              DEBUG
              abort_on_exception
              current
              list
              main
              pending_interrupt?
              report_on_exception
            }).freeze,
            Time => hashify(%I{
              at
              gm
              local
              mktime
              new
              now
              utc
            }).freeze,
            Google::Cloud::Debugger::Breakpoint::Evaluator => hashify(%I{
              disable_method_trace_for_thread
            }).freeze,
          }.freeze

          C_INSTANCE_METHOD_WHITELIST = {
            Array => hashify(%I{
              initialize
              &
              *
              +
              -
              <=>
              ==
              any?
              assoc
              at
              bsearch
              bsearch_index
              collect
              combination
              compact
              []
              count
              cycle
              dig
              drop
              drop_while
              each
              each_index
              empty?
              eql?
              fetch
              find_index
              first
              flatten
              frozen?
              hash
              include?
              index
              inspect
              to_s
              join
              last
              length
              map
              max
              min
              pack
              permutation
              product
              rassoc
              reject
              repeated_combination
              repeated_permutation
              reverse
              reverse_each
              rindex
              rotate
              sample
              select
              shuffle
              size
              slice
              sort
              sum
              take
              take_while
              to_a
              to_ary
              to_h
              transpose
              uniq
              values_at
              zip
              |
            }).freeze,
            BasicObject => hashify(%I{
              initialize
              !
              !=
              ==
              __id__
              object_id
              send
              __send__
              equal?
            }).freeze,
            Binding => hashify(%I{
              local_variable_defined?
              local_variable_get
              local_variables
              receiver
            }).freeze,
            Class => hashify(%I{
              superclass
            }).freeze,
            Dir => hashify(%I{
              inspect
              path
              to_path
            }).freeze,
            Exception => hashify(%I{
              initialize
              ==
              backtrace
              backtrace_locations
              cause
              exception
              inspect
              message
              to_s
            }).freeze,
            Enumerator => hashify(%I{
              initialize
              each
              each_with_index
              each_with_object
              inspect
              size
              with_index
              with_object
            }).freeze,
            Fiber => hashify(%I{
              alive?
            }).freeze,
            File => hashify(%I{
              path
              to_path
            }).freeze,
            Hash => hashify(%I{
              initialize
              <
              <=
              ==
              >
              >=
              []
              any?
              assoc
              compact
              compare_by_identity?
              default_proc
              dig
              each
              each_key
              each_pair
              each_value
              empty?
              eql?
              fetch
              fetch_values
              flatten
              has_key?
              has_value?
              hash
              include?
              to_s
              inspect
              invert
              key
              key?
              keys
              length
              member?
              merge
              rassoc
              reject
              select
              size
              to_a
              to_h
              to_hash
              to_proc
              transform_values
              value?
              values
              value_at
            }).freeze,
            IO => hashify(%I{
              autoclose?
              binmode?
              close_on_exec?
              closed?
              encoding
              inspect
              internal_encoding
              sync
            }).freeze,
            Method => hashify(%I{
              ==
              []
              arity
              call
              clone
              curry
              eql?
              hash
              inspect
              name
              original_name
              owner
              parameters
              receiver
              source_location
              super_method
              to_proc
              to_s
            }).freeze,
            Module => hashify(%I{
              <
              <=
              <=>
              ==
              ===
              >
              >=
              ancestors
              autoload?
              class_variable_defined?
              class_variable_get
              class_variables
              const_defined?
              const_get
              constants
              include?
              included_modules
              inspect
              instance_method
              instance_methods
              method_defined?
              name
              private_instance_methods
              private_method_defined?
              protected_instance_methods
              protected_method_defined?
              public_instance_method
              public_instance_methods
              public_method_defined?
              singleton_class?
              to_s
            }).freeze,
            Mutex => hashify(%I{
              locked?
              owned?
            }).freeze,
            # Object => hashify(%I{
            #   !~
            #   <=>
            #   ===
            #   =~
            #   class
            #   clone
            #   dup
            #   enum_for
            #   eql?
            #   equal?
            #   frozen?
            #   hash
            #   inspect
            #   instance_of?
            #   instance_variable_defined?
            #   instance_variable_get
            #   instance_variables
            #   is_a?
            #   itself
            #   kind_of?
            #   method
            #   methods
            #   nil?
            #   object_id
            #   private_methods
            #   protected_methods
            #   public_method
            #   public_methods
            #   public_send
            #   respond_to?
            #   respond_to_missing?
            #   __send__
            #   send
            #   singleton_class
            #   singleton_method
            #   singleton_methods
            #   tainted?
            #   tap
            #   to_enum
            #   to_s
            #   untrusted?
            # }).freeze,
            String => hashify(%I{
              initialize
              %
              *
              +
              +@
              -@
              <=>
              ==
              ===
              =~
              []
              ascii_only?
              b
              bytes
              bytesize
              byteslice
              capitalize
              casecmp
              casecmp?
              center
              chars
              chomp
              chop
              chr
              codepoints
              count
              crypt
              delete
              downcase
              dump
              each_byte
              each_char
              each_codepoint
              each_line
              empty?
              encoding
              end_with?
              eql?
              getbyte
              gsub
              hash
              hex
              include?
              index
              inspect
              intern
              length
              lines
              ljust
              lstrip
              match
              match?
              next
              oct
              ord
              partition
              reverse
              rindex
              rjust
              rpartition
              rstrip
              scan
              scrub
              size
              slice
              split
              squeeze
              start_with?
              strip
              sub
              succ
              sum
              swapcase
              to_c
              to_f
              to_i
              to_r
              to_s
              to_str
              to_sym
              tr
              tr_s
              unpack
              unpack1
              upcase
              upto
              valid_encoding?
            }).freeze,
            ThreadGroup => hashify(%I{
              enclosed?
              list
            }).freeze,
            Thread => hashify(%I{
              []
              abort_on_exception
              alive?
              backtrace
              backtrace_locations
              group
              inspect
              key?
              keys
              name
              pending_interrupt?
              priority
              report_on_exception
              safe_level
              status
              stop?
              thread_variable?
              thread_variable_get
              thread_variables
            }).freeze,
            Time => hashify(%I{
              initialize
              +
              -
              <=>
              asctime
              ctime
              day
              dst?
              eql?
              friday?
              getgm
              getlocal
              getuc
              gmt
              gmt_offset
              gmtoff
              hash
              hour
              inspect
              isdst
              mday
              min
              mon
              month
              monday?
              month
              nsec
              round
              saturday?
              sec
              strftime
              subsec
              succ
              sunday?
              thursday?
              to_a
              to_f
              to_i
              to_r
              to_s
              tuesday?
              tv_nsec
              tv_sec
              tv_usec
              usec
              utc?
              utc_offset
              wday
              wednesday?
              yday
              year
              zone
            }).freeze,
            UnboundMethod => hashify(%I{
              ==
              arity
              clone
              eql?
              hash
              inspect
              name
              original_name
              owner
              parameters
              source_location
              super_method
              to_s
            }).freeze,
            # Modules
            Kernel => hashify(%I{
              Array
              Complex
              Float
              Hash
              Integer
              Rational
              String
              __callee__
              __dir__
              __method__
              autoload?
              block_given?
              caller
              caller_locations
              catch
              format
              global_variables
              iterator?
              lambda
              local_variables
              loop
              method
              methods
              proc
              rand
              !~
              <=>
              ===
              =~
              class
              clone
              dup
              enum_for
              eql?
              frozen?
              hash
              inspect
              instance_of?
              instance_variable_defined?
              instance_variable_get
              instance_variables
              is_a?
              itself
              kind_of?
              nil?
              object_id
              private_methods
              protected_methods
              public_method
              public_methods
              public_send
              respond_to?
              respond_to_missing?
              __send__
              send
              singleton_class
              singleton_method
              singleton_methods
              tainted?
              tap
              to_enum
              to_s
              untrusted?
            }).freeze,
          }.freeze

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

            # TODO fix false possible of evaluating error condition
            def eval_condition binding, condition
              !!readonly_eval_expression(binding, condition)
            end

            def eval_expressions binding, expressions
              expressions.map do |expression|
                eval_result = readonly_eval_expression binding, expression
                evaluated_var = Variable.from_rb_var eval_result
                evaluated_var.name = expression
                evaluated_var
              end
            end

            def readonly_eval_expression binding, expression
              begin
                yarv_instructions =
                  RubyVM::InstructionSequence.compile(expression).disasm
              rescue ScriptError
                return "Unable to compile expression"
              end

              return "Mutation detected!" unless
                immutable_yarv_instructions? yarv_instructions

              # The evaluation is most likely triggered from a trace callback,
              # so addtional tracing is disabled by VM. So we do actual
              # evaluation in a new thread, where function calls can be traced.
              thr = Thread.new {
                eval_result = nil
                wrapped_expression = wrap_expression expression
                begin
                    eval_result = binding.eval wrapped_expression
                rescue Google::Cloud::Debugger::MutationError => e
                  eval_result = e.message
                rescue Exception => e
                  eval_result = "Unable to evaluate expression: #{}"
                end
                eval_result
              }

              thr.join.value
            end

            private

            def eval_frame_variables frame_binding
              result_variables = []
              result_variables += frame_binding.local_variables.map do |local_var_name|
                local_var = frame_binding.local_variable_get(local_var_name)

                Variable.from_rb_var(local_var, name: local_var_name)
              end

              result_variables
            end

            def immutable_yarv_instructions? yarv_instructions, allow_localops: false
              if allow_localops
                byte_code_blacklist_regex = BYTE_CODE_BLACKLIST_REGEX
              else
                byte_code_blacklist_regex = FULL_BYTE_CODE_BLACKLIST_REGEX
              end

              func_call_flag_blacklist_regex = FUNC_CALL_FLAG_BLACKLIST_REGEX

              catch_table_type_blacklist_regex = CATCH_TABLE_BLACKLIST_REGEX

              !(yarv_instructions.match(func_call_flag_blacklist_regex) ||
                yarv_instructions.match(byte_code_blacklist_regex) ||
                yarv_instructions.match(catch_table_type_blacklist_regex))
            end

            def wrap_expression expression
              return """
                begin
                  Google::Cloud::Debugger::Breakpoint::Evaluator.send(
                    :enable_method_trace_for_thread)
                  #{expression}
                ensure
                  Google::Cloud::Debugger::Breakpoint::Evaluator.disable_method_trace_for_thread
                end
              """
            end


            def trace_func_callback receiver, mid
              meth = receiver.method mid
              yarv_instructions = RubyVM::InstructionSequence.disasm meth

              fail Google::Cloud::Debugger::MutationError unless
                immutable_yarv_instructions? yarv_instructions,
                                             allow_localops: true
            end

            def trace_c_func_callback receiver, defined_class, mid
              if receiver.is_a?(Class) || receiver.is_a?(Module)
                klass = receiver

                unless IMMUTABLE_CLASSES.include?(klass) ||
                  (C_CLASS_METHOD_WHITELIST[klass] || {})[mid] ||
                  (C_INSTANCE_METHOD_WHITELIST[defined_class] || {})[mid]
                  invalid_op = true
                end
              else
                klass = defined_class
                unless IMMUTABLE_CLASSES.include?(klass) ||
                  (C_INSTANCE_METHOD_WHITELIST[klass] || {})[mid]
                  invalid_op = true
                end
              end

              if invalid_op
                fail Google::Cloud::Debugger::MutationError,
                     "Invalid operation detected"
              end
            end
          end
        end
      end

      class MutationError < StandardError
        attr_reader :message

        def initialize msg = "Mutation detected!"
          @message = msg
        end

        def inspect
          "#<MutationError: #{message}>"
        end
      end
    end
  end
end

