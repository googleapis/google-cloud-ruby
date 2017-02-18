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


require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Results
      #
      class Results
        ##
        # Indicates the field names and types for the rows in the returned data.
        #
        # @return [Hash] The types of the returned data.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   results = db.execute "SELECT * FROM users"
        #
        #   results.types.each do |name, type|
        #     puts "Column #{name} is type {type}"
        #   end
        #
        def types
          row_types = @metadata.row_type.fields
          Hash[row_types.map do |field|
            # raise field.inspect
            if field.type.code == :ARRAY
              [field.name.to_sym, [field.type.array_element_type.code]]
            else
              [field.name.to_sym, field.type.code]
            end
          end]
        end

        # rubocop:disable all

        ##
        # The values returned from the request.
        #
        # @yield [rows] An enumerator for the rows.
        # @yieldparam [Hash] rows the hash that contains the result names and
        #   values.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   results = db.execute "SELECT * FROM users"
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}""
        #   end
        #
        def rows
          return @rows.to_enum if @rows

          return nil if @closed

          unless block_given?
            return enum_for(:rows)
          end

          fields = @metadata.row_type.fields
          values = []
          chunked_value = nil
          resume_token = nil

          @enum.each_with_index do |grpc, index|
            # @metadata ||= grpc.metadata # should be set before the first iteration
            @stats ||= grpc.stats

            if chunked_value
              grpc.values.unshift merge(chunked_value, grpc.values.shift)
              chunked_value = nil
            end
            to_iterate = values + grpc.values
            chunked_value = to_iterate.pop if grpc.chunked_value

            resume_token = grpc.resume_token

            values = to_iterate.pop(to_iterate.count % fields.count)
            to_iterate.each_slice(fields.count) do |slice|
              yield Convert.row_to_raw(fields, slice)
            end
          end

          # If we get this far then we can release the session
          @closed = true
          nil
        end

        # rubocop:enable all

        ##
        # Whether the returned data is streaming from the Spanner API.
        # @return [Boolean]
        def streaming?
          !@enum.nil?
        end

        # @private
        def self.from_grpc grpc
          results = new
          rows = grpc.rows.map do |row|
            Convert.row_to_raw grpc.metadata.row_type.fields, row.values
          end
          results.instance_variable_set :@metadata, grpc.metadata
          results.instance_variable_set :@rows,     rows
          results.instance_variable_set :@stats,    grpc.stats
          results
        end

        # @private
        def self.from_enum enum
          grpc = enum.peek
          results = new
          results.instance_variable_set :@metadata,   grpc.metadata
          results.instance_variable_set :@stats,      grpc.stats
          results.instance_variable_set :@enum,       enum
          results
        end

        # @private
        def to_s
          if streaming?
            "#<#{self.class.name} (types: #{types.inspect} streaming)>"
          else
            "#<#{self.class.name} (" \
              "(types: #{types.inspect}, rows: #{rows.count})>"
          end
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        protected

        # rubocop:disable all

        # @private
        def merge left, right
          if left.kind != right.kind
            raise "Can't merge #{left.kind} and #{right.kind} values"
          end
          if left.kind == :string_value
            left.string_value = left.string_value + right.string_value
            return left
          elsif left.kind == :list_value
            left_val = left.list_value.values.pop
            right_val = right.list_value.values.shift
            if left_val.kind == :string_value && right_val.kind == :string_value
              left.list_value.values << merge(left_val, right_val)
            else
              left.list_value.values << left_val
              left.list_value.values << right_val
            end
            right.list_value.values.each { |val| left.list_value.values << val }
            return left
          elsif left.kind == :struct_value
            # Don't worry about this yet since Spanner isn't return STRUCT
            fail "STRUCT not implemented yet"
          else
            raise "Can't merge #{left.kind} values"
          end
        end

        # rubocop:enable all
      end
    end
  end
end
