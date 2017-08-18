# Copyright 2015 Google Inc. All rights reserved.
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


require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/table/list"
require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # View
      #
      # A view is a virtual table defined by a SQL query. You can query views in
      # the browser tool, or by using a query job.
      #
      # BigQuery's views are logical views, not materialized views, which means
      # that the query that defines the view is re-executed every time the view
      # is queried. Queries are billed according to the total amount of data in
      # all table fields referenced directly or indirectly by the top-level
      # query.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   view = dataset.create_view "my_view",
      #            "SELECT name, age FROM `my_project.my_dataset.my_table`"
      #
      class View
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Table object.
        def initialize
          @service = nil
          @gapi = Google::Apis::BigqueryV2::Table.new
        end

        ##
        # A unique ID for this table.
        # The ID must contain only letters (a-z, A-Z), numbers (0-9),
        # or underscores (_). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def table_id
          @gapi.table_reference.table_id
        end

        ##
        # The ID of the `Dataset` containing this table.
        #
        # @!group Attributes
        #
        def dataset_id
          @gapi.table_reference.dataset_id
        end

        ##
        # The ID of the `Project` containing this table.
        #
        # @!group Attributes
        #
        def project_id
          @gapi.table_reference.project_id
        end

        ##
        # @private The gapi fragment containing the Project ID, Dataset ID, and
        # Table ID as a camel-cased hash.
        def table_ref
          table_ref = @gapi.table_reference
          table_ref = table_ref.to_hash if table_ref.respond_to? :to_hash
          table_ref
        end

        ##
        # The combined Project ID, Dataset ID, and Table ID for this table, in
        # the format specified by the [Legacy SQL Query
        # Reference](https://cloud.google.com/bigquery/query-reference#from):
        # `project_name:datasetId.tableId`. To use this value in queries see
        # {#query_id}.
        #
        # @!group Attributes
        #
        def id
          @gapi.id
        end

        ##
        # The value returned by {#id}, wrapped in square brackets if the Project
        # ID contains dashes, as specified by the [Query
        # Reference](https://cloud.google.com/bigquery/query-reference#from).
        # Useful in queries.
        #
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is false.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   data = bigquery.query "SELECT name FROM #{view.query_id}"
        #
        # @!group Attributes
        #
        def query_id standard_sql: nil, legacy_sql: nil
          if Convert.resolve_legacy_sql standard_sql, legacy_sql
            "[#{id}]"
          else
            "`#{project_id}.#{dataset_id}.#{table_id}`"
          end
        end

        ##
        # The name of the table.
        #
        # @!group Attributes
        #
        def name
          @gapi.friendly_name
        end

        ##
        # Updates the name of the table.
        #
        # @!group Attributes
        #
        def name= new_name
          @gapi.update! friendly_name: new_name
          patch_gapi! :friendly_name
        end

        ##
        # A string hash of the dataset.
        #
        # @!group Attributes
        #
        def etag
          ensure_full_data!
          @gapi.etag
        end

        ##
        # A URL that can be used to access the dataset using the REST API.
        #
        # @!group Attributes
        #
        def api_url
          ensure_full_data!
          @gapi.self_link
        end

        ##
        # The description of the table.
        #
        # @!group Attributes
        #
        def description
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the description of the table.
        #
        # @!group Attributes
        #
        def description= new_description
          @gapi.update! description: new_description
          patch_gapi! :description
        end

        ##
        # The time when this table was created.
        #
        # @!group Attributes
        #
        def created_at
          ensure_full_data!
          begin
            ::Time.at(Integer(@gapi.creation_time) / 1000.0)
          rescue
            nil
          end
        end

        ##
        # The time when this table expires.
        # If not present, the table will persist indefinitely.
        # Expired tables will be deleted and their storage reclaimed.
        #
        # @!group Attributes
        #
        def expires_at
          ensure_full_data!
          begin
            ::Time.at(Integer(@gapi.expiration_time) / 1000.0)
          rescue
            nil
          end
        end

        ##
        # The date when this table was last modified.
        #
        # @!group Attributes
        #
        def modified_at
          ensure_full_data!
          begin
            ::Time.at(Integer(@gapi.last_modified_time) / 1000.0)
          rescue
            nil
          end
        end

        ##
        # Checks if the table's type is "TABLE".
        #
        # @!group Attributes
        #
        def table?
          @gapi.type == "TABLE"
        end

        ##
        # Checks if the table's type is "VIEW".
        #
        # @!group Attributes
        #
        def view?
          @gapi.type == "VIEW"
        end

        ##
        # The geographic location where the table should reside. Possible
        # values include EU and US. The default value is US.
        #
        # @!group Attributes
        #
        def location
          ensure_full_data!
          @gapi.location
        end

        ##
        # The schema of the view.
        #
        # @!group Attributes
        #
        def schema
          ensure_full_data!
          Schema.from_gapi(@gapi.schema).freeze
        end

        ##
        # The fields of the view.
        #
        # @!group Attributes
        #
        def fields
          schema.fields
        end

        ##
        # The names of the columns in the view.
        #
        # @!group Attributes
        #
        def headers
          schema.headers
        end

        ##
        # The query that executes each time the view is loaded.
        #
        # @!group Attributes
        #
        def query
          @gapi.view.query if @gapi.view
        end

        ##
        # Updates the query that executes each time the view is loaded.
        #
        # @see https://cloud.google.com/bigquery/query-reference BigQuery Query
        #   Reference
        #
        # @param [String] new_query The query that defines the view.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is false.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.query = "SELECT first_name FROM " \
        #                "`my_project.my_dataset.my_table`"
        #
        # @!group Lifecycle
        #
        def query= new_query, standard_sql: nil, legacy_sql: nil
          @gapi.view ||= Google::Apis::BigqueryV2::ViewDefinition.new
          @gapi.view.update! query: new_query
          @gapi.view.update! use_legacy_sql: \
            Convert.resolve_legacy_sql(standard_sql, legacy_sql)
          patch_view_gapi! :query
        end

        ##
        # Runs a query to retrieve all data from the view, in a synchronous
        # method that blocks for a response. In this method, a {QueryJob} is
        # created and its results are saved to a temporary table, then read from
        # the table. Timeouts and transient errors are generally handled as
        # needed to complete the query.
        #
        # @param [Integer] max The maximum number of rows of data to return per
        #   page of results. Setting this flag to a small value such as 1000 and
        #   then paging through results might improve reliability when the query
        #   result set is large. In addition to this limit, responses are also
        #   limited to 10 MB. By default, there is no maximum row count, and
        #   only the byte limit applies.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        #
        # @return [Google::Cloud::Bigquery::Data]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   data = view.data
        #   data.each do |row|
        #     puts row[:first_name]
        #   end
        #   more_data = data.next if data.next?
        #
        # @!group Data
        #
        def data max: nil, cache: true
          sql = "SELECT * FROM #{query_id}"
          ensure_service!

          gapi = service.query_job sql, cache: cache
          job = Job.from_gapi gapi, service
          job.wait_until_done!

          if job.failed?
            begin
              # raise to activate ruby exception cause handling
              fail job.gapi_error
            rescue => e
              # wrap Google::Apis::Error with Google::Cloud::Error
              raise Google::Cloud::Error.from_error(e)
            end
          end

          job.data max: max
        end

        ##
        # Permanently deletes the table.
        #
        # @return [Boolean] Returns `true` if the table was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.delete
        #
        # @!group Lifecycle
        #
        def delete
          ensure_service!
          service.delete_table dataset_id, table_id
          true
        end

        ##
        # Reloads the table with current data from the BigQuery service.
        #
        # @!group Lifecycle
        #
        def reload!
          ensure_service!
          gapi = service.get_table dataset_id, table_id
          @gapi = gapi
        end
        alias_method :refresh!, :reload!

        ##
        # @private New Table from a Google API Client object.
        def self.from_gapi gapi, conn
          new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        def resolve_legacy_sql legacy_sql, standard_sql
          return legacy_sql unless legacy_sql.nil?
          return !standard_sql unless standard_sql.nil?
          false
        end

        def patch_gapi! *attributes
          return if attributes.empty?
          patch_args = Hash[attributes.map do |attr|
            [attr, @gapi.send(attr)]
          end]
          patch_table_gapi patch_args
        end

        def patch_view_gapi! *attributes
          return if attributes.empty?
          patch_args = Hash[attributes.map do |attr|
            [attr, @gapi.view.send(attr)]
          end]
          patch_view_args = Google::Apis::BigqueryV2::ViewDefinition.new(
            patch_args
          )
          patch_table_gapi view: patch_view_args
        end

        def patch_table_gapi patch_args
          ensure_service!
          patch_gapi = Google::Apis::BigqueryV2::Table.new patch_args
          patch_gapi.etag = etag if etag
          @gapi = service.patch_table dataset_id, table_id, patch_gapi

          # TODO: restore original impl after acceptance test indicates that
          # service etag bug is fixed
          reload!
        end

        ##
        # Load the complete representation of the table if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload_gapi! unless data_complete?
        end

        def reload_gapi!
          ensure_service!
          gapi = service.get_table dataset_id, table_id
          @gapi = gapi
        end

        def data_complete?
          @gapi.is_a? Google::Apis::BigqueryV2::Table
        end
      end
    end
  end
end
