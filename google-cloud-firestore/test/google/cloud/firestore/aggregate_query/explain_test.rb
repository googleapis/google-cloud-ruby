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

require "helper"

describe Google::Cloud::Firestore::AggregateQuery, :explain_options, :mock_firestore do
  let(:query_path) { "projects/#{project}/databases/(default)/documents" }
  let(:query) { Google::Cloud::Firestore::Query.start nil, query_path, firestore }
  let(:aggregate_query) { query.aggregate_query }

  let(:plan_summary_grpc) { Google::Cloud::Firestore::V1::PlanSummary.new(indexes_used: []) }
  let(:execution_stats_grpc) { Google::Cloud::Firestore::V1::ExecutionStats.new(results_returned: 1, read_operations: 5) }
  let(:explain_metrics_grpc) { Google::Cloud::Firestore::V1::ExplainMetrics.new(plan_summary: plan_summary_grpc, execution_stats: execution_stats_grpc) }
  let(:explain_metrics_planning_only_grpc) { Google::Cloud::Firestore::V1::ExplainMetrics.new(plan_summary: plan_summary_grpc) }

  let(:aggregation_result_grpc) do
    Google::Cloud::Firestore::V1::AggregationResult.new(
      aggregate_fields: {
        "total" => Google::Cloud::Firestore::V1::Value.new(integer_value: 5)
      }
    )
  end
  let(:read_time) { Time.now }
  let(:read_time_grpc) { Google::Cloud::Firestore::Convert.time_to_timestamp read_time }

  let(:response_with_metrics_and_result) do
    [
      Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
        result: aggregation_result_grpc,
        read_time: read_time_grpc
      ),
      Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
        explain_metrics: explain_metrics_grpc
      )
    ].to_enum
  end

  let(:response_with_planning_metrics_only) do
    [
      Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
        explain_metrics: explain_metrics_planning_only_grpc
      )
    ].to_enum
  end

  let(:empty_response) { [].to_enum }

  describe "AggregateQuery#explain" do
    it "calls service with analyze: false by default" do
      expected_explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

      request = Google::Cloud::Firestore::V1::RunAggregationQueryRequest.new(
        parent: query_path,
        structured_aggregation_query: aggregate_query.to_grpc,
        explain_options: expected_explain_options
      )

      firestore_mock.expect :run_aggregation_query, response_with_planning_metrics_only, [request]

      explain_result = aggregate_query.explain
      _(explain_result).must_be_kind_of Google::Cloud::Firestore::AggregateQueryExplainResult
      _(explain_result.explain_metrics).must_equal explain_metrics_planning_only_grpc
      _(explain_result.snapshot).must_be_nil
    end

    it "calls service with analyze: true" do
      expected_explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)
      request = Google::Cloud::Firestore::V1::RunAggregationQueryRequest.new(
        parent: query_path,
        structured_aggregation_query: aggregate_query.to_grpc,
        explain_options: expected_explain_options
      )

      firestore_mock.expect :run_aggregation_query, response_with_metrics_and_result, [request]

      explain_result = aggregate_query.explain analyze: true
      _(explain_result).must_be_kind_of Google::Cloud::Firestore::AggregateQueryExplainResult
      _(explain_result.explain_metrics).must_equal explain_metrics_grpc
      _(explain_result.snapshot).wont_be_nil
      _(explain_result.snapshot.get("total")).must_equal 5
    end

    it "raises ArgumentError for invalid analyze option" do
      expect { aggregate_query.explain analyze: "not_a_boolean" }.must_raise ArgumentError
      expect { aggregate_query.explain analyze: nil }.must_raise ArgumentError
    end
  end

  describe "AggregateQueryExplainResult" do
    it "initializes correctly" do
      explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_metrics_and_result
      _(explain_result.metrics_fetched?).must_equal false
    end

    describe "#explain_metrics" do
      it "extracts metrics when present" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_metrics_and_result
        _(explain_result.explain_metrics).must_equal explain_metrics_grpc
        _(explain_result.metrics_fetched?).must_equal true
      end

      it "returns nil if no metrics in response" do
        response_with_result_only = [
          Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
              result: aggregation_result_grpc,
              read_time: read_time_grpc
          )
        ].to_enum

        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_result_only
        _(explain_result.explain_metrics).must_be_nil
        _(explain_result.metrics_fetched?).must_equal true
      end

      it "caches metrics after first call" do
        mock_enum = Minitest::Mock.new
        # Expect each to be called only once since `AggregateQueryExplainResult` caches the results internally
        mock_enum.expect :each, response_with_planning_metrics_only

        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new mock_enum
        explain_result.explain_metrics # First call
        explain_result.explain_metrics # Second call, should use cache

        mock_enum.verify
      end
    end

    describe "#snapshot" do
      it "constructs snapshot if result is present (simulating analyze: true)" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_metrics_and_result
        snapshot = explain_result.snapshot
        _(snapshot).must_be_kind_of Google::Cloud::Firestore::AggregateQuerySnapshot
        _(snapshot.get("total")).must_equal 5
        _(explain_result.metrics_fetched?).must_equal true
      end

      it "returns nil if no result in response (simulating analyze: false or empty result)" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_planning_metrics_only
        _(explain_result.snapshot).must_be_nil
        _(explain_result.metrics_fetched?).must_equal true
      end

      it "caches snapshot after first call" do
        mock_enum = Minitest::Mock.new
        # Expect each to be called only once since `AggregateQueryExplainResult` caches the results internally
        mock_enum.expect :each, response_with_metrics_and_result

        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new mock_enum
        explain_result.snapshot # First call
        explain_result.snapshot # Second call, should use cache

        mock_enum.verify
      end
    end

    describe "#metrics_fetched?" do
      it "is false initially" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new empty_response
        _(explain_result.metrics_fetched?).must_equal false
      end

      it "is true after calling explain_metrics" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_planning_metrics_only
        explain_result.explain_metrics
        _(explain_result.metrics_fetched?).must_equal true
      end

      it "is true after calling snapshot" do
        explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new response_with_metrics_and_result
        explain_result.snapshot
        _(explain_result.metrics_fetched?).must_equal true
      end
    end

    it "handles single response object in result stream correctly" do
      single_part_response = [
        Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
          result: aggregation_result_grpc,
          read_time: read_time_grpc,
          explain_metrics: explain_metrics_grpc
        )
      ].to_enum

      explain_result = Google::Cloud::Firestore::AggregateQueryExplainResult.new single_part_response

      # Access snapshot first
      snapshot = explain_result.snapshot
      _(snapshot).wont_be_nil
      _(snapshot.get("total")).must_equal 5

      # Then access metrics
      metrics = explain_result.explain_metrics
      _(metrics).must_equal explain_metrics_grpc

      _(explain_result.metrics_fetched?).must_equal true
    end
  end
end