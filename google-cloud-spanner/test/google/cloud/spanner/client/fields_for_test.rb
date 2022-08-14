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

describe Google::Cloud::Spanner::Client, :fields_for, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:default_options) { ::Gapic::CallOptions.new metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash do
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
  let(:results_grpc) { Google::Cloud::Spanner::V1::PartialResultSet.new results_hash }
  let(:results_enum) { Array(results_grpc).to_enum }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  it "can get a table's fields" do
    mock = Minitest::Mock.new
   mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    spanner.service.mocked_service = mock
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users WHERE 1 = 0", options: default_options

    fields = client.fields_for "users"

    shutdown_client! client

    mock.verify

    assert_fields fields
  end

  def assert_fields fields
    _(fields).wont_be :nil?
    _(fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(fields.keys.count).must_equal 9
    _(fields[:id]).must_equal          :INT64
    _(fields[:name]).must_equal        :STRING
    _(fields[:active]).must_equal      :BOOL
    _(fields[:age]).must_equal         :INT64
    _(fields[:score]).must_equal       :FLOAT64
    _(fields[:updated_at]).must_equal  :TIMESTAMP
    _(fields[:birthday]).must_equal    :DATE
    _(fields[:avatar]).must_equal      :BYTES
    _(fields[:project_ids]).must_equal [:INT64]
  end
end
