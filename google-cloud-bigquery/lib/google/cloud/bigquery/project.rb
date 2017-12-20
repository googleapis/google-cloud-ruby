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


require "google/cloud/env"
require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/credentials"
require "google/cloud/bigquery/dataset"
require "google/cloud/bigquery/job"
require "google/cloud/bigquery/external"
require "google/cloud/bigquery/project/list"
require "google/cloud/bigquery/time"
require "google/cloud/bigquery/schema"

module Google
  module Cloud
    module BigQuery
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # BigQuery data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::BigQuery::Project is the main object for interacting with
      # Google BigQuery. {Google::Cloud::BigQuery::Dataset} objects are created,
      # accessed, and deleted by Google::Cloud::BigQuery::Project.
      #
      # See {Google::Cloud#bigquery}.
      #
      # @attr_reader [String, nil] name The descriptive name of the project.
      #   Can only be present if the project was retrieved with {#projects}.
      # @attr_reader [Integer, nil] numeric_id The numeric ID of the project.
      #   Can only be present if the project was retrieved with {#projects}.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::BigQuery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        attr_reader :name, :numeric_id

        ##
        # Creates a new Service instance.
        #
        # See {Google::Cloud.bigquery}
        def initialize service
          @service = service
        end

        ##
        # The BigQuery project connected to.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   bigquery.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias_method :project, :project_id

        ##
        # @private Default project_id.
        def self.default_project_id
          ENV["BIGQUERY_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        ##
        # Queries data using the [asynchronous
        # method](https://cloud.google.com/bigquery/querying-data).
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
        # @param [Hash<String|Symbol, External::DataSource>] external A Hash
        #   that represents the mapping of the external tables to the table
        #   names used in the SQL query. The hash keys are the table names, and
        #   the hash values are the external table objects. See {Project#query}.
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
        # @param [Dataset, String] dataset The default dataset to use for
        #   unqualified table names in the query. Optional.
        # @param [String] project Specifies the default projectId to assume for
        #   any unqualified table names in the query. Only used if `dataset`
        #   option is set.
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
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs. Label
        #   keys and values can be no longer than 63 characters, can only
        #   contain lowercase letters, numeric characters, underscores and
        #   dashes. International characters are allowed. Label values are
        #   optional. Label keys must start with a letter and each label in the
        #   list must have a different key.
        # @param [Array<String>, String] udfs User-defined function resources
        #   used in the query. May be either a code resource to load from a
        #   Google Cloud Storage URI (`gs://bucket/path`), or an inline resource
        #   that contains code for a user-defined function (UDF). Providing an
        #   inline code resource is equivalent to providing a URI for a file
        #   containing the same code. See [User-Defined
        #   Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
        #
        # @return [Google::Cloud::BigQuery::QueryJob]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT name FROM " \
        #                            "`my_project.my_dataset.my_table`"
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
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT name FROM " \
        #                            "[my_project:my_dataset.my_table]",
        #                            legacy_sql: true
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
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT name FROM " \
        #                            "`my_dataset.my_table`" \
        #                            " WHERE id = ?",
        #                            params: [1]
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
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT name FROM " \
        #                            "`my_dataset.my_table`" \
        #                            " WHERE id = @id",
        #                            params: { id: 1 }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using external data source:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   job = bigquery.query_job "SELECT * FROM my_ext_table",
        #                            external: { my_ext_table: csv_table }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        def query_job query, params: nil, external: nil,
                      priority: "INTERACTIVE", cache: true, table: nil,
                      create: nil, write: nil, dataset: nil, project: nil,
                      standard_sql: nil, legacy_sql: nil, large_results: nil,
                      flatten: nil, maximum_billing_tier: nil,
                      maximum_bytes_billed: nil, job_id: nil, prefix: nil,
                      labels: nil, udfs: nil
          ensure_service!
          options = { priority: priority, cache: cache, table: table,
                      create: create, write: write,
                      large_results: large_results, flatten: flatten,
                      dataset: dataset, project: project,
                      legacy_sql: legacy_sql, standard_sql: standard_sql,
                      maximum_billing_tier: maximum_billing_tier,
                      maximum_bytes_billed: maximum_bytes_billed,
                      params: params, external: external, labels: labels,
                      job_id: job_id, prefix: prefix, udfs: udfs }
          gapi = service.query_job query, options
          Job.from_gapi gapi, service
        end

        ##
        # Queries data using a synchronous method that blocks for a response. In
        # this method, a {QueryJob} is created and its results are saved
        # to a temporary table, then read from the table. Timeouts and transient
        # errors are generally handled as needed to complete the query.
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
        # @param [Hash<String|Symbol, External::DataSource>] external A Hash
        #   that represents the mapping of the external tables to the table
        #   names used in the SQL query. The hash keys are the table names, and
        #   the hash values are the external table objects. See {Project#query}.
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
        # @param [String] dataset Specifies the default datasetId and projectId
        #   to assume for any unqualified table names in the query. If not set,
        #   all table names in the query string must be qualified in the format
        #   'datasetId.tableId'.
        # @param [String] project Specifies the default projectId to assume for
        #   any unqualified table names in the query. Only used if `dataset`
        #   option is set.
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
        # @return [Google::Cloud::BigQuery::Data]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   sql = "SELECT name FROM `my_project.my_dataset.my_table`"
        #   data = bigquery.query sql
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   sql = "SELECT name FROM [my_project:my_dataset.my_table]"
        #   data = bigquery.query sql, legacy_sql: true
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Retrieve all rows: (See {Data#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table`"
        #
        #   data.all do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using positional query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   data = bigquery.query "SELECT name " \
        #                         "FROM `my_dataset.my_table`" \
        #                         "WHERE id = ?",
        #                         params: [1]
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   data = bigquery.query "SELECT name " \
        #                         "FROM `my_dataset.my_table`" \
        #                         "WHERE id = @id",
        #                         params: { id: 1 }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Query using external data source:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: csv_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        def query query, params: nil, external: nil, max: nil, cache: true,
                  dataset: nil, project: nil, standard_sql: nil, legacy_sql: nil
          ensure_service!
          options = { cache: cache, dataset: dataset, project: project,
                      legacy_sql: legacy_sql, standard_sql: standard_sql,
                      params: params, external: external }

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
        # Creates a new External::DataSource (or subclass) object that
        # represents the external data source that can be queried from directly,
        # even though the data is not stored in BigQuery. Instead of loading or
        # streaming the data, this object references the external data source.
        #
        # @see https://cloud.google.com/bigquery/external-data-sources Querying
        #   External Data Sources
        #
        # @param [String, Array<String>] url The fully-qualified URL(s) that
        #   point to your data in Google Cloud. An attempt will be made to
        #   derive the format from the URLs provided.
        # @param [String|Symbol] format The data format. This value will be used
        #   even if the provided URLs are recognized as a different format.
        #   Optional.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `sheets` - Google Sheets
        #   * `datastore_backup` - Cloud Datastore backup
        #   * `bigtable` - Bigtable
        #
        # @return [External::DataSource] External data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: csv_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        def external url, format: nil
          ext = External.from_urls url, format
          yield ext if block_given?
          ext
        end

        ##
        # Retrieves an existing dataset by ID.
        #
        # @param [String] dataset_id The ID of a dataset.
        # @param [Boolean] skip_lookup Optionally create just a local reference
        #   object without verifying that the resource exists on the BigQuery
        #   service. Calls made on this object will raise errors if the resource
        #   does not exist. Default is `false`. Optional.
        #
        # @return [Google::Cloud::BigQuery::Dataset, nil] Returns `nil` if the
        #   dataset does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   puts dataset.name
        #
        # @example Avoid retrieving the dataset resource with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #
        def dataset dataset_id, skip_lookup: nil
          ensure_service!
          if skip_lookup
            return Dataset.new_reference project, dataset_id, service
          end
          gapi = service.get_dataset dataset_id
          Dataset.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a new dataset.
        #
        # @param [String] dataset_id A unique ID for this dataset, without the
        #   project name. The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), or underscores (_). The maximum length is 1,024 characters.
        # @param [String] name A descriptive name for the dataset.
        # @param [String] description A user-friendly description of the
        #   dataset.
        # @param [Integer] expiration The default lifetime of all tables in the
        #   dataset, in milliseconds. The minimum value is 3600000 milliseconds
        #   (one hour).
        # @param [String] location The geographic location where the dataset
        #   should reside. Possible values include `EU` and `US`. The default
        #   value is `US`.
        # @yield [access] a block for setting rules
        # @yieldparam [Google::Cloud::BigQuery::Dataset] access the object
        #   accepting rules
        #
        # @return [Google::Cloud::BigQuery::Dataset]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   dataset = bigquery.create_dataset "my_dataset"
        #
        # @example A name and description can be provided:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   dataset = bigquery.create_dataset "my_dataset",
        #                                     name: "My Dataset",
        #                                     description: "This is my Dataset"
        #
        # @example Or, configure access with a block: (See {Dataset::Access})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   dataset = bigquery.create_dataset "my_dataset" do |dataset|
        #     dataset.access.add_writer_user "writers@example.com"
        #   end
        #
        def create_dataset dataset_id, name: nil, description: nil,
                           expiration: nil, location: nil
          ensure_service!

          new_ds = Google::Apis::BigqueryV2::Dataset.new(
            dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
              project_id: project, dataset_id: dataset_id))

          # Can set location only on creation, no Dataset#location method
          new_ds.update! location: location unless location.nil?

          updater = Dataset::Updater.new(new_ds).tap do |b|
            b.name = name unless name.nil?
            b.description = description unless description.nil?
            b.default_expiration = expiration unless expiration.nil?
          end

          if block_given?
            yield updater
            updater.check_for_mutated_access!
          end

          gapi = service.insert_dataset new_ds
          Dataset.from_gapi gapi, service
        end

        ##
        # Retrieves the list of datasets belonging to the project.
        #
        # @param [Boolean] all Whether to list all datasets, including hidden
        #   ones. The default is `false`.
        # @param [String] filter An expression for filtering the results of the
        #   request by label. The syntax is `labels.<name>[:<value>]`.
        #   Multiple filters can be `AND`ed together by connecting with a space.
        #   Example: `labels.department:receiving labels.active`. See [Filtering
        #   datasets using labels](https://cloud.google.com/bigquery/docs/labeling-datasets#filtering_datasets_using_labels).
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of datasets to return.
        #
        # @return [Array<Google::Cloud::BigQuery::Dataset>] (See
        #   {Google::Cloud::BigQuery::Dataset::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   datasets = bigquery.datasets
        #   datasets.each do |dataset|
        #     puts dataset.name
        #   end
        #
        # @example Retrieve hidden datasets with the `all` optional arg:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   all_datasets = bigquery.datasets all: true
        #
        # @example Retrieve all datasets: (See {Dataset::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   datasets = bigquery.datasets
        #   datasets.all do |dataset|
        #     puts dataset.name
        #   end
        #
        def datasets all: nil, filter: nil, token: nil, max: nil
          ensure_service!
          options = { all: all, filter: filter, token: token, max: max }
          gapi = service.list_datasets options
          Dataset::List.from_gapi gapi, service, all, filter, max
        end

        ##
        # Retrieves an existing job by ID.
        #
        # @param [String] job_id The ID of a job.
        #
        # @return [Google::Cloud::BigQuery::Job, nil] Returns `nil` if the job
        #   does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.job "my_job"
        #
        def job job_id
          ensure_service!
          gapi = service.get_job job_id
          Job.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of jobs belonging to the project.
        #
        # @param [Boolean] all Whether to display jobs owned by all users in the
        #   project. The default is `false`.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of jobs to return.
        # @param [String] filter A filter for job state.
        #
        #   Acceptable values are:
        #
        #   * `done` - Finished jobs
        #   * `pending` - Pending jobs
        #   * `running` - Running jobs
        #
        # @return [Array<Google::Cloud::BigQuery::Job>] (See
        #   {Google::Cloud::BigQuery::Job::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   jobs = bigquery.jobs
        #   jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve only running jobs using the `filter` optional arg:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   running_jobs = bigquery.jobs filter: "running"
        #   running_jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve all jobs: (See {Job::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   jobs = bigquery.jobs
        #   jobs.all do |job|
        #     # process job
        #   end
        #
        def jobs all: nil, token: nil, max: nil, filter: nil
          ensure_service!
          options = { all: all, token: token, max: max, filter: filter }
          gapi = service.list_jobs options
          Job::List.from_gapi gapi, service, all, max, filter
        end

        ##
        # Retrieves the list of all projects for which the currently authorized
        # account has been granted any project role. The returned project
        # instances share the same credentials as the project used to retrieve
        # them, but lazily create a new API connection for interactions with the
        # BigQuery service.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of projects to return.
        #
        # @return [Array<Google::Cloud::BigQuery::Project>] (See
        #   {Google::Cloud::BigQuery::Project::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   projects = bigquery.projects
        #   projects.each do |project|
        #     puts project.name
        #     project.datasets.all.each do |dataset|
        #       puts dataset.name
        #     end
        #   end
        #
        # @example Retrieve all projects: (See {Project::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   projects = bigquery.projects
        #
        #   projects.all do |project|
        #     puts project.name
        #     project.datasets.all.each do |dataset|
        #       puts dataset.name
        #     end
        #   end
        #
        def projects token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          gapi = service.list_projects options
          Project::List.from_gapi gapi, service, max
        end

        ##
        # Creates a BigQuery::Time object to represent a time, independent of a
        # specific date.
        #
        # @param [Integer] hour Hour, valid values from 0 to 23.
        # @param [Integer] minute Minute, valid values from 0 to 59.
        # @param [Integer, Float] second Second, valid values from 0 to 59. Can
        #   contain microsecond precision.
        #
        # @return [BigQuery::Time]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   fourpm = bigquery.time 16, 0, 0
        #   data = bigquery.query "SELECT name " \
        #                         "FROM `my_dataset.my_table`" \
        #                         "WHERE time_of_date = @time",
        #                         params: { time: fourpm }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        # @example Create Time with fractional seconds:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   precise_time = bigquery.time 16, 35, 15.376541
        #   data = bigquery.query "SELECT name " \
        #                         "FROM `my_dataset.my_table`" \
        #                         "WHERE time_of_date >= @time",
        #                         params: { time: precise_time }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        def time hour, minute, second
          BigQuery::Time.new "#{hour}:#{minute}:#{second}"
        end

        ##
        # Creates a new schema instance. An optional block may be given to
        # configure the schema, otherwise the schema is returned empty and may
        # be configured directly.
        #
        # The returned schema can be passed to {Dataset#load} using the
        # `schema` option. However, for most use cases, the block yielded by
        # {Dataset#load} is a more convenient way to configure the schema
        # for the destination table.
        #
        # @yield [schema] a block for setting the schema
        # @yieldparam [Schema] schema the object accepting the schema
        #
        # @return [Google::Cloud::BigQuery::Schema]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   schema = bigquery.schema do |s|
        #     s.string "first_name", mode: :required
        #     s.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   load_job = dataset.load_job "my_new_table", gs_url, schema: schema
        #
        def schema
          s = Schema.from_gapi
          yield s if block_given?
          s
        end

        ##
        # @private New Project from a Google API Client object, using the
        # same Credentials as this project.
        def self.from_gapi gapi, service
          project_service = Service.new gapi.project_reference.project_id,
                                        service.credentials,
                                        retries: service.retries,
                                        timeout: service.timeout
          new(project_service).tap do |p|
            p.instance_variable_set :@name, gapi.friendly_name

            # TODO: remove `Integer` and set normally after migrating to Gax or
            # to google-api-client 0.10 (See google/google-api-ruby-client#439)
            if gapi.numeric_id
              p.instance_variable_set :@numeric_id, Integer(gapi.numeric_id)
            end
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
