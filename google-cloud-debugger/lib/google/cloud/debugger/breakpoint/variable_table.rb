# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "forwardable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        ##
        # # VariableTable
        #
        # The variable_table exists to aid with computation, memory and network
        # traffic optimization. It enables storing a variable once and reference
        # it from multiple variables, including variables stored in the
        # variable_table itself. For example, the same this object, which may
        # appear at many levels of the stack, can have all of its data stored
        # once in this table. The stack frame variables then would hold only a
        # reference to it.
        #
        # The variable var_table_index field is an index into this repeated
        # field. The stored objects are nameless and get their name from the
        # referencing variable. The effective variable is a merge of the
        # referencing variable and the referenced variable.
        #
        # See also {Breakpoint#variable_table}.
        #
        class VariableTable
          extend Forwardable

          ##
          # @private Array to store variables.
          attr_accessor :variables

          ##
          # @private Create a new VariableTable instance
          def initialize
            @variables = []
          end

          ##
          # @private Create a new VariableTable instance from a variable table
          # gRPC struct
          def self.from_grpc grpc_table
            return if grpc_table.nil?

            new.tap do |vt|
              vt.variables = grpc_table.map do |grpc_var|
                Breakpoint::Variable.from_grpc grpc_var
              end
            end
          end

          ##
          # @private Search a variable in this VariableTable by matching
          # object_id, return the array index if found.
          def rb_var_index rb_var
            variables.each_with_index do |var, i|
              return i if var.source_var.object_id == rb_var.object_id
            end

            nil
          end

          ##
          # @private Add a Breakpoint::Variable to this VariableTable
          def add var
            return unless var.is_a? Breakpoint::Variable

            variables << var
          end

          ##
          # @private Export this VariableTable as a gRPC struct
          def to_grpc
            variables.map(&:to_grpc).compact
          end

          def_instance_delegators :@variables, :size, :first, :[]
        end
      end
    end
  end
end
