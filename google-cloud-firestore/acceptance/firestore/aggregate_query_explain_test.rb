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

require "firestore_helper"

describe "AggregateQuery Explain", :firestore_acceptance do
  let(:rand_query_col) do
    query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    query_col.add({ name: "Alice", type: "human", population: 100 })
    query_col.add({ name: "Bob", type: "human", population: 200 })
    query_col.add({ name: "Charlie", type: "human", population: 300 })
    query_col.add({ name: "Robot", type: "robot", population: 50 })
    query_col
  end

  let(:aggregate_query) { rand_query_col.aggregate_query.add_count(aggregate_alias: "total").add_sum("population", aggregate_alias: "total_pop") }

  it "runs an aggregate query with explain (analyze: false) - returns only metrics, no snapshot" do
    explain_result = aggregate_query.explain

    _(explain_result).must_be_kind_of Google::Cloud::Firestore::AggregateQueryExplainResult

    # Should have no actual snapshot
    _(explain_result.snapshot).must_be_nil

    # Should have explain_metrics
    metrics = explain_result.explain_metrics
    _(metrics).wont_be_nil
    _(metrics).must_be_kind_of Google::Cloud::Firestore::V1::ExplainMetrics
    _(metrics.plan_summary).wont_be_nil

    # Execution stats should be nil as analyze was false
    _(metrics.execution_stats).must_be_nil
  end

  it "runs an aggregate query with explain (analyze: true) - returns both snapshot and metrics" do
    explain_result = aggregate_query.explain analyze: true

    _(explain_result).must_be_kind_of Google::Cloud::Firestore::AggregateQueryExplainResult

    # Before access metrics_fetched should be false
    _(explain_result.metrics_fetched?).must_equal false

    # Should have an actual snapshot
    snapshot = explain_result.snapshot
    _(snapshot).wont_be_nil
    _(snapshot).must_be_kind_of Google::Cloud::Firestore::AggregateQuerySnapshot
    _(snapshot.get("total")).must_equal 4
    _(snapshot.get("total_pop")).must_equal 100 + 200 + 300 + 50

    # After access metrics_fetched should be true
    _(explain_result.metrics_fetched?).must_equal true

    # Should have explain_metrics with both planning and execution data
    metrics = explain_result.explain_metrics
    _(metrics).wont_be_nil
    _(metrics).must_be_kind_of Google::Cloud::Firestore::V1::ExplainMetrics
    _(metrics.plan_summary).wont_be_nil
    _(metrics.execution_stats).wont_be_nil
    _(metrics.execution_stats.results_returned).must_equal 1
  end

  it "produces consistent results between explain(analyze:true).snapshot and normal get" do
    explain_result_analyzed = aggregate_query.explain analyze: true

    snapshot_from_explain = explain_result_analyzed.snapshot
    snapshot_from_get = aggregate_query.get.first

    _(snapshot_from_explain).wont_be_nil
    _(snapshot_from_get).wont_be_nil

    _(snapshot_from_explain.get("total")).must_equal snapshot_from_get.get("total")
    _(snapshot_from_explain.get("total_pop")).must_equal snapshot_from_get.get("total_pop")

    metrics_analyzed = explain_result_analyzed.explain_metrics
    _(metrics_analyzed).wont_be_nil
    _(metrics_analyzed.plan_summary).wont_be_nil
    _(metrics_analyzed.execution_stats).wont_be_nil
  end

  it "handles empty result sets for aggregation with analyze: true" do
    empty_query = rand_query_col.where(:type, :==, "alien").aggregate_query.add_count(aggregate_alias: "alien_count")
    explain_result = empty_query.explain analyze: true

    _(explain_result.snapshot.get("alien_count")).must_equal 0
    _(explain_result.explain_metrics).wont_be_nil
    _(explain_result.explain_metrics.execution_stats.results_returned).must_equal 1 # empty result is still reflected
  end
end
