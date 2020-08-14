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

describe Google::Cloud::Spanner::Client, :execute_query, :resume, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let :metadata_result do
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
  let :partial_row_1 do
    {
      values: [
        { string_value: "1" },
        { string_value: "Charlie" }
      ],
      resume_token: "xyz890"
    }
  end
  let :partial_row_2 do
    {
      values: [
        { bool_value: true},
        { string_value: "29" }
      ]
    }
  end
  let :partial_row_3 do
    {
      values: [
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" }
      ],
      resume_token: "abc123"
    }
  end
  let :partial_row_4 do
    {
      values: [
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" },
      ]
    }
  end
  let :partial_row_5 do
    {
      values: [
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ]
    }
  end
  let :full_row do
    {
      values: [
        { string_value: "1" },
        { string_value: "Charlie" },
        { bool_value: true},
        { string_value: "29" },
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" },
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" },
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ],
    }
  end

  let(:service_mock) { Minitest::Mock.new }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  before do
    spanner.service.mocked_service = service_mock
  end

  after do
    shutdown_client! client
  end

  describe "when a resume token is available" do
    it "resumes broken response streams" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_1),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_2),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_3),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_4),
        GRPC::Unavailable,
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_5)
      ].to_enum
      resulting_stream_2 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_4),
        Google::Cloud::Spanner::V1::PartialResultSet.new(partial_row_5)
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_2), session_grpc.name, "SELECT * FROM users", resume_token: "abc123", options: default_options

      results = client.execute_query "SELECT * FROM users"

      assert_results results
      service_mock.verify
    end
  end

  describe "when a resume token is NOT available" do
    it "restarts the request when an unavailable error is returned" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        GRPC::Unavailable,
      ].to_enum
      resulting_stream_2 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(full_row)
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_2), session_grpc.name, "SELECT * FROM users", options: default_options

      results = client.execute_query "SELECT * FROM users"

      assert_results results
      service_mock.verify
    end

    it "restarts the request when an aborted error is returned" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        GRPC::Aborted,
      ].to_enum
      resulting_stream_2 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(full_row)
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_2), session_grpc.name, "SELECT * FROM users", options: default_options

      results = client.execute_query "SELECT * FROM users"

      assert_results results
      service_mock.verify
    end

    it "restarts the request when a EOS internal error is returned" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        GRPC::Internal.new("INTERNAL: Received unexpected EOS on DATA frame from server"),
      ].to_enum
      resulting_stream_2 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(full_row)
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_2), session_grpc.name, "SELECT * FROM users", options: default_options

      results = client.execute_query "SELECT * FROM users"

      assert_results results
      service_mock.verify
    end

    it "restarts the request when a RST_STREAM internal error is returned" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        GRPC::Internal.new("INTERNAL: Received RST_STREAM with code 2 (Internal server error)"),
      ].to_enum
      resulting_stream_2 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(full_row)
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_2), session_grpc.name, "SELECT * FROM users", options: default_options

      results = client.execute_query "SELECT * FROM users"

      assert_results results
      service_mock.verify
    end

    it "bubbles up the error when a generic internal error is returned" do
      resulting_stream_1 = [
        Google::Cloud::Spanner::V1::PartialResultSet.new(metadata_result),
        GRPC::Internal.new("INTERNAL: Generic (Internal server error)"),
      ].to_enum
      service_mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      expect_execute_streaming_sql RaiseableEnumerator.new(resulting_stream_1), session_grpc.name, "SELECT * FROM users", options: default_options

      assert_raises Google::Cloud::Error do
        results = client.execute_query "SELECT * FROM users"
        results.rows.to_a # gets results from the enumerator
      end
    end
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

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
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
