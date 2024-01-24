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
    module Bigquery
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # BigQuery data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::Bigquery::Project is the main object for interacting with
      # Google BigQuery. {Google::Cloud::Bigquery::Dataset} objects are created,
      # accessed, and deleted by Google::Cloud::Bigquery::Project.
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
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        attr_reader :name
        attr_reader :numeric_id

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
        #   bigquery = Google::Cloud::Bigquery.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   bigquery.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # The email address of the service account for the project used to
        # connect to BigQuery. (See also {#project_id}.)
        #
        # @return [String] The service account email address.
        #
        def service_account_email
          @service_account_email ||= service.project_service_account.email
        end

        ##
        # Copies the data from the source table to the destination table using
        # an asynchronous method. In this method, a {CopyJob} is immediately
        # returned. The caller may poll the service by repeatedly calling
        # {Job#reload!} and {Job#done?} to detect when the job is done, or
        # simply block until the job is done by calling #{Job#wait_until_done!}.
        # See {#copy} for the synchronous version. Use this method instead of
        # {Table#copy_job} to copy from source tables in other projects.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {CopyJob::Updater#location=} in a block passed to this method.
        #
        # @param [String, Table] source_table The source table for the
        #   copied data. This can be a table object; or a string ID as specified
        #   by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [String, Table] destination_table The destination table for the
        #   copied data. This can be a table object; or a string ID as specified
        #   by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies how to handle data already present in
        #   the destination table. The default value is `empty`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - An error will be returned if the destination table
        #     already contains data.
        # @param [String] job_id A user-defined ID for the copy job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::CopyJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Google::Cloud::Bigquery::CopyJob]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   source_table_id = "bigquery-public-data.samples.shakespeare"
        #   destination_table = dataset.table "my_destination_table"
        #
        #   copy_job = bigquery.copy_job source_table_id, destination_table
        #
        #   copy_job.wait_until_done!
        #   copy_job.done? #=> true
        #
        # @!group Data
        #
        def copy_job source_table, destination_table, create: nil, write: nil, job_id: nil, prefix: nil, labels: nil
          ensure_service!
          options = { create: create, write: write, labels: labels, job_id: job_id, prefix: prefix }

          updater = CopyJob::Updater.from_options(
            service,
            Service.get_table_ref(source_table, default_ref: project_ref),
            Service.get_table_ref(destination_table, default_ref: project_ref),
            options
          )

          yield updater if block_given?

          job_gapi = updater.to_gapi
          gapi = service.copy_table job_gapi
          Job.from_gapi gapi, service
        end

        ##
        # Copies the data from the source table to the destination table using a
        # synchronous method that blocks for a response. Timeouts and transient
        # errors are generally handled as needed to complete the job. See
        # {#copy_job} for the asynchronous version. Use this method instead of
        # {Table#copy} to copy from source tables in other projects.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {CopyJob::Updater#location=} in a block passed to this method.
        #
        # @param [String, Table] source_table The source table for the
        #   copied data. This can be a table object; or a string ID as specified
        #   by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [String, Table] destination_table The destination table for the
        #   copied data. This can be a table object; or a string ID as specified
        #   by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies how to handle data already present in
        #   the destination table. The default value is `empty`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - An error will be returned if the destination table
        #     already contains data.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::CopyJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Boolean] Returns `true` if the copy operation succeeded.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   destination_table = dataset.table "my_destination_table"
        #
        #   bigquery.copy "bigquery-public-data.samples.shakespeare",
        #                 destination_table
        #
        # @!group Data
        #
        def copy source_table, destination_table, create: nil, write: nil, &block
          job = copy_job source_table, destination_table, create: create, write: write, &block
          job.wait_until_done!
          ensure_job_succeeded! job
          true
        end

        ##
        # Queries data by creating a [query
        # job](https://cloud.google.com/bigquery/docs/query-overview#query_jobs).
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {QueryJob::Updater#location=} in a block passed to this method.
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query arguments when the `query` string contains
        #   either positional (`?`) or named (`@myparam`) query parameters. If value passed is an array `["foo"]`, the
        #   query must use positional query parameters. If value passed is a hash `{ myparam: "foo" }`, the query must
        #   use named query parameters. When set, `legacy_sql` will automatically be set to false and `standard_sql` to
        #   true.
        #
        #   BigQuery types are converted from Ruby types as follows:
        #
        #   | BigQuery     | Ruby                                 | Notes                                              |
        #   |--------------|--------------------------------------|----------------------------------------------------|
        #   | `BOOL`       | `true`/`false`                       |                                                    |
        #   | `INT64`      | `Integer`                            |                                                    |
        #   | `FLOAT64`    | `Float`                              |                                                    |
        #   | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
        #   | `BIGNUMERIC` | `BigDecimal`                         | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `STRING`     | `String`                             |                                                    |
        #   | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
        #   | `DATE`       | `Date`                               |                                                    |
        #   | `GEOGRAPHY`  | `String` (WKT or GeoJSON)            | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `JSON`       | `String` (Stringified JSON)          | String, as JSON does not have a schema to verify.  |
        #   | `TIMESTAMP`  | `Time`                               |                                                    |
        #   | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
        #   | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
        #   | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
        #   | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
        #
        #   See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types) for an overview
        #   of each BigQuery data type, including allowed values. For the `GEOGRAPHY` type, see [Working with BigQuery
        #   GIS data](https://cloud.google.com/bigquery/docs/gis-data).
        # @param [Array, Hash] types Standard SQL only. Types of the SQL parameters in `params`. It is not always
        #   possible to infer the right SQL type from a value in `params`. In these cases, `types` must be used to
        #   specify the SQL type for these values.
        #
        #   Arguments must match the value type passed to `params`. This must be an `Array` when the query uses
        #   positional query parameters. This must be an `Hash` when the query uses named query parameters. The values
        #   should be BigQuery type codes from the following list:
        #
        #   * `:BOOL`
        #   * `:INT64`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:BIGNUMERIC`
        #   * `:STRING`
        #   * `:DATETIME`
        #   * `:DATE`
        #   * `:GEOGRAPHY`
        #   * `:JSON`
        #   * `:TIMESTAMP`
        #   * `:TIME`
        #   * `:BYTES`
        #   * `Array` - Lists are specified by providing the type code in an array. For example, an array of integers
        #     are specified as `[:INT64]`.
        #   * `Hash` - Types for STRUCT values (`Hash` objects) are specified using a `Hash` object, where the keys
        #     match the `params` hash, and the values are the types value that matches the data.
        #
        #   Types are optional.
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
        # @param [Boolean] dryrun If set to true, BigQuery doesn't run the job.
        #   Instead, if the query is valid, BigQuery returns statistics about
        #   the job such as how many bytes would be processed. If the query is
        #   invalid, an error returns. The default value is false.
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
        #   (without incurring a charge). WARNING: The billed byte amount can be
        #   multiplied by an amount up to this number! Most users should not need
        #   to alter this setting, and we recommend that you avoid introducing new
        #   uses of it. Deprecated.
        # @param [Integer] maximum_bytes_billed Limits the bytes billed for this
        #   job. Queries that will have bytes billed beyond this limit will fail
        #   (without incurring a charge). Optional. If unspecified, this will be
        #   set to your project default.
        # @param [String] job_id A user-defined ID for the query job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @param [Array<String>, String] udfs User-defined function resources
        #   used in a legacy SQL query. May be either a code resource to load from
        #   a Google Cloud Storage URI (`gs://bucket/path`), or an inline resource
        #   that contains code for a user-defined function (UDF). Providing an
        #   inline code resource is equivalent to providing a URI for a file
        #   containing the same code.
        #
        #   This parameter is used for defining User Defined Function (UDF)
        #   resources only when using legacy SQL. Users of standard SQL should
        #   leverage either DDL (e.g. `CREATE [TEMPORARY] FUNCTION ...`) or the
        #   Routines API to define UDF resources.
        #
        #   For additional information on migrating, see: [Migrating to
        #   standard SQL - Differences in user-defined JavaScript
        #   functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql#differences_in_user-defined_javascript_functions)
        # @param [Boolean] create_session If true, creates a new session, where the
        #   session ID will be a server generated random id. If false, runs query
        #   with an existing session ID when one is provided in the `session_id`
        #   param, otherwise runs query in non-session mode. See {Job#session_id}.
        #   The default value is false.
        # @param [String] session_id The ID of an existing session. See also the
        #   `create_session` param and {Job#session_id}.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::QueryJob::Updater] job a job
        #   configuration object for setting query options.
        #
        # @return [Google::Cloud::Bigquery::QueryJob]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "SELECT name FROM `my_project.my_dataset.my_table`"
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
        #
        #   job = bigquery.query_job "SELECT name FROM [my_project:my_dataset.my_table]",
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
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "SELECT name FROM `my_dataset.my_table` WHERE id = ?",
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
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "SELECT name FROM `my_dataset.my_table` WHERE id = @id",
        #                            params: { id: 1 }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using named query parameters with types:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "SELECT name FROM `my_dataset.my_table` WHERE id IN UNNEST(@ids)",
        #                            params: { ids: [] },
        #                            types: { ids: [:INT64] }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Execute a DDL statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "CREATE TABLE`my_dataset.my_table` (x INT64)"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     table_ref = job.ddl_target_table # Or ddl_target_routine for CREATE/DROP FUNCTION/PROCEDURE
        #   end
        #
        # @example Execute a DML statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "UPDATE `my_dataset.my_table` SET x = x + 1 WHERE x IS NOT NULL"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     puts job.num_dml_affected_rows
        #   end
        #
        # @example Query using external data source, set destination:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   job = bigquery.query_job "SELECT * FROM my_ext_table" do |query|
        #     query.external = { my_ext_table: csv_table }
        #     dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #     query.table = dataset.table "my_table", skip_lookup: true
        #   end
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        def query_job query,
                      params: nil,
                      types: nil,
                      external: nil,
                      priority: "INTERACTIVE",
                      cache: true,
                      table: nil,
                      create: nil,
                      write: nil,
                      dryrun: nil,
                      dataset: nil,
                      project: nil,
                      standard_sql: nil,
                      legacy_sql: nil,
                      large_results: nil,
                      flatten: nil,
                      maximum_billing_tier: nil,
                      maximum_bytes_billed: nil,
                      job_id: nil,
                      prefix: nil,
                      labels: nil,
                      udfs: nil,
                      create_session: nil,
                      session_id: nil
          ensure_service!
          options = {
            params: params,
            types: types,
            external: external,
            priority: priority,
            cache: cache,
            table: table,
            create: create,
            write: write,
            dryrun: dryrun,
            dataset: dataset,
            project: (project || self.project),
            standard_sql: standard_sql,
            legacy_sql: legacy_sql,
            large_results: large_results,
            flatten: flatten,
            maximum_billing_tier: maximum_billing_tier,
            maximum_bytes_billed: maximum_bytes_billed,
            job_id: job_id,
            prefix: prefix,
            labels: labels,
            udfs: udfs,
            create_session: create_session,
            session_id: session_id
          }

          updater = QueryJob::Updater.from_options service, query, options

          yield updater if block_given?

          gapi = service.query_job updater.to_gapi
          Job.from_gapi gapi, service
        end

        ##
        # Queries data and waits for the results. In this method, a {QueryJob}
        # is created and its results are saved to a temporary table, then read
        # from the table. Timeouts and transient errors are generally handled
        # as needed to complete the query. When used for executing DDL/DML
        # statements, this method does not return row data.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {QueryJob::Updater#location=} in a block passed to this method.
        #
        # @see https://cloud.google.com/bigquery/querying-data Querying Data
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query arguments when the `query` string contains
        #   either positional (`?`) or named (`@myparam`) query parameters. If value passed is an array `["foo"]`, the
        #   query must use positional query parameters. If value passed is a hash `{ myparam: "foo" }`, the query must
        #   use named query parameters. When set, `legacy_sql` will automatically be set to false and `standard_sql` to
        #   true.
        #
        #   BigQuery types are converted from Ruby types as follows:
        #
        #   | BigQuery     | Ruby                                 | Notes                                              |
        #   |--------------|--------------------------------------|----------------------------------------------------|
        #   | `BOOL`       | `true`/`false`                       |                                                    |
        #   | `INT64`      | `Integer`                            |                                                    |
        #   | `FLOAT64`    | `Float`                              |                                                    |
        #   | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
        #   | `BIGNUMERIC` | `BigDecimal`                         | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `STRING`     | `String`                             |                                                    |
        #   | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
        #   | `DATE`       | `Date`                               |                                                    |
        #   | `GEOGRAPHY`  | `String` (WKT or GeoJSON)            | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `JSON`       | `String` (Stringified JSON)          | String, as JSON does not have a schema to verify.  |
        #   | `TIMESTAMP`  | `Time`                               |                                                    |
        #   | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
        #   | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
        #   | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
        #   | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
        #
        #   See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types) for an overview
        #   of each BigQuery data type, including allowed values. For the `GEOGRAPHY` type, see [Working with BigQuery
        #   GIS data](https://cloud.google.com/bigquery/docs/gis-data).
        # @param [Array, Hash] types Standard SQL only. Types of the SQL parameters in `params`. It is not always
        #   possible to infer the right SQL type from a value in `params`. In these cases, `types` must be used to
        #   specify the SQL type for these values.
        #
        #   Arguments must match the value type passed to `params`. This must be an `Array` when the query uses
        #   positional query parameters. This must be an `Hash` when the query uses named query parameters. The values
        #   should be BigQuery type codes from the following list:
        #
        #   * `:BOOL`
        #   * `:INT64`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:BIGNUMERIC`
        #   * `:STRING`
        #   * `:DATETIME`
        #   * `:DATE`
        #   * `:GEOGRAPHY`
        #   * `:JSON`
        #   * `:TIMESTAMP`
        #   * `:TIME`
        #   * `:BYTES`
        #   * `Array` - Lists are specified by providing the type code in an array. For example, an array of integers
        #     are specified as `[:INT64]`.
        #   * `Hash` - Types for STRUCT values (`Hash` objects) are specified using a `Hash` object, where the keys
        #     match the `params` hash, and the values are the types value that matches the data.
        #
        #   Types are optional.
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
        # @param [String] session_id The ID of an existing session. See the
        #   `create_session` param in {#query_job} and {Job#session_id}.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::QueryJob::Updater] job a job
        #   configuration object for setting additional options for the query.
        #
        # @return [Google::Cloud::Bigquery::Data]
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT name FROM `my_project.my_dataset.my_table`"
        #   data = bigquery.query sql
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT name FROM [my_project:my_dataset.my_table]"
        #   data = bigquery.query sql, legacy_sql: true
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Retrieve all rows: (See {Data#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
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
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table` WHERE id = ?",
        #                         params: [1]
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table` WHERE id = @id",
        #                         params: { id: 1 }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using named query parameters with types:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table` WHERE id IN UNNEST(@ids)",
        #                         params: { ids: [] },
        #                         types: { ids: [:INT64] }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Execute a DDL statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "CREATE TABLE `my_dataset.my_table` (x INT64)"
        #
        #   table_ref = data.ddl_target_table # Or ddl_target_routine for CREATE/DROP FUNCTION/PROCEDURE
        #
        # @example Execute a DML statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "UPDATE `my_dataset.my_table` SET x = x + 1 WHERE x IS NOT NULL"
        #
        #   puts data.num_dml_affected_rows
        #
        # @example Query using external data source, set destination:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table" do |query|
        #     query.external = { my_ext_table: csv_table }
        #     dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #     query.table = dataset.table "my_table", skip_lookup: true
        #   end
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        def query query,
                  params: nil,
                  types: nil,
                  external: nil,
                  max: nil,
                  cache: true,
                  dataset: nil,
                  project: nil,
                  standard_sql: nil,
                  legacy_sql: nil,
                  session_id: nil,
                  &block
          job = query_job query,
                          params: params,
                          types: types,
                          external: external,
                          cache: cache,
                          dataset: dataset,
                          project: project,
                          standard_sql: standard_sql,
                          legacy_sql: legacy_sql,
                          session_id: session_id,
                          &block
          job.wait_until_done!

          if job.failed?
            begin
              # raise to activate ruby exception cause handling
              raise job.gapi_error
            rescue StandardError => e
              # wrap Google::Apis::Error with Google::Cloud::Error
              raise Google::Cloud::Error.from_error(e)
            end
          end

          job.data max: max
        end

        ##
        # Loads data into the provided destination table using an asynchronous
        # method. In this method, a {LoadJob} is immediately returned. The
        # caller may poll the service by repeatedly calling {Job#reload!} and
        # {Job#done?} to detect when the job is done, or simply block until the
        # job is done by calling #{Job#wait_until_done!}. See also {#load}.
        #
        # For the source of the data, you can pass a google-cloud storage file
        # path or a google-cloud-storage `File` instance. Or, you can upload a
        # file directly. See [Loading Data with a POST
        # Request](https://cloud.google.com/bigquery/loading-data-post-request#multipart).
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {LoadJob::Updater#location=} in a block passed to this method.
        #
        # @param [String] table_id The destination table to load the data into.
        # @param [File, Google::Cloud::Storage::File, String, URI,
        #   Array<Google::Cloud::Storage::File, String, URI>] files
        #   A file or the URI of a Google Cloud Storage file, or an Array of
        #   those, containing data to load into the table.
        # @param [String] format The exported file format. The default value is
        #   `csv`.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](https://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `orc` - [ORC](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-orc)
        #   * `parquet` - [Parquet](https://parquet.apache.org/)
        #   * `datastore_backup` - Cloud Datastore backup
        # @param [String] dataset_id The destination table to load the data into.
        #   For load job with create_session/session_id it defaults to "_SESSION"
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
        # @param [String] null_marker Specifies a string that represents a null
        #   value in a CSV file. For example, if you specify `\N`, BigQuery
        #   interprets `\N` as a null value when loading a CSV file. The default
        #   value is the empty string. If you set this property to a custom
        #   value, BigQuery throws an error if an empty string is present for
        #   all data types except for STRING and BYTE. For STRING and BYTE
        #   columns, BigQuery interprets the empty string as an empty value.
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
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @param [Boolean] create_session If set to true a new session will be created
        #   and the load job will happen in the table created within that session.
        #   Note: This will work only for tables in _SESSION dataset
        #         else the property will be ignored by the backend.
        # @param [string] session_id Session ID in which the load job must run.
        #
        # @yield [updater] A block for setting the schema and other
        #   options for the destination table. The schema can be omitted if the
        #   destination table already exists, or if you're loading data from a
        #   Google Cloud Datastore backup.
        # @yieldparam [Google::Cloud::Bigquery::LoadJob::Updater] updater An
        #   updater to modify the load job and its schema.
        # @param [Boolean] dryrun  If set, don't actually run this job. Behavior
        #   is undefined however for non-query jobs and may result in an error.
        #   Deprecated.
        #
        # @return [Google::Cloud::Bigquery::LoadJob] A new load job object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   load_job = bigquery.load_job "temp_table", gs_url, autodetect: true, create_session: true
        #   load_job.wait_until_done!
        #   session_id = load_job.statistics["sessionInfo"]["sessionId"]
        #
        def load_job table_id, files, dataset_id: nil, format: nil, create: nil, write: nil,
                     projection_fields: nil, jagged_rows: nil, quoted_newlines: nil, encoding: nil,
                     delimiter: nil, ignore_unknown: nil, max_bad_records: nil, quote: nil,
                     skip_leading: nil, schema: nil, job_id: nil, prefix: nil, labels: nil, autodetect: nil,
                     null_marker: nil, dryrun: nil, create_session: nil, session_id: nil, &block
          ensure_service!
          dataset_id ||= "_SESSION" unless create_session.nil? && session_id.nil?
          session_dataset = dataset dataset_id, skip_lookup: true
          table = session_dataset.table table_id, skip_lookup: true
          table.load_job  files,
                          format: format, create: create, write: write, projection_fields: projection_fields,
                          jagged_rows: jagged_rows, quoted_newlines: quoted_newlines, encoding: encoding,
                          delimiter: delimiter, ignore_unknown: ignore_unknown,
                          max_bad_records: max_bad_records, quote: quote, skip_leading: skip_leading,
                          dryrun: dryrun, schema: schema, job_id: job_id, prefix: prefix, labels: labels,
                          autodetect: autodetect, null_marker: null_marker, create_session: create_session,
                          session_id: session_id, &block
        end

        ##
        # Loads data into the provided destination table using a synchronous
        # method that blocks for a response. Timeouts and transient errors are
        # generally handled as needed to complete the job. See also
        # {#load_job}.
        #
        # For the source of the data, you can pass a google-cloud storage file
        # path or a google-cloud-storage `File` instance. Or, you can upload a
        # file directly. See [Loading Data with a POST
        # Request](https://cloud.google.com/bigquery/loading-data-post-request#multipart).
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {LoadJob::Updater#location=} in a block passed to this method.
        #
        # @param [String] table_id The destination table to load the data into.
        # @param [File, Google::Cloud::Storage::File, String, URI,
        #   Array<Google::Cloud::Storage::File, String, URI>] files
        #   A file or the URI of a Google Cloud Storage file, or an Array of
        #   those, containing data to load into the table.
        # @param [String] format The exported file format. The default value is
        #   `csv`.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](https://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `orc` - [ORC](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-orc)
        #   * `parquet` - [Parquet](https://parquet.apache.org/)
        #   * `datastore_backup` - Cloud Datastore backup
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] dataset_id The destination table to load the data into.
        #   For load job with session it defaults to "_SESSION"
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
        # @param [String] null_marker Specifies a string that represents a null
        #   value in a CSV file. For example, if you specify `\N`, BigQuery
        #   interprets `\N` as a null value when loading a CSV file. The default
        #   value is the empty string. If you set this property to a custom
        #   value, BigQuery throws an error if an empty string is present for
        #   all data types except for STRING and BYTE. For STRING and BYTE
        #   columns, BigQuery interprets the empty string as an empty value.
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
        # @param [string] session_id Session ID in which the load job must run.
        #
        # @yield [updater] A block for setting the schema of the destination
        #   table and other options for the load job. The schema can be omitted
        #   if the destination table already exists, or if you're loading data
        #   from a Google Cloud Datastore backup.
        # @yieldparam [Google::Cloud::Bigquery::LoadJob::Updater] updater An
        #   updater to modify the load job and its schema.
        #
        # @return [Boolean] Returns `true` if the load job was successful.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   bigquery.load "my_new_table", gs_url, dataset_id: "my_dataset" do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @!group Data
        #
        def load table_id, files, dataset_id: "_SESSION", format: nil, create: nil, write: nil,
                 projection_fields: nil, jagged_rows: nil, quoted_newlines: nil, encoding: nil,
                 delimiter: nil, ignore_unknown: nil, max_bad_records: nil, quote: nil,
                 skip_leading: nil, schema: nil, autodetect: nil, null_marker: nil, session_id: nil, &block
          job = load_job table_id, files, dataset_id: dataset_id,
                        format: format, create: create, write: write, projection_fields: projection_fields,
                        jagged_rows: jagged_rows, quoted_newlines: quoted_newlines, encoding: encoding,
                        delimiter: delimiter, ignore_unknown: ignore_unknown, max_bad_records: max_bad_records,
                        quote: quote, skip_leading: skip_leading, schema: schema, autodetect: autodetect,
                        null_marker: null_marker, session_id: session_id, &block

          job.wait_until_done!
          ensure_job_succeeded! job
          true
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
        #   * `json` - [Newline-delimited JSON](https://jsonlines.org/)
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
        #   bigquery = Google::Cloud::Bigquery.new
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
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
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
        # @return [Google::Cloud::Bigquery::Dataset, nil] Returns `nil` if the
        #   dataset does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   puts dataset.name
        #
        # @example Avoid retrieving the dataset resource with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #
        def dataset dataset_id, skip_lookup: nil
          ensure_service!
          return Dataset.new_reference project, dataset_id, service if skip_lookup
          gapi = service.get_dataset dataset_id
          Dataset.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a new dataset.
        #
        # @param [String] dataset_id A unique ID for this dataset, without the
        #   project name. The ID must contain only letters (`[A-Za-z]`), numbers
        #   (`[0-9]`), or underscores (`_`). The maximum length is 1,024 characters.
        # @param [String] name A descriptive name for the dataset.
        # @param [String] description A user-friendly description of the
        #   dataset.
        # @param [Integer] expiration The default lifetime of all tables in the
        #   dataset, in milliseconds. The minimum value is `3_600_000` (one hour).
        # @param [String] location The geographic location where the dataset
        #   should reside. Possible values include `EU` and `US`. The default
        #   value is `US`.
        # @yield [access] a block for setting rules
        # @yieldparam [Google::Cloud::Bigquery::Dataset] access the object
        #   accepting rules
        #
        # @return [Google::Cloud::Bigquery::Dataset]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.create_dataset "my_dataset"
        #
        # @example A name and description can be provided:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.create_dataset "my_dataset",
        #                                     name: "My Dataset",
        #                                     description: "This is my Dataset"
        #
        # @example Or, configure access with a block: (See {Dataset::Access})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
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
              project_id: project, dataset_id: dataset_id
            )
          )

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
        # @return [Array<Google::Cloud::Bigquery::Dataset>] (See
        #   {Google::Cloud::Bigquery::Dataset::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   datasets = bigquery.datasets
        #   datasets.each do |dataset|
        #     puts dataset.name
        #   end
        #
        # @example Retrieve hidden datasets with the `all` optional arg:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   all_datasets = bigquery.datasets all: true
        #
        # @example Retrieve all datasets: (See {Dataset::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   datasets = bigquery.datasets
        #   datasets.all do |dataset|
        #     puts dataset.name
        #   end
        #
        def datasets all: nil, filter: nil, token: nil, max: nil
          ensure_service!
          gapi = service.list_datasets all: all, filter: filter, token: token, max: max
          Dataset::List.from_gapi gapi, service, all, filter, max
        end

        ##
        # Retrieves an existing job by ID.
        #
        # @param [String] job_id The ID of a job.
        # @param [String] location The geographic location where the job was
        #   created. Required except for US and EU.
        #
        # @return [Google::Cloud::Bigquery::Job, nil] Returns `nil` if the job
        #   does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.job "my_job"
        #
        def job job_id, location: nil
          ensure_service!
          gapi = service.get_job job_id, location: location
          Job.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of jobs belonging to the project.
        #
        # @param [Boolean] all Whether to display jobs owned by all users in the
        #   project. The default is `false`. Optional.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view. Optional.
        # @param [Integer] max Maximum number of jobs to return. Optional.
        # @param [String] filter A filter for job state. Optional.
        #
        #   Acceptable values are:
        #
        #   * `done` - Finished jobs
        #   * `pending` - Pending jobs
        #   * `running` - Running jobs
        # @param [Time] min_created_at Min value for {Job#created_at}. When
        #   provided, only jobs created after or at this time are returned.
        #   Optional.
        # @param [Time] max_created_at Max value for {Job#created_at}. When
        #   provided, only jobs created before or at this time are returned.
        #   Optional.
        # @param [Google::Cloud::Bigquery::Job, String] parent_job A job
        #   object or a job ID. If set, retrieve only child jobs of the
        #   specified parent. Optional. See {Job#job_id}, {Job#num_child_jobs},
        #   and {Job#parent_job_id}.
        #
        # @return [Array<Google::Cloud::Bigquery::Job>] (See
        #   {Google::Cloud::Bigquery::Job::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   jobs = bigquery.jobs
        #   jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve only running jobs using the `filter` optional arg:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   running_jobs = bigquery.jobs filter: "running"
        #   running_jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve only jobs created within provided times:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   two_days_ago = Time.now - 60*60*24*2
        #   three_days_ago = Time.now - 60*60*24*3
        #
        #   jobs = bigquery.jobs min_created_at: three_days_ago,
        #                        max_created_at: two_days_ago
        #   jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve all jobs: (See {Job::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   jobs = bigquery.jobs
        #   jobs.all do |job|
        #     # process job
        #   end
        #
        # @example Retrieve child jobs by setting `parent_job`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   multi_statement_sql = <<~SQL
        #     -- Declare a variable to hold names as an array.
        #     DECLARE top_names ARRAY<STRING>;
        #     -- Build an array of the top 100 names from the year 2017.
        #     SET top_names = (
        #     SELECT ARRAY_AGG(name ORDER BY number DESC LIMIT 100)
        #     FROM `bigquery-public-data.usa_names.usa_1910_current`
        #     WHERE year = 2017
        #     );
        #     -- Which names appear as words in Shakespeare's plays?
        #     SELECT
        #     name AS shakespeare_name
        #     FROM UNNEST(top_names) AS name
        #     WHERE name IN (
        #     SELECT word
        #     FROM `bigquery-public-data.samples.shakespeare`
        #     );
        #   SQL
        #
        #   job = bigquery.query_job multi_statement_sql
        #
        #   job.wait_until_done!
        #
        #   child_jobs = bigquery.jobs parent_job: job
        #
        #   child_jobs.each do |child_job|
        #     script_statistics = child_job.script_statistics
        #     puts script_statistics.evaluation_kind
        #     script_statistics.stack_frames.each do |stack_frame|
        #       puts stack_frame.text
        #     end
        #   end
        #
        def jobs all: nil,
                 token: nil,
                 max: nil,
                 filter: nil,
                 min_created_at: nil,
                 max_created_at: nil,
                 parent_job: nil
          ensure_service!
          parent_job = parent_job.job_id if parent_job.is_a? Job
          options = {
            parent_job_id: parent_job,
            all: all,
            token: token,
            max: max, filter: filter,
            min_created_at: min_created_at,
            max_created_at: max_created_at
          }
          gapi = service.list_jobs(**options)
          Job::List.from_gapi gapi, service, **options
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
        # @return [Array<Google::Cloud::Bigquery::Project>] (See
        #   {Google::Cloud::Bigquery::Project::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
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
        #   bigquery = Google::Cloud::Bigquery.new
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
          gapi = service.list_projects token: token, max: max
          Project::List.from_gapi gapi, service, max
        end

        ##
        # Creates a Bigquery::Time object to represent a time, independent of a
        # specific date.
        #
        # @param [Integer] hour Hour, valid values from 0 to 23.
        # @param [Integer] minute Minute, valid values from 0 to 59.
        # @param [Integer, Float] second Second, valid values from 0 to 59. Can
        #   contain microsecond precision.
        #
        # @return [Bigquery::Time]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   fourpm = bigquery.time 16, 0, 0
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table` WHERE time_of_date = @time",
        #                         params: { time: fourpm }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Create Time with fractional seconds:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   precise_time = bigquery.time 16, 35, 15.376541
        #   data = bigquery.query "SELECT name FROM `my_dataset.my_table` WHERE time_of_date >= @time",
        #                         params: { time: precise_time }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        def time hour, minute, second
          Bigquery::Time.new "#{hour}:#{minute}:#{second}"
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
        # @return [Google::Cloud::Bigquery::Schema]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
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
        # Creates a new Bigquery::EncryptionConfiguration instance.
        #
        # This method does not execute an API call. Use the encryption
        # configuration to encrypt a table when creating one via
        # Bigquery::Dataset#create_table, Bigquery::Dataset#load,
        # Bigquery::Table#copy, or Bigquery::Project#query.
        #
        # @param [String] kms_key Name of the Cloud KMS encryption key that
        #   will be used to protect the destination BigQuery table. The BigQuery
        #   Service Account associated with your project requires access to this
        #   encryption key.
        #
        # @example Encrypt a new table
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #
        #   table = dataset.create_table "my_table" do |updater|
        #     updater.encryption = encrypt_config
        #   end
        #
        # @example Encrypt a load destination table
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #   job = dataset.load_job "my_table", "gs://abc/file" do |job|
        #     job.encryption = encrypt_config
        #   end
        #
        # @example Encrypt a copy destination table
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #   job = table.copy_job "my_dataset.new_table" do |job|
        #     job.encryption = encrypt_config
        #   end
        #
        # @example Encrypt a query destination table
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #   job = bigquery.query_job "SELECT 1;" do |query|
        #     query.table = dataset.table "my_table", skip_lookup: true
        #     query.encryption = encrypt_config
        #   end
        #
        # @return [Google::Cloud::Bigquery::EncryptionConfiguration]
        def encryption kms_key: nil
          encrypt_config = Bigquery::EncryptionConfiguration.new
          encrypt_config.kms_key = kms_key unless kms_key.nil?
          encrypt_config
        end

        ##
        # Extracts the data from a table or exports a model to Google Cloud Storage
        # asynchronously, immediately returning an {ExtractJob} that can be used to
        # track the progress of the export job.  The caller may poll the service by
        # repeatedly calling {Job#reload!} and {Job#done?} to detect when the job
        # is done, or simply block until the job is done by calling
        # #{Job#wait_until_done!}. See {#extract} for the synchronous version.
        #
        # Use this method instead of {Table#extract_job} or {Model#extract_job} to
        # extract data from source tables or models in other projects.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {ExtractJob::Updater#location=} in a block passed to this method.
        #
        # @see https://cloud.google.com/bigquery/docs/exporting-data
        #   Exporting table data
        # @see https://cloud.google.com/bigquery-ml/docs/exporting-models
        #   Exporting models
        #
        # @param [Table, Model, String] source The source table or model for
        #   the extract operation. This can be a table or model object; or a
        #   table ID string as specified by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [Google::Cloud::Storage::File, String, Array<String>]
        #   extract_url The Google Storage file or file URI pattern(s) to which
        #   BigQuery should extract. For a model export this value should be a
        #   string ending in an object name prefix, since multiple objects will
        #   be exported.
        # @param [String] format The exported file format. The default value for
        #   tables is `csv`. Tables with nested or repeated fields cannot be
        #   exported as CSV. The default value for models is `ml_tf_saved_model`.
        #
        #   Supported values for tables:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](https://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #
        #   Supported values for models:
        #
        #   * `ml_tf_saved_model` - TensorFlow SavedModel
        #   * `ml_xgboost_booster` - XGBoost Booster
        # @param [String] compression The compression type to use for exported
        #   files. Possible values include `GZIP` and `NONE`. The default value
        #   is `NONE`. Not applicable when extracting models.
        # @param [String] delimiter Delimiter to use between fields in the
        #   exported table data. Default is `,`. Not applicable when extracting
        #   models.
        # @param [Boolean] header Whether to print out a header row in table
        #   exports. Default is `true`. Not applicable when extracting models.
        # @param [String] job_id A user-defined ID for the extract job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::ExtractJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Google::Cloud::Bigquery::ExtractJob]
        #
        # @example Export table data
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   table_id = "bigquery-public-data.samples.shakespeare"
        #   extract_job = bigquery.extract_job table_id, "gs://my-bucket/shakespeare.csv"
        #   extract_job.wait_until_done!
        #   extract_job.done? #=> true
        #
        # @example Export a model
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   extract_job = bigquery.extract model, "gs://my-bucket/#{model.model_id}"
        #
        # @!group Data
        #
        def extract_job source, extract_url, format: nil, compression: nil, delimiter: nil, header: nil, job_id: nil,
                        prefix: nil, labels: nil
          ensure_service!
          options = { format: format, compression: compression, delimiter: delimiter, header: header, job_id: job_id,
                      prefix: prefix, labels: labels }
          source_ref = if source.respond_to? :model_ref
                         source.model_ref
                       else
                         Service.get_table_ref source, default_ref: project_ref
                       end

          updater = ExtractJob::Updater.from_options service, source_ref, extract_url, options

          yield updater if block_given?

          job_gapi = updater.to_gapi
          gapi = service.extract_table job_gapi
          Job.from_gapi gapi, service
        end

        ##
        # Extracts the data from a table or exports a model to Google Cloud Storage
        # using a synchronous method that blocks for a response. Timeouts
        # and transient errors are generally handled as needed to complete the
        # job. See {#extract_job} for the asynchronous version.
        #
        # Use this method instead of {Table#extract} or {Model#extract} to
        # extract data from source tables or models in other projects.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {ExtractJob::Updater#location=} in a block passed to this method.
        #
        # @see https://cloud.google.com/bigquery/docs/exporting-data
        #   Exporting table data
        # @see https://cloud.google.com/bigquery-ml/docs/exporting-models
        #   Exporting models
        #
        # @param [Table, Model, String] source The source table or model for
        #   the extract operation. This can be a table or model object; or a
        #   table ID string as specified by the [Standard SQL Query
        #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
        #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
        #   Reference](https://cloud.google.com/bigquery/query-reference#from)
        #   (`project-name:dataset_id.table_id`).
        # @param [Google::Cloud::Storage::File, String, Array<String>]
        #   extract_url The Google Storage file or file URI pattern(s) to which
        #   BigQuery should extract. For a model export this value should be a
        #   string ending in an object name prefix, since multiple objects will
        #   be exported.
        # @param [String] format The exported file format. The default value for
        #   tables is `csv`. Tables with nested or repeated fields cannot be
        #   exported as CSV. The default value for models is `ml_tf_saved_model`.
        #
        #   Supported values for tables:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](https://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #
        #   Supported values for models:
        #
        #   * `ml_tf_saved_model` - TensorFlow SavedModel
        #   * `ml_xgboost_booster` - XGBoost Booster
        # @param [String] compression The compression type to use for exported
        #   files. Possible values include `GZIP` and `NONE`. The default value
        #   is `NONE`. Not applicable when extracting models.
        # @param [String] delimiter Delimiter to use between fields in the
        #   exported table data. Default is `,`. Not applicable when extracting
        #   models.
        # @param [Boolean] header Whether to print out a header row in table
        #   exports. Default is `true`. Not applicable when extracting models.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::ExtractJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Boolean] Returns `true` if the extract operation succeeded.
        #
        # @example Export table data
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   bigquery.extract "bigquery-public-data.samples.shakespeare",
        #                    "gs://my-bucket/shakespeare.csv"
        #
        # @example Export a model
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   bigquery.extract model, "gs://my-bucket/#{model.model_id}"
        #
        # @!group Data
        #
        def extract source, extract_url, format: nil, compression: nil, delimiter: nil, header: nil, &block
          job = extract_job source, extract_url,
                            format:      format,
                            compression: compression,
                            delimiter:   delimiter,
                            header:      header,
                            &block
          job.wait_until_done!
          ensure_job_succeeded! job
          true
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
            p.instance_variable_set :@numeric_id, Integer(gapi.numeric_id) if gapi.numeric_id
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end

        def ensure_job_succeeded! job
          return unless job.failed?
          begin
            # raise to activate ruby exception cause handling
            raise job.gapi_error
          rescue StandardError => e
            # wrap Google::Apis::Error with Google::Cloud::Error
            raise Google::Cloud::Error.from_error(e)
          end
        end

        def project_ref
          Google::Apis::BigqueryV2::ProjectReference.new project_id: project_id
        end
      end
    end
  end
end
