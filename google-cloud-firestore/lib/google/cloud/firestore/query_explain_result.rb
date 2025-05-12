# Copyright 2024 Google LLC
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


module Google
  module Cloud
    module Firestore
      ##
      # # QueryExplainResult
      #
      # Represents the result of a Firestore query explanation. This class
      # provides an enumerable interface to iterate over the {DocumentSnapshot}
      # results (if the explanation was run with `analyze: true`) and allows
      # access to the {Google::Cloud::Firestore::V1::ExplainMetrics} which
      # contain details about the query plan and execution statistics.
      #
      # @see Query#explain
      #
      # @example Iterating over results and accessing metrics
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #   query = firestore.col(:cities).where(:population, :>, 100000)
      #
      #   # Run the query and return metrics from the planning and execution stages
      #   explanation_result = query.explain analyze: true
      #
      #   explanation_result.each do |city_snapshot|
      #     puts "City: #{city_snapshot.document_id}, Population: #{city_snapshot[:population]}"
      #   end
      #
      #   # Metrics are populated after iterating or calling fetch_metrics
      #   metrics = explanation_result.explain_metrics
      #   puts "Results returned: #{metrics.execution_stats.results_returned}" if metrics&.execution_stats
      #
      # @example Fetching metrics directly (which also iterates internally if needed)
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #   query = firestore.col(:cities).where(:population, :>, 100000)
      #
      #   # Get the execution plan without running the query (or with analyze: true)
      #   explanation_result = query.explain analyze: false # or true
      #
      #   metrics = explanation_result.fetch_metrics
      #   if metrics
      #     puts "Plan summary: #{metrics.plan_summary}"
      #     if metrics.execution_stats
      #       puts "Execution stats: #{metrics.execution_stats.results_returned} results"
      #     end
      #   end
      ##
      class QueryExplainResult
        include Enumerable

        # The metrics from planning and execution stages of the query.
        # This attribute is populated after iterating through the results (e.g., via {#each})
        # or by explicitly calling {#fetch_metrics}.
        # It will be `nil` if the query explanation did not produce metrics or if
        # iteration has not yet occurred.
        #
        # @return [Google::Cloud::Firestore::V1::ExplainMetrics, nil] The query explanation metrics,
        #   or `nil` if not yet populated or not available.
        attr_reader :explain_metrics

        # @private Creates a new QueryRunResult.
        def initialize results_enum, client
          @results_enum = results_enum
          @client = client
        end

        # Iterates over the document snapshots returned by the query explanation
        # if `analyze: true` was used. If `analyze: false` was used, this
        # method will still iterate but will not yield any documents, though it
        # will populate the query explanation metrics.
        #
        # @yieldparam [DocumentSnapshot] snapshot A document snapshot from the query results.
        # @return [Enumerator] If no block is given.
        def each
          return enum_for :each unless block_given?
          @results ||= @results_enum.to_a
          @results.each do |result|
            @explain_metrics ||= result.explain_metrics if result.explain_metrics
            next if result.document.nil?

            yield DocumentSnapshot.from_query_result(result, @client)
          end
        end

        # Ensures that all results from the underlying enumerator have been seen
        # and the metrics are populated.
        # This method will iterate through any remaining results if they haven't been
        # fully processed yet.
        #
        # @return [Google::Cloud::Firestore::V1::ExplainMetrics, nil] The query explanation metrics.
        def fetch_metrics
          # rubocop:disable Lint/EmptyBlock
          each {} if explain_metrics.nil?
          # rubocop:enable Lint/EmptyBlock
          explain_metrics
        end
      end
    end
  end
end
