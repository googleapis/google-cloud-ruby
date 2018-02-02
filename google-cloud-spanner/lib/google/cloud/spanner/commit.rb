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


require "google/cloud/spanner/data"
require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Commit
      #
      # Accepts mutations for execution within a transaction. All writes will
      # execute atomically at a single logical point in time across columns,
      # rows, and tables in a database.
      #
      # All changes are accumulated in memory until the block passed to
      # {Client#commit} completes.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   db.commit do |c|
      #     c.update "users", [{ id: 1, name: "Charlie", active: false }]
      #     c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      #   end
      #
      class Commit
        ##
        # @private
        def initialize
          @mutations = []
        end

        ##
        # Inserts or updates rows in a table. If any of the rows already exist,
        # then its column values are overwritten with the ones provided. Any
        # column values not explicitly written are preserved.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#commit} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.upsert "users", [{ id: 1, name: "Charlie", active: false },
        #                        { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def upsert table, *rows
          rows = Array(rows).flatten
          return rows if rows.empty?
          rows.delete_if(&:nil?)
          rows.delete_if(&:empty?)
          @mutations += rows.map do |row|
            Google::Spanner::V1::Mutation.new(
              insert_or_update: Google::Spanner::V1::Mutation::Write.new(
                table: table, columns: row.keys.map(&:to_s),
                values: [Convert.raw_to_value(row.values).list_value]
              )
            )
          end
          rows
        end
        alias save upsert

        ##
        # Inserts new rows in a table. If any of the rows already exist, the
        # write or request fails with error {Google::Cloud::AlreadyExistsError}.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#commit} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.insert "users", [{ id: 1, name: "Charlie", active: false },
        #                        { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def insert table, *rows
          rows = Array(rows).flatten
          return rows if rows.empty?
          rows.delete_if(&:nil?)
          rows.delete_if(&:empty?)
          @mutations += rows.map do |row|
            Google::Spanner::V1::Mutation.new(
              insert: Google::Spanner::V1::Mutation::Write.new(
                table: table, columns: row.keys.map(&:to_s),
                values: [Convert.raw_to_value(row.values).list_value]
              )
            )
          end
          rows
        end

        ##
        # Updates existing rows in a table. If any of the rows does not already
        # exist, the request fails with error {Google::Cloud::NotFoundError}.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#commit} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.update "users", [{ id: 1, name: "Charlie", active: false },
        #                        { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def update table, *rows
          rows = Array(rows).flatten
          return rows if rows.empty?
          rows.delete_if(&:nil?)
          rows.delete_if(&:empty?)
          @mutations += rows.map do |row|
            Google::Spanner::V1::Mutation.new(
              update: Google::Spanner::V1::Mutation::Write.new(
                table: table, columns: row.keys.map(&:to_s),
                values: [Convert.raw_to_value(row.values).list_value]
              )
            )
          end
          rows
        end

        ##
        # Inserts or replaces rows in a table. If any of the rows already exist,
        # it is deleted, and the column values provided are inserted instead.
        # Unlike #upsert, this means any values not explicitly written become
        # `NULL`.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#commit} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.replace "users", [{ id: 1, name: "Charlie", active: false },
        #                        { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def replace table, *rows
          rows = Array(rows).flatten
          return rows if rows.empty?
          rows.delete_if(&:nil?)
          rows.delete_if(&:empty?)
          @mutations += rows.map do |row|
            Google::Spanner::V1::Mutation.new(
              replace: Google::Spanner::V1::Mutation::Write.new(
                table: table, columns: row.keys.map(&:to_s),
                values: [Convert.raw_to_value(row.values).list_value]
              )
            )
          end
          rows
        end

        ##
        # Deletes rows from a table. Succeeds whether or not the specified rows
        # were present.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#commit} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Object, Array<Object>] keys A single, or list of keys or key
        #   ranges to match returned data to. Values should have exactly as many
        #   elements as there are columns in the primary key.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.delete "users", [1, 2, 3]
        #   end
        #
        def delete table, keys = []
          @mutations += [
            Google::Spanner::V1::Mutation.new(
              delete: Google::Spanner::V1::Mutation::Delete.new(
                table: table, key_set: key_set(keys)
              )
            )
          ]
          keys
        end

        # @private
        def mutations
          @mutations
        end

        protected

        def key_set keys
          return Google::Spanner::V1::KeySet.new(all: true) if keys.nil?
          keys = [keys] unless keys.is_a? Array
          return Google::Spanner::V1::KeySet.new(all: true) if keys.empty?
          if keys_are_ranges? keys
            key_ranges = keys.map do |r|
              Convert.to_key_range(r)
            end
            return Google::Spanner::V1::KeySet.new(ranges: key_ranges)
          end
          key_list = keys.map do |key|
            key = [key] unless key.is_a? Array
            Convert.raw_to_value(key).list_value
          end
          Google::Spanner::V1::KeySet.new keys: key_list
        end

        def keys_are_ranges? keys
          keys.each do |key|
            return true if key.is_a? ::Range
            return true if key.is_a? Google::Cloud::Spanner::Range
          end
          false
        end
      end
    end
  end
end
