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

describe Google::Cloud::Spanner::Database, :ddl, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:database_grpc) { Google::Cloud::Spanner::Admin::Database::V1::Database.new database_hash(instance_id: instance_id, database_id: database_id) }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }
  let(:statements) { ["CREATE TABLE table1", "CREATE TABLE table2", "CREATE TABLE table3"] }

  it "gets the DDL statements" do
    update_res = Google::Cloud::Spanner::Admin::Database::V1::GetDatabaseDdlResponse.new(
      statements: statements
    )
    mock = Minitest::Mock.new
    mock.expect :get_database_ddl, update_res, [database: database_path(instance_id, database_id)]
    spanner.service.mocked_databases = mock

    ddl = database.ddl

    mock.verify

    _(ddl).must_equal statements

    # The results are cached, second call does not raise
    ddl2 = database.ddl
    _(ddl2).must_equal ddl
  end

  it "forces an API request" do
    database.instance_variable_set :@ddl, statements

    # The results are cached, this does not make an API request
    cached_ddl = database.ddl
    _(cached_ddl).must_equal statements

    update_res = Google::Cloud::Spanner::Admin::Database::V1::GetDatabaseDdlResponse.new(
      statements: statements.reverse
    )
    mock = Minitest::Mock.new
    mock.expect :get_database_ddl, update_res, [database: database_path(instance_id, database_id)]
    spanner.service.mocked_databases = mock

    ddl = database.ddl force: true

    mock.verify

    _(ddl).must_equal statements.reverse
  end
end
