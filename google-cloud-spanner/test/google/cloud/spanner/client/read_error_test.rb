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

describe Google::Cloud::Spanner::Client, :read, :error, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:default_options) { ::Gapic::CallOptions.new metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash1 do
    {
      metadata: {
        row_type: {
          fields: [
            { name: "id",          type: { code: :INT64 } },
            { name: "name",        type: { code: :STRING } },
            { name: "active",      type: { code: :BOOL } },
            { name: "age",         type: { code: :INT64 } },
            { name: "score",       type: { code: :FLOAT64 } },
            { name: "updated_at",  type: { code: :TIMESTAMP } },
            { name: "birthday",    type: { code: :DATE} },
            { name: "avatar",      type: { code: :BYTES } },
            { name: "project_ids", type: { code: :ARRAY,
                                           array_element_type: { code: :INT64 } } }
          ]
        }
      }
    }
  end
  let :results_hash2 do
    {
      values: [
        { string_value: "1" },
        { string_value: "Charlie" }
      ],
      resume_token: Base64.strict_encode64("xyz890")
    }
  end
  let :results_hash3 do
    {
      values: [
        { bool_value: true},
        { string_value: "29" }
      ]
    }
  end
  let :results_hash4 do
    {
      values: [
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" }
      ],
      resume_token: Base64.strict_encode64("abc123")
    }
  end
  let :results_hash5 do
    {
      values: [
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" },
      ]
    }
  end
  let :results_hash6 do
    {
      values: [
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ]
    }
  end
  let(:results_enum1) do
    [
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5),
      GRPC::InvalidArgument,
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash6)
    ].to_enum
  end
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  it "raises unhandled errors" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, RaiseableEnumerator.new(results_enum1), [{
      session: session_grpc.name,
      table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true), transaction: nil, index: nil, limit: nil, resume_token: nil, partition_token: nil,
      request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    assert_raises Google::Cloud::InvalidArgumentError do
      client.read("my-table", columns).rows.to_a
    end

    shutdown_client! client

    mock.verify
  end
end
