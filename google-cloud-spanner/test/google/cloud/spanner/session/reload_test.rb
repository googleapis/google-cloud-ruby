# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Session, :reload, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }

  let(:labels) { { "env" => "production" } }
  let(:session_grpc_labels) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id), labels: labels }
  let(:session_labels) { Google::Cloud::Spanner::Session.from_grpc session_grpc_labels, spanner.service }

  it "can reload itself" do
    mock = Minitest::Mock.new
    mock.expect :get_session, session_grpc, [{ name: session_grpc.name }, default_options]
    session.service.mocked_service = mock

    _(session).must_be_kind_of Google::Cloud::Spanner::Session

    session.reload!

    mock.verify

    _(session).must_be_kind_of Google::Cloud::Spanner::Session

    _(session.project_id).must_equal "test"
    _(session.instance_id).must_equal "my-instance-id"
    _(session.database_id).must_equal "my-database-id"
    _(session.session_id).must_equal "session123"
  end

  it "can recreate itself if error is raised on reload" do
    mock = Minitest::Mock.new
    def mock.get_session *args
      grpc_error = GRPC::NotFound.new 5, "not found"
      raise Google::Cloud::Error.from_error grpc_error
    end
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    session.service.mocked_service = mock

    _(session).must_be_kind_of Google::Cloud::Spanner::Session

    session.reload!

    mock.verify

    _(session).must_be_kind_of Google::Cloud::Spanner::Session

    _(session.project_id).must_equal "test"
    _(session.instance_id).must_equal "my-instance-id"
    _(session.database_id).must_equal "my-database-id"
    _(session.session_id).must_equal "session123"
  end

  it "can recreate itself with labels if error on reload" do
    mock = Minitest::Mock.new
    def mock.get_session *args
      grpc_error = GRPC::NotFound.new 5, "not found"
      raise Google::Cloud::Error.from_error grpc_error
    end
    mock.expect :create_session, session_grpc_labels, [{ database: database_path(instance_id, database_id), session: Google::Cloud::Spanner::V1::Session.new(labels: labels) }, default_options]
    session_labels.service.mocked_service = mock

    _(session_labels).must_be_kind_of Google::Cloud::Spanner::Session

    session_labels.reload!

    mock.verify

    _(session_labels).must_be_kind_of Google::Cloud::Spanner::Session

    _(session_labels.project_id).must_equal "test"
    _(session_labels.instance_id).must_equal "my-instance-id"
    _(session_labels.database_id).must_equal "my-database-id"
    _(session_labels.session_id).must_equal "session123"
  end
end
