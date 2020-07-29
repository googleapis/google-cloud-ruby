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

describe Google::Cloud::Spanner::Instance, :backup_operations, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:backup_grpc) { Google::Cloud::Spanner::Admin::Database::V1::Backup.new backup_hash }
  let(:job_name) { "1234567890" }
  let(:job_hash) do
    {
      name: job_name,
      metadata: {
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.CreateBackupMetadata",
        value: ""
      }
    }
  end
  let(:job_grpc) { Google::Longrunning::Operation.new job_hash }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.CreateBackupMetadata",
        value: Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.backup",
        value: backup_grpc.to_proto
      )
    )
  end
  let(:jobs_hash) do
    3.times.map { job_hash }
  end
  let(:first_page) do
    h = { operations: jobs_hash }
    h[:next_page_token] = "next_page_token"
    Google::Cloud::Spanner::Admin::Database::V1::ListBackupOperationsResponse.new h
  end
  let(:second_page) do
    h = { operations: jobs_hash }
    h[:next_page_token] = "second_page_token"
    Google::Cloud::Spanner::Admin::Database::V1::ListBackupOperationsResponse.new h
  end
  let(:last_page) do
    h = { operations: jobs_hash }
    h[:operations].pop
    Google::Cloud::Spanner::Admin::Database::V1::ListBackupOperationsResponse.new h
  end

  it "list backup operations" do
    list_res =  MockPagedEnumerable.new([first_page])

    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: nil, page_token: nil }, nil]
    3.times do
      gapic_operation = Gapic::Operation.new job_grpc_done, mock
      mock.expect :get_operation, gapic_operation, [{ name: job_name }, Gapic::CallOptions]
    end
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations
    _(jobs.size).must_equal 3

    jobs.each do |job|
      _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job
      _(job).wont_be :done?
      _(job).wont_be :error?
      _(job.error).must_be :nil?
      _(job.backup).must_be :nil?
      job.reload!

      backup = job.backup
      _(backup).wont_be :nil?
      _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    end

    mock.verify
  end

  it "paginates backup operations with page size" do
    list_res =  MockPagedEnumerable.new([first_page])

    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: 3, page_token: nil }, nil]
    3.times do
      gapic_operation = Gapic::Operation.new job_grpc_done, mock
      mock.expect :get_operation, gapic_operation, [{ name: job_name }, Gapic::CallOptions]
    end
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations page_size: 3
    _(jobs.size).must_equal 3

    jobs.each do |job|
      _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job
      _(job).wont_be :done?
      _(job).wont_be :error?
      _(job.error).must_be :nil?
      _(job.backup).must_be :nil?
      job.reload!

      backup = job.backup
      _(backup).wont_be :nil?
      _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    end

    mock.verify
  end

  it "paginates backup operations with next? and next" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: nil, page_token: nil }, nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations

    _(jobs.size).must_equal 3
    _(jobs.next?).must_equal true
    _(jobs.next.size).must_equal 2
    _(jobs.next?).must_equal false

    mock.verify
  end

  it "paginates backup operations with all" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: nil, page_token: nil }, nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations.all.to_a

    mock.verify

    _(jobs.size).must_equal 5
  end

  it "paginates backup operations with all and page size" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: 3, page_token: nil }, nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations(page_size: 3).all.to_a

    mock.verify

    _(jobs.size).must_equal 5
  end

  it "iterates backup operations with all using Enumerator" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: nil, page_size: nil, page_token: nil }, nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations.all.take(5)

    mock.verify

    _(jobs.size).must_equal 5
  end

  it "paginates backup operations with filter" do
    filter = 'metadata.@type:CreateBackupMetadata'
    list_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: filter, page_size: nil, page_token: nil }, nil]
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations filter: filter

    mock.verify

    _(jobs.size).must_equal 3
  end

  it "paginates backup operations with filter and page size" do
    filter = 'metadata.@type:CreateBackupMetadata'
    list_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backup_operations, list_res, [{ parent: instance_path(instance_id), filter: filter, page_size: 3, page_token: nil }, nil]
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    instance.service.mocked_databases = mock

    jobs = instance.backup_operations filter: filter, page_size: 3

    mock.verify

    _(jobs.size).must_equal 3
  end
end
