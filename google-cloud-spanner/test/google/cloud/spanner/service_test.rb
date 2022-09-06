# Copyright 2022 Google LLC
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

describe Google::Cloud::Spanner::Service, :mock_spanner  do
    let(:instance_id) { "my-instance-id" }
    let(:database_id) { "my-database-id" }
    let(:session_id) { "session123" }
    let(:default_options) { ::Gapic::CallOptions.new metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
    let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }

    describe ".new" do
      it "sets quota_project with given value" do
        expected_quota_project = "test_quota_project"
        service = Google::Cloud::Spanner::Service.new(
          "test_project", nil, quota_project: expected_quota_project
        )
        assert_equal expected_quota_project, service.quota_project
      end

      it "sets quota_project from credentials if not given from config" do 
        expected_quota_project = "test_quota_project"
        service = Google::Cloud::Spanner::Service.new(
          "test_project", OpenStruct.new(quota_project_id: expected_quota_project)
        )
        assert_equal expected_quota_project, service.quota_project
      end

    end

    describe ".create_session" do
      it "creates session with given database role" do
        mock = Minitest::Mock.new
        session = Google::Cloud::Spanner::V1::Session.new labels: nil, creator_role: "test_role"
        mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: session }, default_options]
        service = Google::Cloud::Spanner::Service.new(
            "test_project", OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new{""}))
        )
        service.mocked_service = mock  
        service.create_session database_path(instance_id, database_id), database_role: "test_role"
        mock.verify
      end
    end

    describe ".batch_create_sessions" do
      it "batch creates session with given database role" do
        mock = Minitest::Mock.new
        session = Google::Cloud::Spanner::V1::Session.new labels: nil, creator_role: "test_role"
        mock.expect :batch_create_sessions, OpenStruct.new(session: Array.new(10) { session_grpc }), [{database: database_path(instance_id, database_id), session_count: 10, session_template: session }, default_options]
        service = Google::Cloud::Spanner::Service.new(
            "test_project", OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new{""}))
        )
        service.mocked_service = mock  
        service.batch_create_sessions database_path(instance_id, database_id), 10, database_role: "test_role"
        mock.verify
      end
    end
end