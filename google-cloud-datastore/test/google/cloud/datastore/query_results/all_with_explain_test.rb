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

describe Google::Cloud::Datastore::Dataset, :all_with_explain, :mock_datastore do
  let(:explain_options) { { analyze: true } }
  let(:query_1) { Google::Cloud::Datastore::Query.new.kind("User").to_grpc }
  let(:run_query_res_1) do
    run_query_res_entities_1 = 2.times.map do
      Google::Cloud::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::V1::Entity.new(
          key: Google::Cloud::Datastore::V1::Key.new(
            partition_id: Google::Cloud::Datastore::V1::PartitionId.new(project_id: project),
            path: [Google::Cloud::Datastore::V1::Key::PathElement.new(kind: "User")]
          )
        )
      )
    end
    Google::Cloud::Datastore::V1::RunQueryResponse.new(
      batch: Google::Cloud::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities_1,
        more_results: :NOT_FINISHED,
        end_cursor: "second-page-cursor".force_encoding("ASCII-8BIT")
      )
    )
  end
  let(:query_2) do 
    Google::Cloud::Datastore::Query.new.kind("User").start(
      Google::Cloud::Datastore::Cursor.from_grpc("second-page-cursor")
    ).to_grpc
  end
  let(:run_query_res_2) do
    run_query_res_entities_2 = 2.times.map do
      Google::Cloud::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::V1::Entity.new(
          key: Google::Cloud::Datastore::V1::Key.new(
            partition_id: Google::Cloud::Datastore::V1::PartitionId.new(project_id: project),
            path: [Google::Cloud::Datastore::V1::Key::PathElement.new(kind: "User")]
          )
        )
      )
    end
    Google::Cloud::Datastore::V1::RunQueryResponse.new(
      batch: Google::Cloud::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities_2,
        more_results: :NO_MORE_RESULTS,
        end_cursor: nil
      ),
      explain_metrics: Google::Cloud::Datastore::V1::ExplainMetrics.new(
        plan_summary: Google::Cloud::Datastore::V1::PlanSummary.new(
          indexes_used: []
        ),
        execution_stats: Google::Cloud::Datastore::V1::ExecutionStats.new(
          results_returned: 4,
          execution_duration: { "seconds" => 0, "nanos" => 20_000_000 },
          read_operations: 4
        )
      )
    )
  end

  before do
    dataset.service.mocked_service = Minitest::Mock.new
    dataset.service.mocked_service.expect :run_query, run_query_res_1,
      project_id: project, 
      partition_id: nil, 
      read_options: nil, 
      query: query_1, 
      gql_query: nil, 
      database_id: default_database,
      explain_options: Google::Cloud::Datastore::V1::ExplainOptions.new(analyze: true)

    dataset.service.mocked_service.expect :run_query, run_query_res_2,
      project_id: project, 
      partition_id: nil, 
      read_options: nil, 
      query:  query_2, 
      gql_query: nil, 
      database_id: default_database,
      explain_options: Google::Cloud::Datastore::V1::ExplainOptions.new(analyze: true)
  end

  after do
    dataset.service.mocked_service.verify
  end

  it "keeps explain_options for subsequent API calls" do
    results_1 = dataset.run dataset.query("User"), explain_options: explain_options
    results_2 = results_1.next
     _(results_2.explain_metrics).wont_be :nil?
  end
end
