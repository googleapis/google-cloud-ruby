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


require "forwardable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        class VariableTable
          extend Forwardable

          ##
          # @private Array to store variables.
          attr_accessor :variables

          ##
          # @private Item in the variables list. :orig_var is reference to the
          # original Ruby variable. :var is the equivalent
          # Breakpoint::Variable.
          ListItem = Struct.new(:orig_var, :var)

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
                ListItem.new nil, Breakpoint::Variable.from_grpc(grpc_var)
              end
            end
          end

          ##
          # @private Search a variable in this VariableTable by matching
          # object_id, return the array index if found.
          def rb_var_index rb_var
            variables.each_with_index do |list_item, i|
              return i if list_item.orig_var.object_id == rb_var.object_id
            end

            nil
          end

          ##
          # @private Add a Ruby object and it's Breakpoint::Variable equivalent
          # to this VariableTable
          def add_var rb_var, var = nil
            var ||=
              Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var rb_var

            variables << ListItem.new(rb_var, var)
          end

          ##
          # @private Export this VariableTable as a gRPC struct
          def to_grpc
            variables.map do |list_item|
              list_item.var.nil? ? nil : list_item.var.to_grpc
            end.compact
          end

          def_instance_delegators :@variables, :size, :first, :[]
        end
      end
    end
  end
end
