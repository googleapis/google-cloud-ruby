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

  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.UpdateDatabaseDdlRequest",
        value: ""
      }
    )
  end

  it "creates an empty database" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    create_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
      )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [{ parent: instance_path(instance_id), create_statement: "CREATE DATABASE `#{database_id}`", extra_statements: [], encryption_config: nil }, nil]
    spanner.service.mocked_databases = mock

    job = spanner.create_database instance_id, database_id

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end

  it "creates a database with additional statements" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    create_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
    )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [{ parent: instance_path(instance_id), create_statement: "CREATE DATABASE `#{database_id}`", extra_statements: ["CREATE TABLE table1;", "CREATE TABLE table2;"], encryption_config: nil }, nil]
    spanner.service.mocked_databases = mock

    job = spanner.create_database instance_id, database_id, statements: [
      "CREATE TABLE table1;",
      "CREATE TABLE table2;"
    ]

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end

  it "creates a database with cmek config" do
    instance_id = "my-instance-id"
    database_id = "new-database"

    kms_key_name = "projects/<project>/locations/<location>/keyRings/<key_ring>/cryptoKeys/<kms_key_name>"

    create_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Database::V1::Database,
        metadata_type: Google::Cloud::Spanner::Admin::Database::V1::CreateDatabaseMetadata
    )
    mock = Minitest::Mock.new
    mock.expect :create_database, create_res, [{ parent: instance_path(instance_id), create_statement: "CREATE DATABASE `#{database_id}`", extra_statements: [], encryption_config: { kms_key_name: kms_key_name } }, nil]
    spanner.service.mocked_databases = mock

    job = spanner.create_database instance_id, database_id, encryption_config: { kms_key_name: kms_key_name }

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done?
  end
end
