# Copyright 2021 Google LLC
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


require "google/apis/bigquery_v2"
require "base64"
require "google/cloud/bigquery/external/bigtable_source/column"

module Google
  module Cloud
    module Bigquery
      module External
        class BigtableSource < External::DataSource
          ##
          # # BigtableSource::ColumnFamily
          #
          # A Bigtable column family used to expose in the table schema along
          # with its types and columns.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #     bt.add_family "user" do |u|
          #       u.add_string "name"
          #       u.add_string "email"
          #       u.add_integer "age"
          #       u.add_boolean "active"
          #     end
          #   end
          #
          #   data = bigquery.query "SELECT * FROM my_ext_table",
          #                         external: { my_ext_table: bigtable_table }
          #
          #   # Iterate over the first page of results
          #   data.each do |row|
          #     puts row[:name]
          #   end
          #   # Retrieve the next page of results
          #   data = data.next if data.next?
          #
          class ColumnFamily
            ##
            # @private Create an empty BigtableSource::ColumnFamily object.
            def initialize
              @gapi = Google::Apis::BigqueryV2::BigtableColumnFamily.new
              @columns = []
            end

            ##
            # The encoding of the values when the type is not `STRING`.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.encoding = "UTF-8"
            #     end
            #   end
            #
            #   bigtable_table.families[0].encoding #=> "UTF-8"
            #
            def encoding
              @gapi.encoding
            end

            ##
            # Set the encoding of the values when the type is not `STRING`.
            # Acceptable encoding values are:
            #
            # * `TEXT` - indicates values are alphanumeric text strings.
            # * `BINARY` - indicates values are encoded using HBase
            #   `Bytes.toBytes` family of functions. This can be overridden on a
            #   column.
            #
            # @param [String] new_encoding New encoding value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.encoding = "UTF-8"
            #     end
            #   end
            #
            #   bigtable_table.families[0].encoding #=> "UTF-8"
            #
            def encoding= new_encoding
              frozen_check!
              @gapi.encoding = new_encoding
            end

            ##
            # Identifier of the column family.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user"
            #   end
            #
            #   bigtable_table.families[0].family_id #=> "user"
            #
            def family_id
              @gapi.family_id
            end

            ##
            # Set the identifier of the column family.
            #
            # @param [String] new_family_id New family_id value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user"
            #   end
            #
            #   bigtable_table.families[0].family_id #=> "user"
            #   bigtable_table.families[0].family_id = "User"
            #   bigtable_table.families[0].family_id #=> "User"
            #
            def family_id= new_family_id
              frozen_check!
              @gapi.family_id = new_family_id
            end

            ##
            # Whether only the latest version of value are exposed for all
            # columns in this column family.
            #
            # @return [Boolean]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.latest = true
            #     end
            #   end
            #
            #   bigtable_table.families[0].latest #=> true
            #
            def latest
              @gapi.only_read_latest
            end

            ##
            # Set whether only the latest version of value are exposed for all
            # columns in this column family.
            #
            # @param [Boolean] new_latest New latest value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.latest = true
            #     end
            #   end
            #
            #   bigtable_table.families[0].latest #=> true
            #
            def latest= new_latest
              frozen_check!
              @gapi.only_read_latest = new_latest
            end

            ##
            # The type to convert the value in cells of this column family. The
            # values are expected to be encoded using HBase `Bytes.toBytes`
            # function when using the `BINARY` encoding value. The following
            # BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. This can be overridden on a column.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.type = "STRING"
            #     end
            #   end
            #
            #   bigtable_table.families[0].type #=> "STRING"
            #
            def type
              @gapi.type
            end

            ##
            # Set the type to convert the value in cells of this column family.
            # The values are expected to be encoded using HBase `Bytes.toBytes`
            # function when using the `BINARY` encoding value. The following
            # BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. This can be overridden on a column.
            #
            # @param [String] new_type New type value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.type = "STRING"
            #     end
            #   end
            #
            #   bigtable_table.families[0].type #=> "STRING"
            #
            def type= new_type
              frozen_check!
              @gapi.type = new_type
            end

            ##
            # Lists of columns that should be exposed as individual fields.
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_string "name"
            #       u.add_string "email"
            #       u.add_integer "age"
            #       u.add_boolean "active"
            #     end
            #   end
            #
            #   bigtable_table.families[0].columns.count #=> 4
            #
            def columns
              @columns
            end

            ##
            # Add a column to the column family to expose in the table schema
            # along with its types.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            # @param [String] type The type to convert the value in cells of
            #   this column. See {BigtableSource::Column#type}. The following
            #   BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_column "name", type: "STRING"
            #     end
            #   end
            #
            def add_column qualifier, as: nil, type: nil
              frozen_check!
              col = BigtableSource::Column.new
              col.qualifier = qualifier
              col.field_name = as if as
              col.type = type if type
              yield col if block_given?
              @columns << col
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `BYTES` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_bytes "avatar"
            #     end
            #   end
            #
            def add_bytes qualifier, as: nil
              col = add_column qualifier, as: as, type: "BYTES"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `STRING` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_string "name"
            #     end
            #   end
            #
            def add_string qualifier, as: nil
              col = add_column qualifier, as: as, type: "STRING"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `INTEGER` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_integer "age"
            #     end
            #   end
            #
            def add_integer qualifier, as: nil
              col = add_column qualifier, as: as, type: "INTEGER"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `FLOAT` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_float "score"
            #     end
            #   end
            #
            def add_float qualifier, as: nil
              col = add_column qualifier, as: as, type: "FLOAT"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `BOOLEAN` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_boolean "active"
            #     end
            #   end
            #
            def add_boolean qualifier, as: nil
              col = add_column qualifier, as: as, type: "BOOLEAN"
              yield col if block_given?
              col
            end

            ##
            # @private Google API Client object.
            def to_gapi
              @gapi.columns = @columns.map(&:to_gapi)
              @gapi
            end

            ##
            # @private Google API Client object.
            def self.from_gapi gapi
              new_fam = new
              new_fam.instance_variable_set :@gapi, gapi
              columns = Array(gapi.columns).map { |col_gapi| BigtableSource::Column.from_gapi col_gapi }
              new_fam.instance_variable_set :@columns, columns
              new_fam
            end

            ##
            # @private
            def freeze
              @columns.map(&:freeze!)
              @columns.freeze!
              super
            end

            protected

            def frozen_check!
              return unless frozen?
              raise ArgumentError, "Cannot modify external data source when frozen"
            end
          end
        end
      end
    end
  end
end
