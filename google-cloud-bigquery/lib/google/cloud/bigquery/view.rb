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
        # @private Create an empty View object.
        def initialize
          @service = nil
          @gapi = Google::Apis::BigqueryV2::Table.new
        end

        ##
        # A unique ID for this view.
        #
        # @return [String] The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), or underscores (_). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def table_id
          @gapi.table_reference.table_id
        end

        ##
        # The ID of the `Dataset` containing this view.
        #
        # @return [String] The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), or underscores (_). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def dataset_id
          @gapi.table_reference.dataset_id
        end

        ##
        # The ID of the `Project` containing this view.
        #
        # @return [String] The project ID.
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
        # The combined Project ID, Dataset ID, and Table ID for this view, in
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
        # The name of the view.
        #
        # @return [String] The friendly name.
        #
        # @!group Attributes
        #
        def name
          @gapi.friendly_name
        end

        ##
        # Updates the name of the view.
        #
        # @param [String] new_name The new friendly name.
        #
        # @!group Attributes
        #
        def name= new_name
          @gapi.update! friendly_name: new_name
          patch_gapi! :friendly_name
        end

        ##
        # The ETag hash of the view.
        #
        # @return [String] The ETag hash.
        #
        # @!group Attributes
        #
        def etag
          ensure_full_data!
          @gapi.etag
        end

        ##
        # A URL that can be used to access the view using the REST API.
        #
        # @return [String] A REST URL for the resource.
        #
        # @!group Attributes
        #
        def api_url
          ensure_full_data!
          @gapi.self_link
        end

        ##
        # A user-friendly description of the view.
        #
        # @return [String] The description.
        #
        # @!group Attributes
        #
        def description
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the user-friendly description of the view.
        #
        # @param [String] new_description The new user-friendly description.
        #
        # @!group Attributes
        #
        def description= new_description
          @gapi.update! description: new_description
          patch_gapi! :description
        end

        ##
        # The time when this view was created.
        #
        # @return [Time, nil] The creation time.
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
        # The time when this view expires.
        # If not present, the view will persist indefinitely.
        # Expired views will be deleted and their storage reclaimed.
        #
        # @return [Time, nil] The expiration time.
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
        # The date when this view was last modified.
        #
        # @return [Time, nil] The last modified time.
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
        # Checks if the view's type is "TABLE".
        #
        # @return [Boolean] `true` when the type is `TABLE`, `false` otherwise.
        #
        # @!group Attributes
        #
        def table?
          @gapi.type == "TABLE"
        end

        ##
        # Checks if the view's type is "VIEW".
        #
        # @return [Boolean] `true` when the type is `VIEW`, `false` otherwise.
        #
        # @!group Attributes
        #
        def view?
          @gapi.type == "VIEW"
        end

        ##
        # Checks if the view's type is "EXTERNAL".
        #
        # @return [Boolean] `true` when the type is `EXTERNAL`, `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def external?
          @gapi.type == "EXTERNAL"
        end

        ##
        # The geographic location where the view should reside. Possible
        # values include `EU` and `US`. The default value is `US`.
        #
        # @return [String] The location code.
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
        # The returned object is frozen and changes are not allowed.
        #
        # @return [Schema] A schema object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   schema = view.schema
        #   field = schema.field "name"
        #   field.required? #=> true
        #
        # @!group Attributes
        #
        def schema
          ensure_full_data!
          Schema.from_gapi(@gapi.schema).freeze
        end

        ##
        # The fields of the view, obtained from its schema.
        #
        # @return [Array<Schema::Field>] An array of field objects.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.fields.each do |field|
        #     puts field.name
        #   end
        #
        # @!group Attributes
        #
        def fields
          schema.fields
        end

        ##
        # The names of the columns in the view, obtained from its schema.
        #
        # @return [Array<Symbol>] An array of column names.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.headers.each do |header|
        #     puts header
        #   end
        #
        # @!group Attributes
        #
        def headers
          schema.headers
        end

        ##
        # The query that executes each time the view is loaded.
        #
        # @return [String] The query that defines the view.
        #
        # @!group Attributes
        #
        def query
          @gapi.view.query if @gapi.view
        end

        ##
        # Updates the query that executes each time the view is loaded.
        #
        # This sets the query using standard SQL. To specify legacy SQL or to
        # use user-defined function resources use (#set_query) instead.
        #
        # @see https://cloud.google.com/bigquery/query-reference BigQuery Query
        #   Reference
        #
        # @param [String] new_query The query that defines the view.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.query = "SELECT first_name FROM " \
        #                  "`my_project.my_dataset.my_table`"
        #
        # @!group Lifecycle
        #
        def query= new_query
          set_query new_query
        end

        ##
        # Updates the query that executes each time the view is loaded. Allows
        # setting of standard vs. legacy SQL and user-defined function
        # resources.
        #
        # @see https://cloud.google.com/bigquery/query-reference BigQuery Query
        #   Reference
        #
        # @param [String] query The query that defines the view.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is false.
        # @param [Array<String>, String] udfs User-defined function resources
        #   used in the query. May be either a code resource to load from a
        #   Google Cloud Storage URI (`gs://bucket/path`), or an inline resource
        #   that contains code for a user-defined function (UDF). Providing an
        #   inline code resource is equivalent to providing a URI for a file
        #   containing the same code. See [User-Defined
        #   Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.table "my_view"
        #
        #   view.set_query "SELECT first_name FROM " \
        #                    "`my_project.my_dataset.my_table`",
        #                  standard_sql: true
        #
        # @!group Lifecycle
        #
        def set_query query, standard_sql: nil, legacy_sql: nil, udfs: nil
          @gapi.view = Google::Apis::BigqueryV2::ViewDefinition.new \
            query: query,
            use_legacy_sql: Convert.resolve_legacy_sql(standard_sql,
                                                       legacy_sql),
            user_defined_function_resources: udfs_gapi(udfs)
          patch_view_gapi!
        end

        ##
        # Checks if the view's query is using legacy sql.
        #
        # @return [Boolean] `true` when legacy sql is used, `false` otherwise.
        #
        # @!group Attributes
        #
        def query_legacy_sql?
          val = @gapi.view.use_legacy_sql
          return true if val.nil?
          val
        end

        ##
        # Checks if the view's query is using standard sql.
        #
        # @return [Boolean] `true` when standard sql is used, `false` otherwise.
        #
        # @!group Attributes
        #
        def query_standard_sql?
          !query_legacy_sql?
        end

        ##
        # The user-defined function resources used in the view's query. May be
        # either a code resource to load from a Google Cloud Storage URI
        # (`gs://bucket/path`), or an inline resource that contains code for a
        # user-defined function (UDF). Providing an inline code resource is
        # equivalent to providing a URI for a file containing the same code. See
        # [User-Defined
        # Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
        #
        # @return [Array<String>] An array containing Google Cloud Storage URIs
        #   and/or inline source code.
        #
        # @!group Attributes
        #
        def query_udfs
          udfs_gapi = @gapi.view.user_defined_function_resources
          return [] if udfs_gapi.nil?
          Array(udfs_gapi).map { |udf| udf.inline_code || udf.resource_uri }
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
        # Permanently deletes the view.
        #
        # @return [Boolean] Returns `true` if the view was deleted.
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
        # Reloads the view with current data from the BigQuery service.
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

        def patch_gapi! *attributes
          return if attributes.empty?
          patch_args = Hash[attributes.map do |attr|
            [attr, @gapi.send(attr)]
          end]
          patch_table_gapi patch_args
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

        def patch_view_gapi!
          patch_table_gapi view: @gapi.view
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

        def udfs_gapi array_or_str
          return [] if array_or_str.nil?
          Array(array_or_str).map do |uri_or_code|
            resource = Google::Apis::BigqueryV2::UserDefinedFunctionResource.new
            if uri_or_code.start_with?("gs://")
              resource.resource_uri = uri_or_code
            else
              resource.inline_code = uri_or_code
            end
            resource
          end
        end
      end
    end
  end
end
