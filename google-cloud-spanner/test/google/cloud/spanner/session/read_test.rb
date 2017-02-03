# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::Spanner::Session, :read, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
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
      },
     rows: [{
        values: [
          { stringValue: "1" },
          { stringValue: "Charlie" },
          { boolValue: true},
          { stringValue: "29" },
          { numberValue: 0.9 },
          { stringValue: "2017-01-29T00:00:10Z" },
          { stringValue: "1950-01-01" },
          { stringValue: "aW1hZ2U=" },
          { listValue: { values: [ { stringValue: "1"},
                                   { stringValue: "2"},
                                   { stringValue: "3"} ]}}
        ]
      }
    ]}
  end
  let(:results_json) { results_hash.to_json }
  let(:results_grpc) { Google::Spanner::V1::ResultSet.decode_json results_json }

  it "can read all rows" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :read, results_grpc, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), limit: nil]
    session.service.mocked_service = mock

    results = session.read "my-table", columns, streaming: false

    mock.verify

    assert_results results
  end

  it "can read rows by id" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :read, results_grpc, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3]).list_value]), limit: nil]
    session.service.mocked_service = mock

    results = session.read "my-table", columns, id: [1, 2, 3], streaming: false

    mock.verify

    assert_results results
  end

  it "can read rows with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :read, results_grpc, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), limit: 5]
    session.service.mocked_service = mock

    results = session.read "my-table", columns, limit: 5, streaming: false

    mock.verify

    assert_results results
  end

  it "can read just one row with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :read, results_grpc, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value]), limit: 1]
    session.service.mocked_service = mock

    results = session.read "my-table", columns, id: 1, limit: 1, streaming: false

    mock.verify

    assert_results results
  end

  def assert_results results
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.wont_be :streaming?

    results.types.wont_be :nil?
    results.types.must_be_kind_of Hash
    results.types.keys.count.must_equal 9
    results.types[:id].must_equal          :INT64
    results.types[:name].must_equal        :STRING
    results.types[:active].must_equal      :BOOL
    results.types[:age].must_equal         :INT64
    results.types[:score].must_equal       :FLOAT64
    results.types[:updated_at].must_equal  :TIMESTAMP
    results.types[:birthday].must_equal    :DATE
    results.types[:avatar].must_equal      :BYTES
    results.types[:project_ids].must_equal [:INT64]

    results.rows.count.must_equal 1
    row = results.rows.first
    row.must_be_kind_of Hash
    row.keys.must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    row[:id].must_equal 1
    row[:name].must_equal "Charlie"
    row[:active].must_equal true
    row[:age].must_equal 29
    row[:score].must_equal 0.9
    row[:updated_at].must_equal Time.parse("2017-01-29T00:00:10Z")
    row[:birthday].must_equal Date.parse("1950-01-01")
    row[:avatar].must_be_kind_of StringIO
    row[:avatar].read.must_equal "image"
    row[:project_ids].must_equal [1, 2, 3]
  end
end
