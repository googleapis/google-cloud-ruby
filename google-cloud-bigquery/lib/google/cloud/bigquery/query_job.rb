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


require "google/cloud/bigquery/service"
require "google/cloud/bigquery/data"

module Google
  module Cloud
    module Bigquery
      ##
      # # QueryJob
      #
      # A {Job} subclass representing a query operation that may be performed
      # on a {Table}. A QueryJob instance is created when you call
      # {Project#query_job}, {Dataset#query_job}, or {View#data}.
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
      #                            "publicdata.samples.shakespeare"
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
        # beyond this tier will fail (without incurring a charge). If
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
        # billed beyond this limit will fail (without incurring a charge). If
        # `nil`, this will be set to your project default.
        #
        # @return [Integer, nil] The number of bytes, or `nil` for the project
        #   default.
        #
        def maximum_bytes_billed
          Integer @gapi.configuration.query.maximum_bytes_billed
        rescue
          nil
        end

        ##
        # Checks if the query results are from the query cache.
        #
        # @return [Boolean] `true` when the job statistics indicate a cache hit,
        #   `false` otherwise.
        #
        def cache_hit?
          @gapi.statistics.query.cache_hit
        end

        ##
        # The number of bytes processed by the query.
        #
        # @return [Integer] Total bytes processed for the job.
        #
        def bytes_processed
          Integer @gapi.statistics.query.total_bytes_processed
        rescue
          nil
        end

        ##
        # Describes the execution plan for the query.
        #
        # @return [Array<Google::Cloud::Bigquery::QueryJob::Stage>] An array
        #   containing the stages of the execution plan.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT word FROM publicdata.samples.shakespeare"
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
          return nil unless @gapi.statistics.query.query_plan
          Array(@gapi.statistics.query.query_plan).map do |stage|
            Stage.from_gapi stage
          end
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
        # Refreshes the job until the job is `DONE`.
        # The delay between refreshes will incrementally increase.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sql = "SELECT word FROM publicdata.samples.shakespeare"
        #   job = bigquery.query_job sql
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        def wait_until_done!
          return if done?

          ensure_service!
          loop do
            query_results_gapi = service.job_query_results job_id, max: 0
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
        #   sql = "SELECT word FROM publicdata.samples.shakespeare"
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

          ensure_schema!

          options = { token: token, max: max, start: start }
          data_hash = service.list_tabledata_raw_json \
            destination_table_dataset_id,
            destination_table_table_id,
            options
          Data.from_json data_hash, destination_table_gapi, service
        end
        alias_method :query_results, :data

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
        #   sql = "SELECT word FROM publicdata.samples.shakespeare"
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
        #   sql = "SELECT word FROM publicdata.samples.shakespeare"
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

          query_results_gapi = service.job_query_results job_id, max: 0
          # fail "unable to retrieve schema" if query_results_gapi.schema.nil?
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
