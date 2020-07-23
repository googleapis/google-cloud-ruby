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

describe Google::Cloud::Spanner::Backup, :expire_time=, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:backup_grpc) {
    Google::Cloud::Spanner::Admin::Database::V1::Backup.new(
      backup_hash(instance_id: instance_id, database_id: database_id, backup_id: backup_id)
    )
  }
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "update backup expire time" do
    mask = Google::Protobuf::FieldMask.new paths: ["expire_time"]
    mock = Minitest::Mock.new
    mock.expect :update_backup, backup_grpc, [backup: backup_grpc, update_mask: mask]
    spanner.service.mocked_databases = mock

    expire_time = Time.now + 36000
    backup.expire_time = expire_time
    _(backup.expire_time).must_equal expire_time

    mock.verify
  end

  it "reset previous expire time on update error" do
    stub = Object.new

    def stub.update_backup *args
      raise Google::Cloud::InvalidArgumentError.new "invalid expire time"
    end
    backup.service.mocked_databases = stub
    expire_time_was = backup.expire_time

    assert_raises Google::Cloud::Error do
      backup.expire_time = (Time.now - 36000)
    end

    _(backup.expire_time).must_equal expire_time_was
  end
end
