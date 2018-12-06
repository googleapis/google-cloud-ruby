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


require "google/cloud/bigquery/service"
require "google/cloud/bigquery/data"
require "google/cloud/bigquery/encryption_configuration"
require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # QueryJob
      #
      # A {Job} subclass representing a query operation that may be performed
      # on a {Table}. A QueryJob instance is created when you call
      # {Project#query_job}, {Dataset#query_job}.
      #
      # @see https://cloud.google.com/bigquery/querying-data Querying Data
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
      #                            "`bigquery-public-data.samples.shakespeare`"
      #
      #   job.wait_until_done!
      #
      #   if job.failed?
      #     puts job.error
      #   else
      #     puts job.data.first
      #   end
      #
      class QueryJob < Job
        ##
        # Checks if the priority for the query is `BATCH`.
        #
        # @return [Boolean] `true` when the priority is `BATCH`, `false`
        #   otherwise.
        #
        def batch?
          val = @gapi.configuration.query.priority
          val == "BATCH"
        end

        ##
        # Checks if the priority for the query is `INTERACTIVE`.
        #
        # @return [Boolean] `true` when the priority is `INTERACTIVE`, `false`
        #   otherwise.
        #
        def interactive?
          val = @gapi.configuration.query.priority
          return true if val.nil?
          val == "INTERACTIVE"
        end

        ##
        # Checks if the the query job allows arbitrarily large results at a
        # slight cost to performance.
        #
        # @return [Boolean] `true` when large results are allowed, `false`
        #   otherwise.
        #
        def large_results?
          val = @gapi.configuration.query.allow_large_results
          return false if val.nil?
          val
        end

        ##
        # Checks if the query job looks for an existing result in the query
        # cache. For more information, see [Query
        # Caching](https://cloud.google.com/bigquery/querying-data#querycaching).
        #
        # @return [Boolean] `true` when the query cache will be used, `false`
        #   otherwise.
        #
        def cache?
          val = @gapi.configuration.query.use_query_cache
          return false if val.nil?
          val
        end

        ##
        # If set, don't actually run this job. A valid query will return a
        # mostly empty response with some processing statistics, while an
        # invalid query will return the same error it would if it wasn't a dry
        # run.
        #
        # @return [Boolean] `true` when the dry run flag is set for the query
        #   job, `false` otherwise.
        #
        def dryrun
          @gapi.configuration.dry_run
        end
        alias dryrun? dryrun
        alias dry_run dryrun
        alias dry_run? dryrun

        ##
        # Checks if the query job flattens nested and repeated fields in the
        # query results. The default is `true`. If the value is `false`,
        # #large_results? should return `true`.
        #
        # @return [Boolean] `true` when the job flattens results, `false`
        #   otherwise.
        #
        def flatten?
          val = @gapi.configuration.query.flatten_results
          return true if val.nil?
          val
        end

        ##
        # Limits the billing tier for this job. Queries that have resource usage
        # beyond this tier will raise (without incurring a charge). If
        # unspecified, this will be set to your project default. For more
        # information, see [High-Compute
        # queries](https://cloud.google.com/bigquery/pricing#high-compute).
        #
        # @return [Integer, nil] The tier number, or `nil` for the project
        #   default.
        #
        def maximum_billing_tier
          @gapi.configuration.query.maximum_billing_tier
        end

        ##
        # Limits the bytes billed for this job. Queries that will have bytes
        # billed beyond this limit will raise (without incurring a charge). If
        # `nil`, this will be set to your project default.
        #
        # @return [Integer, nil] The number of bytes, or `nil` for the project
        #   default.
        #
        def maximum_bytes_billed
          Integer @gapi.configuration.query.maximum_bytes_billed
        rescue StandardError
          nil
        end

        ##
        # Checks if the query results are from the query cache.
        #
        # @return [Boolean] `true` when the job statistics indicate a cache hit,
        #   `false` otherwise.
        #
        def cache_hit?
          return false unless @gapi.statistics.query
          @gapi.statistics.query.cache_hit
        end

        ##
        # The number of bytes processed by the query.
        #
        # @return [Integer, nil] Total bytes processed for the job.
        #
        def bytes_processed
          Integer @gapi.statistics.query.total_bytes_processed
        rescue StandardError
          nil
        end

        ##
        # Describes the execution plan for the query.
        #
        # @return [Array<Google::Cloud::Bigquery::QueryJob::Stage>, nil] An
        #   array containing the stages of the execution plan.
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
        #
        #   stages = job.query_plan
        #   stages.each do |stage|
        #     puts stage.name
        #     stage.steps.each do |step|
        #       puts step.kind
        #       puts step.substeps.inspect
        #     end
        #   end
        #
        def query_plan
          return nil unless @gapi.statistics.query &&
                            @gapi.statistics.query.query_plan
          Array(@gapi.statistics.query.query_plan).map do |stage|
            Stage.from_gapi stage
          end
        end

        ##
        # The type of query statement, if valid. Possible values (new values
        # might be added in the future):
        #
        # * "CREATE_MODEL": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "CREATE_TABLE": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "CREATE_TABLE_AS_SELECT": DDL statement, see [Using Data Definition
        #   Language Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "CREATE_VIEW": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "DELETE": DML statement, see [Data Manipulation Language Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax)
        # * "DROP_MODEL": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "DROP_TABLE": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "DROP_VIEW": DDL statement, see [Using Data Definition Language
        #   Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)
        # * "INSERT": DML statement, see [Data Manipulation Language Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax)
        # * "MERGE": DML statement, see [Data Manipulation Language Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax)
        # * "SELECT": SQL query, see [Standard SQL Query Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
        # * "UPDATE": DML statement, see [Data Manipulation Language Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax)
        #
        # @return [String, nil] The type of query statement.
        #
        def statement_type
          return nil unless @gapi.statistics.query
          @gapi.statistics.query.statement_type
        end

        ##
        # Whether the query is a DDL statement.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language
        #   Using Data Definition Language Statements
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   query_job = bigquery.query_job "CREATE TABLE my_table (x INT64)"
        #
        #   query_job.statement_type #=> "CREATE_TABLE"
        #   query_job.ddl? #=> true
        #
        def ddl?
          %w[CREATE_MODEL CREATE_TABLE CREATE_TABLE_AS_SELECT CREATE_VIEW \
             DROP_MODEL DROP_TABLE DROP_VIEW].include? statement_type
        end

        ##
        # Whether the query is a DML statement.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax
        #   Data Manipulation Language Syntax
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   query_job = bigquery.query_job "UPDATE my_table " \
        #                                  "SET x = x + 1 " \
        #                                  "WHERE x IS NOT NULL"
        #
        #   query_job.statement_type #=> "UPDATE"
        #   query_job.dml? #=> true
        #
        def dml?
          %w[INSERT UPDATE MERGE DELETE].include? statement_type
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
          return nil unless @gapi.statistics.query
          @gapi.statistics.query.ddl_operation_performed
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
          return nil unless @gapi.statistics.query
          ensure_service!
          table = @gapi.statistics.query.ddl_target_table
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
          return nil unless @gapi.statistics.query
          @gapi.statistics.query.num_dml_affected_rows
        end

        ##
        # The table in which the query results are stored.
        #
        # @return [Table] A table instance.
        #
        def destination
          table = @gapi.configuration.query.destination_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # Checks if the query job is using legacy sql.
        #
        # @return [Boolean] `true` when legacy sql is used, `false` otherwise.
        #
        def legacy_sql?
          val = @gapi.configuration.query.use_legacy_sql
          return true if val.nil?
          val
        end

        ##
        # Checks if the query job is using standard sql.
        #
        # @return [Boolean] `true` when standard sql is used, `false` otherwise.
        #
        def standard_sql?
          !legacy_sql?
        end

        ##
        # The user-defined function resources used in the query. May be either a
        # code resource to load from a Google Cloud Storage URI
        # (`gs://bucket/path`), or an inline resource that contains code for a
        # user-defined function (UDF). Providing an inline code resource is
        # equivalent to providing a URI for a file containing the same code. See
        # [User-Defined Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
        #
        # @return [Array<String>] An array containing Google Cloud Storage URIs
        #   and/or inline source code.
        #
        def udfs
          udfs_gapi = @gapi.configuration.query.user_defined_function_resources
          return nil unless udfs_gapi
          Array(udfs_gapi).map do |udf|
            udf.inline_code || udf.resource_uri
          end
        end

        ##
        # The encryption configuration of the destination table.
        #
        # @return [Google::Cloud::BigQuery::EncryptionConfiguration] Custom
        #   encryption configuration (e.g., Cloud KMS keys).
        #
        # @!group Attributes
        def encryption
          EncryptionConfiguration.from_gapi(
            @gapi.configuration.query.destination_encryption_configuration
          )
        end

        ###
        # Checks if the destination table will be time-partitioned. See
        # [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Boolean, nil] `true` when the table will be time-partitioned,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def time_partitioning?
          !@gapi.configuration.query.time_partitioning.nil?
        end

        ###
        # The period for which the destination table will be partitioned, if
        # any. See [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [String, nil] The partition type. Currently the only supported
        #   value is "DAY", or `nil` if not present.
        #
        # @!group Attributes
        #
        def time_partitioning_type
          @gapi.configuration.query.time_partitioning.type if time_partitioning?
        end

        ###
        # The field on which the destination table will be partitioned, if any.
        # If not set, the destination table will be partitioned by pseudo column
        # `_PARTITIONTIME`; if set, the table will be partitioned by this field.
        # See [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [String, nil] The partition field, if a field was configured.
        #   `nil` if not partitioned or not set (partitioned by pseudo column
        #   '_PARTITIONTIME').
        #
        # @!group Attributes
        #
        def time_partitioning_field
          return nil unless time_partitioning?
          @gapi.configuration.query.time_partitioning.field
        end

        ###
        # The expiration for the destination table partitions, if any, in
        # seconds. See [Partitioned
        # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Integer, nil] The expiration time, in seconds, for data in
        #   partitions, or `nil` if not present.
        #
        # @!group Attributes
        #
        def time_partitioning_expiration
          tp = @gapi.configuration.query.time_partitioning
          tp.expiration_ms / 1_000 if tp && !tp.expiration_ms.nil?
        end

        ###
        # If set to true, queries over the destination table will require a
        # partition filter that can be used for partition elimination to be
        # specified. See [Partitioned
        # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Boolean] `true` when a partition filter will be required,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def time_partitioning_require_filter?
          tp = @gapi.configuration.query.time_partitioning
          return false if tp.nil? || tp.require_partition_filter.nil?
          tp.require_partition_filter
        end

        ###
        # Checks if the destination table will be clustered.
        #
        # @see https://cloud.google.com/bigquery/docs/clustered-tables
        #   Introduction to Clustered Tables
        #
        # @return [Boolean, nil] `true` when the table will be clustered,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def clustering?
          !@gapi.configuration.query.clustering.nil?
        end

        ###
        # One or more fields on which the destination table should be clustered.
        # Must be specified with time-based partitioning, data in the table will
        # be first partitioned and subsequently clustered. The order of the
        # returned fields determines the sort order of the data.
        #
        # See {QueryJob::Updater#clustering_fields=}.
        #
        # @see https://cloud.google.com/bigquery/docs/partitioned-tables
        #   Partitioned Tables
        # @see https://cloud.google.com/bigquery/docs/clustered-tables
        #   Introduction to Clustered Tables
        # @see https://cloud.google.com/bigquery/docs/creating-clustered-tables
        #   Creating and Using Clustered Tables
        #
        # @return [Array<String>, nil] The clustering fields, or `nil` if the
        #   destination table will not be clustered.
        #
        # @!group Attributes
        #
        def clustering_fields
          @gapi.configuration.query.clustering.fields if clustering?
        end

        ##
        # Refreshes the job until the job is `DONE`.
        # The delay between refreshes will incrementally increase.
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
        #   job.done? #=> true
        #
        def wait_until_done!
          return if done?

          ensure_service!
          loop do
            query_results_gapi = service.job_query_results \
              job_id, location: location, max: 0
            if query_results_gapi.job_complete
              @destination_schema_gapi = query_results_gapi.schema
              break
            end
          end
          reload!
        end

        ##
        # Retrieves the query results for the job.
        #
        # @param [String] token Page token, returned by a previous call,
        #   identifying the result set.
        # @param [Integer] max Maximum number of results to return.
        # @param [Integer] start Zero-based index of the starting row to read.
        #
        # @return [Google::Cloud::Bigquery::Data] An object providing access to
        #   data read from the destination table for the job.
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
        #   data.each do |row|
        #     puts row[:word]
        #   end
        #   data = data.next if data.next?
        #
        def data token: nil, max: nil, start: nil
          return nil unless done?
          if dry_run?
            return Data.from_gapi_json({ rows: [] }, nil, @gapi, service)
          end
          if ddl? || dml?
            data_hash = { totalRows: nil, rows: [] }
            return Data.from_gapi_json data_hash, nil, @gapi, service
          end
          ensure_schema!

          options = { token: token, max: max, start: start }
          data_hash = service.list_tabledata \
            destination_table_dataset_id,
            destination_table_table_id,
            options
          Data.from_gapi_json data_hash, destination_table_gapi, @gapi, service
        end
        alias query_results data

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < QueryJob
          ##
          # @private Create an Updater object.
          def initialize service, gapi
            @service = service
            @gapi = gapi
          end

          # rubocop:disable all

          ##
          # @private Create an Updater from an options hash.
          #
          # @return [Google::Cloud::Bigquery::QueryJob::Updater] A job
          #   configuration object for setting query options.
          def self.from_options service, query, options
            job_ref = service.job_ref_from options[:job_id], options[:prefix]
            dataset_config = service.dataset_ref_from options[:dataset],
                                                      options[:project]
            req = Google::Apis::BigqueryV2::Job.new(
              job_reference: job_ref,
              configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
                query: Google::Apis::BigqueryV2::JobConfigurationQuery.new(
                  query: query,
                  default_dataset: dataset_config,
                  maximum_billing_tier: options[:maximum_billing_tier]
                )
              )
            )

            updater = QueryJob::Updater.new service, req
            updater.params = options[:params] if options[:params]
            updater.create = options[:create]
            updater.write = options[:write]
            updater.table = options[:table]
            updater.dry_run = options[:dryrun]
            updater.maximum_bytes_billed = options[:maximum_bytes_billed]
            updater.labels = options[:labels] if options[:labels]
            updater.legacy_sql = Convert.resolve_legacy_sql(
              options[:standard_sql], options[:legacy_sql])
            updater.external = options[:external] if options[:external]
            updater.priority = options[:priority]
            updater.cache = options[:cache]
            updater.large_results = options[:large_results]
            updater.flatten = options[:flatten]
            updater.udfs = options[:udfs]
            updater
          end

          # rubocop:enable all

          ##
          # Sets the geographic location where the job should run. Required
          # except for US and EU.
          #
          # @param [String] value  A geographic location, such as "US", "EU" or
          #   "asia-northeast1". Required except for US and EU.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   job = bigquery.query_job "SELECT 1;" do |query|
          #     query.table = dataset.table "my_table", skip_lookup: true
          #     query.location = "EU"
          #   end
          #
          # @!group Attributes
          def location= value
            @gapi.job_reference.location = value
            return unless value.nil?

            # Treat assigning value of nil the same as unsetting the value.
            unset = @gapi.job_reference.instance_variables.include? :@location
            @gapi.job_reference.remove_instance_variable :@location if unset
          end

          ##
          # Sets the priority of the query.
          #
          # @param [String] value Specifies a priority for the query. Possible
          #   values include `INTERACTIVE` and `BATCH`.
          #
          # @!group Attributes
          def priority= value
            @gapi.configuration.query.priority = priority_value value
          end

          ##
          # Specifies to look in the query cache for results.
          #
          # @param [Boolean] value Whether to look for the result in the query
          #   cache. The query cache is a best-effort cache that will be flushed
          #   whenever tables in the query are modified. The default value is
          #   true. For more information, see [query
          #   caching](https://developers.google.com/bigquery/querying-data).
          #
          # @!group Attributes
          def cache= value
            @gapi.configuration.query.use_query_cache = value
          end

          ##
          # Allow large results for a legacy SQL query.
          #
          # @param [Boolean] value This option is specific to Legacy SQL.
          #   If `true`, allows the query to produce arbitrarily large result
          #   tables at a slight cost in performance. Requires `table` parameter
          #   to be set.
          #
          # @!group Attributes
          def large_results= value
            @gapi.configuration.query.allow_large_results = value
          end

          ##
          # Flatten nested and repeated fields in legacy SQL queries.
          #
          # @param [Boolean] value This option is specific to Legacy SQL.
          #   Flattens all nested and repeated fields in the query results. The
          #   default value is `true`. `large_results` parameter must be `true`
          #   if this is set to `false`.
          #
          # @!group Attributes
          def flatten= value
            @gapi.configuration.query.flatten_results = value
          end

          ##
          # Sets the default dataset of tables referenced in the query.
          #
          # @param [Dataset] value The default dataset to use for unqualified
          #   table names in the query.
          #
          # @!group Attributes
          def dataset= value
            @gapi.configuration.query.default_dataset =
              @service.dataset_ref_from value
          end

          ##
          # Sets the query parameters. Standard SQL only.
          #
          # @param [Array, Hash] params Used to pass query arguments when the
          #   `query` string contains either positional (`?`) or named
          #   (`@myparam`) query parameters. If value passed is an array
          #   `["foo"]`, the query must use positional query parameters. If
          #   value passed is a hash `{ myparam: "foo" }`, the query must use
          #   named query parameters. When set, `legacy_sql` will automatically
          #   be set to false and `standard_sql` to true.
          #
          # @!group Attributes
          def params= params
            case params
            when Array then
              @gapi.configuration.query.use_legacy_sql = false
              @gapi.configuration.query.parameter_mode = "POSITIONAL"
              @gapi.configuration.query.query_parameters = params.map do |param|
                Convert.to_query_param param
              end
            when Hash then
              @gapi.configuration.query.use_legacy_sql = false
              @gapi.configuration.query.parameter_mode = "NAMED"
              @gapi.configuration.query.query_parameters =
                params.map do |name, param|
                  Convert.to_query_param(param).tap do |named_param|
                    named_param.name = String name
                  end
                end
            else
              raise "Query parameters must be an Array or a Hash."
            end
          end

          ##
          # Sets the create disposition for creating the query results table.
          #
          # @param [String] value Specifies whether the job is allowed to
          # create new tables. The default value is `needed`.
          #
          #   The following values are supported:
          #
          #   * `needed` - Create the table if it does not exist.
          #   * `never` - The table must already exist. A 'notFound' error is
          #     raised if the table does not exist.
          #
          # @!group Attributes
          def create= value
            @gapi.configuration.query.create_disposition =
              Convert.create_disposition value
          end

          ##
          # Sets the write disposition for when the query results table exists.
          #
          # @param [String] value Specifies the action that occurs if the
          #   destination table already exists. The default value is `empty`.
          #
          #   The following values are supported:
          #
          #   * `truncate` - BigQuery overwrites the table data.
          #   * `append` - BigQuery appends the data to the table.
          #   * `empty` - A 'duplicate' error is returned in the job result if
          #     the table exists and contains data.
          #
          # @!group Attributes
          def write= value
            @gapi.configuration.query.write_disposition =
              Convert.write_disposition value
          end

          ##
          # Sets the dry run flag for the query job.
          #
          # @param [Boolean] value If set, don't actually run this job. A valid
          #   query will return a mostly empty response with some processing
          #   statistics, while an invalid query will return the same error it
          #   would if it wasn't a dry run..
          #
          # @!group Attributes
          def dryrun= value
            @gapi.configuration.dry_run = value
          end
          alias dry_run= dryrun=

          ##
          # Sets the destination for the query results table.
          #
          # @param [Table] value The destination table where the query results
          #   should be stored. If not present, a new table will be created
          #   according to the create disposition to store the results.
          #
          # @!group Attributes
          def table= value
            @gapi.configuration.query.destination_table = table_ref_from value
          end

          ##
          # Sets the maximum bytes billed for the query.
          #
          # @param [Integer] value Limits the bytes billed for this job.
          #   Queries that will have bytes billed beyond this limit will fail
          #   (without incurring a charge). Optional. If unspecified, this will
          #   be set to your project default.
          #
          # @!group Attributes
          def maximum_bytes_billed= value
            @gapi.configuration.query.maximum_bytes_billed = value
          end

          ##
          # Sets the labels to use for the job.
          #
          # @param [Hash] value A hash of user-provided labels associated with
          #   the job. You can use these to organize and group your jobs. Label
          #   keys and values can be no longer than 63 characters, can only
          #   contain lowercase letters, numeric characters, underscores and
          #   dashes. International characters are allowed. Label values are
          #   optional. Label keys must start with a letter and each label in
          #   the list must have a different key.
          #
          # @!group Attributes
          #
          def labels= value
            @gapi.configuration.update! labels: value
          end

          ##
          # Sets the query syntax to legacy SQL.
          #
          # @param [Boolean] value Specifies whether to use BigQuery's [legacy
          #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
          #   dialect for this query. If set to false, the query will use
          #   BigQuery's [standard
          #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
          #   dialect. Optional. The default value is false.
          #
          # @!group Attributes
          #
          def legacy_sql= value
            @gapi.configuration.query.use_legacy_sql = value
          end

          ##
          # Sets the query syntax to standard SQL.
          #
          # @param [Boolean] value Specifies whether to use BigQuery's [standard
          #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
          #   dialect for this query. If set to true, the query will use
          #   standard SQL rather than the [legacy
          #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
          #   dialect. Optional. The default value is true.
          #
          # @!group Attributes
          #
          def standard_sql= value
            @gapi.configuration.query.use_legacy_sql = !value
          end

          ##
          # Sets definitions for external tables used in the query.
          #
          # @param [Hash<String|Symbol, External::DataSource>] value A Hash
          #   that represents the mapping of the external tables to the table
          #   names used in the SQL query. The hash keys are the table names,
          #   and the hash values are the external table objects.
          #
          # @!group Attributes
          #
          def external= value
            external_table_pairs = value.map do |name, obj|
              [String(name), obj.to_gapi]
            end
            external_table_hash = Hash[external_table_pairs]
            @gapi.configuration.query.table_definitions = external_table_hash
          end

          ##
          # Sets user defined functions for the query.
          #
          # @param [Array<String>, String] value User-defined function resources
          #   used in the query. May be either a code resource to load from a
          #   Google Cloud Storage URI (`gs://bucket/path`), or an inline
          #   resource that contains code for a user-defined function (UDF).
          #   Providing an inline code resource is equivalent to providing a URI
          #   for a file containing the same code. See [User-Defined
          #   Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
          #
          # @!group Attributes
          def udfs= value
            @gapi.configuration.query.user_defined_function_resources =
              udfs_gapi_from value
          end

          ##
          # Sets the encryption configuration of the destination table.
          #
          # @param [Google::Cloud::BigQuery::EncryptionConfiguration] val
          #   Custom encryption configuration (e.g., Cloud KMS keys).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   encrypt_config = bigquery.encryption kms_key: key_name
          #   job = bigquery.query_job "SELECT 1;" do |job|
          #     job.table = dataset.table "my_table", skip_lookup: true
          #     job.encryption = encrypt_config
          #   end
          #
          # @!group Attributes
          def encryption= val
            @gapi.configuration.query.update!(
              destination_encryption_configuration: val.to_gapi
            )
          end

          ##
          # Sets the partitioning for the destination table. See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # You can only set the partitioning field while creating a table.
          # BigQuery does not allow you to change partitioning on an existing
          # table.
          #
          # @param [String] type The partition type. Currently the only
          #   supported value is "DAY".
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   destination_table = dataset.table "my_destination_table",
          #                                     skip_lookup: true
          #
          #   job = dataset.query_job "SELECT * FROM UNNEST(" \
          #                           "GENERATE_TIMESTAMP_ARRAY(" \
          #                           "'2018-10-01 00:00:00', " \
          #                           "'2018-10-10 00:00:00', " \
          #                           "INTERVAL 1 DAY)) AS dob" do |job|
          #     job.table = destination_table
          #     job.time_partitioning_type = "DAY"
          #   end
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_type= type
            @gapi.configuration.query.time_partitioning ||= \
              Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.query.time_partitioning.update! type: type
          end

          ##
          # Sets the field on which to partition the destination table. If not
          # set, the destination table is partitioned by pseudo column
          # `_PARTITIONTIME`; if set, the table is partitioned by this field.
          # See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # The destination table must also be partitioned. See
          # {#time_partitioning_type=}.
          #
          # You can only set the partitioning field while creating a table.
          # BigQuery does not allow you to change partitioning on an existing
          # table.
          #
          # @param [String] field The partition field. The field must be a
          #   top-level TIMESTAMP or DATE field. Its mode must be NULLABLE or
          #   REQUIRED.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   destination_table = dataset.table "my_destination_table",
          #                                     skip_lookup: true
          #
          #   job = dataset.query_job "SELECT * FROM UNNEST(" \
          #                           "GENERATE_TIMESTAMP_ARRAY(" \
          #                           "'2018-10-01 00:00:00', " \
          #                           "'2018-10-10 00:00:00', " \
          #                           "INTERVAL 1 DAY)) AS dob" do |job|
          #     job.table = destination_table
          #     job.time_partitioning_type  = "DAY"
          #     job.time_partitioning_field = "dob"
          #   end
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_field= field
            @gapi.configuration.query.time_partitioning ||= \
              Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.query.time_partitioning.update! field: field
          end

          ##
          # Sets the partition expiration for the destination table. See
          # [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # The destination table must also be partitioned. See
          # {#time_partitioning_type=}.
          #
          # @param [Integer] expiration An expiration time, in seconds,
          #   for data in partitions.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   destination_table = dataset.table "my_destination_table",
          #                                     skip_lookup: true
          #
          #   job = dataset.query_job "SELECT * FROM UNNEST(" \
          #                           "GENERATE_TIMESTAMP_ARRAY(" \
          #                           "'2018-10-01 00:00:00', " \
          #                           "'2018-10-10 00:00:00', " \
          #                           "INTERVAL 1 DAY)) AS dob" do |job|
          #     job.table = destination_table
          #     job.time_partitioning_type = "DAY"
          #     job.time_partitioning_expiration = 86_400
          #   end
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_expiration= expiration
            @gapi.configuration.query.time_partitioning ||= \
              Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.query.time_partitioning.update! \
              expiration_ms: expiration * 1000
          end

          ##
          # If set to true, queries over the destination table will require a
          # partition filter that can be used for partition elimination to be
          # specified. See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # @param [Boolean] val Indicates if queries over the destination table
          #   will require a partition filter. The default value is `false`.
          #
          # @!group Attributes
          #
          def time_partitioning_require_filter= val
            @gapi.configuration.query.time_partitioning ||= \
              Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.query.time_partitioning.update! \
              require_partition_filter: val
          end

          ##
          # Sets one or more fields on which the destination table should be
          # clustered. Must be specified with time-based partitioning, data in
          # the table will be first partitioned and subsequently clustered.
          #
          # Only top-level, non-repeated, simple-type fields are supported. When
          # you cluster a table using multiple columns, the order of columns you
          # specify is important. The order of the specified columns determines
          # the sort order of the data.
          #
          # See {QueryJob#clustering_fields}.
          #
          # @see https://cloud.google.com/bigquery/docs/partitioned-tables
          #   Partitioned Tables
          # @see https://cloud.google.com/bigquery/docs/clustered-tables
          #   Introduction to Clustered Tables
          # @see https://cloud.google.com/bigquery/docs/creating-clustered-tables
          #   Creating and Using Clustered Tables
          #
          # @param [Array<String>] fields The clustering fields. Only top-level,
          #   non-repeated, simple-type fields are supported.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   destination_table = dataset.table "my_destination_table",
          #                                     skip_lookup: true
          #
          #   job = dataset.query_job "SELECT * FROM my_table" do |job|
          #     job.table = destination_table
          #     job.time_partitioning_type = "DAY"
          #     job.time_partitioning_field = "dob"
          #     job.clustering_fields = ["last_name", "first_name"]
          #   end
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          # @!group Attributes
          #
          def clustering_fields= fields
            @gapi.configuration.query.clustering ||= \
              Google::Apis::BigqueryV2::Clustering.new
            @gapi.configuration.query.clustering.fields = fields
          end

          ##
          # @private Returns the Google API client library version of this job.
          #
          # @return [<Google::Apis::BigqueryV2::Job>] (See
          #   {Google::Apis::BigqueryV2::Job})
          def to_gapi
            @gapi
          end

          protected

          # Creates a table reference from a table object.
          def table_ref_from tbl
            return nil if tbl.nil?
            Google::Apis::BigqueryV2::TableReference.new(
              project_id: tbl.project_id,
              dataset_id: tbl.dataset_id,
              table_id: tbl.table_id
            )
          end

          def priority_value str
            { "batch" => "BATCH",
              "interactive" => "INTERACTIVE" }[str.to_s.downcase]
          end

          def udfs_gapi_from array_or_str
            Array(array_or_str).map do |uri_or_code|
              resource =
                Google::Apis::BigqueryV2::UserDefinedFunctionResource.new
              if uri_or_code.start_with?("gs://")
                resource.resource_uri = uri_or_code
              else
                resource.inline_code = uri_or_code
              end
              resource
            end
          end
        end

        ##
        # Represents a stage in the execution plan for the query.
        #
        # @attr_reader [Float] compute_ratio_avg Relative amount of time the
        #   average shard spent on CPU-bound tasks.
        # @attr_reader [Float] compute_ratio_max Relative amount of time the
        #   slowest shard spent on CPU-bound tasks.
        # @attr_reader [Integer] id Unique ID for the stage within the query
        #   plan.
        # @attr_reader [String] name Human-readable name for the stage.
        # @attr_reader [Float] read_ratio_avg Relative amount of time the
        #   average shard spent reading input.
        # @attr_reader [Float] read_ratio_max Relative amount of time the
        #   slowest shard spent reading input.
        # @attr_reader [Integer] records_read Number of records read into the
        #   stage.
        # @attr_reader [Integer] records_written Number of records written by
        #   the stage.
        # @attr_reader [Array<Step>] steps List of operations within the stage
        #   in dependency order (approximately chronological).
        # @attr_reader [Float] wait_ratio_avg Relative amount of time the
        #   average shard spent waiting to be scheduled.
        # @attr_reader [Float] wait_ratio_max Relative amount of time the
        #   slowest shard spent waiting to be scheduled.
        # @attr_reader [Float] write_ratio_avg Relative amount of time the
        #   average shard spent on writing output.
        # @attr_reader [Float] write_ratio_max Relative amount of time the
        #   slowest shard spent on writing output.
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
        #
        #   stages = job.query_plan
        #   stages.each do |stage|
        #     puts stage.name
        #     stage.steps.each do |step|
        #       puts step.kind
        #       puts step.substeps.inspect
        #     end
        #   end
        #
        class Stage
          attr_reader :compute_ratio_avg, :compute_ratio_max, :id, :name,
                      :read_ratio_avg, :read_ratio_max, :records_read,
                      :records_written, :status, :steps, :wait_ratio_avg,
                      :wait_ratio_max, :write_ratio_avg, :write_ratio_max

          ##
          # @private Creates a new Stage instance.
          def initialize compute_ratio_avg, compute_ratio_max, id, name,
                         read_ratio_avg, read_ratio_max, records_read,
                         records_written, status, steps, wait_ratio_avg,
                         wait_ratio_max, write_ratio_avg, write_ratio_max
            @compute_ratio_avg = compute_ratio_avg
            @compute_ratio_max = compute_ratio_max
            @id                = id
            @name              = name
            @read_ratio_avg    = read_ratio_avg
            @read_ratio_max    = read_ratio_max
            @records_read      = records_read
            @records_written   = records_written
            @status            = status
            @steps             = steps
            @wait_ratio_avg    = wait_ratio_avg
            @wait_ratio_max    = wait_ratio_max
            @write_ratio_avg   = write_ratio_avg
            @write_ratio_max   = write_ratio_max
          end

          ##
          # @private New Stage from a statistics.query.queryPlan element.
          def self.from_gapi gapi
            steps = Array(gapi.steps).map { |g| Step.from_gapi g }
            new gapi.compute_ratio_avg, gapi.compute_ratio_max, gapi.id,
                gapi.name, gapi.read_ratio_avg, gapi.read_ratio_max,
                gapi.records_read, gapi.records_written, gapi.status, steps,
                gapi.wait_ratio_avg, gapi.wait_ratio_max, gapi.write_ratio_avg,
                gapi.write_ratio_max
          end
        end

        ##
        # Represents an operation in a stage in the execution plan for the
        # query.
        #
        # @attr_reader [String] kind Machine-readable operation type. For a full
        #   list of operation types, see [Steps
        #   metadata](https://cloud.google.com/bigquery/query-plan-explanation#steps_metadata).
        # @attr_reader [Array<String>] substeps Human-readable stage
        #   descriptions.
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
        #
        #   stages = job.query_plan
        #   stages.each do |stage|
        #     puts stage.name
        #     stage.steps.each do |step|
        #       puts step.kind
        #       puts step.substeps.inspect
        #     end
        #   end
        #
        class Step
          attr_reader :kind, :substeps

          ##
          # @private Creates a new Stage instance.
          def initialize kind, substeps
            @kind = kind
            @substeps = substeps
          end

          ##
          # @private New Step from a statistics.query.queryPlan[].steps element.
          def self.from_gapi gapi
            new gapi.kind, Array(gapi.substeps)
          end
        end

        protected

        def ensure_schema!
          return unless destination_schema.nil?

          query_results_gapi = service.job_query_results \
            job_id, location: location, max: 0
          # raise "unable to retrieve schema" if query_results_gapi.schema.nil?
          @destination_schema_gapi = query_results_gapi.schema
        end

        def destination_schema
          @destination_schema_gapi
        end

        def destination_table_dataset_id
          @gapi.configuration.query.destination_table.dataset_id
        end

        def destination_table_table_id
          @gapi.configuration.query.destination_table.table_id
        end

        def destination_table_gapi
          Google::Apis::BigqueryV2::Table.new \
            table_reference: @gapi.configuration.query.destination_table,
            schema: destination_schema
        end
      end
    end
  end
end
