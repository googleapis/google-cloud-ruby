# Copyright 2017 Google LLC
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

describe Google::Cloud::Spanner::Client, :read, :resume, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash1 do
    {
      metadata: {
        rowType: {
          fields: [
            { name: "id",          type: { code: "INT64" } },
            { name: "name",        type: { code: "STRING" } },
            { name: "active",      type: { code: "BOOL" } },
            { name: "age",         type: { code: "INT64" } },
            { name: "score",       type: { code: "FLOAT64" } },
            { name: "updated_at",  type: { code: "TIMESTAMP" } },
            { name: "birthday",    type: { code: "DATE"} },
            { name: "avatar",      type: { code: "BYTES" } },
            { name: "project_ids", type: { code: "ARRAY",
                                           arrayElementType: { code: "INT64" } } }
          ]
        }
      }
    }
  end
  let :results_hash2 do
    {
      values: [
        { stringValue: "1" },
        { stringValue: "Charlie" }
      ],
      resumeToken: Base64.strict_encode64("xyz890")
    }
  end
  let :results_hash3 do
    {
      values: [
        { boolValue: true},
        { stringValue: "29" }
      ]
    }
  end
  let :results_hash4 do
    {
      values: [
        { numberValue: 0.9 },
        { stringValue: "2017-01-02T03:04:05.060000000Z" }
      ],
      resumeToken: Base64.strict_encode64("abc123")
    }
  end
  let :results_hash5 do
    {
      values: [
        { stringValue: "1950-01-01" },
        { stringValue: "aW1hZ2U=" },
      ]
    }
  end
  let :results_hash6 do
    {
      values: [
        { listValue: { values: [ { stringValue: "1"},
                                 { stringValue: "2"},
                                 { stringValue: "3"} ]}}
      ]
    }
  end
  let(:results_enum1) do
    [
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash1.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash2.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash3.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash4.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash5.to_json),
      GRPC::Unavailable,
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash6.to_json)
    ].to_enum
  end
  let(:results_enum2) do
    [
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash1.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash5.to_json),
      Google::Spanner::V1::PartialResultSet.decode_json(results_hash6.to_json)
    ].to_enum
  end
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  it "resumes broken response streams" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    mock.expect :streaming_read, RaiseableEnumerator.new(results_enum1), [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: nil, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    mock.expect :streaming_read, RaiseableEnumerator.new(results_enum2), [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: nil, index: nil, limit: nil, resume_token: "abc123", partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns

    assert_results results

    shutdown_client! client

    mock.verify
  end

  def assert_results results
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 9
    results.fields[:id].must_equal          :INT64
    results.fields[:name].must_equal        :STRING
    results.fields[:active].must_equal      :BOOL
    results.fields[:age].must_equal         :INT64
    results.fields[:score].must_equal       :FLOAT64
    results.fields[:updated_at].must_equal  :TIMESTAMP
    results.fields[:birthday].must_equal    :DATE
    results.fields[:avatar].must_equal      :BYTES
    results.fields[:project_ids].must_equal [:INT64]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    row[:id].must_equal 1
    row[:name].must_equal "Charlie"
    row[:active].must_equal true
    row[:age].must_equal 29
    row[:score].must_equal 0.9
    row[:updated_at].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    row[:birthday].must_equal Date.parse("1950-01-01")
    row[:avatar].must_be_kind_of StringIO
    row[:avatar].read.must_equal "image"
    row[:project_ids].must_equal [1, 2, 3]
  end
end
