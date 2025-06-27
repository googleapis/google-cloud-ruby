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

describe "Query Explain", :firestore_acceptance do
  # Basic explain feature tests
  it "runs a query with explain (analyze: false) - returns only metrics, no results" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run a query with explain(analyze: false)
    results = rand_query_col.explain

    # Should have no actual document results
    _(results.to_a).must_be :empty?

    # But should have explain_metrics
    _(results.explain_metrics).wont_be_nil
    _(results.explain_metrics).must_be_kind_of Google::Cloud::Firestore::V1::ExplainMetrics
    _(results.explain_metrics.plan_summary).wont_be_nil
  end

  it "runs a query with explain (analyze: true) - returns both results and metrics" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run a query with explain(analyze: true)
    results = rand_query_col.explain analyze: true

    # Should have actual document results
    _(results.count).must_equal 3

    # And should have explain_metrics with both planning and execution data
    _(results.explain_metrics).wont_be_nil
    _(results.explain_metrics).must_be_kind_of Google::Cloud::Firestore::V1::ExplainMetrics

    # Verify metrics have proper structure (specific fields may vary based on implementation)
    # This verifies that execution metrics are present (when analyze is true)
    _(results.explain_metrics.plan_summary).wont_be_nil
    _(results.explain_metrics.execution_stats).wont_be_nil
  end

  it "returns explain_metrics only after full enumeration" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run a query with explain(analyze: true)
    results = rand_query_col.explain analyze: true

    # Before iteration, explain_metrics should be nil
    _(results.metrics_fetched?).must_equal false

    # Get just the first element
    first = results.first
    _(first).wont_be_nil

    # fetching the first element should populate explain_metrics
    _(results.explain_metrics).wont_be_nil
    _(results.metrics_fetched?).must_equal true

    # Force complete enumeration
    all_results = results.to_a

    # Now explain_metrics should be populated
    _(results.explain_metrics).wont_be_nil
    _(results.explain_metrics).must_be_kind_of Google::Cloud::Firestore::V1::ExplainMetrics
  end

  # Limit test - standard limit
  it "works with limit and analyze: true" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run a query with limit and explain(analyze: true)
    results = rand_query_col.order(:population).limit(2).explain analyze: true

    # Should respect the limit
    _(results.count).must_equal 2

    # Verify correct ordering and limit
    names = results.map { |doc| doc[:name] }
    _(names).must_equal ["Alice", "Bob"]

    # And should have explain_metrics
    _(results.explain_metrics).wont_be_nil
  end

  # Limit_to_last test - special case because of reversing
  it "works with limit_to_last and analyze: true" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run a query with limit_to_last and explain(analyze: true)
    results = rand_query_col.order(:population).limit_to_last(2).explain analyze: true

    # Should respect the limit_to_last
    _(results.count).must_equal 2

    # Verify correct ordering - should be the last 2 items
    names = results.map { |doc| doc[:name] }
    _(names).must_equal ["Bob", "Charlie"]

    # And should have explain_metrics
    _(results.explain_metrics).wont_be_nil
  end

  # Compatibility and edge cases
  it "handles empty result sets with analyze: true" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents that won't match our filter
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})

    # Run a query with filter that returns no results
    results = rand_query_col.where(:population, :>, 1000).explain analyze: true

    # Should have no results
    _(results.to_a).must_be :empty?

    # But should still have explain_metrics
    _(results.explain_metrics).wont_be_nil
  end

  it "works with order and limit" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    results = rand_query_col.order(:population).limit(2).explain analyze: true
    _(results.count).must_equal 2
    _(results.explain_metrics).wont_be_nil
  end

  it "doesn't produce different results from queries without explain" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    # Add some documents
    rand_query_col.add({name: "Alice", population: 100})
    rand_query_col.add({name: "Bob", population: 200})
    rand_query_col.add({name: "Charlie", population: 300})

    # Run identical queries with and without explain(analyze: true)
    results_with_explain = rand_query_col.order(:population).explain analyze: true
    results_without_explain = rand_query_col.order(:population).get

    # Both should return the same document count
    _(results_with_explain.count).must_equal results_without_explain.count

    # Both should return the same document content in the same order
    names_with_explain = results_with_explain.map { |doc| doc[:name] }
    names_without_explain = results_without_explain.map { |doc| doc[:name] }
    _(names_with_explain).must_equal names_without_explain

    # Only the explain query should have metrics
    _(results_with_explain.explain_metrics).wont_be_nil
    _(results_without_explain).wont_respond_to :explain_metrics
  end
end