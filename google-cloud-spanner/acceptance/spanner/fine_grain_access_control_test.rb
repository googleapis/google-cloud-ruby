# Copyright 2022 Google LLC
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

describe "Fine Grained Access Control", :spanner do
  let(:table_name) { "stuffs" }
  let(:db) { spanner }
  let(:db_client) { spanner_client }
  let(:admin) { $spanner_db_admin }
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { $spanner_database_id }
  let(:role) { "selector" }

  before do
    skip if emulator_enabled?
    db_client.delete table_name # remove all data
    db_client.insert table_name, [
      { id: 1, bool: false },
      { id: 2, bool: false },
      { id: 3, bool: true },
      { id: 4, bool: false },
      { id: 5, bool: true }
    ]

    db_path = admin.database_path project: db.project_id,
                                  instance: instance_id,
                                  database: database_id

    db_job = admin.update_database_ddl database: db_path, statements: [
      "CREATE ROLE #{role}",
      "GRANT SELECT ON TABLE #{table_name} TO ROLE #{role}"
    ]
    db_job.wait_until_done!
  end

  it "should be able to do granted actions for role" do
    skip if emulator_enabled?
    selector_client = db.client $spanner_instance_id, $spanner_database_id, database_role: role
    _(selector_client.read(table_name, [:id]).rows.map(&:to_h)).must_equal [{ id: 1 },
                                                                            { id: 2 },
                                                                            { id: 3 },
                                                                            { id: 4 },
                                                                            { id: 5 }]
  end

  it "should give error for actions without access" do
    skip if emulator_enabled?
    selector_client = db.client $spanner_instance_id, $spanner_database_id, database_role: role
    error = assert_raises Google::Cloud::PermissionDeniedError do
      selector_client.insert table_name, [
        { id: 1, bool: false }
      ]
    end

    assert_includes error.message, "Role selector does not have required privileges on table #{table_name}"
  end

  it "should give error when database role does not exists" do
    skip if emulator_enabled?

    error = assert_raises Google::Cloud::PermissionDeniedError do
      db.client $spanner_instance_id, $spanner_database_id, database_role: "unknown"
    end

    assert_includes error.message, "Role not found: unknown"
  end
end
