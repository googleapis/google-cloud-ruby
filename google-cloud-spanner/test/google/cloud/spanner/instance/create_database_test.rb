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

describe Google::Cloud::Spanner::Instance, :create_database, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.UpdateDatabaseDdlRequest",
        value: ""
      }
    )
  end
  let(:database_grpc) do
    Google::Cloud::Spanner::Admin::Database::V1::Database.new(
      name: "projects/bustling-kayak-91516/instances/my-new-instance",
      state: :READY,
      create_time: Time.now
    )
  end
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.CreateDatabaseMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.Database",
        value: database_grpc.to_proto
      )
    )
  end

  it "creates an empty database" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    mock = Minitest::Mock.new
    create_res = \
      Gapic::Operation.new(
        job_grpc, mock,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
    )
    operation_done = \
      Gapic::Operation.new(
        job_grpc_done, mock,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
      )
    mock.expect :create_database, create_res, [{ parent: instance_path(instance_id), create_statement: "CREATE DATABASE `#{database_id}`", extra_statements: [] }, nil]
    mock.expect :get_operation, operation_done, [{ name: "1234567890" }, Gapic::CallOptions]
    instance.service.mocked_databases = mock

    job = instance.create_database database_id

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.database).must_be :nil?

    job.reload!
    database = job.database

    _(database).wont_be :nil?
    _(database).must_be_kind_of Google::Cloud::Spanner::Database

    mock.verify
  end

  it "creates a database with additional statements" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    create_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
      )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [{ parent: instance_path(instance_id), create_statement: "CREATE DATABASE `#{database_id}`", extra_statements: ["CREATE TABLE table1;", "CREATE TABLE table2;"] }, nil]
    instance.service.mocked_databases = mock

    job = instance.create_database database_id, statements: [
      "CREATE TABLE table1;",
      "CREATE TABLE table2;"
    ]

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end
end
