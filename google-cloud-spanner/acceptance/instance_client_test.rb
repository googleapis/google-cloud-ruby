# Copyright 2021 Google LLC
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

require "google/cloud/spanner/admin/instance"
require "spanner_helper"

describe "Spanner Instances Client", :spanner do
  let(:instance_id) { $spanner_instance_id }
  let(:instance) { {} }

  it "creates, gets, updates, and deletes an instance" do
    puts "let's run"
    client = Google::Cloud::Spanner::Admin::Instance.instance_admin project_id: spanner.project

    project_path = client.project_path project: spanner.project

    instance_path = client.instance_path project: spanner.project, instance: instance_id

    instance_config_path = client.instance_config_path project: spanner.project, instance_config: "regional-asia-south1"

    instance = Google::Cloud::Spanner::Admin::Instance::V1::Instance.new name: instance_path,
                                                                         config: instance_config_path,
                                                                         display_name: instance_id,
                                                                         node_count: 1

    request = Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceRequest.new parent: project_path,
                                                                                     instance_id: instance_id,
                                                                                     instance: instance                                                    

    job = client.create_instance request
    # _(job).wont_be :done? unless emulator_enabled?
    # job.wait_until_done!

    # _(job).must_be :done?
    # raise Google::Cloud::Error.from_error(job.error) if job.error?
    # database = job.results
    # _(database).wont_be :nil?
    # _(database).must_be_kind_of Google::Cloud::Spanner::Admin::Database::V1::Database
    # _(database.name).must_equal db_path
    # _(database.encryption_config).must_be :nil?
    # _(database.encryption_info).must_be_kind_of Google::Protobuf::RepeatedField

    # database = client.get_database name: db_path
    # _(database).must_be_kind_of Google::Cloud::Spanner::Admin::Database::V1::Database

    # add_users_table_sql = "CREATE TABLE users (id INT64 NOT NULL) PRIMARY KEY(id)"
    # job2 = client.update_database_ddl database: db_path,
    #                                   statements: [add_users_table_sql]

    # _(job2).wont_be :done? unless emulator_enabled?
    # job2.wait_until_done!

    # _(job2).must_be :done?

    # client.drop_database database: db_path
    # assert_raises Google::Cloud::NotFoundError do
    #   client.get_database name: db_path
    # end
  end

  # it "lists databases" do
  #   client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: spanner.project

  #   instance_path = \
  #     client.instance_path project: spanner.project, instance: instance_id
  #   all_databases = client.list_databases parent: instance_path
  #   _(all_databases.response).wont_be :nil?
  #   all_databases.each do |database|
  #     _(database).must_be_kind_of Google::Cloud::Spanner::Admin::Database::V1::Database
  #     _(database.encryption_info).must_be_kind_of Google::Protobuf::RepeatedField
  #   end
  # end
end