# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Project, :query, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM `some_project.some_dataset.users`" }
  let(:job_id) { "job_9876543210" }

  it "queries the data using stateless jobs.query" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    query_request_gapi = Google::Apis::BigqueryV2::QueryRequest.new(
      query: query,
      use_query_cache: true,
      use_legacy_sql: false
    )
    
    # Mock the stateless query response
    query_resp_gapi = Google::Apis::BigqueryV2::QueryResponse.new(
      job_complete: true,
      schema: Google::Apis::BigqueryV2::TableSchema.new(
        fields: [
          Google::Apis::BigqueryV2::TableFieldSchema.new(name: "name", type: "STRING"),
          Google::Apis::BigqueryV2::TableFieldSchema.new(name: "age", type: "INTEGER"),
          Google::Apis::BigqueryV2::TableFieldSchema.new(name: "score", type: "FLOAT"),
          Google::Apis::BigqueryV2::TableFieldSchema.new(name: "active", type: "BOOLEAN")
        ]
      ),
      rows: [
        Google::Apis::BigqueryV2::TableRow.new(f: [
          Google::Apis::BigqueryV2::TableCell.new(v: "FirstName"),
          Google::Apis::BigqueryV2::TableCell.new(v: "36"),
          Google::Apis::BigqueryV2::TableCell.new(v: "7.65"),
          Google::Apis::BigqueryV2::TableCell.new(v: "true")
        ])
      ],
      total_rows: 1
    )

    mock.expect :query_job, query_resp_gapi do |p, req|
      p == project && req.query == query && req.use_query_cache == true
    end

    data = bigquery.query query
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 1
    _(data[0][:name]).must_equal "FirstName"
    _(data[0][:age]).must_equal 36
  end

  it "falls back to stateful jobs.insert when priority is BATCH" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    # When priority is BATCH, it should NOT be stateless
    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.priority = "BATCH"
    
    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil, format_options_use_int64_timestamp: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}, format_options_use_int64_timestamp: true

    data = bigquery.query query do |q|
      q.priority = "BATCH"
    end
    mock.verify
    _(data.class).must_equal Google::Cloud::Bigquery::Data
  end
end
