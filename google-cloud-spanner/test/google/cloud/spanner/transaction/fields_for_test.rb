# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Transaction, :fields_for, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:transaction) { Google::Cloud::Spanner::Transaction.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash do
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
  let(:results_json) { results_hash.to_json }
  let(:results_grpc) { Google::Spanner::V1::PartialResultSet.decode_json results_json }
  let(:results_enum) { Array(results_grpc).to_enum }

  it "can get a table's fields" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "SELECT * FROM users WHERE 1 = 0", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    fields = transaction.fields_for "users"

    mock.verify

    assert_fields fields
  end

  def assert_fields fields
    fields.wont_be :nil?
    fields.must_be_kind_of Google::Cloud::Spanner::Fields
    fields.keys.count.must_equal 9
    fields[:id].must_equal          :INT64
    fields[:name].must_equal        :STRING
    fields[:active].must_equal      :BOOL
    fields[:age].must_equal         :INT64
    fields[:score].must_equal       :FLOAT64
    fields[:updated_at].must_equal  :TIMESTAMP
    fields[:birthday].must_equal    :DATE
    fields[:avatar].must_equal      :BYTES
    fields[:project_ids].must_equal [:INT64]
  end
end
