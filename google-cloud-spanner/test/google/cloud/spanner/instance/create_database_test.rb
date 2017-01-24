# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Instance, :create_database, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_json) { instance_hash(name: instance_id).to_json }
  let(:instance_grpc) { Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_json }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }

  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"google.spanner.admin.database.v1.CreateDatabaseMetadata\",\"value\":\"\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }

  it "creates an empty database" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    create_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Database::V1::Database,
                   Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata
                 )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [instance_path(instance_id), "CREATE DATABASE `#{database_id}`", extra_statements: []]
    instance.service.mocked_databases = mock

    job = instance.create_database database_id

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end

  it "creates a database with additional statements" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    create_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Database::V1::Database,
                   Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata
                 )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [instance_path(instance_id), "CREATE DATABASE `#{database_id}`", extra_statements: ["CREATE TABLE table1;", "CREATE TABLE table2;"]]
    instance.service.mocked_databases = mock

    job = instance.create_database database_id, statements: [
      "CREATE TABLE table1;",
      "CREATE TABLE table2;"
    ]

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end
end
