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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/spanner"
require "grpc"

class MockSpanner < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:spanner) { Google::Cloud::Spanner::Project.new(Google::Cloud::Spanner::Service.new(project, credentials)) }

  # Register this spec type for when :spanner is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_spanner
  end

  def shutdown_client! client
    # extract the pool
    pool = client.instance_variable_get :@pool
    # remove all sessions so we don't have to handle the calls to session_delete
    pool.all_sessions = []

    # close the client
    client.close

    # close the client
    shutdown_pool! pool
  end

  def shutdown_pool! pool
    # ensure the pool's thread pool is also shut down
    thread_pool = pool.instance_variable_get :@thread_pool
    thread_pool.shutdown
    thread_pool.wait_for_termination 60
  end

  def instance_configs_hash
    {
      instance_configs: [
        { name: "projects/#{project}/instanceConfigs/regional-europe-west1",
          display_name: "EU West 1"},
        { name: "projects/#{project}/instanceConfigs/regional-us-west1",
          display_name: "US West 1"},
        { name: "projects/#{project}/instanceConfigs/regional-us-central1",
          display_name: "US Central 1"}
      ]
    }
  end

  def instance_config_hash
    instance_configs_hash[:instance_configs].last
  end

  def instances_hash
    { instances: 3.times.map { instance_hash } }
  end

  def instance_hash name: "instance-#{rand(9999)}", nodes: 1, state: "READY", labels: {}
    {
      name: "projects/#{project}/instances/#{name}",
      config: "projects/#{project}/instanceConfigs/regional-us-central1",
      display_name: name.split("-").map(&:capitalize).join(" "),
      node_count: nodes,
      state: state,
      labels: labels
    }
  end

  def databases_hash instance_id: "my-instance-id"
    { databases: 3.times.map { database_hash(instance_id: instance_id) } }
  end

  def database_hash instance_id: "my-instance-id", database_id: "database-#{rand(9999)}",
                    state: "READY", restore_info: {}, version_retention_period: "",
                    earliest_version_time: nil, encryption_config: {}
    {
      name: "projects/#{project}/instances/#{instance_id}/databases/#{database_id}",
      state: state,
      restore_info: restore_info,
      version_retention_period: version_retention_period,
      earliest_version_time: earliest_version_time,
      encryption_config: encryption_config
    }
  end

  def restore_info_hash source_type: "BACKUP", backup_info: {}
    {
      source_type: source_type,
      backup_info: backup_info
    }
  end

  def backup_info_hash instance_id: "my-instance-id", backup_id: "my-backup-id",
                       create_time: Time.now, source_database_id: "my-backup-source-database-id"
    {
      backup: "projects/#{project}/instances/#{instance_id}/backups/#{backup_id}",
      create_time: create_time,
      source_database: "projects/#{project}/instances/#{instance_id}/databases/#{source_database_id}"
    }
  end

  def backup_hash instance_id: "my-instance-id", database_id: "database-#{rand(9999)}",
                  backup_id: "backup-#{rand(9999)}", state: "READY", expire_time: Time.now + 36000,
                  create_time: Time.now, size_bytes: 1024, referencing_databases: ["db1"]
    {
      name: "projects/#{project}/instances/#{instance_id}/backups/#{backup_id}",
      database: "projects/#{project}/instances/#{instance_id}/databases/#{database_id}",
      state: state,
      expire_time: expire_time,
      create_time: create_time,
      size_bytes: size_bytes,
      referencing_databases: referencing_databases.map do |database|
        "projects/#{project}/instances/#{instance_id}/databases/#{database}"
      end
    }
  end

  def backups_hash instance_id: "my-instance-id"
    { backups: 3.times.map { backup_hash instance_id: instance_id } }
  end

  def project_path
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Paths.project_path \
      project: project
  end

  def instance_path name
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Paths.instance_path \
      project: project, instance: name
  end

  def database_path instance, name
    Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Paths.database_path \
      project: project, instance: instance, database: name
  end

  def instance_config_path name
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Paths.instance_config_path \
      project: project, instance_config: name
  end

  def session_path instance_id, database_id, session_id
    Google::Cloud::Spanner::V1::Spanner::Paths.session_path \
      project: project, instance: instance_id, database: database_id, session: session_id
  end

  def backup_path instance, backup
    Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Paths.backup_path \
     project: project, instance: instance, backup: backup
  end

  def paged_enum_struct response
    OpenStruct.new(response: response)
  end

  def expect_execute_streaming_sql results_enum, session_name, sql,
                                   transaction: nil, params: nil, param_types: nil,
                                   resume_token: nil, partition_token: nil, seqno: nil,
                                   query_options: nil, options: nil
    spanner.service.mocked_service.expect :execute_streaming_sql, results_enum do |request, gapic_options|
      request[:session] == session_name &&
        request[:sql] == sql &&
        request[:transaction] == transaction &&
        request[:params] == params &&
        request[:param_types] == param_types &&
        request[:resume_token] == resume_token &&
        request[:partition_token] == partition_token &&
        request[:seqno] == seqno &&
        gapic_options == options &&
        request[:query_options] == query_options
    end
  end

  def expect_begin_transaction transaction, tx_opts, options
    spanner.service.mocked_service.expect :begin_transaction, transaction do |request, gapic_options|
      request[:session].instance_of?(String) && request[:options] == tx_opts && gapic_options == options
    end
  end
end

# This is used to raise errors in an enumerator
class RaiseableEnumerator
  def initialize enum
    @enum = enum
  end

  def next
    v = @enum.next
    raise v if v.is_a? Class
    raise v if v.is_a? StandardError
    v
  end

  def method_missing method, *args
    @enum.send method, *args
  end

  def inspect
    "<#{self.class}>"
  end
end

class MockPagedEnumerable
  def initialize responses = []
    @responses = responses
    @current_index = 0
  end

  def response
    @responses[@current_index]
  end

  def next_page?
    response.next_page_token != ""
  end

  def next_page
    @current_index += 1
    response
  end
end
