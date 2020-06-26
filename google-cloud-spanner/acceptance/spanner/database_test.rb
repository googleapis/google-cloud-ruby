# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Databases", :spanner do
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { "#{$spanner_database_id}-crud" }

  it "creates, updates, and drops a database" do
    _(spanner.database(instance_id, database_id)).must_be :nil?

    job = spanner.create_database instance_id, database_id
    _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job).wont_be :done? unless emulator_enabled?
    job.wait_until_done!

    _(job).must_be :done?
    raise Google::Cloud::Error.from_error(job.error) if job.error?
    database = job.database
    _(database).wont_be :nil?
    _(database).must_be_kind_of Google::Cloud::Spanner::Database
    _(database.database_id).must_equal database_id
    _(database.instance_id).must_equal instance_id
    _(database.project_id).must_equal spanner.project

    _(spanner.database(instance_id, database_id)).wont_be :nil?

    job2 = database.update statements: "CREATE TABLE users (id INT64 NOT NULL) PRIMARY KEY(id)"

    _(job2).must_be_kind_of Google::Cloud::Spanner::Database::Job
    _(job2).wont_be :done? unless emulator_enabled?
    job2.wait_until_done!

    _(job2).must_be :done?
    _(job2.database).must_be :nil?

    database.drop
    _(spanner.database(instance_id, database_id)).must_be :nil?
  end

  it "lists and gets databases" do
    all_databases = spanner.databases(instance_id).all.to_a
    _(all_databases).wont_be :empty?
    all_databases.each do |database|
      _(database).must_be_kind_of Google::Cloud::Spanner::Database
    end

    first_database = spanner.database all_databases.first.instance_id, all_databases.first.database_id
    _(first_database).must_be_kind_of Google::Cloud::Spanner::Database
  end
end
