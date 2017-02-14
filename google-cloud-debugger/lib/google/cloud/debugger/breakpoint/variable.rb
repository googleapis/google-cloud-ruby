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
          MAX_DEPTH = 3
          MAX_MEMBERS = 25
          MAX_STRING_LENGTH = 260

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
            var.name = name.to_s if name
            var.type = source.class.to_s

            case source
              when Hash
                parse_nested var, source, source, depth do |(k, v), _|
                  var.members << from_rb_var(v, name: k, depth: depth - 1)
                end
              when Array
                parse_nested var, source, source, depth do |el, i|
                  var.members << from_rb_var(el, name: "[#{i}]",
                                                 depth: depth - 1)
                end
              else
                unless source.instance_variables.empty?
                  parse_nested var, source,
                               source.instance_variables, depth do |var_name, _|
                    instance_var = source.instance_variable_get var_name
                    var.members << from_rb_var(instance_var,
                                               name: var_name,
                                               depth: depth - 1)
                  end
                else
                  var.value = truncate_str(source.inspect)
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

          def self.parse_nested var, source, member_enumerable, depth
            if depth > 0
              member_enumerable.each_with_index do |el, i|
                if i < MAX_MEMBERS
                  yield el, i
                else
                  var.members << Variable.new.tap { |last_var|
                    last_var.value = "(Only first 25 items were captured)"
                  }
                  break
                end
              end
            else
              var.value = truncate_str(source.inspect)
            end
          end

          def self.truncate_str str
            str.gsub(/(.{#{MAX_STRING_LENGTH - 3}}).+/,'\1...')
          end
          private_class_method :parse_nested, :truncate_str
        end
      end
    end
  end
end