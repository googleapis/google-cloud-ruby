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


module Google
  module Cloud
    module Debugger
      class Breakpoint
        class Variable
          MAX_DEPTH = 2

          attr_accessor :name

          attr_accessor :value

          attr_accessor :type

          attr_accessor :members

          def initialize
            @name = nil
            @value =nil
            @type = nil
            @members = []
          end

          def self.from_rb_var source, name: nil, depth: MAX_DEPTH
            return source if source.is_a? Variable
            var = Variable.new
            var.name = name.to_s

            if source.is_a? Hash
              var.type = "Hash"
              if depth > 0
                source.each_pair do |k, v|
                  var.members << from_rb_var(v, name: k, depth: depth - 1)
                end
              else
                var.value = source.to_s
              end
            elsif source.is_a? Array
              var.type = "Array"
              if depth > 0
                source.each_with_index do |el, i|
                  var.members << from_rb_var(el, name: "[#{i}]",
                                                 depth: depth - 1)
                end
              else
                var.value = source.to_s
              end
            else
              var.type = source.class.to_s
              instance_var_names = source.instance_variables
              if !instance_var_names.empty? && depth > 0
                instance_var_names.each do |instance_var_name|
                  instance_var = source.instance_variable_get instance_var_name
                  var.members << from_rb_var(instance_var,
                                             name: instance_var_name,
                                             depth: depth - 1)
                end
              else
                var.value = source.to_s
              end
            end

            var
          end

          def to_grpc
            Google::Apis::ClouddebuggerV2::Variable.new.tap do |v|
              v.name = @name
              v.value = @value
              v.type = @type
              v.members = @members.map { |mem| mem.to_grpc }
            end
          end

          def self.from_grpc grpc
            Variable.new.tap do |var|
              var.name = grpc.name
              var.value = grpc.value
              var.type = grpc.type
              members = grpc.members || []
              var.members = members.map { |mem| Variable.from_grpc mem }
            end
          end
        end
      end
    end
  end
end