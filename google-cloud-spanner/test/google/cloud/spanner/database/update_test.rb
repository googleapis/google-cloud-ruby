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

describe Google::Cloud::Spanner::Database, :update, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:database_grpc) { Google::Cloud::Spanner::Admin::Database::V1::Database.new database_hash(instance_id: instance_id, database_id: database_id) }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.UpdateDatabaseDdlRequest",
        value: ""
      }
    )
  end

  it "updates with single statement" do
    update_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
      )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [{ database: database_path(instance_id, database_id), statements: ["CREATE TABLE table4"], operation_id: nil }, nil]
    spanner.service.mocked_databases = mock

    job = database.update statements: "CREATE TABLE table4"

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end

  it "updates with multiple statements" do
    update_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
      )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [{ database: database_path(instance_id, database_id), statements: ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: nil }, nil]
    spanner.service.mocked_databases = mock

    job = database.update statements: ["CREATE TABLE table4", "CREATE TABLE table5"]

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end

  it "updates with operation_id" do
    update_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest
      )
    mock = Minitest::Mock.new
    mock.expect :update_database_ddl, update_res, [{ database: database_path(instance_id, database_id), statements: ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: "update123" }, nil]
    spanner.service.mocked_databases = mock

    job = database.update statements: ["CREATE TABLE table4", "CREATE TABLE table5"], operation_id: "update123"

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end
end
