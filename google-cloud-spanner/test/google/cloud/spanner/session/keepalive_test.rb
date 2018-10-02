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

describe Google::Cloud::Spanner::Session, :keepalive, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash do
    {
      metadata: {
        rowType: {
          fields: [
            { type: { code: "INT64" } }
          ]
        }
      },
      values: [
        { stringValue: "1" }
      ]
    }
  end
  let(:results_json) { results_hash.to_json }
  let(:results_grpc) { Google::Spanner::V1::PartialResultSet.decode_json results_json }
  let(:results_enum) { Array(results_grpc).to_enum }

  let(:labels) { { "env" => "production" } }
  let(:session_grpc_labels) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id), labels: labels }
  let(:session_labels) { Google::Cloud::Spanner::Session.from_grpc session_grpc_labels, spanner.service }

  it "can call keepalive" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: nil, options: default_options]
    session.service.mocked_service = mock

    session.keepalive!

    mock.verify
  end

  it "can recreate itself if error is raised on keepalive" do
    mock = Minitest::Mock.new
    def results_enum.peek
      raise GRPC::NotFound.new 5, "not found"
    end
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: nil, options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    session.service.mocked_service = mock

    result = session.keepalive!
    result.must_equal false
    mock.verify
  end

  it "can recreate itself with labels if error is raised on keepalive" do
    mock = Minitest::Mock.new
    def results_enum.peek
      raise GRPC::NotFound.new 5, "not found"
    end
    mock.expect :execute_streaming_sql, results_enum, [session_labels.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: nil, options: default_options]
    mock.expect :create_session, session_grpc_labels, [database_path(instance_id, database_id), session: Google::Spanner::V1::Session.new(labels: labels), options: default_options]
    session_labels.service.mocked_service = mock

    result = session_labels.keepalive!
    result.must_equal false
    mock.verify
  end
end
