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


require "json"
require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/table"
require "google/cloud/bigquery/dataset/list"
require "google/cloud/bigquery/dataset/access"
require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Dataset
      #
      # Represents a Dataset. A dataset is a grouping mechanism that holds zero
      # or more tables. Datasets are the lowest level unit of access control;
      # you cannot control access at the table level. A dataset is contained
      # within a specific project.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   dataset = bigquery.create_dataset "my_dataset",
      #                                     name: "My Dataset",
      #                                     description: "This is my Dataset"
      #
      class Dataset
        ##
        # @private The Connection object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Dataset object.
        def initialize
          @service = nil
          @gapi = {}
        end

        ##
        # A unique ID for this dataset, without the project name.
        # The ID must contain only letters (a-z, A-Z), numbers (0-9),
        # or underscores (_). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def dataset_id
          @gapi.dataset_reference.dataset_id
        end

        ##
        # The ID of the project containing this dataset.
        #
        # @!group Attributes
        #
        def project_id
          @gapi.dataset_reference.project_id
        end

        ##
        # @private
        # The gapi fragment containing the Project ID and Dataset ID as a
        # camel-cased hash.
        def dataset_ref
          dataset_ref = @gapi.dataset_reference
          dataset_ref = dataset_ref.to_h if dataset_ref.respond_to? :to_h
          dataset_ref
        end

        ##
        # A descriptive name for the dataset.
        #
        # @!group Attributes
        #
        def name
          @gapi.friendly_name
        end

        ##
        # Updates the descriptive name for the dataset.
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
        # A user-friendly description of the dataset.
        #
        # @!group Attributes
        #
        def description
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the user-friendly description of the dataset.
        #
        # @!group Attributes
        #
        def description= new_description
          @gapi.update! description: new_description
          patch_gapi! :description
        end

        ##
        # The default lifetime of all tables in the dataset, in milliseconds.
        #
        # @!group Attributes
        #
        def default_expiration
          ensure_full_data!
          begin
            Integer @gapi.default_table_expiration_ms
          rescue
            nil
          end
        end

        ##
        # Updates the default lifetime of all tables in the dataset, in
        # milliseconds.
        #
        # @!group Attributes
        #
        def default_expiration= new_default_expiration
          @gapi.update! default_table_expiration_ms: new_default_expiration
          patch_gapi! :default_table_expiration_ms
        end

        ##
        # The time when this dataset was created.
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
        # The date when this dataset or any of its tables was last modified.
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
        # The geographic location where the dataset should reside. Possible
        # values include EU and US. The default value is US.
        #
        # @!group Attributes
        #
        def location
          ensure_full_data!
          @gapi.location
        end

        ##
        # A hash of user-provided labels associated with this dataset. Labels
        # are used to organize and group datasets. See [Labeling
        # Datasets](https://cloud.google.com/bigquery/docs/labeling-datasets).
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to replace the entire hash.
        #
        # @!group Attributes
        #
        def labels
          m = @gapi.labels
          m = m.to_h if m.respond_to? :to_h
          m.dup.freeze
        end

        ##
        # Updates the hash of user-provided labels associated with this dataset.
        # Labels are used to organize and group datasets. See [Labeling
        # Datasets](https://cloud.google.com/bigquery/docs/labeling-datasets).
        #
        # @!group Attributes
        #
        def labels= labels
          @gapi.labels = labels
          patch_gapi! :labels
        end

        ##
        # Retrieves the access rules for a Dataset. The rules can be updated
        # when passing a block, see {Dataset::Access} for all the methods
        # available.
        #
        # @see https://cloud.google.com/bigquery/access-control BigQuery Access
        #   Control
        #
        # @yield [access] a block for setting rules
        # @yieldparam [Dataset::Access] access the object accepting rules
        #
        # @return [Google::Cloud::Bigquery::Dataset::Access]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.access # [{"role"=>"OWNER",
        #                  #   "specialGroup"=>"projectOwners"},
        #                  #  {"role"=>"WRITER",
        #                  #   "specialGroup"=>"projectWriters"},
        #                  #  {"role"=>"READER",
        #                  #   "specialGroup"=>"projectReaders"},
        #                  #  {"role"=>"OWNER",
        #                  #   "userByEmail"=>"123456789-...com"}]
        #
        # @example Manage the access rules by passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.access do |access|
        #     access.add_owner_group "owners@example.com"
        #     access.add_writer_user "writer@example.com"
        #     access.remove_writer_user "readers@example.com"
        #     access.add_reader_special :all
        #     access.add_reader_view other_dataset_view_object
        #   end
        #
        def access
          ensure_full_data!
          access_builder = Access.from_gapi @gapi
          if block_given?
            yield access_builder
            if access_builder.changed?
              @gapi.update! access: access_builder.to_gapi
              patch_gapi! :access
            end
          end
          access_builder.freeze
        end

        ##
        # Permanently deletes the dataset. The dataset must be empty before it
        # can be deleted unless the `force` option is set to `true`.
        #
        # @param [Boolean] force If `true`, delete all the tables in the
        #   dataset. If `false` and the dataset contains tables, the request
        #   will fail. Default is `false`.
        #
        # @return [Boolean] Returns `true` if the dataset was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.delete
        #
        # @!group Lifecycle
        #
        def delete force: nil
          ensure_service!
          service.delete_dataset dataset_id, force
          true
        end

        ##
        # Creates a new table. If you are adapting existing code that was
        # written for the [Rest API
        # ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource),
        # you can pass the table's schema as a hash (see example.)
        #
        # @param [String] table_id The ID of the table. The ID must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_). The maximum
        #   length is 1,024 characters.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @yield [table] a block for setting the table
        # @yieldparam [Table] table the table object to be updated
        #
        # @return [Google::Cloud::Bigquery::Table]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table"
        #
        # @example You can also pass name and description options.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table",
        #                                name: "My Table",
        #                                description: "A description of table."
        #
        # @example Or the table's schema can be configured with the block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.schema.string "first_name", mode: :required
        #     t.schema.record "cities_lived", mode: :required do |s|
        #       s.string "place", mode: :required
        #       s.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example You can define the schema using a nested block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.name = "My Table",
        #     t.description = "A description of my table."
        #     t.schema do |s|
        #       s.string "first_name", mode: :required
        #       s.record "cities_lived", mode: :repeated do |r|
        #         r.string "place", mode: :required
        #         r.integer "number_of_years", mode: :required
        #       end
        #     end
        #   end
        #
        # @!group Table
        #
        def create_table table_id, name: nil, description: nil
          ensure_service!
          new_tb = Google::Apis::BigqueryV2::Table.new(
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id, dataset_id: dataset_id,
              table_id: table_id))
          updater = Table::Updater.new(new_tb).tap do |tb|
            tb.name = name unless name.nil?
            tb.description = description unless description.nil?
          end

          yield updater if block_given?

          gapi = service.insert_table dataset_id, updater.to_gapi
          Table.from_gapi gapi, service
        end

        ##
        # Creates a new view table from the given query.
        #
        # @param [String] table_id The ID of the view table. The ID must contain
        #   only letters (a-z, A-Z), numbers (0-9), or underscores (_). The
        #   maximum length is 1,024 characters.
        # @param [String] query The query that BigQuery executes when the view
        #   is referenced.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is false.
        #
        # @return [Google::Cloud::Bigquery::View]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   view = dataset.create_view "my_view",
        #             "SELECT name, age FROM proj.dataset.users"
        #
        # @example A name and description can be provided:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   view = dataset.create_view "my_view",
        #             "SELECT name, age FROM proj.dataset.users",
        #             name: "My View", description: "This is my view"
        #
        # @!group Table
        #
        def create_view table_id, query, name: nil, description: nil,
                        standard_sql: nil, legacy_sql: nil
          new_view_opts = {
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id, dataset_id: dataset_id, table_id: table_id
            ),
            friendly_name: name,
            description: description,
            view: Google::Apis::BigqueryV2::ViewDefinition.new(
              query: query,
              use_legacy_sql: Convert.resolve_legacy_sql(standard_sql,
                                                         legacy_sql)
            )
          }.delete_if { |_, v| v.nil? }
          new_view = Google::Apis::BigqueryV2::Table.new new_view_opts

          gapi = service.insert_table dataset_id, new_view
          Table.from_gapi gapi, service
        end

        ##
        # Retrieves an existing table by ID.
        #
        # @param [String] table_id The ID of a table.
        #
        # @return [Google::Cloud::Bigquery::Table,
        #   Google::Cloud::Bigquery::View, nil] Returns `nil` if the table does
        #   not exist
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.table "my_table"
        #   puts table.name
        #
        # @!group Table
        #
        def table table_id
          ensure_service!
          gapi = service.get_table dataset_id, table_id
          Table.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of tables belonging to the dataset.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of tables to return.
        #
        # @return [Array<Google::Cloud::Bigquery::Table>,
        #   Array<Google::Cloud::Bigquery::View>] (See
        #   {Google::Cloud::Bigquery::Table::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   tables = dataset.tables
        #   tables.each do |table|
        #     puts table.name
        #   end
        #
        # @example Retrieve all tables: (See {Table::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   tables = dataset.tables
        #   tables.all do |table|
        #     puts table.name
        #   end
        #
        # @!group Table
        #
        def tables token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          gapi = service.list_tables dataset_id, options
          Table::List.from_gapi gapi, service, dataset_id, max
        end

        ##
        # Queries data using the [asynchronous
        # method](https://cloud.google.com/bigquery/querying-data).
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # When using standard SQL and passing arguments using `params`, Ruby
        # types are mapped to BigQuery types as follows:
        #
        # | BigQuery    | Ruby           | Notes  |
        # |-------------|----------------|---|
        # | `BOOL`      | `true`/`false` | |
        # | `INT64`     | `Integer`      | |
        # | `FLOAT64`   | `Float`        | |
        # | `STRING`    | `STRING`       | |
        # | `DATETIME`  | `DateTime`  | `DATETIME` does not support time zone. |
        # | `DATE`      | `Date`         | |
        # | `TIMESTAMP` | `Time`         | |
        # | `TIME`      | `Google::Cloud::BigQuery::Time` | |
        # | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        # | `ARRAY` | `Array` | Nested arrays, `nil` values are not supported. |
        # | `STRUCT`    | `Hash`        | Hash keys may be strings or symbols. |
        #
        # See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types)
        # for an overview of each BigQuery data type, including allowed values.
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query
        #   arguments when the `query` string contains either positional (`?`)
        #   or named (`@myparam`) query parameters. If value passed is an array
        #   `["foo"]`, the query must use positional query parameters. If value
        #   passed is a hash `{ myparam: "foo" }`, the query must use named
        #   query parameters. When set, `legacy_sql` will automatically be set
        #   to false and `standard_sql` to true.
        # @param [String] priority Specifies a priority for the query. Possible
        #   values include `INTERACTIVE` and `BATCH`. The default value is
        #   `INTERACTIVE`.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        # @param [Table] table The destination table where the query results
        #   should be stored. If not present, a new table will be created to
        #   store the results.
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies the action that occurs if the
        #   destination table already exists. The default value is `empty`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - A 'duplicate' error is returned in the job result if the
        #     table exists and contains data.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect for this query. If set to true, the query will use standard
        #   SQL rather than the [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect for this query. If set to false, the query will use
        #   BigQuery's [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is false.
        # @param [Boolean] large_results This option is specific to Legacy SQL.
        #   If `true`, allows the query to produce arbitrarily large result
        #   tables at a slight cost in performance. Requires `table` parameter
        #   to be set.
        # @param [Boolean] flatten This option is specific to Legacy SQL.
        #   Flattens all nested and repeated fields in the query results. The
        #   default value is `true`. `large_results` parameter must be `true` if
        #   this is set to `false`.
        # @param [Integer] maximum_billing_tier Limits the billing tier for this
        #   job. Queries that have resource usage beyond this tier will fail
        #   (without incurring a charge). Optional. If unspecified, this will be
        #   set to your project default. For more information, see [High-Compute
        #   queries](https://cloud.google.com/bigquery/pricing#high-compute).
        # @param [Integer] maximum_bytes_billed Limits the bytes billed for this
        #   job. Queries that will have bytes billed beyond this limit will fail
        #   (without incurring a charge). Optional. If unspecified, this will be
        #   set to your project default.
        # @param [String] job_id A user-defined ID for the query job. The ID
        #   must contain only letters (a-z, A-Z), numbers (0-9), underscores
        #   (_), or dashes (-). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (a-z, A-Z), numbers (0-9),
        #   underscores (_), or dashes (-). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs. Label
        #   keys and values can be no longer than 63 characters, can only
        #   contain lowercase letters, numeric characters, underscores and
        #   dashes. International characters are allowed. Label values are
        #   optional. Label keys must start with a letter and each label in the
        #   list must have a different key.
        #
        # @return [Google::Cloud::Bigquery::QueryJob]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table",
        #                           legacy_sql: true
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using positional query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table WHERE id = ?",
        #                           params: [1]
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table WHERE id = @id",
        #                           params: { id: 1 }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @!group Data
        #
        def query_job query, params: nil, priority: "INTERACTIVE", cache: true,
                      table: nil, create: nil, write: nil, standard_sql: nil,
                      legacy_sql: nil, large_results: nil, flatten: nil,
                      maximum_billing_tier: nil, maximum_bytes_billed: nil,
                      job_id: nil, prefix: nil, labels: nil
          options = { priority: priority, cache: cache, table: table,
                      create: create, write: write,
                      large_results: large_results, flatten: flatten,
                      legacy_sql: legacy_sql, standard_sql: standard_sql,
                      maximum_billing_tier: maximum_billing_tier,
                      maximum_bytes_billed: maximum_bytes_billed,
                      params: params, job_id: job_id, prefix: prefix,
                      labels: labels }
          options[:dataset] ||= self
          ensure_service!
          gapi = service.query_job query, options
          Job.from_gapi gapi, service
        end

        ##
        # Queries data using a synchronous method that blocks for a response. In
        # this method, a {QueryJob} is created and its results are saved
        # to a temporary table, then read from the table. Timeouts and transient
        # errors are generally handled as needed to complete the query.
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # When using standard SQL and passing arguments using `params`, Ruby
        # types are mapped to BigQuery types as follows:
        #
        # | BigQuery    | Ruby           | Notes  |
        # |-------------|----------------|---|
        # | `BOOL`      | `true`/`false` | |
        # | `INT64`     | `Integer`      | |
        # | `FLOAT64`   | `Float`        | |
        # | `STRING`    | `STRING`       | |
        # | `DATETIME`  | `DateTime`  | `DATETIME` does not support time zone. |
        # | `DATE`      | `Date`         | |
        # | `TIMESTAMP` | `Time`         | |
        # | `TIME`      | `Google::Cloud::BigQuery::Time` | |
        # | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        # | `ARRAY` | `Array` | Nested arrays, `nil` values are not supported. |
        # | `STRUCT`    | `Hash`        | Hash keys may be strings or symbols. |
        #
        # See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types)
        # for an overview of each BigQuery data type, including allowed values.
        #
        # @see https://cloud.google.com/bigquery/querying-data Querying Data
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query
        #   arguments when the `query` string contains either positional (`?`)
        #   or named (`@myparam`) query parameters. If value passed is an array
        #   `["foo"]`, the query must use positional query parameters. If value
        #   passed is a hash `{ myparam: "foo" }`, the query must use named
        #   query parameters. When set, `legacy_sql` will automatically be set
        #   to false and `standard_sql` to true.
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
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect for this query. If set to true, the query will use standard
        #   SQL rather than the [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. When set to true, the values of `large_results` and
        #   `flatten` are ignored; the query will be run as if `large_results`
        #   is true and `flatten` is false. Optional. The default value is
        #   true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect for this query. If set to false, the query will use
        #   BigQuery's [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   When set to false, the values of `large_results` and `flatten` are
        #   ignored; the query will be run as if `large_results` is true and
        #   `flatten` is false. Optional. The default value is false.
        #
        # @return [Google::Cloud::Bigquery::Data]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table"
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table",
        #                        legacy_sql: true
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using positional query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table WHERE id = ?",
        #                        params: [1]
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table WHERE id = @id",
        #                        params: { id: 1 }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @!group Data
        #
        def query query, params: nil, max: nil, cache: true, standard_sql: nil,
                  legacy_sql: nil
          ensure_service!
          options = { cache: cache, legacy_sql: legacy_sql,
                      standard_sql: standard_sql, params: params }

          job = query_job query, options
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
        # Loads data into the provided destination table. For the source of the
        # data, you can pass a google-cloud storage file path or a
        # google-cloud-storage `File` instance. Or, you can upload a file
        # directly. See [Loading Data with a POST
        # Request](https://cloud.google.com/bigquery/loading-data-post-request#multipart).
        #
        # @param [String] table_id The destination table to load the data into.
        # @param [File, Google::Cloud::Storage::File, String] file A file or the
        #   URI of a Google Cloud Storage file containing data to load into the
        #   table.
        # @param [String] format The exported file format. The default value is
        #   `csv`.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `datastore_backup` - Cloud Datastore backup
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies how to handle data already present in
        #   the table. The default value is `append`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - An error will be returned if the table already contains
        #     data.
        # @param [Array<String>] projection_fields If the `format` option is set
        #   to `datastore_backup`, indicates which entity properties to load
        #   from a Cloud Datastore backup. Property names are case sensitive and
        #   must be top-level properties. If not set, BigQuery loads all
        #   properties. If any named property isn't found in the Cloud Datastore
        #   backup, an invalid error is returned.
        # @param [Boolean] jagged_rows Accept rows that are missing trailing
        #   optional columns. The missing values are treated as nulls. If
        #   `false`, records with missing trailing columns are treated as bad
        #   records, and if there are too many bad records, an invalid error is
        #   returned in the job result. The default value is `false`. Only
        #   applicable to CSV, ignored for other formats.
        # @param [Boolean] quoted_newlines Indicates if BigQuery should allow
        #   quoted data sections that contain newline characters in a CSV file.
        #   The default value is `false`.
        # @param [Boolean] autodetect Indicates if BigQuery should
        #   automatically infer the options and schema for CSV and JSON sources.
        #   The default value is `false`.
        # @param [String] encoding The character encoding of the data. The
        #   supported values are `UTF-8` or `ISO-8859-1`. The default value is
        #   `UTF-8`.
        # @param [String] delimiter Specifices the separator for fields in a CSV
        #   file. BigQuery converts the string to `ISO-8859-1` encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. Default is <code>,</code>.
        # @param [Boolean] ignore_unknown Indicates if BigQuery should allow
        #   extra values that are not represented in the table schema. If true,
        #   the extra values are ignored. If false, records with extra columns
        #   are treated as bad records, and if there are too many bad records,
        #   an invalid error is returned in the job result. The default value is
        #   `false`.
        #
        #   The `format` property determines what BigQuery treats as an extra
        #   value:
        #
        #   * `CSV`: Trailing columns
        #   * `JSON`: Named values that don't match any column names
        # @param [Integer] max_bad_records The maximum number of bad records
        #   that BigQuery can ignore when running the job. If the number of bad
        #   records exceeds this value, an invalid error is returned in the job
        #   result. The default value is `0`, which requires that all records
        #   are valid.
        # @param [String] quote The value that is used to quote data sections in
        #   a CSV file. BigQuery converts the string to ISO-8859-1 encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. The default value is a double-quote
        #   <code>"</code>. If your data does not contain quoted sections, set
        #   the property value to an empty string. If your data contains quoted
        #   newline characters, you must also set the allowQuotedNewlines
        #   property to true.
        # @param [Integer] skip_leading The number of rows at the top of a CSV
        #   file that BigQuery will skip when loading the data. The default
        #   value is `0`. This property is useful if you have header rows in the
        #   file that should be skipped.
        # @param [Google::Cloud::Bigquery::Schema] schema The schema for the
        #   destination table. Optional. The schema can be omitted if the
        #   destination table already exists, or if you're loading data from a
        #   Google Cloud Datastore backup.
        #
        #   See {Project#schema} for the creation of the schema for use with
        #   this option. Also note that for most use cases, the block yielded by
        #   this method is a more convenient way to configure the schema.
        # @param [String] job_id A user-defined ID for the load job. The ID
        #   must contain only letters (a-z, A-Z), numbers (0-9), underscores
        #   (_), or dashes (-). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (a-z, A-Z), numbers (0-9),
        #   underscores (_), or dashes (-). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs. Label
        #   keys and values can be no longer than 63 characters, can only
        #   contain lowercase letters, numeric characters, underscores and
        #   dashes. International characters are allowed. Label values are
        #   optional. Label keys must start with a letter and each label in the
        #   list must have a different key.
        #
        # @yield [schema] A block for setting the schema for the destination
        #   table. The schema can be omitted if the destination table already
        #   exists, or if you're loading data from a Google Cloud Datastore
        #   backup.
        # @yieldparam [Google::Cloud::Bigquery::Schema] schema The schema
        #   instance provided using the `schema` option, or a new, empty schema
        #   instance
        #
        # @return [Google::Cloud::Bigquery::LoadJob]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   load_job = dataset.load "my_new_table", gs_url do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Pass a google-cloud-storage `File` instance:
        #   require "google/cloud/bigquery"
        #   require "google/cloud/storage"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #   file = bucket.file "file-name.csv"
        #   load_job = dataset.load "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Upload a file directly:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   file = File.open "my_data.csv"
        #   load_job = dataset.load "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Schema is not required with a Cloud Datastore backup:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   load_job = dataset.load "my_new_table",
        #                           "gs://my-bucket/xxxx.kind_name.backup_info",
        #                           format: "datastore_backup"
        #
        # @!group Data
        #
        def load table_id, file, format: nil, create: nil, write: nil,
                 projection_fields: nil, jagged_rows: nil, quoted_newlines: nil,
                 encoding: nil, delimiter: nil, ignore_unknown: nil,
                 max_bad_records: nil, quote: nil, skip_leading: nil,
                 dryrun: nil, schema: nil, job_id: nil, prefix: nil,
                 labels: nil, autodetect: nil
          ensure_service!

          if block_given?
            schema ||= Schema.from_gapi
            yield schema
          end
          schema_gapi = schema.to_gapi if schema

          options = { format: format, create: create, write: write,
                      projection_fields: projection_fields,
                      jagged_rows: jagged_rows,
                      quoted_newlines: quoted_newlines, encoding: encoding,
                      delimiter: delimiter, ignore_unknown: ignore_unknown,
                      max_bad_records: max_bad_records, quote: quote,
                      skip_leading: skip_leading, dryrun: dryrun,
                      schema: schema_gapi, job_id: job_id, prefix: prefix,
                      labels: labels, autodetect: autodetect }
          return load_storage(table_id, file, options) if storage_url? file
          return load_local(table_id, file, options) if local_file? file
          fail Google::Cloud::Error, "Don't know how to load #{file}"
        end

        ##
        # @private New Dataset from a Google API Client object.
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
          ensure_service!
          patch_args = Hash[attributes.map do |attr|
            [attr, @gapi.send(attr)]
          end]
          patch_gapi = Google::Apis::BigqueryV2::Dataset.new patch_args
          patch_gapi.etag = etag if etag
          @gapi = service.patch_dataset dataset_id, patch_gapi
        end

        ##
        # Load the complete representation of the dataset if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload_gapi! unless data_complete?
        end

        def reload_gapi!
          ensure_service!
          gapi = service.get_dataset dataset_id
          @gapi = gapi
        end

        def data_complete?
          @gapi.is_a? Google::Apis::BigqueryV2::Dataset
        end

        def load_storage table_id, url, options = {}
          # Convert to storage URL
          url = url.to_gs_url if url.respond_to? :to_gs_url

          gapi = service.load_table_gs_url dataset_id, table_id, url, options
          Job.from_gapi gapi, service
        end

        def load_local table_id, file, options = {}
          # Convert to storage URL
          file = file.to_gs_url if file.respond_to? :to_gs_url

          gapi = service.load_table_file dataset_id, table_id, file, options
          Job.from_gapi gapi, service
        end

        def storage_url? file
          file.respond_to?(:to_gs_url) ||
            (file.respond_to?(:to_str) &&
            file.to_str.downcase.start_with?("gs://"))
        end

        def local_file? file
          ::File.file? file
        rescue
          false
        end

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < Dataset
          ##
          # A list of attributes that were updated.
          attr_reader :updates

          ##
          # Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi
          end

          def access
            # TODO: make sure to call ensure_full_data! on Dataset#update
            @access ||= Access.from_gapi @gapi
            if block_given?
              yield @access
              check_for_mutated_access!
            end
            # Same as Dataset#access, but not frozen
            @access
          end

          ##
          # Make sure any access changes are saved
          def check_for_mutated_access!
            return if @access.nil?
            return unless @access.changed?
            @gapi.update! access: @access.to_gapi
            patch_gapi! :access
          end

          def to_gapi
            check_for_mutated_access!
            @gapi
          end

          protected

          ##
          # Queue up all the updates instead of making them.
          def patch_gapi! attribute
            @updates << attribute
            @updates.uniq!
          end
        end
      end
    end
  end
end
