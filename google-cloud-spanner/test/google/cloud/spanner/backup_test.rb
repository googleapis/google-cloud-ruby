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

describe Google::Cloud::Spanner::Backup, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:backup_grpc) {
    Google::Cloud::Spanner::Admin::Database::V1::Backup.new(
      backup_hash(
        instance_id: instance_id,
        database_id: database_id,
        backup_id: backup_id,
        expire_time: Time.now + 36000,
        create_time: Time.now,
        size_bytes: 1024
      )
    )
  }
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "knows the identifiers" do
    _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    _(backup.project_id).must_equal project
    _(backup.instance_id).must_equal instance_id
    _(backup.database_id).must_equal database_id
    _(backup.backup_id).must_equal backup_id

    _(backup.state).must_equal :READY
    _(backup).must_be :ready?
    _(backup).wont_be :creating?

    _(backup.expire_time).must_be_kind_of Time
    _(backup.create_time).must_be_kind_of Time
    _(backup.size_in_bytes).must_be :>, 0
  end
end
