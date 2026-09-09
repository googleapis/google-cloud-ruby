# Copyright 2025 Google LLC
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

require "google/cloud/firestore/aggregate_query_snapshot"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/v1" # For ExplainMetrics and AggregationResult types

module Google
  module Cloud
    module Firestore
      ##
      # # AggregateQueryExplainResult
      #
      # Represents the result of a Firestore aggregate query explanation.
      # This class provides access to the
      # {Google::Cloud::Firestore::V1::ExplainMetrics}, which contain details
      # about the query plan and execution statistics. If the explanation was
      # run with `analyze: true`, it also provides access to the
      # {AggregateQuerySnapshot}.
      #
      # The metrics and snapshot (if applicable) are fetched and cached upon
      # the first call to either {#explain_metrics} or {#snapshot}.
      #
      # @see AggregateQuery#explain
      #
      # @example Getting planning and execution metrics with the snapshot
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #   aggregate_query = firestore.col(:cities).aggregate_query.add_count
      #
      #   explain_result = aggregate_query.explain analyze: true
      #
      #   metrics = explain_result.explain_metrics
      #   if metrics
      #     puts "Plan summary: #{metrics.plan_summary&.to_json}"
      #     puts "Execution stats: #{metrics.execution_stats&.to_json}"
      #   end
      #
      #   snapshot = explain_result.snapshot
      #   puts "Count: #{snapshot.get}" if snapshot
      #
      # @example Getting only planning metrics
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #   aggregate_query = firestore.col(:cities).aggregate_query.add_count
      #
      #   explain_result = aggregate_query.explain analyze: false # Default
      #
      #   metrics = explain_result.explain_metrics
      #   puts "Plan summary: #{metrics.plan_summary&.to_json}" if metrics
      #
      #   # Snapshot will be nil because analyze was false
      #   puts "Snapshot is nil: #{explain_result.snapshot.nil?}"
      #
      class AggregateQueryExplainResult
        # Indicates whether the metrics and snapshot (if applicable) have been
        # fetched from the server response and cached.
        # This becomes `true` after the first call to {#explain_metrics} or
        # {#snapshot}.
        #
        # @return [Boolean] `true` if data has been fetched, `false` otherwise.
        attr_reader :metrics_fetched
        alias metrics_fetched? metrics_fetched

        ##
        # @private Creates a new AggregateQueryExplainResult.
        #
        # @param responses_enum [Enumerable<Google::Cloud::Firestore::V1::RunAggregationQueryResponse>]
        #   The enum of response objects from the gRPC call.
        #
        def initialize responses_enum
          @responses_enum = responses_enum

          @metrics_fetched = false
          @explain_metrics = nil
          @snapshot = nil
        end

        # The metrics from planning and potentially execution stages of the
        # aggregate query.
        #
        # Calling this method for the first time will process the server
        # responses to extract and cache the metrics (and snapshot if
        # `analyze: true` was used). Subsequent calls return the cached metrics.
        #
        # @return [Google::Cloud::Firestore::V1::ExplainMetrics, nil]
        #   The query explanation metrics, or `nil` if no metrics were returned
        #   by the server.
        #
        def explain_metrics
          ensure_fetched!
          @explain_metrics
        end

        # The {AggregateQuerySnapshot} containing the aggregation results.
        #
        # This is only available if the explanation was run with `analyze: true`.
        # If `analyze: false` was used, or if the query yielded no results
        # even with `analyze: true`, this method returns `nil`.
        #
        # Calling this method for the first time will process the server
        # responses to extract and cache the snapshot (and metrics).
        # Subsequent calls return the cached snapshot.
        #
        # @return [AggregateQuerySnapshot, nil]
        #   The aggregate query snapshot if `analyze: true` was used and results
        #   are available, otherwise `nil`.
        #
        def snapshot
          ensure_fetched!
          @snapshot
        end

        private

        # Processes the responses from the server to populate metrics and,
        # if applicable, the snapshot. This method is called internally by
        # {#explain_metrics} and {#snapshot} and ensures that processing
        # happens only once.
        # @private
        def ensure_fetched!
          return if @metrics_fetched

          @responses_enum.each do |response|
            if @explain_metrics.nil? && response.explain_metrics
              @explain_metrics = response.explain_metrics
            end

            if @snapshot.nil? && response.result
              @snapshot = AggregateQuerySnapshot.from_run_aggregate_query_response response
            end
          end

          @metrics_fetched = true
        end
      end
    end
  end
end
