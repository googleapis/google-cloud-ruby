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
        # Creates {Fields} object from types. See {Client#fields}.
        #
        # This object can be used to create {Data} objects by providing values
        # that match the field types. See {Fields#struct}.
        #
        # See [Data Types - Constructing a
        # STRUCT](https://cloud.google.com/spanner/docs/data-types#constructing-a-struct).
        #
        # @param [Array, Hash] types Accepts an array or hash types.
        #
        #   Arrays can contain just the type value, or a sub-array of the
        #   field's name and type value. Hash keys must contain the field name
        #   as a `Symbol` or `String`, or the field position as an `Integer`.
        #   Hash values must contain the type value. If a Hash is used the
        #   fields will be created using the same order as the Hash keys.
        #
        #   Supported type values incude:
        #
        #   * `:BOOL`
        #   * `:BYTES`
        #   * `:DATE`
        #   * `:FLOAT64`
        #   * `:INT64`
        #   * `:STRING`
        #   * `:TIMESTAMP`
        #   * `Array` - Lists are specified by providing the type code in an
        #     array. For example, an array of integers are specified as
        #     `[:INT64]`.
        #   * {Fields} - Nested Structs are specified by providing a Fields
        #     object.
        #
        # @return [Fields] The fields of the given types.
        #
        # @example Create a STRUCT value with named fields using Fields object:
        #   require "google/cloud/spanner"
        #
        #   named_type = Google::Cloud::Spanner::Fields.new(
        #     { id: :INT64, name: :STRING, active: :BOOL }
        #   )
        #   named_data = named_type.struct(
        #     { id: 42, name: nil, active: false }
        #   )
        #
        # @example Create a STRUCT value with anonymous field names:
        #   require "google/cloud/spanner"
        #
        #   anon_type = Google::Cloud::Spanner::Fields.new(
        #     [:INT64, :STRING, :BOOL]
        #   )
        #   anon_data = anon_type.struct [42, nil, false]
        #
        # @example Create a STRUCT value with duplicate field names:
        #   require "google/cloud/spanner"
        #
        #   dup_type = Google::Cloud::Spanner::Fields.new(
        #     [[:x, :INT64], [:x, :STRING], [:x, :BOOL]]
        #   )
        #   dup_data = dup_type.struct [42, nil, false]
        #
        def initialize types
          types = types.to_a if types.is_a? Hash

          unless types.is_a? Array
            raise ArgumentError, "can only accept Array or Hash"
          end

          sorted_types, unsorted_types = types.partition do |type|
            type.is_a?(Array) && type.count == 2 && type.first.is_a?(Integer)
          end

          verify_sorted_types! sorted_types, types.count

          @grpc_fields = Array.new(types.count) do |index|
            sorted_type = sorted_types.assoc index
            if sorted_type
              to_grpc_field sorted_type.last
            else
              to_grpc_field unsorted_types.shift
            end
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
          @grpc_fields.map(&:type).map do |type|
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
          @grpc_fields.map.with_index do |field, index|
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
          name_count = @grpc_fields.find_all { |f| f.name == String(key) }.count
          return nil if name_count.zero?
          raise DuplicateNameError if name_count > 1
          index = @grpc_fields.find_index { |f| f.name == String(key) }
          types[index]
        end

        # rubocop:disable all

        ##
        # Creates a new {Data} object given the data values matching the fields.
        # Can be provided as either an Array of values, or a Hash where the hash
        # keys match the field name or match the index position of the field.
        #
        # For more information, see [Data Types - Constructing a
        # STRUCT](https://cloud.google.com/spanner/docs/data-types#constructing-a-struct).
        #
        # @param [Array, Hash] data Accepts an array or hash data values.
        #
        #   Arrays can contain just the data value, nested arrays will be
        #   treated as lists of values. Values must be provided in the same
        #   order as the fields, and there is no way to associate values to the
        #   field names.
        #
        #   Hash keys must contain the field name as a `Symbol` or `String`, or
        #   the field position as an `Integer`. Hash values must contain the
        #   data value. Hash values will be matched to the fields, so they don't
        #   need to match the same order as the fields.
        #
        # @return [Data] A new Data object.
        #
        # @example Create a STRUCT value with named fields using Fields object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   named_type = db.fields(
        #     { id: :INT64, name: :STRING, active: :BOOL }
        #   )
        #   named_data = named_type.struct(
        #     { id: 42, name: nil, active: false }
        #   )
        #
        # @example Create a STRUCT value with anonymous field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   anon_type = db.fields [:INT64, :STRING, :BOOL]
        #   anon_data = anon_type.struct [42, nil, false]
        #
        # @example Create a STRUCT value with duplicate field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   dup_type = db.fields [[:x, :INT64], [:x, :STRING], [:x, :BOOL]]
        #   dup_data = dup_type.struct [42, nil, false]
        #
        def struct data
          # create local copy of types so they are parsed just once.
          cached_types = types
          if data.nil?
            return Data.from_grpc nil, @grpc_fields
          elsif data.is_a? Array
            # Convert data in the order it was recieved
            values = data.map.with_index do |datum, index|
              Convert.object_to_grpc_value_and_type(datum, cached_types[index]).first
            end
            return Data.from_grpc values, @grpc_fields
          elsif data.is_a? Hash
            # Pull values from hash in order of the fields,
            # we can't always trust the Hash to be in order.
            values = @grpc_fields.map.with_index do |field, index|
              if data.key? index
                Convert.object_to_grpc_value_and_type(data[index],
                                              cached_types[index]).first
              elsif !field.name.to_s.empty?
                if data.key? field.name.to_s
                  Convert.object_to_grpc_value_and_type(data[field.name.to_s],
                                                cached_types[index]).first
                elsif data.key? field.name.to_s.to_sym
                  Convert.object_to_grpc_value_and_type(data[field.name.to_s.to_sym],
                                                cached_types[index]).first
                else
                  raise "data value for field #{field.name} missing"
                end
              else
                raise "data value for field #{index} missing"
              end
            end
            return Data.from_grpc values, @grpc_fields
          end
          raise ArgumentError, "can only accept Array or Hash"
        end
        alias data struct
        alias new struct

        # rubocop:enable all

        ##
        # Returns the type codes as an array. Do not use this method if the data
        # has more than one member with the same name. (See {#duplicate_names?})
        #
        # @return [Array<Symbol|Array<Symbol>|Fields|Array<Fields>>] An array
        #   containing the type codes.
        #
        def to_a
          types
        end

        ##
        # Returns the names or indexes and corresponding type codes as a hash.
        #
        # @raise [Google::Cloud::Spanner::DuplicateNameError] if the data
        #   contains duplicate names.
        #
        # @return [Hash<(Symbol|Integer) =>
        #   (Symbol|Array<Symbol>|Fields|Array<Fields>)] A hash containing the
        #   names or indexes and corresponding types.
        #
        def to_h
          raise DuplicateNameError if duplicate_names?
          Hash[pairs]
        end

        # @private
        def count
          @grpc_fields.count
        end
        alias size count

        # @private
        def == other
          return false unless other.is_a? Fields
          pairs == other.pairs
        end

        # @private
        def to_s
          named_types = pairs.map do |key, type|
            if key.is_a? Integer
              type.inspect
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
        # @private Creates a new Fields instance from a
        # Google::Spanner::V1::Metadata::Row_type::Fields.
        def self.from_grpc fields
          new([]).tap do |f|
            f.instance_variable_set :@grpc_fields, Array(fields)
          end
        end

        protected

        # rubocop:disable all

        def verify_sorted_types! sorted_types, total_count
          sorted_unique_positions = sorted_types.map(&:first).uniq.sort
          return if sorted_unique_positions.empty?

          if sorted_unique_positions.first < 0
            raise ArgumentError, "cannot specify position less than 0"
          end
          if sorted_unique_positions.last >= total_count
            raise ArgumentError, "cannot specify position more than field count"
          end
          if sorted_types.count != sorted_unique_positions.count
            raise ArgumentError, "cannot specify position more than once"
          end
        end

        def to_grpc_field pair
          if pair.is_a?(Array)
            if pair.count == 2
              if pair.first.is_a?(Integer)
                Google::Spanner::V1::StructType::Field.new(
                  type: Convert.grpc_type_for_field(pair.last)
                )
              else
                Google::Spanner::V1::StructType::Field.new(
                  name: String(pair.first),
                  type: Convert.grpc_type_for_field(pair.last)
                )
              end
            else
              Google::Spanner::V1::StructType::Field.new(
                type: Google::Spanner::V1::Type.new(
                  code: :ARRAY,
                  array_element_type: Convert.grpc_type_for_field(pair.last)
                )
              )
            end
          else
            # TODO: Handle Fields object
            # TODO: Handle Hash by creating Fields object
            unless pair.is_a?(Symbol)
              raise ArgumentError, "type must be a symbol"
            end
            Google::Spanner::V1::StructType::Field.new(
              type: Convert.grpc_type_for_field(pair)
            )
          end

          # rubocop:enable all
        end
      end
    end
  end
end
