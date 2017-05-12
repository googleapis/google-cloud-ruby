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


require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Fields
      #
      # ...
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

        def keys
          @fields.each_with_index.map do |field, index|
            if field.name.empty?
              index
            else
              field.name.to_sym
            end
          end
        end

        def duplicate_names?
          keys.count != keys.uniq.count
        end

        def pairs
          keys.zip types
        end

        def [] key
          return types[key] if key.is_a? Integer
          name_count = @fields.find_all { |f| f.name == String(key) }.count
          return nil if name_count == 0
          fail DuplicateNameError if name_count > 1
          index = @fields.find_index { |f| f.name == String(key) }
          types[index]
        end

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
