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
require "google/cloud/bigquery/external/bigtable_source/column_family"

module Google
  module Cloud
    module Bigquery
      module External
        ##
        # # BigtableSource
        #
        # {External::BigtableSource} is a subclass of {External::DataSource} and
        # represents a Bigtable external data source that can be queried from
        # directly, even though the data is not stored in BigQuery. Instead of
        # loading or streaming the data, this object references the external
        # data source.
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
        class BigtableSource < External::DataSource
          ##
          # @private Create an empty BigtableSource object.
          def initialize
            super
            @gapi.bigtable_options = Google::Apis::BigqueryV2::BigtableOptions.new
            @families = []
          end

          ##
          # List of column families to expose in the table schema along with
          # their types. This list restricts the column families that can be
          # referenced in queries and specifies their value types. You can use
          # this list to do type conversions - see
          # {BigtableSource::ColumnFamily#type} for more details. If you leave
          # this list empty, all column families are present in the table schema
          # and their values are read as `BYTES`. During a query only the column
          # families referenced in that query are read from Bigtable.
          #
          # @return [Array<BigtableSource::ColumnFamily>]
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
          #   bigtable_table.families.count #=> 1
          #
          def families
            @families
          end

          ##
          # Add a column family to expose in the table schema along with its
          # types. Columns belonging to the column family may also be exposed.
          #
          # @param [String] family_id Identifier of the column family. See
          #   {BigtableSource::ColumnFamily#family_id}.
          # @param [String] encoding The encoding of the values when the type is
          #   not `STRING`. See {BigtableSource::ColumnFamily#encoding}.
          # @param [Boolean] latest Whether only the latest version of value are
          #   exposed for all columns in this column family. See
          #   {BigtableSource::ColumnFamily#latest}.
          # @param [String] type The type to convert the value in cells of this
          #   column. See {BigtableSource::ColumnFamily#type}.
          #
          # @yield [family] a block for setting the family
          # @yieldparam [BigtableSource::ColumnFamily] family the family object
          #
          # @return [BigtableSource::ColumnFamily]
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
          def add_family family_id, encoding: nil, latest: nil, type: nil
            frozen_check!
            fam = BigtableSource::ColumnFamily.new
            fam.family_id = family_id
            fam.encoding = encoding if encoding
            fam.latest = latest if latest
            fam.type = type if type
            yield fam if block_given?
            @families << fam
            fam
          end

          ##
          # Whether the rowkey column families will be read and converted to
          # string. Otherwise they are read with `BYTES` type values and users
          # need to manually cast them with `CAST` if necessary. The default
          # value is `false`.
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
          #     bt.rowkey_as_string = true
          #   end
          #
          #   bigtable_table.rowkey_as_string #=> true
          #
          def rowkey_as_string
            @gapi.bigtable_options.read_rowkey_as_string
          end

          ##
          # Set the number of rows at the top of a sheet that BigQuery will skip
          # when reading the data.
          #
          # @param [Boolean] row_rowkey New rowkey_as_string value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #   end
          #
          #   bigtable_table.rowkey_as_string #=> true
          #
          def rowkey_as_string= row_rowkey
            frozen_check!
            @gapi.bigtable_options.read_rowkey_as_string = row_rowkey
          end

          ##
          # @private Google API Client object.
          def to_gapi
            @gapi.bigtable_options.column_families = @families.map(&:to_gapi)
            @gapi
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_table = super
            families = Array gapi.bigtable_options.column_families
            families = families.map { |fam_gapi| BigtableSource::ColumnFamily.from_gapi fam_gapi }
            new_table.instance_variable_set :@families, families
            new_table
          end

          ##
          # @private
          def freeze
            @families.map(&:freeze!)
            @families.freeze!
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
