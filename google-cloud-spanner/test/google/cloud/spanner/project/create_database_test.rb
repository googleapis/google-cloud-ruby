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

describe Google::Cloud::Spanner::Project, :create_database, :mock_spanner do
  let(:instance_id) { "my-instance-id" }

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
    spanner.service.mocked_databases = mock

    job = spanner.create_database instance_id, database_id

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
    spanner.service.mocked_databases = mock

    job = spanner.create_database instance_id, database_id, statements: [
      "CREATE TABLE table1;",
      "CREATE TABLE table2;"
    ]

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end
end
