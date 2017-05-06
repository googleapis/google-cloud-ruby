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


require "google/cloud/spanner/fields"
require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Data
      #
      # ...
      class Data
        def fields
          @fields ||= Fields.from_grpc @grpc_fields
        end

        def types
          fields.types
        end

        def keys
          fields.keys
        end

        def values
          keys.count.times.map { |i| self[i] }
        end

        def pairs
          keys.zip values
        end

        def [] key
          if key.is_a? Integer
            return Convert.value_to_raw(@grpc_values[key],
                                        @grpc_fields[key].type)
          end
          name_count = @grpc_fields.find_all { |f| f.name == String(key) }.count
          return nil if name_count == 0
          fail DuplicateNameError if name_count > 1
          index = @grpc_fields.find_index { |f| f.name == String(key) }
          Convert.value_to_raw(@grpc_values[index], @grpc_fields[index].type)
        end

        def to_a
          values.map do |value|
            if value.is_a? Data
              value.to_h
            elsif value.is_a? Array
              value.map { |v| v.is_a?(Data) ? v.to_h : v }
            else
              value
            end
          end
        end

        def to_h
          fail DuplicateNameError if fields.duplicate_names?
          hashified_pairs = pairs.map do |key, value|
            if value.is_a? Data
              [key, value.to_h]
            elsif value.is_a? Array
              [key, value.map { |v| v.is_a?(Data) ? v.to_h : v }]
            else
              [key, value]
            end
          end
          Hash[hashified_pairs]
        end

        # @private
        def == other
          return false unless other.is_a? Data
          pairs == other.pairs
        end

        # @private
        def to_s
          named_values = pairs.map do |key, value|
            if key.is_a? Integer
              "#{value.inspect}"
            else
              "(#{key})#{value.inspect}"
            end
          end
          "(#{named_values.join ', '})"
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        def self.from_grpc grpc_values, grpc_fields
          new.tap do |d|
            d.instance_variable_set :@grpc_values, grpc_values
            d.instance_variable_set :@grpc_fields, grpc_fields
          end
        end
      end
    end
  end
end
