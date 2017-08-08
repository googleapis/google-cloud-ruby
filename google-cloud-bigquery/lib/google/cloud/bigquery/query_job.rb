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
      class QueryJob < Job
        ##
        # Checks if the priority for the query is `BATCH`.
        def batch?
          val = @gapi.configuration.query.priority
          val == "BATCH"
        end

        ##
        # Checks if the priority for the query is `INTERACTIVE`.
        def interactive?
          val = @gapi.configuration.query.priority
          return true if val.nil?
          val == "INTERACTIVE"
        end

        ##
        # Checks if the the query job allows arbitrarily large results at a
        # slight cost to performance.
        def large_results?
          val = @gapi.configuration.query.allow_large_results
          return false if val.nil?
          val
        end

        ##
        # Checks if the query job looks for an existing result in the query
        # cache. For more information, see [Query
        # Caching](https://cloud.google.com/bigquery/querying-data#querycaching).
        def cache?
          val = @gapi.configuration.query.use_query_cache
          return false if val.nil?
          val
        end

        ##
        # Checks if the query job flattens nested and repeated fields in the
        # query results. The default is `true`. If the value is `false`,
        # #large_results? should return `true`.
        def flatten?
          val = @gapi.configuration.query.flatten_results
          return true if val.nil?
          val
        end

        ##
        # Limits the billing tier for this job.
        # For more information, see [High-Compute
        # queries](https://cloud.google.com/bigquery/pricing#high-compute).
        def maximum_billing_tier
          @gapi.configuration.query.maximum_billing_tier
        end

        ##
        # Limits the bytes billed for this job.
        def maximum_bytes_billed
          Integer @gapi.configuration.query.maximum_bytes_billed
        rescue
          nil
        end

        ##
        # Checks if the query results are from the query cache.
        def cache_hit?
          @gapi.statistics.query.cache_hit
        end

        ##
        # The number of bytes processed by the query.
        def bytes_processed
          Integer @gapi.statistics.query.total_bytes_processed
        rescue
          nil
        end

        ##
        # The table in which the query results are stored.
        def destination
          table = @gapi.configuration.query.destination_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # Checks if the query job is using legacy sql.
        def legacy_sql?
          val = @gapi.configuration.query.use_legacy_sql
          return true if val.nil?
          val
        end

        ##
        # Checks if the query job is using standard sql.
        def standard_sql?
          !legacy_sql?
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
        # @return [Google::Cloud::Bigquery::Data]
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
          data_gapi = service.list_tabledata destination_table_dataset_id,
                                             destination_table_table_id, options
          Data.from_gapi data_gapi, destination_table_gapi, service
        end
        alias_method :query_results, :data

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
