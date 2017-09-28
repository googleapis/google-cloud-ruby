# Copyright 2017 Google Inc. All rights reserved.
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

require "spanner_helper"

describe "Spanner Databases", :spanner do
  let(:instance_id) { $spanner_prefix }

  it "creates, updates, and drops a database" do
    database_id = "crud"

    spanner.database(instance_id, database_id).must_be :nil?

    job = spanner.create_database instance_id, database_id
    job.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job.wont_be :done?
    job.wait_until_done!

    job.must_be :done?
    raise Google::Cloud::Error.from_error(job.error) if job.error?
    database = job.database
    database.wont_be :nil?
    database.must_be_kind_of Google::Cloud::Spanner::Database
    database.database_id.must_equal database_id
    database.instance_id.must_equal instance_id
    database.project_id.must_equal spanner.project

    spanner.database(instance_id, database_id).wont_be :nil?

    job2 = database.update statements: "CREATE TABLE users (id INT64 NOT NULL) PRIMARY KEY(id)"

    job2.must_be_kind_of Google::Cloud::Spanner::Database::Job
    job2.wont_be :done?
    job2.wait_until_done!

    job2.must_be :done?
    job2.database.wont_be :nil?
    job2.database.must_be_kind_of Google::Cloud::Spanner::Database

    database.drop
    spanner.database(instance_id, database_id).must_be :nil?
  end

  it "lists and gets databases" do
    all_databases = spanner.databases(instance_id).all.to_a
    all_databases.wont_be :empty?
    all_databases.each do |database|
      database.must_be_kind_of Google::Cloud::Spanner::Database
    end

    first_database = spanner.database all_databases.first.instance_id, all_databases.first.database_id
    first_database.must_be_kind_of Google::Cloud::Spanner::Database
  end
end
