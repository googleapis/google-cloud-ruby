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

describe Google::Cloud::Spanner::Client, :read, :resume, :buffer_bound, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let :results_header do
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
  let :results_hash1 do
    {
      values: [
        { string_value: "1" },
        { string_value: "Charlie" }
      ]
    }
  end
  let :results_hash2 do
    {
      values: [
        { bool_value: true},
        { string_value: "29" }
      ]
    }
  end
  let :results_hash3 do
    {
      values: [
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" }
      ]
    }
  end
  let :results_hash4 do
    {
      values: [
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" },
      ]
    }
  end
  let :results_hash5 do
    {
      values: [
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ]
    }
  end
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:columns) { [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids] }

  it "returns all rows even when there is no resume_token" do
    no_tokens_enum = [
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_header),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5)
    ].to_enum

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, no_tokens_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: nil, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns

    assert_results results
    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 3
    rows.each { |row| assert_row row }

    shutdown_client! client

    mock.verify
  end

  it "returns all rows even when all requests have resume_token" do
    all_tokens_enum = [
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_header),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1.merge(resume_token: Base64.strict_encode64("xyz123"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2.merge(resume_token: Base64.strict_encode64("xyz124"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3.merge(resume_token: Base64.strict_encode64("xyz125"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4.merge(resume_token: Base64.strict_encode64("xyz126"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5.merge(resume_token: Base64.strict_encode64("xyz127"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1.merge(resume_token: Base64.strict_encode64("xyz128"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2.merge(resume_token: Base64.strict_encode64("xyz129"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3.merge(resume_token: Base64.strict_encode64("xyz130"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4.merge(resume_token: Base64.strict_encode64("xyz131"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5.merge(resume_token: Base64.strict_encode64("xyz132"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1.merge(resume_token: Base64.strict_encode64("xyz133"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2.merge(resume_token: Base64.strict_encode64("xyz134"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3.merge(resume_token: Base64.strict_encode64("xyz135"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4.merge(resume_token: Base64.strict_encode64("xyz137"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5.merge(resume_token: Base64.strict_encode64("xyz128")))
    ].to_enum

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, all_tokens_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: nil, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns

    assert_results results
    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 3
    rows.each { |row| assert_row row }

    shutdown_client! client

    mock.verify
  end

  it "returns buffered responses once it hits the buffer bounds, but will re-raise if there is no resume_token" do
    bounds_with_abort_enum = [
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_header),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1.merge(resume_token: Base64.strict_encode64("xyz123"))),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3),
      GRPC::Unavailable,
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash4),
      Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash5)
    ].to_enum

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, RaiseableEnumerator.new(bounds_with_abort_enum), [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: nil, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns

    assert_results results
    row_enum = results.rows
    # gets the first row
    assert_row row_enum.next
    # gets the second row
    assert_row row_enum.next
    # raises error getting third row, since the buffer bound has been reached
    assert_raises Google::Cloud::UnavailableError do
      results.rows.next
    end

    shutdown_client! client

    mock.verify
  end

  def assert_results results
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 9
    _(results.fields[:id]).must_equal          :INT64
    _(results.fields[:name]).must_equal        :STRING
    _(results.fields[:active]).must_equal      :BOOL
    _(results.fields[:age]).must_equal         :INT64
    _(results.fields[:score]).must_equal       :FLOAT64
    _(results.fields[:updated_at]).must_equal  :TIMESTAMP
    _(results.fields[:birthday]).must_equal    :DATE
    _(results.fields[:avatar]).must_equal      :BYTES
    _(results.fields[:project_ids]).must_equal [:INT64]
  end

  def assert_row row
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    _(row[:id]).must_equal 1
    _(row[:name]).must_equal "Charlie"
    _(row[:active]).must_equal true
    _(row[:age]).must_equal 29
    _(row[:score]).must_equal 0.9
    _(row[:updated_at]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(row[:birthday]).must_equal Date.parse("1950-01-01")
    _(row[:avatar]).must_be_kind_of StringIO
    _(row[:avatar].read).must_equal "image"
    _(row[:project_ids]).must_equal [1, 2, 3]
  end
end
