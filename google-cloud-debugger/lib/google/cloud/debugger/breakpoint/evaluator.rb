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


require "google/cloud/debugger/breakpoint/source_location"
require "google/cloud/debugger/breakpoint/stack_frame"
require "google/cloud/debugger/breakpoint/variable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        ##
        # Helps to evaluate program state at the location of breakpoint during
        # executing. The program state, such as local variables and call stack,
        # are retrieved using Ruby Binding objects.
        #
        # The breakpoints may consist of conditional expression and other
        # code expressions. The Evaluator helps evaluates these expression in
        # a read-only context. Meaning if the expressions trigger any write
        # operations in middle of the evaluation, the evaluator is able to
        # abort the operation and prevent the program state from being altered.
        #
        # The evaluated results are saved onto the breakpoints fields. See
        # [Stackdriver Breakpoints
        # Doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Breakpoint)
        # for details.
        #
        module Evaluator
          ##
          # @private YARV bytecode that the evaluator blocks during expression
          # evaluation. If the breakpoint contains expressions that uses the
          # following bytecode, the evaluator will block the expression
          # evaluation from execusion.
          BYTE_CODE_BLACKLIST = %w(
            setinstancevariable
            setclassvariable
            setconstant
            setglobal
            defineclass
            opt_ltlt
            opt_aset
            opt_aset_with
          ).freeze

          ##
          # @private YARV bytecode that the evaluator blocks during expression
          # evaluation on the top level. (not from within by predefined methods)
          LOCAL_BYTE_CODE_BLACKLIST = %w(
            setlocal
          ).freeze

          ##
          # @private YARV bytecode call flags that the evaluator blocks during
          # expression evaluation
          FUNC_CALL_FLAG_BLACKLIST = %w(
            ARGS_BLOCKARG
          ).freeze

          ##
          # @private YARV instructions catch table type that the evaluator
          # blocks during expression evaluation
          CATCH_TABLE_TYPE_BLACKLIST = %w(
            rescue
          ).freeze

          ##
          # @private Predefined regex. Saves time during runtime.
          BYTE_CODE_BLACKLIST_REGEX = /^\d+ #{BYTE_CODE_BLACKLIST.join '|'}/

          ##
          # @private Predefined regex. Saves time during runtime.
          FULL_BYTE_CODE_BLACKLIST_REGEX = /^\d+ #{
              [*BYTE_CODE_BLACKLIST, *LOCAL_BYTE_CODE_BLACKLIST].join '|'
          }/

          ##
          # @private Predefined regex. Saves time during runtime.
          FUNC_CALL_FLAG_BLACKLIST_REGEX =
            /<callinfo!.+#{FUNC_CALL_FLAG_BLACKLIST.join '|'}/

          ##
          # @private Predefined regex. Saves time during runtime.
          CATCH_TABLE_BLACKLIST_REGEX =
            /catch table.*catch type: #{CATCH_TABLE_TYPE_BLACKLIST.join '|'}/m

          private_constant :BYTE_CODE_BLACKLIST_REGEX,
                           :FULL_BYTE_CODE_BLACKLIST_REGEX,
                           :FUNC_CALL_FLAG_BLACKLIST_REGEX,
                           :CATCH_TABLE_BLACKLIST_REGEX

          ##
          # @private List of pre-approved classes to be used during expression
          # evaluation.
          IMMUTABLE_CLASSES = [
            Complex,
            FalseClass,
            Float,
            Integer,
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
            RUBY_VERSION.to_f >= 2.4 ? [] : [Bignum, Fixnum]
          ).freeze

          ##
          # @private helper method to hashify an array
          def self.hashify ary
            ary.each.with_index(1).to_h
          end
          private_class_method :hashify

          ##
          # @private List of C level class methods that the evaluator allows
          # during expression evaluation
          C_CLASS_METHOD_WHITELIST = {
            # Classes
            ArgumentError => hashify(%I{
              new
            }).freeze,
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
            FiberError => hashify(%I{
              new
            }).freeze,
            File => hashify(%I{
              basename
              dirname
              extname
              join
              path
              split
            }).freeze,
            FloatDomainError => hashify(%I{
              new
            }).freeze,
            Hash => hashify(%I{
              []
              new
              try_convert
            }).freeze,
            IndexError => hashify(%I{
              new
            }).freeze,
            KeyError => hashify(%I{
              new
            }).freeze,
            Module => hashify(%I{
              constants
              nesting
              used_modules
            }).freeze,
            NameError => hashify(%I{
              new
            }).freeze,
            NoMethodError => hashify(%I{
              new
            }).freeze,
            Object => hashify(%I{
              new
            }).freeze,
            RangeError => hashify(%I{
              new
            }).freeze,
            RegexpError => hashify(%I{
              new
            }).freeze,
            RuntimeError => hashify(%I{
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
            TypeError => hashify(%I{
              new
            }).freeze,
            Google::Cloud::Debugger::Breakpoint::Evaluator => hashify(%I{
              disable_method_trace_for_thread
            }).freeze,
            ZeroDivisionError => hashify(%I{
              new
            }).freeze
          }.freeze

          ##
          # @private List of C level instance methods that the evaluator allows
          # during expression evaluation
          C_INSTANCE_METHOD_WHITELIST = {
            ArgumentError => hashify(%I{
              initialize
            }).freeze,
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
              method_missing
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
            FiberError => hashify(%I{
              initialize
            }).freeze,
            File => hashify(%I{
              path
              to_path
            }).freeze,
            FloatDomainError => hashify(%I{
              initialize
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
            IndexError => hashify(%I{
              initialize
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
            KeyError => hashify(%I{
              initialize
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
            NameError => hashify(%I{
              initialize
            }).freeze,
            NoMethodError => hashify(%I{
              initialize
            }).freeze,
            RangeError => hashify(%I{
              initialize
            }).freeze,
            RegexpError => hashify(%I{
              initialize
            }).freeze,
            RuntimeError => hashify(%I{
              initialize
            }).freeze,
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
            TypeError => hashify(%I{
              initialize
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
            ZeroDivisionError => hashify(%I{
              initialize
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
            }).freeze
          }.freeze

          PROHIBITED_OPERATION_MSG = "Prohibited operation detected".freeze
          MUTATION_DETECTED_MSG = "Mutation detected!".freeze
          COMPILATION_FAIL_MSG = "Unable to compile expression".freeze
          LONG_EVAL_MSG = "Evaluation exceeded time limit".freeze

          EXPRESSION_EVALUATION_TIME_THRESHOLD = 0.05

          class << self
            ##
            # @private Read-only evaluates a single expression in a given
            # context binding. Handles any exceptions raised.
            #
            # @param [Binding] binding The binding object from the context
            # @param [String] expression A string of code to be evaluates
            #
            # @return [Object] The result Ruby object from evaluating the
            #   expression. If the expression is blocked from mutating
            #   the state of program. A
            #   {Google::Cloud::Debugger::MutationError} will be returned.
            #
            def readonly_eval_expression binding, expression
              compilation_result = validate_compiled_expression expression
              return compilation_result if compilation_result.is_a?(Exception)

              readonly_eval_expression_exec binding, expression
            rescue => e
              "Unable to evaluate expression: #{e.message}"
            end

            private

            ##
            # @private Actually read-only evaluates an expression in a given
            # context binding. The evaluation is done in a separate thread due
            # to this method may be run from Ruby Trace call back, where
            # addtional code tracing is disabled in original thread.
            #
            # @param [Binding] binding The binding object from the context
            # @param [String] expression A string of code to be evaluates
            #
            # @return [Object] The result Ruby object from evaluating the
            #   expression. It returns Google::Cloud::Debugger::MutationError
            #   if a mutation is caught.
            #
            def readonly_eval_expression_exec binding, expression
              # The evaluation is most likely triggered from a trace callback,
              # where addtional nested tracing is disabled by VM. So we need to
              # do evaluation in a new thread, where function calls can be
              # traced.
              thr = Thread.new do
                begin
                  binding.eval wrap_expression(expression)
                rescue => e
                  # Treat all StandardError as mutation and set @mutation_cause
                  unless e.instance_variable_get :@mutation_cause
                    e.instance_variable_set(
                      :@mutation_cause,
                      Google::Cloud::Debugger::EvaluationError::UNKNOWN_CAUSE)
                  end

                  e
                end
              end

              thr.join EXPRESSION_EVALUATION_TIME_THRESHOLD

              # Force terminate evaluation thread if not finished already and
              # return an Exception
              if thr.alive?
                thr.kill

                Google::Cloud::Debugger::EvaluationError.new LONG_EVAL_MSG
              else
                thr.value
              end
            end

            ##
            # @private Compile the expression into YARV instructions. Return
            # Google::Cloud::Debugger::MutationError if any prohibited YARV
            # instructions are found.
            #
            # @param [String] expression String of code expression
            #
            # @return [String,Google::Cloud::Debugger::MutationError] It returns
            #   the compile YARV instructions if no prohibited bytecodes are
            #   found. Otherwise return Google::Cloud::Debugger::MutationError.
            #
            def validate_compiled_expression expression
              begin
                yarv_instructions =
                  RubyVM::InstructionSequence.compile(expression).disasm
              rescue ScriptError
                return Google::Cloud::Debugger::MutationError.new(
                  COMPILATION_FAIL_MSG,
                  Google::Cloud::Debugger::EvaluationError::PROHIBITED_YARV
                )
              end

              unless immutable_yarv_instructions? yarv_instructions
                return Google::Cloud::Debugger::MutationError.new(
                  MUTATION_DETECTED_MSG,
                  Google::Cloud::Debugger::EvaluationError::PROHIBITED_YARV
                )
              end

              yarv_instructions
            end

            ##
            # @private Helps checking if a given set of YARV instructions
            # contains any prohibited bytecode or instructions.
            #
            # @param [String] yarv_instructions Compiled YARV instructions
            #   string
            # @param [Boolean] allow_localops Whether allows local variable
            #   write operations
            #
            # @return [Boolean] True if the YARV instructions don't contain any
            #   prohibited operations. Otherwise false.
            #
            def immutable_yarv_instructions? yarv_instructions,
                                             allow_localops: false
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

            ##
            # @private Wraps expression with tracing code
            def wrap_expression expression
              """
                begin
                  Google::Cloud::Debugger::Breakpoint::Evaluator.send(
                    :enable_method_trace_for_thread)
                  #{expression}
                ensure
                  Google::Cloud::Debugger::Breakpoint::Evaluator.send(
                    :disable_method_trace_for_thread)
                end
              """
            end

            ##
            # @private Evaluation tracing callback function. This is called
            # everytime a Ruby function is called during evaluation of
            # an expression.
            #
            # @param [Object] receiver The receiver of the function being called
            # @param [Symbol] mid The method name
            #
            # @return [NilClass] Nil if no prohibited operations are found.
            #   Otherwise raise Google::Cloud::Debugger::MutationError error.
            #
            def trace_func_callback receiver, mid
              meth = nil
              begin
                meth = receiver.method mid
              rescue
                raise Google::Cloud::Debugger::EvaluationError.new(
                  PROHIBITED_OPERATION_MSG,
                  Google::Cloud::Debugger::EvaluationError::META_PROGRAMMING)
              end

              yarv_instructions = RubyVM::InstructionSequence.disasm meth

              return if immutable_yarv_instructions?(yarv_instructions,
                                                     allow_localops: true)
              fail Google::Cloud::Debugger::MutationError.new(
                MUTATION_DETECTED_MSG,
                Google::Cloud::Debugger::EvaluationError::PROHIBITED_YARV)
            end

            ##
            # @private Evaluation tracing callback function. This is called
            # everytime a C function is called during evaluation of
            # an expression.
            #
            # @param [Object] receiver The receiver of the function being called
            # @param [Class] defined_class The Class of where the function is
            #   defined
            # @param [Symbol] mid The method name
            #
            # @return [NilClass] Nil if no prohibited operations are found.
            #   Otherwise raise Google::Cloud::Debugger::MutationError error.
            #
            def trace_c_func_callback receiver, defined_class, mid
              if receiver.is_a?(Class) || receiver.is_a?(Module)
                invalid_op =
                  !validate_c_class_method(defined_class, receiver, mid)
              else
                invalid_op = !validate_c_instance_method(defined_class, mid)
              end

              return unless invalid_op

              Google::Cloud::Debugger::Breakpoint::Evaluator.send(
                :disable_method_trace_for_thread)
              fail Google::Cloud::Debugger::MutationError.new(
                PROHIBITED_OPERATION_MSG,
                Google::Cloud::Debugger::EvaluationError::PROHIBITED_C_FUNC)
            end

            ##
            # @private Helper method to verify wehter a C level class method
            # is allowed or not.
            def validate_c_class_method klass, receiver, mid
              IMMUTABLE_CLASSES.include?(receiver) ||
                (C_CLASS_METHOD_WHITELIST[receiver] || {})[mid] ||
                (C_INSTANCE_METHOD_WHITELIST[klass] || {})[mid]
            end

            ##
            # @private Helper method to verify wehter a C level instance method
            # is allowed or not.
            def validate_c_instance_method klass, mid
              IMMUTABLE_CLASSES.include?(klass) ||
                (C_INSTANCE_METHOD_WHITELIST[klass] || {})[mid]
            end
          end
        end
      end

      ##
      # @private Custom error type used to identify evaluation error during
      # breakpoint expression evaluation.
      class EvaluationError < StandardError
        UNKNOWN_CAUSE = :unknown_cause
        PROHIBITED_YARV = :prohibited_yarv
        PROHIBITED_C_FUNC = :prohibited_c_func
        META_PROGRAMMING = :meta_programming

        attr_reader :mutation_cause

        def initialize msg = nil, mutation_cause = UNKNOWN_CAUSE
          @mutation_cause = mutation_cause
          super(msg)
        end

        def inspect
          "#<#{self.class}: #{message}>"
        end
      end

      ##
      # @private Custom error type used to identify mutation during breakpoint
      # expression evaluations
      class MutationError < EvaluationError
        def initialize msg = "Mutation detected!", *args
          super
        end
      end
    end
  end
end
