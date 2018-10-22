# Copyright 2015 Google LLC
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


require "delegate"
require "google/cloud/bigquery/service"

module Google
  module Cloud
    module Bigquery
      ##
      # # Data
      #
      # Represents a page of results (rows) as an array of hashes. Because Data
      # delegates to Array, methods such as `Array#count` represent the number
      # of rows in the page. In addition, methods of this class include result
      # set metadata such as `total` and provide access to the schema of the
      # query or table. See {Project#query}, {Dataset#query} and {Table#data}.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   sql = "SELECT word FROM `bigquery-public-data.samples.shakespeare`"
      #   job = bigquery.query_job sql
      #
      #   job.wait_until_done!
      #   data = job.data
      #
      #   data.count # 100000
      #   data.total # 164656
      #   data.each do |row|
      #     puts row[:word]
      #   end
      #   data = data.next if data.next?
      #
      class Data < DelegateClass(::Array)
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The {Table} object the data belongs to.
        attr_accessor :table_gapi

        ##
        # @private The Google API Client object in JSON Hash.
        attr_accessor :gapi_json

        ##
        # @private The query Job gapi object, or nil if from Table#data.
        attr_accessor :job_gapi

        # @private
        def initialize arr = []
          @service = nil
          @table_gapi = nil
          @gapi_json = nil
          super arr
        end

        ##
        # The resource type of the API response.
        #
        # @return [String] The resource type.
        #
        def kind
          @gapi_json[:kind]
        end

        ##
        # An ETag hash for the page of results represented by the data instance.
        #
        # @return [String] The ETag hash.
        #
        def etag
          @gapi_json[:etag]
        end

        ##
        # A token used for paging results. Used by the data instance to retrieve
        # subsequent pages. See {#next}.
        #
        # @return [String] The pagination token.
        #
        def token
          @gapi_json[:pageToken]
        end

        ##
        # The total number of rows in the complete table.
        #
        # @return [Integer] The number of rows.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT word FROM `bigquery-public-data.samples.shakespeare`"
        #   job = bigquery.query_job sql
        #
        #   job.wait_until_done!
        #   data = job.data
        #
        #   data.count # 100000
        #   data.total # 164656
        #   data.each do |row|
        #     puts row[:word]
        #   end
        #   data = data.next if data.next?
        #
        def total
          Integer @gapi_json[:totalRows]
        rescue StandardError
          nil
        end

        ##
        # The schema of the table from which the data was read.
        #
        # The returned object is frozen and changes are not allowed. Use
        # {Table#schema} to update the schema.
        #
        # @return [Schema] A schema object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   schema = data.schema
        #   field = schema.field "name"
        #   field.required? #=> true
        #
        def schema
          Schema.from_gapi(@table_gapi.schema).freeze
        end

        ##
        # The fields of the data, obtained from the schema of the table from
        # which the data was read.
        #
        # @return [Array<Schema::Field>] An array of field objects.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   data.fields.each do |field|
        #     puts field.name
        #   end
        #
        def fields
          schema.fields
        end

        ##
        # The names of the columns in the data, obtained from the schema of the
        # table from which the data was read.
        #
        # @return [Array<Symbol>] An array of column names.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   data.headers.each do |header|
        #     puts header
        #   end
        #
        def headers
          schema.headers
        end

        ##
        # The type of query statement, if valid. Possible values (new values
        # might be added in the future):
        #
        # * "SELECT": `SELECT` query.
        # * "INSERT": `INSERT` query; see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language
        # * "UPDATE": `UPDATE` query; see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language
        # * "DELETE": `DELETE` query; see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language
        # * "CREATE_TABLE": `CREATE [OR REPLACE] TABLE` without `AS SELECT`.
        # * "CREATE_TABLE_AS_SELECT": `CREATE [OR REPLACE] TABLE ... AS SELECT`.
        # * "DROP_TABLE": `DROP TABLE` query.
        # * "CREATE_VIEW": `CREATE [OR REPLACE] VIEW ... AS SELECT ...`.
        # * "DROP_VIEW": `DROP VIEW` query.
        #
        # @return [String, nil] The type of query statement.
        #
        def statement_type
          return nil unless job_gapi && job_gapi.statistics.query
          job_gapi.statistics.query.statement_type
        end

        def ddl?
          %w[CREATE_TABLE CREATE_TABLE_AS_SELECT DROP_TABLE CREATE_VIEW \
             DROP_VIEW].include? statement_type
        end

        def dml?
          %w[INSERT UPDATE DELETE].include? statement_type
        end

        ##
        # The DDL operation performed, possibly dependent on the pre-existence
        # of the DDL target. (See {#ddl_target_table}.) Possible values (new
        # values might be added in the future):
        #
        # * "CREATE": The query created the DDL target.
        # * "SKIP": No-op. Example cases: the query is
        #   `CREATE TABLE IF NOT EXISTS` while the table already exists, or the
        #   query is `DROP TABLE IF EXISTS` while the table does not exist.
        # * "REPLACE": The query replaced the DDL target. Example case: the
        #   query is `CREATE OR REPLACE TABLE`, and the table already exists.
        # * "DROP": The query deleted the DDL target.
        #
        # @return [String, nil] The DDL operation performed.
        #
        def ddl_operation_performed
          return nil unless job_gapi && job_gapi.statistics.query
          job_gapi.statistics.query.ddl_operation_performed
        end

        ##
        # The DDL target table, in reference state. (See {Table#reference?}.)
        # Present only for `CREATE/DROP TABLE/VIEW` queries. (See
        # {#statement_type}.)
        #
        # @return [Google::Cloud::Bigquery::Table, nil] The DDL target table, in
        #   reference state.
        #
        def ddl_target_table
          return nil unless job_gapi && job_gapi.statistics.query
          ensure_service!
          table = job_gapi.statistics.query.ddl_target_table
          return nil unless table
          Google::Cloud::Bigquery::Table.new_reference_from_gapi table, service
        end

        ##
        # The number of rows affected by a DML statement. Present only for DML
        # statements `INSERT`, `UPDATE` or `DELETE`. (See {#statement_type}.)
        #
        # @return [Integer, nil] The number of rows affected by a DML statement,
        #   or `nil` if the query is not a DML statement.
        #
        def num_dml_affected_rows
          return nil unless job_gapi && job_gapi.statistics.query
          job_gapi.statistics.query.num_dml_affected_rows
        end

        ##
        # Whether there is a next page of data.
        #
        # @return [Boolean] `true` when there is a next page, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT word FROM `bigquery-public-data.samples.shakespeare`"
        #   job = bigquery.query_job sql
        #
        #   job.wait_until_done!
        #   data = job.data
        #
        #   data.count # 100000
        #   data.total # 164656
        #   data.each do |row|
        #     puts row[:word]
        #   end
        #   data = data.next if data.next?
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieves the next page of data.
        #
        # @return [Data] A new instance providing the next page of data.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT word FROM `bigquery-public-data.samples.shakespeare`"
        #   job = bigquery.query_job sql
        #
        #   job.wait_until_done!
        #   data = job.data
        #
        #   data.count # 100000
        #   data.total # 164656
        #   data.each do |row|
        #     puts row[:word]
        #   end
        #   data = data.next if data.next?
        #
        def next
          return nil unless next?
          ensure_service!
          data_json = service.list_tabledata \
            @table_gapi.table_reference.dataset_id,
            @table_gapi.table_reference.table_id,
            token: token
          self.class.from_gapi_json data_json, @table_gapi, job_gapi, @service
        end

        ##
        # Retrieves all rows by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each row, which is
        # passed as the parameter.
        #
        # An enumerator is returned if no block is given.
        #
        # This method may make several API calls until all rows are retrieved.
        # Be sure to use as narrow a search criteria as possible. Please use
        # with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all data. Default is no limit.
        # @yield [row] The block for accessing each row of data.
        # @yieldparam [Hash] row The row object.
        #
        # @return [Enumerator] An enumerator providing access to all of the
        #   data.
        #
        # @example Iterating each rows by passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.data.all do |row|
        #     puts row[:word]
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   words = table.data.all.map do |row|
        #     row[:word]
        #   end
        #
        #
        # @example Limit the number of API calls made:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.data.all(request_limit: 10) do |row|
        #     puts row[:word]
        #   end
        #
        def all request_limit: nil
          request_limit = request_limit.to_i if request_limit
          unless block_given?
            return enum_for(:all, request_limit: request_limit)
          end
          results = self
          loop do
            results.each { |r| yield r }
            if request_limit
              request_limit -= 1
              break if request_limit < 0
            end
            break unless results.next?
            results = results.next
          end
        end

        ##
        # @private New Data from a response object.
        def self.from_gapi_json gapi_json, table_gapi, job_gapi, service
          rows = gapi_json[:rows] || []
          unless rows.empty?
            rows = Convert.format_rows rows, table_gapi.schema.fields
          end

          data = new rows
          data.table_gapi = table_gapi
          data.gapi_json = gapi_json
          data.job_gapi = job_gapi
          data.service = service
          data
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end
      end
    end
  end
end
