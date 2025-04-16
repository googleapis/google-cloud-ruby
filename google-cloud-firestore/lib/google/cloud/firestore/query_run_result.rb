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
      # # QueryRunResult
      #
      # A custom enumerator that extends Enumerator<DocumentSnapshot> with additional properties
      # related to the query execution.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Create a query with explanation enabled
      #   query = firestore.col(:cities).select(:population).explain
      #
      #   # Get the query results with explanation
      #   results = query.get
      #
      #   # Access the documents
      #   results.each do |city|
      #     puts "#{city.document_id} has #{city[:population]} residents."
      #   end
      #
      #   # Access the explanation if available
      #   if results.explain_metrics
      #     puts "Query planning metrics: #{results.explain_metrics}"
      #   end
      #
      class QueryRunResult < Enumerator
        # @return [Google::Cloud::Firestore::V1::ExplainMetrics, nil] The metrics from planning and execution stages
        #   This parameter will only be populated after all results are read from the enumeration
        #   and only if the query was configured with `explain` method.
        attr_reader :explain_metrics

        # @private Creates a new QueryRunResult.
        def initialize results_generator, client, reverse_results: false
          super() do |yielder|
            query_results = results_generator.call
            ordered_results = reverse_results ? query_results.to_a.reverse : query_results

            ordered_results.each do |result|
              @explain_metrics ||= result.explain_metrics if result.explain_metrics
              next if result.document.nil?

              # If we want more separation of concerns, `client` can be replaced by a result transformation lambda
              # but currently I think passing `client` should be prefered for simplicity
              yielder << DocumentSnapshot.from_query_result(result, client)
            end
          end
        end
      end
    end
  end
end
