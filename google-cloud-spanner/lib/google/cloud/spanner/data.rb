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


require "google/cloud/spanner/fields"
require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Data
      #
      # Represents a row in a result from Cloud Spanner. Provides access to data
      # in a hash-like structure. Values can be retrieved by name (String), or
      # in cases in which values are unnamed, by zero-based index position
      # (Integer).
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   results = db.execute_query "SELECT * FROM users"
      #
      #   results.rows.each do |row|
      #     puts "User #{row[:id]} is #{row[:name]}"
      #   end
      #
      class Data
        ##
        # Returns the configuration object ({Fields}) of the names and types of
        # the data.
        #
        # @return [Array<Array>] An array containing name and value pairs.
        #
        def fields
          @fields ||= Fields.from_grpc @grpc_fields
        end

        ##
        # Returns the types of the data.
        #
        # See [Data
        # types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Array<Symbol>] An array containing the types of the values.
        #
        def types
          fields.types
        end

        ##
        # Returns the names of values, or in cases in which values are unnamed,
        # the zero-based index position of values.
        #
        # @return [Array<(String,Integer)>] An array containing the names
        #   (String) or position (Integer) for the corresponding values of the
        #   data.
        #
        def keys
          fields.keys
        end

        ##
        # Returns the values of the data.
        #
        # @return [Array<Object>] An array containing the values.
        #
        def values
          Array.new(keys.count) { |i| self[i] }
        end

        ##
        # Returns the names or positions and their corresponding values as an
        # array of arrays.
        #
        # @return [Array<Array>] An array containing name/position and value
        #   pairs.
        #
        def pairs
          keys.zip values
        end

        ##
        # Returns the value object for the provided name (String) or index
        # (Integer). Do not pass a name to this method if the data has more than
        # one member with the same name.
        #
        # @param [String, Integer] key The name (String) or zero-based index
        #   position (Integer) of the value.
        #
        # @raise [Google::Cloud::Spanner::DuplicateNameError] if the data
        #   contains duplicate names.
        #
        # @return [Object, nil] The value, or nil if no value is found.
        #
        def [] key
          if key.is_a? Integer
            return Convert.grpc_value_to_object(@grpc_values[key],
                                                @grpc_fields[key].type)
          end
          name_count = @grpc_fields.find_all { |f| f.name == String(key) }.count
          return nil if name_count.zero?
          raise DuplicateNameError if name_count > 1
          index = @grpc_fields.find_index { |f| f.name == String(key) }
          Convert.grpc_value_to_object(@grpc_values[index],
                                       @grpc_fields[index].type)
        end

        ##
        # Returns the values as an array.
        #
        # @return [Array<Object>] An array containing the values of the data.
        #
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

        ##
        # Returns the names or indexes and corresponding values of the data as a
        # hash. Do not use this method if the data has more than one member with
        # the same name.
        #
        # @raise [Google::Cloud::Spanner::DuplicateNameError] if the data
        #   contains duplicate names.
        #
        # @return [Hash<(String,Integer)=>Object>] A hash containing the names
        #   or indexes and corresponding values.
        #
        def to_h
          raise DuplicateNameError if fields.duplicate_names?
          Hash[keys.zip to_a]
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
              value.inspect
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

        ##
        # @private
        def to_grpc_value
          if @grpc_values.nil?
            return Google::Protobuf::Value.new null_value: :NULL_VALUE
          end

          Google::Protobuf::Value.new(
            list_value: Google::Protobuf::ListValue.new(
              values: @grpc_values
            )
          )
        end

        ##
        # @private
        def to_grpc_type
          Google::Spanner::V1::Type.new(
            code: :STRUCT,
            struct_type: Google::Spanner::V1::StructType.new(
              fields: @grpc_fields
            )
          )
        end

        ##
        # @private
        def to_grpc_value_and_type
          [to_grpc_value, to_grpc_type]
        end

        ##
        # @private Creates a new Data instance from
        # Spanner values and fields.
        def self.from_grpc grpc_values, grpc_fields
          new.tap do |d|
            d.instance_variable_set :@grpc_values, Array(grpc_values)
            d.instance_variable_set :@grpc_fields, Array(grpc_fields)
          end
        end
      end
    end
  end
end
