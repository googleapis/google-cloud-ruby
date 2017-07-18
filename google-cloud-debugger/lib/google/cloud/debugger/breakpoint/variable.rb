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


require "google/cloud/debugger/breakpoint/status_message"

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
        # ```ruby
        #   x = 5
        #   # Captured variable:
        #   # { name: "x", value: "5", type: "Integer" }
        # ```
        #
        # A Compound Variable:
        # ```ruby
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
        # ```
        #
        # A Hash object:
        # ```ruby
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
        # ```
        #
        # An Array object:
        # ```ruby
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
        # ```
        #
        class Variable
          ##
          # Max depth to convert on compound variables
          MAX_DEPTH = 3

          ##
          # Max number of member variables to evaluate in compound variables
          MAX_MEMBERS = 10

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
          # @private Reference to a variable in the shared variable table. More
          # than one variable can reference the same variable in the table. The
          # var_table_index field is an index into variable_table in Breakpoint.
          attr_accessor :var_table_index

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
          attr_accessor :status

          ##
          # @private Create an empty Variable object.
          def initialize
            @members = []
          end

          ##
          # Convert a Ruby variable into a
          # Google::Cloud::Debugger::Breakpoint::Variable object. If
          # a variable table is provided, it will store all the subsequently
          # created compound variables into the variable table for sharing.
          #
          # @param [Any] source Source Ruby variable to convert from
          # @param [String] name Name of the varaible
          # @param [Integer] depth Number of levels to evaluate in compound
          #   variables. Default to
          #   {Google::Cloud::Debugger::Breakpoint::Variable::MAX_DEPTH}
          # @param [Breakpoint::VariableTable] var_table A variable table
          #   to store shared compound variables. Optional.
          #
          # @example Simple variable convertion
          #   x = 3
          #   var = Variable.from_rb_var x, name: "x"
          #   var.name  #=> "x"
          #   var.value #=> "3"
          #   var.type  #=> "Integer"
          #
          # @example Hash convertion
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
          # @example Custom compound variable convertion
          #   foo = Foo.new(a: 1, b: []) #=> #<Foo:0x0000 @a: 1, @b: []>
          #   var_table = VariableTable.new
          #   var = Variable.from_rb_var foo, name: "foo"
          #   var.name  #=> "foo"
          #   var.type  #=> "Foo"
          #   var.members[0].name  #=> "@a"
          #   var.members[0].value #=> "1"
          #   var.members[0].type  #=> "Integer"
          #   var.members[1].name  #=> "@b"
          #   var.members[1].value #=> "[]"
          #   var.members[1].type  #=> "Array"
          #
          # @example Use variable table for shared compound variables
          #   hash = {a: 1}
          #   ary = [hash, hash]
          #   var_table = VariableTable.new
          #   var = Variable.from_rb_var ary, name: "ary", var_table: var_table
          #   var.name            #=> "ary"
          #   var.var_table_index #=> 0
          #   var_table[0].type   #=> "Array"
          #   var_table[0].members[0].name            #=> "[0]"
          #   var_table[0].members[0].var_table_index #=> 1
          #   var_table[0].members[1].name            #=> "[1]"
          #   var_table[0].members[1].var_table_index #=> 1
          #   var_table[1].type #=> "Hash"
          #   var_table[1].members[0].name #=> "a"
          #   var_table[1].members[0].type #=> "Integer"
          #   var_table[1].members[0].value #=> "1"
          #
          # @return [Google::Cloud::Debugger::Breakpoint::Variable] Converted
          #   variable.
          #
          def self.from_rb_var source, name: nil, depth: MAX_DEPTH,
                               var_table: nil
            return source if source.is_a? Variable

            # If source is a non-empty Array or Hash, or source has instance
            # variables, evaluate source as a compound variable.
            if compound_var?(source) && depth > 0
              from_compound_var source, name: name, depth: depth,
                                        var_table: var_table
            else
              var = Variable.new
              var.name = name.to_s if name
              var.type = source.class.to_s
              var.value = truncate_value(source.inspect)

              var
            end
          end

          ##
          # @private Helper method that converts compound variables.
          def self.from_compound_var source, name: nil, depth: MAX_DEPTH,
                                     var_table: nil
            return source if source.is_a? Variable

            var = Variable.new
            var.name = name.to_s if name

            if var_table
              var.var_table_index =
                var_table.rb_var_index(source) ||
                add_shared_compound_var(source, depth, var_table)
            else
              var.type = source.class.to_s
              add_compound_members var, source, depth
            end

            var
          end

          ##
          # @private Determine if a given Ruby variable is a compound variable.
          def self.compound_var? source
            ((source.is_a?(Hash) || source.is_a?(Array)) && !source.empty?) ||
              !source.instance_variables.empty?
          end

          ##
          # @private Add a shared compound variable to the breakpoint
          # variable table.
          def self.add_shared_compound_var source, depth, var_table
            var = Variable.new
            var.type = source.class.to_s

            table_index = var_table.size
            var_table.add_var source, var

            add_compound_members var, source, depth, var_table

            table_index
          end

          ##
          # @private Add member variables to a compound variable.
          def self.add_compound_members var, source, depth, var_table = nil
            case source
            when Hash
              add_member_vars var, source do |(k, v)|
                from_rb_var v, name: k, depth: depth - 1, var_table: var_table
              end
            when Array
              add_member_vars var, source do |el, i|
                from_rb_var el, name: "[#{i}]", depth: depth - 1,
                                var_table: var_table
              end
            else
              add_member_vars var, source.instance_variables do |var_name|
                instance_var = source.instance_variable_get var_name
                from_rb_var instance_var, name: var_name, depth: depth - 1,
                                          var_table: var_table
              end
            end
          end

          ##
          # @private Help interate through collection of member variables for
          # compound variables.
          def self.add_member_vars var, members
            members.each_with_index do |el, i|
              if i < MAX_MEMBERS
                var.members << yield(el, i)
              else
                var.members << Variable.new.tap do |last_var|
                  last_var.value =
                    "(Only first #{MAX_MEMBERS} items were captured)"
                end
                break
              end
            end
          end

          private_class_method :add_compound_members, :add_shared_compound_var,
                               :add_member_vars, :compound_var?

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
              o.var_table_index = var_table_index_from_grpc grpc.var_table_index
              o.status = Breakpoint::StatusMessage.from_grpc grpc.status
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
          # @private Extract var_table_index from the equivalent GRPC struct
          def self.var_table_index_from_grpc grpc
            grpc.nil? ? nil : grpc.value
          end

          ##
          # @private Limit string to MAX_STRING_LENTH. Replace extra characters
          # with ellipsis
          def self.truncate_value str
            str.gsub(/(.{#{MAX_STRING_LENGTH - 3}}).+/, '\1...')
          end
          private_class_method :add_compound_members, :truncate_value

          ##
          # @private Determines if the Variable has any data.
          def empty?
            name.nil? &&
              value.nil? &&
              type.nil? &&
              members.nil? &&
              var_table_index.nil? &&
              status.nil?
          end

          ##
          # Exports the Variable to a
          # Google::Devtools::Clouddebugger::V2::Variable object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouddebugger::V2::Variable.new(
              name: name.to_s,
              value: value.to_s,
              type: type.to_s,
              var_table_index: var_table_index_to_grpc,
              members: members_to_grpc || [],
              status: status_to_grpc
            )
          end

          ##
          # Set this variable to an error state by setting the status field
          def set_error_state message, refers_to: StatusMessage::UNSPECIFIED
            @status = StatusMessage.new.tap do |s|
              s.is_error = true
              s.refers_to = refers_to
              s.description = message
            end
          end

          private

          ##
          # @private Exports the Variable status to grpc
          def status_to_grpc
            status.nil? ? nil : status.to_grpc
          end

          ##
          # @private Exports the Variable var_table_index attribute to
          # an Int32Value gRPC struct
          def var_table_index_to_grpc
            if var_table_index
              Google::Protobuf::Int32Value.new value: var_table_index
            else
              nil
            end
          end

          ##
          # @private Exports the Variable members to an array of
          # Google::Devtools::Clouddebugger::V2::Variable objects.
          def members_to_grpc
            members.nil? ? nil : members.map(&:to_grpc)
          end
        end
      end
    end
  end
end
