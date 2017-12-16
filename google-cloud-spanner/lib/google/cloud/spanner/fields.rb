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


require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Fields
      #
      # Represents the field names and types of data returned by Cloud Spanner.
      #
      # See [Data
      # types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   results = db.execute "SELECT * FROM users"
      #
      #   results.fields.pairs.each do |name, type|
      #     puts "Column #{name} is type {type}"
      #   end
      #
      class Fields
        ##
        # @private
        def initialize types
          @fields = []
          if types.is_a? Array
            types.each do |type|
              @fields << field(type)
            end
          elsif types.is_a? Hash
            types.each do |type|
              @fields << field(type)
            end
          else
            fail ArgumentError, "can only accept Array or Hash"
          end
        end

        ##
        # Returns the types of the data.
        #
        # See [Data
        # types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Array<Symbol>] An array containing the types of the data.
        #
        def types
          @fields.map(&:type).map do |type|
            if type.code == :ARRAY
              if type.array_element_type.code == :STRUCT
                [Fields.from_grpc(type.array_element_type.struct_type.fields)]
              else
                [type.array_element_type.code]
              end
            elsif type.code == :STRUCT
              Fields.from_grpc type.struct_type.fields
            else
              type.code
            end
          end
        end

        ##
        # Returns the names of the data values, or in cases in which values are
        # unnamed, the zero-based index position of values.
        #
        # @return [Array<(String,Integer)>] An array containing the names
        #   (String) or position (Integer) for the corresponding values of the
        #   data.
        #
        def keys
          @fields.each_with_index.map do |field, index|
            if field.name.empty?
              index
            else
              field.name.to_sym
            end
          end
        end

        ##
        # Detects duplicate names in the keys for the fields.
        #
        # @return [Boolean] Returns `true` if there are duplicate names.
        #
        def duplicate_names?
          keys.count != keys.uniq.count
        end

        ##
        # Returns the names or positions and their corresponding types as an
        # array of arrays.
        #
        # @return [Array<Array>] An array containing name/position and types
        #   pairs.
        #
        def pairs
          keys.zip types
        end

        ##
        # Returns the type code for the provided name (String) or index
        # (Integer). Do not pass a name to this method if the data has more than
        # one member with the same name. (See {#duplicate_names?})
        #
        # @param [String, Integer] key The name (String) or zero-based index
        #   position (Integer) of the value.
        #
        # @raise [Google::Cloud::Spanner::DuplicateNameError] if the data
        #   contains duplicate names.
        #
        # @return [Symbol, nil] The type code, or nil if no value is found.
        #
        def [] key
          return types[key] if key.is_a? Integer
          name_count = @fields.find_all { |f| f.name == String(key) }.count
          return nil if name_count == 0
          fail DuplicateNameError if name_count > 1
          index = @fields.find_index { |f| f.name == String(key) }
          types[index]
        end

        ##
        # Returns the type codes as an array. Do not use this method if the data
        # has more than one member with the same name. (See {#duplicate_names?})
        #
        # @raise [Google::Cloud::Spanner::DuplicateNameError] if the data
        #   contains duplicate names.
        #
        # @return [Array<Symbol>] An array containing the type codes.
        #
        def to_a
          keys.count.times.map { |i| self[i] }.map do |field|
            if field.is_a? Fields
              field.to_h
            elsif field.is_a? Array
              field.map { |f| f.is_a?(Fields) ? f.to_h : f }
            else
              field
            end
          end
        end

        ##
        # Returns the names or indexes and corresponding type codes as a hash.
        #
        # @return [Hash<(String,Integer)=>Symbol>] A hash containing the names
        #   or indexes and corresponding types.
        #
        def to_h
          fail DuplicateNameError if duplicate_names?
          hashified_pairs = pairs.map do |key, value|
            if value.is_a? Fields
              [key, value.to_h]
            elsif value.is_a? Array
              [key, value.map { |v| v.is_a?(Fields) ? v.to_h : v }]
            else
              [key, value]
            end
          end
          Hash[hashified_pairs]
        end

        # @private
        def data data
          # TODO: match order of types
          data = data.values if data.is_a?(Hash)
          values = data.map { |datum| Convert.raw_to_value datum }
          Data.from_grpc values, @fields
        end
        alias_method :new, :data

        # @private
        def == other
          return false unless other.is_a? Fields
          pairs == other.pairs
        end

        # @private
        def to_s
          named_types = pairs.map do |key, type|
            if key.is_a? Integer
              "#{type.inspect}"
            else
              "(#{key})#{type.inspect}"
            end
          end
          "(#{named_types.join ', '})"
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private Creates a new Fields instance from a
        # Google::Spanner::V1::Metadata::Row_type::Fields.
        def self.from_grpc fields
          new([]).tap do |f|
            f.instance_variable_set :@fields, fields
          end
        end

        protected

        def field pair
          if pair.is_a?(Array)
            unless pair.count == 2
              fail ArgumentError, "can only accept pairs of name and type"
            end
            if pair.first.nil? || pair.first.is_a?(Integer)
              Google::Spanner::V1::StructType::Field.new(
                type: Google::Spanner::V1::Type.new(code: pair.last))
            else
              Google::Spanner::V1::StructType::Field.new(
                name: String(pair.first),
                type: Google::Spanner::V1::Type.new(code: pair.last))
            end
          else
            unless pair.is_a?(Symbol)
              fail ArgumentError, "type must be a symbol"
            end
            Google::Spanner::V1::StructType::Field.new(
              type: Google::Spanner::V1::Type.new(code: pair))
          end
        end
      end
    end
  end
end
