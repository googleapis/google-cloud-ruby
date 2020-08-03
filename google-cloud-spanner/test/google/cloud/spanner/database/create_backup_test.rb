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

describe Google::Cloud::Spanner::Backup, :create_backup, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:database_grpc) { Google::Cloud::Spanner::Admin::Database::V1::Database.new \
      database_hash(instance_id: instance_id, database_id: database_id)
  }
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.CreateBackupMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata.new(
          progress: { start_time: Time.now }
        ).to_proto
      }
    )
  end
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.CreateBackupMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata.new(
          progress: {
            start_time: Time.now,
            end_time: Time.now + 100,
            progress_percent: 100
          }
        ).to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.Backup",
        value: Google::Cloud::Spanner::Admin::Database::V1::Backup.new.to_proto
      )
    )
  end
  let(:job_grpc_cancel) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.CreateBackupMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata.new(
          progress: {
            start_time: Time.now,
            end_time: Time.now + 100,
            progress_percent: 100
          },
          cancel_time: Time.now + 100
        ).to_proto
      ),
      done: true,
      error: { code: 1, message: 'Backup creation cancelled by the user' }
    )
  end
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }
  let(:expire_time) { Time.now + 36000 }

  it "create a database backup" do
    mock = Minitest::Mock.new
    create_req = {
      database: database_path(instance_id, database_id),
      expire_time: expire_time
    }
    create_res = Gapic::Operation.new(
      job_grpc, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Backup,
      metadata_type:  Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata
    )
    operation_done = Gapic::Operation.new(
      job_grpc_done, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Backup,
      metadata_type:  Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata
    )
    mock.expect :create_backup, create_res, [{
      parent: instance_path(instance_id),
      backup_id: backup_id,
      backup: create_req
    }, nil]
    mock.expect :get_operation, operation_done, [{ name: "1234567890" }, Gapic::CallOptions]
    spanner.service.mocked_databases = mock

    job = database.create_backup backup_id, expire_time

    _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.backup).must_be :nil?
    _(job.start_time).must_be_kind_of Time
    _(job.end_time).must_be :nil?
    _(job.progress_percent).must_equal 0

    job.reload!
    backup = job.backup
    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    _(job.start_time).must_be_kind_of Time
    _(job.end_time).must_be_kind_of Time
    _(job.cancel_time).must_be :nil?
    _(job.progress_percent).must_equal 100

    mock.verify
  end

  it "cancel create database backup job" do
    mock = Minitest::Mock.new
    create_req = {
      database: database_path(instance_id, database_id),
      expire_time: expire_time
    }
    create_res = Gapic::Operation.new(
      job_grpc, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Backup,
      metadata_type:  Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata
    )
    operation_cancel = Gapic::Operation.new(
      job_grpc_cancel, mock,
      result_type: Google::Cloud::Spanner::Admin::Database::V1::Backup,
      metadata_type:  Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata
    )
    mock.expect :create_backup, create_res, [{
      parent: instance_path(instance_id),
      backup_id: backup_id,
      backup: create_req
    }, nil]
    mock.expect :cancel_operation, nil , [{ name: "1234567890" }, Gapic::CallOptions]
    mock.expect :get_operation, operation_cancel, [{ name: "1234567890" }, Gapic::CallOptions]
    spanner.service.mocked_databases = mock

    job = database.create_backup backup_id, expire_time

    _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job
    _(job).wont_be :done?
    _(job.cancel).must_be_nil

    job.reload!
    _(job).must_be :done?
    _(job.start_time).must_be_kind_of Time
    _(job.end_time).must_be_kind_of Time
    _(job.cancel_time).must_be_kind_of Time
    _(job.progress_percent).must_equal 100

    mock.verify
  end

  it "raise an error on create database backup for invalid expire time" do
    stub = Object.new

    def stub.create_backup *args
      raise Google::Cloud::InvalidArgumentError.new "invalid expire time"
    end

    spanner.service.mocked_databases = stub

    assert_raises Google::Cloud::Error do
      database.create_backup backup_id, Time.now - 36000
    end
  end
end
