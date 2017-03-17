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


module Google
  module Cloud
    module Debugger
      class Breakpoint
        ##
        # # Variable
        #
        # Represents a variable or an argument possibly of a compound object
        # type. Note how the following variables are represented:
        #
        # A simple Variable:
        #   x = 5
        #   # Captured variable:
        #   # { name: "x", value: "5", type: "Integer" }
        #
        # A Compound Variable:
        #   class T
        #     attr_accessor :m1, :m2
        #     ...
        #   end
        #   v = T.new(1, "2")
        #   # Captured variable:
        #   # {
        #   #   name: "v",
        #   #   type: "T",
        #   #   members: [
        #   #     { name: "@m1", value: "1", type: "Integer" },
        #   #     { name: "@m2", value: "2", type: "String" }
        #   #   ]
        #   # }
        #
        # A Hash object:
        #   hash = { a: 1, b: :two }
        #   # Captured variable:
        #   # {
        #   #   name: "hash",
        #   #   type: "Hash",
        #   #   members: [
        #   #     { name: "a", value: "1", type: "Integer" },
        #   #     { name: "b", value: ":2", type: "Symbol" }
        #   #   ]
        #   # }
        #
        # An Array object:
        #   ary = [1, nil]
        #   # Captured variable:
        #   # {
        #   #   name: "ary",
        #   #   type: "Array",
        #   #   members: [
        #   #     { name: "[0]", value: "1", type: "Integer" },
        #   #     { name: "[1]", value: "nil", type: "NilClass" }
        #   #   ]
        #   # }
        #
        class Variable
          ##
          # Max depth to convert on compound variables
          MAX_DEPTH = 3

          ##
          # Max number of member variables to evaluate in compound variables
          # TODO: Reduce max members to just 10
          MAX_MEMBERS = 25

          ##
          # Max length on variable inspect results. Truncate extra and replace
          # with ellipsis.
          MAX_STRING_LENGTH = 260

          ##
          # @private Name of the variable, if any.
          # @return [String]
          attr_accessor :name

          ##
          # @private Simple value of the variable.
          # @return [String]
          attr_accessor :value

          ##
          # @private Variable type (e.g. MyClass). If the variable is split with
          # var_table_index, type goes next to value.
          # @return [String]
          attr_accessor :type

          ##
          # @private Members contained or pointed to by the variable.
          # @return [Array<Variable>]
          attr_accessor :members

          ##
          # @private Status associated with the variable. This field will
          # usually stay unset. A status of a single variable only applies to
          # that variable or expression. The rest of breakpoint data still
          # remains valid. Variables might be reported in error state even when
          # breakpoint is not in final state.
          # The message may refer to variable name with refers_to set to
          # VARIABLE_NAME. Alternatively refers_to will be set to
          # VARIABLE_VALUE. In either case variable value and members will be
          # unset.
          # TODO: Implement variable status
          # attr_accessor :status

          ##
          # @private Create an empty Variable object.
          def initialize
            @members = []
          end

          ##
          # Convert a Ruby variable into a
          # Google::Cloud::Debugger::Breakpoint::Variable object.
          #
          # @param [Any] source Source Ruby variable to convert from
          # @param [String] name Name of the varaible
          # @param [Integer] depth Number of levels to evaluate in compound
          #   variables. Default to
          #   {Google::Cloud::Debugger::Breakpoint::Variable::MAX_DEPTH}
          #
          # @example
          #   x = 3
          #   var = Variable.from_rb_var x, name: "x"
          #   var.name  #=> "x"
          #   var.value #=> "3"
          #   var.type  #=> "Integer"
          #
          # @example
          #   hash = {a: 1, b: :two}
          #   var = Variable.from_rb_var hash, name: "hash"
          #   var.name  #=> "hash"
          #   var.type  #=> "Hash"
          #   var.members[0].name  #=> "a"
          #   var.members[0].value #=> "1"
          #   var.members[0].type  #=> "Integer"
          #   var.members[1].name  #=> "b"
          #   var.members[1].value #=> "two"
          #   var.members[1].type  #=> "Symbol"
          #
          # TODO: add more examples
          #
          # @return [Google::Cloud::Debugger::Breakpoint::Variable] Converted
          #   variable.
          #

          def self.from_rb_var source, name: nil, depth: MAX_DEPTH
            return source if source.is_a? Variable

            if (source.is_a?(Hash) || source.is_a?(Array) ||
              !source.instance_variables.empty?) && depth > 0
              return from_compound_var source, name: name, depth: depth
            end

            var = Variable.new
            var.name = name.to_s if name
            var.type = source.class.to_s
            var.value = truncate_value(source.inspect)

            var
          end

          def self.from_compound_var source, name: nil, depth: MAX_DEPTH
            return source if source.is_a? Variable
            var = Variable.new
            var.name = name.to_s if name
            var.type = source.class.to_s

            case source
              when Hash
                add_compound_members var, source do |(k, v)|
                  from_rb_var(v, name: k, depth: depth - 1)
                end
              when Array
                add_compound_members var, source do |el, i|
                  from_rb_var(el, name: "[#{i}]", depth: depth - 1)
                end
              else
                add_compound_members var,
                                     source.instance_variables do |var_name|
                  instance_var = source.instance_variable_get var_name
                  from_rb_var(instance_var, name: var_name, depth: depth - 1)
                end
            end
            var
          end

          ##
          # @private Help interate through collection of member variables for
          # compound variables.
          def self.add_compound_members var, members
            members.each_with_index do |el, i|
              if i < MAX_MEMBERS
                var.members << yield(el, i)
              else
                var.members << Variable.new.tap { |last_var|
                  last_var.value = "(Only first 25 items were captured)"
                }
                break
              end
            end
          end

          ##
          # @private New Google::Cloud::Debugger::Breakpoint::Variable
          # from a Google::Devtools::Clouddebugger::V2::Variable object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |o|
              o.name    = grpc.name
              o.value   = grpc.value
              o.type    = grpc.type
              o.members = from_grpc_list grpc.members
            end
          end

          ##
          # @private New array of Google::Cloud::Debugger::Breakpoint::Variable
          # from an array of Google::Devtools::Clouddebugger::V2::Variable
          # objects.
          def self.from_grpc_list grpc_list
            return [] if grpc_list.nil?
            grpc_list.map { |var_grpc| from_grpc var_grpc }
          end

          ##
          # @private Limit string to MAX_STRING_LENTH. Replace extra characters
          # with ellipsis
          def self.truncate_value str
            str.gsub(/(.{#{MAX_STRING_LENGTH - 3}}).+/,'\1...')
          end
          private_class_method :add_compound_members, :truncate_value

          ##
          # @private Determines if the Variable has any data.
          def empty?
            name.nil? &&
              value.nil? &&
              type.nil? &&
              members.nil?
            # TODO: Add status when implementing variable status
          end

          ##
          # @private Exports the Variable to a
          # Google::Devtools::Clouddebugger::V2::Variable object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouddebugger::V2::Variable.new(
              name: name.to_s,
              value: value.to_s,
              type: type.to_s,
              members: members_to_grpc || []
            )
          end

          private

          ##
          # @private Exports the Variable members to an array of
          # Google::Devtools::Clouddebugger::V2::Variable objects.
          def members_to_grpc
            return nil if members.nil?
            members.map { |var| var.to_grpc }
          end
        end
      end
    end
  end
end