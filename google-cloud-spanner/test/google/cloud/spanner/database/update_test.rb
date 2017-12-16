# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Database, :update, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:database_json) { database_hash(instance_id: instance_id, database_id: database_id).to_json }
  let(:database_grpc) { Google::Spanner::Admin::Database::V1::Database.decode_json database_json }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"google.spanner.admin.database.v1.UpdateDatabaseDdlRequest\",\"value\":\"\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }

  it "updates with single statement" do
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Database::V1::Database,
                   Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
                 )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [database_path(instance_id, database_id), ["CREATE TABLE table4"], operation_id: nil]
    spanner.service.mocked_databases = mock

    job = database.update statements: "CREATE TABLE table4"

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end

  it "updates with multiple statements" do
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Database::V1::Database,
                   Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
                 )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [database_path(instance_id, database_id), ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: nil]
    spanner.service.mocked_databases = mock

    job = database.update statements: ["CREATE TABLE table4", "CREATE TABLE table5"]

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end

  it "updates with operation_id" do
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Database::V1::Database,
                   Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
                 )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [database_path(instance_id, database_id), ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: "update123"]
    spanner.service.mocked_databases = mock

    job = database.update statements: ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: "update123"

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
  end
end
