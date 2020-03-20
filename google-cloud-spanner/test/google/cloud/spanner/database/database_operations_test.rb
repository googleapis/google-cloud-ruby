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

describe Google::Cloud::Spanner::Database, :database_operations, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:databases_grpc) {
    Google::Spanner::Admin::Database::V1::Database.new database_hash(
      instance_id: instance_id, database_id: database_id)
  }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc databases_grpc, spanner.service }
  let(:database_grpc) { Google::Spanner::Admin::Database::V1::Database.new database_hash }
  let(:database_metadata_filter) {
    format(
      Google::Cloud::Spanner::Database::DATBASE_OPERATION_METADAT_FILTER_TEMPLATE,
      database_id: database_id
    )
  }
  let(:job_name) { "1234567890" }
  let(:job_hash) do
    {
      name: job_name,
      metadata: {
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.CreateDatabaseMetadata",
        value: Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata.new.to_proto
      }
    }
  end
  let(:job_grpc) { Google::Longrunning::Operation.new job_hash }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.database.v1.CreateDatabaseMetadata",
        value: Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.spanner.admin.database.v1.Database",
        value: database_grpc.to_proto
      )
    )
  end
  let(:jobs_hash) do
    3.times.map { job_hash }
  end
  let(:first_page) do
    h = { operations: jobs_hash }
    h[:next_page_token] = "next_page_token"
    Google::Spanner::Admin::Database::V1::ListDatabaseOperationsResponse.new h
  end
  let(:second_page) do
    h = { operations: jobs_hash }
    h[:next_page_token] = "second_page_token"
    Google::Spanner::Admin::Database::V1::ListDatabaseOperationsResponse.new h
  end
  let(:last_page) do
    h = { operations: jobs_hash }
    h[:operations].pop
    Google::Spanner::Admin::Database::V1::ListDatabaseOperationsResponse.new h
  end

  it "list database operations" do
    list_res =  MockPagedEnumerable.new([first_page])

    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: nil]
    3.times do
      mock.expect :get_operation, job_grpc_done, [job_name, Hash]
    end
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    database.service.mocked_databases = mock

    jobs = database.database_operations
    jobs.size.must_equal 3

    jobs.each do |job|
      job.must_be_kind_of Google::Cloud::Spanner::Database::Job
      job.wont_be :done?
      job.wont_be :error?
      job.error.must_be :nil?
      job.database.must_be :nil?
      job.reload!

      database = job.database
      database.wont_be :nil?
      database.must_be_kind_of Google::Cloud::Spanner::Database
    end

    mock.verify
  end

  it "paginates database operations with page size" do
    list_res =  MockPagedEnumerable.new([first_page])

    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: 3]
    3.times do
      mock.expect :get_operation, job_grpc_done.dup, [job_name, Hash]
    end
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    database.service.mocked_databases = mock

    jobs = database.database_operations page_size: 3
    jobs.size.must_equal 3

    jobs.each do |job|
      job.must_be_kind_of Google::Cloud::Spanner::Database::Job
      job.wont_be :done?
      job.wont_be :error?
      job.error.must_be :nil?
      job.database.must_be :nil?
      job.reload!

      database = job.database
      database.wont_be :nil?
      database.must_be_kind_of Google::Cloud::Spanner::Database
    end

    mock.verify
  end

  it "paginates database operations with next? and next" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    database.service.mocked_databases = mock

    jobs = database.database_operations

    jobs.size.must_equal 3
    jobs.next?.must_equal true
    jobs.next.size.must_equal 2
    jobs.next?.must_equal false

    mock.verify
  end

  it "paginates database operations with all" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    database.service.mocked_databases = mock

    jobs = database.database_operations.all.to_a

    mock.verify

    jobs.size.must_equal 5
  end

  it "paginates database operations with all and page size" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: 3]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    database.service.mocked_databases = mock

    jobs = database.database_operations(page_size: 3).all.to_a

    mock.verify

    jobs.size.must_equal 5
  end

  it "iterates database operations with all using Enumerator" do
    list_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), database_metadata_filter, page_size: nil]
    2.times do
      mock.expect :instance_variable_get, mock, ["@operations_client"]
    end
    database.service.mocked_databases = mock

    jobs = database.database_operations.all.take(5)

    mock.verify

    jobs.size.must_equal 5
  end

  it "paginates database operations with filter" do
    filter = format(
      "(%<filter>s) AND (%<database_filter>s)",
      filter: "done:true", database_filter: database_metadata_filter
    )
    list_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), filter, page_size: nil ]
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    database.service.mocked_databases = mock

    jobs = database.database_operations filter: "done:true"

    mock.verify

    jobs.size.must_equal 3
  end

  it "paginates database operations with filter and page size" do
    filter = format(
      "(%<filter>s) AND (%<database_filter>s)",
      filter: "done:true", database_filter: database_metadata_filter
    )
    list_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_database_operations, list_res, [instance_path(instance_id), filter, page_size: 3 ]
    mock.expect :instance_variable_get, mock, ["@operations_client"]
    database.service.mocked_databases = mock

    jobs = database.database_operations filter: "done:true", page_size: 3

    mock.verify

    jobs.size.must_equal 3
  end
end
