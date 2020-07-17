# Copyright 2020 Google LLC
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

describe Google::Cloud::Spanner::Backup, :restore_database, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:backup_grpc) {
    Google::Cloud::Spanner::Admin::Database::V1::Backup.new(
      backup_hash(instance_id: instance_id, database_id: database_id, backup_id: backup_id)
    )
  }
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.RestoreDatabaseRequest",
        value: ""
      }
    )
  end
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.RestoreDatabaseMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.Database",
        value: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata.new.to_proto
      )
    )
  end
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "restore a database in the same instance as the backup instance" do
    mock = Minitest::Mock.new
    restore_res = Gapic::Operation.new(
      job_grpc, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
      metadata_type: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata,
    )
    operation_done = Gapic::Operation.new(
      job_grpc_done, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
      metadata_type: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata,
    )
    mock.expect :restore_database, restore_res, [
      parent: instance_path(instance_id),
      database_id: "restored-database",
      backup: backup_path(instance_id, backup_id)
    ]
    mock.expect :get_operation, operation_done, [{ name: "1234567890" }, Gapic::CallOptions]
    spanner.service.mocked_databases = mock

    job = backup.restore "restored-database"

    _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Restore::Job
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

  it "restore a database in a different instance than the backup instance" do
    mock = Minitest::Mock.new
    restore_res = Gapic::Operation.new(
      job_grpc, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
      metadata_type: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata,
    )
    operation_done = Gapic::Operation.new(
      job_grpc_done, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
      metadata_type: Google::Cloud::Spanner::Admin::Database::V1::RestoreDatabaseMetadata,
    )
    mock.expect :restore_database, restore_res, [
      parent: instance_path("other-instance"),
      database_id: "restored-database",
      backup: backup_path(instance_id, backup_id)
    ]
    mock.expect :get_operation, operation_done, [{ name: "1234567890" } , Gapic::CallOptions]
    spanner.service.mocked_databases = mock

    job = backup.restore "restored-database", instance_id: "other-instance"

    _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Restore::Job
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
end
