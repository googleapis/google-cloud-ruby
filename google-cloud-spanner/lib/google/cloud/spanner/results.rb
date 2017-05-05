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
require "google/cloud/errors"

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
        # @param [Boolean] pairs Allow the types to be represented as a nested
        #   Array of pairs rather than a Hash. This is useful when results have
        #   duplicate names. The default is `false`.
        #
        # @return [Hash, Array] The types of the returned data. The default is a
        #   Hash. Is a nested Array of Arrays when `pairs` is specified.
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
        #   results.types.each do |name, type|
        #     puts "Column #{name} is type {type}"
        #   end
        #
        # @example Can return an array of array pairs instead of a hash
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.execute "SELECT 1 AS count, 2 AS count"
        #
        #   results.types(pairs: true).each do |row|
        #     row #=> [[:count, :INT64], [:count, :INT64]]
        #   end
        #
        def types pairs: false
          row_types = @metadata.row_type.fields
          type_pairs = row_types.map do |field|
            # raise field.inspect
            if field.type.code == :ARRAY
              [field.name.to_sym, [field.type.array_element_type.code]]
            else
              [field.name.to_sym, field.type.code]
            end
          end
          return type_pairs if pairs
          Hash[type_pairs]
        end

        # rubocop:disable all

        ##
        # The values returned from the request.
        #
        # @param [Boolean] pairs Allow the rows to be represented as a nested
        #   Array of pairs rather than a Hash. This is useful when results have
        #   duplicate names. The default is `false`.
        #
        # @yield [row] An enumerator for the rows.
        # @yieldparam [Hash, Array] row a hash that contains the result names
        #   and values. Or, if pairs was specified, an array of arrays.
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
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}""
        #   end
        #
        # @example Can returns an array of array pairs instead of a hash
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.execute "SELECT 1 AS count, 2 AS count"
        #
        #   results.rows(pairs: true).each do |row|
        #     row #=> [[:count, 1], [:count, 2]]
        #   end
        #
        def rows pairs: false
          return nil if @closed

          unless block_given?
            return enum_for(:rows, pairs: pairs)
          end

          fields = @metadata.row_type.fields
          values = []
          buffered_responses = []
          buffer_upper_bound = 10
          chunked_value = nil
          resume_token = nil

          # Cannot call Enumerator#each because it won't return the first
          # value that was already identified when calling Enumerator#peek.
          # Iterate only using Enumerator#next and break on StopIteration.
          loop do
            begin
              grpc = @enum.next
              # metadata should be set before the first iteration...
              @metadata ||= grpc.metadata
              @stats ||= grpc.stats

              buffered_responses << grpc

              if (grpc.resume_token && grpc.resume_token != "") ||
                buffered_responses.size >= buffer_upper_bound
                # This can set the resume_token to nil
                resume_token = grpc.resume_token

                buffered_responses.each do |resp|
                  if chunked_value
                    resp.values.unshift merge(chunked_value, resp.values.shift)
                    chunked_value = nil
                  end
                  to_iterate = values + Array(resp.values)
                  chunked_value = to_iterate.pop if resp.chunked_value
                  values = to_iterate.pop(to_iterate.count % fields.count)
                  to_iterate.each_slice(fields.count) do |slice|
                    if pairs
                      yield Convert.row_to_pairs(fields, slice)
                    else
                      yield Convert.row_to_raw(fields, slice)
                    end
                  end
                end

                # Flush the buffered responses now that they are all handled
                buffered_responses = []
              end
            rescue GRPC::Aborted => aborted
              if resume_token.nil? || resume_token.empty?
                # Re-raise if the resume_token is not a valid value.
                # This can happen if the buffer was flushed.
                raise Google::Cloud::Error.from_error(aborted)
              end

              # Resume the stream from the last known resume_token
              if @execute_options
                @enum = @service.streaming_execute_sql \
                  @session_path, @sql,
                  @execute_options.merge(resume_token: resume_token)
              else
                @enum = @service.streaming_read_table \
                  @session_path, @table, @columns,
                  @read_options.merge(resume_token: resume_token)
              end

              # Flush the buffered responses to reset to the resume_token
              buffered_responses = []
            rescue StopIteration
              break
            end
          end

          # clear out any remaining values left over
          buffered_responses.each do |resp|
            if chunked_value
              resp.values.unshift merge(chunked_value, resp.values.shift)
              chunked_value = nil
            end
            to_iterate = values + Array(resp.values)
            chunked_value = to_iterate.pop if resp.chunked_value
            values = to_iterate.pop(to_iterate.count % fields.count)
            to_iterate.each_slice(fields.count) do |slice|
              if pairs
                yield Convert.row_to_pairs(fields, slice)
              else
                yield Convert.row_to_raw(fields, slice)
              end
            end
          end
          values.each_slice(fields.count) do |slice|
            if pairs
              yield Convert.row_to_pairs(fields, slice)
            else
              yield Convert.row_to_raw(fields, slice)
            end
          end

          # If we get this far then we can release the session
          @closed = true
          nil
        end

        # rubocop:enable all

        # @private
        def self.from_enum enum, service
          grpc = enum.peek
          new.tap do |results|
            results.instance_variable_set :@metadata, grpc.metadata
            results.instance_variable_set :@stats,    grpc.stats
            results.instance_variable_set :@enum,     enum
            results.instance_variable_set :@service,  service
          end
        end

        # @private
        def self.execute service, session_path, sql, params: nil,
                         transaction: nil
          execute_options = { transaction: transaction, params: params }
          enum = service.streaming_execute_sql session_path, sql,
                                               execute_options
          from_enum(enum, service).tap do |results|
            results.instance_variable_set :@session_path,    session_path
            results.instance_variable_set :@sql,             sql
            results.instance_variable_set :@execute_options, execute_options
          end
        end

        # @private
        def self.read service, session_path, table, columns, id: nil,
                      limit: nil, transaction: nil
          read_options = { id: id, limit: limit, transaction: transaction }
          enum = service.streaming_read_table \
            session_path, table, columns, read_options
          from_enum(enum, service).tap do |results|
            results.instance_variable_set :@session_path, session_path
            results.instance_variable_set :@table,        table
            results.instance_variable_set :@columns,      columns
            results.instance_variable_set :@read_options, read_options
          end
        end

        # @private
        def to_s
          "(types: #{types.inspect} streaming)"
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
