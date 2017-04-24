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
      # # Commit
      #
      # Creates changes to be applied to rows in the database.
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
        alias_method :save, :upsert

        ##
        # Inserts new rows in a table. If any of the rows already exist, the
        # write or request fails with error `ALREADY_EXISTS`.
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
        # exist, the request fails with error `NOT_FOUND`.
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
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Object>] id One or more primary keys of the rows within
        #   table to delete.
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
        def delete table, *id
          keys = Array(id).flatten
          keys.delete_if(&:nil?)
          key_set = Google::Spanner::V1::KeySet.new(all: true)
          if keys.any?
            key_list = keys.map do |i|
              Convert.raw_to_value(Array(i)).list_value
            end
            key_set = Google::Spanner::V1::KeySet.new(keys: key_list)
          end
          @mutations += [
            Google::Spanner::V1::Mutation.new(
              delete: Google::Spanner::V1::Mutation::Delete.new(
                table: table, key_set: key_set)
            )
          ]
          keys
        end

        # @private
        def mutations
          @mutations
        end
      end
    end
  end
end
