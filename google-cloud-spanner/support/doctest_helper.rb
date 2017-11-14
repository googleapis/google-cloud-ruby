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

require "google/cloud/spanner"
require "grpc/errors"

module Google
  module Cloud
    module Spanner
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

def mock_spanner
  Google::Cloud::Spanner.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    spanner = Google::Cloud::Spanner::Project.new(Google::Cloud::Spanner::Service.new("my-project", credentials))

    service = spanner.service
    service.mocked_service = Minitest::Mock.new
    service.mocked_instances = Minitest::Mock.new
    service.mocked_databases = Minitest::Mock.new
    if block_given?
      yield service.mocked_service, service.mocked_instances, service.mocked_databases
    end
    spanner
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Spanner::V1"
  doctest.skip "Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient"
  doctest.skip "Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient"

  # Skip private classes and methods
  doctest.skip "Google::Cloud::Spanner::Session"
  doctest.skip "Google::Cloud::Spanner::Client#fields"
  doctest.skip "Google::Cloud::Spanner::Client#fields_for"
  doctest.skip "Google::Cloud::Spanner::Transaction#fields_for"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Spanner::Client#query"
  doctest.skip "Google::Cloud::Spanner::Client#save"
  doctest.skip "Google::Cloud::Spanner::Commit#save"
  doctest.skip "Google::Cloud::Spanner::Fields#new"
  doctest.skip "Google::Cloud::Spanner::Project#project_id"
  doctest.skip "Google::Cloud::Spanner::Snapshot#query"
  doctest.skip "Google::Cloud::Spanner::Transaction#query"
  doctest.skip "Google::Cloud::Spanner::Transaction#save"
  doctest.skip "Google::Cloud::Spanner::Instance::Job#refresh!"
  doctest.skip "Google::Cloud::Spanner::Database::Job#refresh!"

  doctest.before "Google::Cloud#spanner" do
    mock_spanner do |mock, mock_instances, mock_databases|
      #mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud.spanner" do
    mock_spanner do |mock, mock_instances, mock_databases|
    end
  end

  doctest.before "Google::Cloud::Spanner" do
    mock_spanner do |mock, mock_instances, mock_databases|
    end
  end

  doctest.before "Google::Cloud::Spanner.new" do
    mock_spanner do |mock, mock_instances, mock_databases|
    end
  end

  doctest.skip "Google::Cloud::Spanner::Credentials" # occasionally getting "This code example is not yet mocked"

  # Instance

  doctest.before "Google::Cloud::Spanner::Instance" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      mock_instances.expect :create_instance, create_instance_resp(client: mock_client), ["projects/my-project", "my-new-instance", Google::Spanner::Admin::Instance::V1::Instance]
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-new-instance"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#create_database" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_databases.expect :create_database, create_database_resp(client: mock_client), ["projects/my-project/instances/my-instance", "CREATE DATABASE `my-new-database`", {:extra_statements=>[]}]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#database" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#database@Will return `nil` if instance does not exist." do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :get_database, nil, ["projects/my-project/instances/my-instance/databases/my-database"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#databases" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :list_databases, databases_resp(token: "token"), ["projects/my-project/instances/my-instance", Hash]
      mock_databases.expect :list_databases, databases_resp, ["projects/my-project/instances/my-instance", Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#policy" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_instances.expect :get_iam_policy, policy_resp, ["projects/my-project/instances/my-instance"]
      mock_instances.expect :set_iam_policy, policy_resp, ["projects/my-project/instances/my-instance", Google::Iam::V1::Policy]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#test_permissions" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_instances.expect :test_iam_permissions, test_permissions_res, ["projects/my-project/instances/my-instance", ["spanner.instances.get", "spanner.instances.update"]]
    end
  end

  doctest.before "Google::Cloud::Spanner::Instance#delete" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_instances.expect :delete_instance, nil, ["projects/my-project/instances/my-instance"]
    end
  end

  # Instance::Config

  doctest.before "Google::Cloud::Spanner::Instance::Config" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :list_instance_configs, instance_configs_resp, ["projects/my-project", Hash]
    end
  end

  # Instance::List

  doctest.before "Google::Cloud::Spanner::Instance::List" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :list_instances, instances_resp(token: "token"), ["projects/my-project", Hash]
      mock_instances.expect :list_instances, instances_resp, ["projects/my-project", Hash]
    end
  end

  # Instance::Config::List

  doctest.before "Google::Cloud::Spanner::Instance::Config::List" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :list_instance_configs, instance_configs_resp(token: "token"), ["projects/my-project", Hash]
      mock_instances.expect :list_instance_configs, instance_configs_resp, ["projects/my-project", Hash]
    end
  end

  # Policy

  doctest.before "Google::Cloud::Spanner::Policy" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_instances.expect :get_iam_policy, policy_resp, ["projects/my-project/instances/my-instance"]
      mock_instances.expect :set_iam_policy, policy_resp, ["projects/my-project/instances/my-instance", Google::Iam::V1::Policy]
    end
  end

  # Project

  doctest.before "Google::Cloud::Spanner::Project" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project@Obtaining a client for use with a database." do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#client" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#create_instance" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_instances.expect :create_instance, create_instance_resp(client: mock_client), ["projects/my-project", "my-new-instance", Google::Spanner::Admin::Instance::V1::Instance]
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-new-instance"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instance" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instance@Will return `nil` if instance does not exist." do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/non-existing"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instances" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :list_instances, instances_resp(token: "token"), ["projects/my-project", Hash]
      mock_instances.expect :list_instances, instances_resp, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instance_config" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance_config, instance_config_resp, ["projects/my-project/instanceConfigs/regional-us-central1"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instance_config@Will return `nil` if instance config does not exist." do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance_config, instance_config_resp, ["projects/my-project/instanceConfigs/non-existing"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#instance_configs" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :list_instance_configs, instance_configs_resp(token: "token"), ["projects/my-project", Hash]
      mock_instances.expect :list_instance_configs, instance_configs_resp, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#create_database" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      #mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_databases.expect :create_database, create_database_resp(client: mock_client), ["projects/my-project/instances/my-instance", "CREATE DATABASE `my-new-database`", {:extra_statements=>[]}]
    end
  end

  doctest.before "Google::Cloud::Spanner::Project#databases" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :list_databases, databases_resp(token: "token"), ["projects/my-project/instances/my-instance", Hash]
      mock_databases.expect :list_databases, databases_resp, ["projects/my-project/instances/my-instance", Hash]
    end
  end

  # Client

  doctest.before "Google::Cloud::Spanner::Client" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#execute" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#execute@Query using query parameters:" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users WHERE active = @active", Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#transaction" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :rollback, nil, ["session-name", "tx-001-02", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#snapshot" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#fields" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end

    # TODO: Failing 1) wrong num args in Fields#data  2) undefined method `empty?' for #<Google::Cloud::Spanner::Data
  end

  doctest.before "Google::Cloud::Spanner::Client#range" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Client#read" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
    end
  end

  # Commit

  doctest.before "Google::Cloud::Spanner::Commit" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  # Data

  doctest.before "Google::Cloud::Spanner::Data" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
    end
  end

  # Database

  doctest.before "Google::Cloud::Spanner::Database" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_databases.expect :create_database, create_database_resp(client: mock_client), ["projects/my-project/instances/my-instance", "CREATE DATABASE `my-new-database`", {:extra_statements=>[]}]
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-new-database"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Database#ddl" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :get_database_ddl, database_ddl_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :get_database_ddl, database_ddl_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
    end
  end

  doctest.before "Google::Cloud::Spanner::Database#policy" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :get_iam_policy, policy_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :set_iam_policy, policy_resp, ["projects/my-project/instances/my-instance/databases/my-database", Google::Iam::V1::Policy]
    end
  end

  doctest.before "Google::Cloud::Spanner::Database#test_permissions" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :test_iam_permissions, test_permissions_res(permissions: ["spanner.databases.get"]),
                            ["projects/my-project/instances/my-instance/databases/my-database", ["spanner.databases.get", "spanner.databases.update"]]
    end
  end

  doctest.before "Google::Cloud::Spanner::Database#update" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :update_database_ddl, nil, ["projects/my-project/instances/my-instance/databases/my-database", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Database#drop" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_databases.expect :get_database, database_resp, ["projects/my-project/instances/my-instance/databases/my-database"]
      mock_databases.expect :drop_database, nil, ["projects/my-project/instances/my-instance/databases/my-database"]
    end
  end

  # Database::List

  doctest.before "Google::Cloud::Spanner::Database::List" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_databases.expect :list_databases, databases_resp(token: "token"), ["projects/my-project/instances/my-instance", Hash]
      mock_databases.expect :list_databases, databases_resp, ["projects/my-project/instances/my-instance", Hash]
    end
  end

  # Fields

  doctest.before "Google::Cloud::Spanner::Fields" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
    end
  end

  # Range

  doctest.before "Google::Cloud::Spanner::Range" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
    end
  end

  # Results

  doctest.before "Google::Cloud::Spanner::Results" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
    end
  end

  # Rollback

  doctest.before "Google::Cloud::Spanner::Rollback" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :rollback, nil, ["session-name", "tx-001-02", Hash]
    end
  end

  # Snapshot

  doctest.before "Google::Cloud::Spanner::Snapshot" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Snapshot#execute@Query using query parameters:" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users WHERE active = @active", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Snapshot#range" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Snapshot#read" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Status" do
    mock_spanner do |mock, mock_instances, mock_databases|
      mock_client = Minitest::Mock.new
      #mock_instances.expect :get_instance, OpenStruct.new(instance_hash), ["projects/my-project/instances/my-instance"]
      mock_client.expect :get_operation, OpenStruct.new(done: true), ["1234567890", {:options=>nil}]
      mock_databases.expect :create_database, create_database_resp(client: mock_client), ["projects/my-project/instances/my-instance", "CREATE DATABASE `my-new-database`", {:extra_statements=>[]}]
    end
  end

  # Transaction

  doctest.before "Google::Cloud::Spanner::Transaction" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum_marketing, ["session-name", "Albums", ["marketing_budget"], Google::Spanner::V1::KeySet, Hash]
      mock.expect :streaming_read, results_enum_marketing, ["session-name", "Albums", ["marketing_budget"], Google::Spanner::V1::KeySet, Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Transaction#execute" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Transaction#execute@Query using query parameters:" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :execute_streaming_sql, results_enum, ["session-name", "SELECT * FROM users WHERE active = @active", Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Transaction#range" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Spanner::Transaction#read" do
    mock_spanner do |mock, mock_instances, mock_databases|
      20.times do
        mock.expect :create_session, OpenStruct.new(name: "session-name"), ["projects/my-project/instances/my-instance/databases/my-database", Hash]
      end
      5.times do
        mock.expect :begin_transaction, tx_resp, ["session-name", Google::Spanner::V1::TransactionOptions, Hash]
      end
      mock.expect :streaming_read, results_enum, ["session-name", "users", ["id", "name"], Google::Spanner::V1::KeySet, Hash]
      mock.expect :commit, commit_resp, ["session-name", Array, Hash]
    end
  end

end

# Stubs

def something_wrong?
  true
end

# Fixtures
def project
  "my-project"
end

def instance_hash name: "my-instance", nodes: 1, state: "READY", labels: {}
  {
    name: "projects/#{project}/instances/#{name}",
    config: "projects/#{project}/instanceConfigs/regional-us-central1",
    displayName: name.split("-").map(&:capitalize).join(" "),
    nodeCount: nodes,
    state: state,
    labels: labels
  }
end

def job_json
  "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"google.spanner.admin.database.v1.CreateDatabaseMetadata\",\"value\":\"\"}}"
end

def job_grpc
  Google::Longrunning::Operation.decode_json job_json
end

def create_instance_resp client: nil
  Google::Gax::Operation.new(
                 job_grpc,
                 client,
                 Google::Spanner::Admin::Instance::V1::Instance,
                 Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata
               )
end

def instance_configs_hash
  {
    instanceConfigs: [
      { name: "projects/#{project}/instanceConfigs/regional-europe-west1",
        displayName: "EU West 1"},
      { name: "projects/#{project}/instanceConfigs/regional-us-west1",
        displayName: "US West 1"},
      { name: "projects/#{project}/instanceConfigs/regional-us-central1",
        displayName: "US Central 1"}
    ]
  }
end

def instance_config_hash
  instance_configs_hash[:instanceConfigs].last
end

def instance_config_resp
  Google::Spanner::Admin::Instance::V1::InstanceConfig.decode_json instance_config_hash.to_json
end

def instance_configs_resp token: nil
  h = instance_configs_hash
  h[:nextPageToken] = token if token
  response = Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse.decode_json h.to_json
  paged_enum_struct response
end

def instances_hash
  { instances: [instance_hash] }
end

def instance_hash name: "my-instance", nodes: 1, state: "READY", labels: {}
  {
    name: "projects/#{project}/instances/#{name}",
    config: "projects/#{project}/instanceConfigs/regional-us-central1",
    displayName: name.split("-").map(&:capitalize).join(" "),
    nodeCount: nodes,
    state: state,
    labels: labels
  }
end

def instances_resp token: nil
  h = instances_hash
  h[:nextPageToken] = token if token
  response = Google::Spanner::Admin::Instance::V1::ListInstancesResponse.decode_json h.to_json
  paged_enum_struct response
end

def create_database_resp client: nil
  Google::Gax::Operation.new(
                 job_grpc,
                 client,
                 Google::Spanner::Admin::Database::V1::Database,
                 Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata
               )
end

def databases_hash instance_id: "my-instance"
  { databases: [database_hash(instance_id: instance_id)] }
end

def database_hash instance_id: "my-instance", database_id: "my-database", state: "READY"
  {
    name: "projects/#{project}/instances/#{instance_id}/databases/#{database_id}",
    state: state
  }
end

def database_resp instance_id: "my-instance", database_id: "my-database"
  Google::Spanner::Admin::Database::V1::Database.decode_json database_hash(instance_id: instance_id, database_id: database_id).to_json
end

def databases_resp token: nil
  h = databases_hash
  h[:nextPageToken] = token if token
  response = Google::Spanner::Admin::Database::V1::ListDatabasesResponse.decode_json h.to_json
  paged_enum_struct response
end

def database_ddl_resp
  Google::Spanner::Admin::Database::V1::GetDatabaseDdlResponse.new(
    statements: ["CREATE TABLE table1", "CREATE TABLE table2", "CREATE TABLE table3"]
  )
end

def policy_json
  {
    etag: "CAE=",
    bindings: [{
      role: "roles/viewer",
      members: [
        "user:viewer@example.com",
        "serviceAccount:1234567890@developer.gserviceaccount.com"
       ]
    }]
  }.to_json
end

def policy_resp
  Google::Iam::V1::Policy.decode_json policy_json
end

def test_permissions_res permissions: ["spanner.instances.get"]
  Google::Iam::V1::TestIamPermissionsResponse.new(
    permissions: permissions
  )
end


def paged_enum_struct response
  OpenStruct.new page: OpenStruct.new(response: response)
end

def tx_resp
  Google::Spanner::V1::Transaction.new(id: "tx-001-02")
end

def results_hash1
  {
    metadata: {
      rowType: {
        fields: [
          { name: "id",          type: { code: "INT64" } },
          { name: "name",        type: { code: "STRING" } },
          { name: "active",      type: { code: "BOOL" } },
          { name: "age",         type: { code: "INT64" } },
          { name: "score",       type: { code: "FLOAT64" } },
          { name: "updated_at",  type: { code: "TIMESTAMP" } },
          { name: "birthday",    type: { code: "DATE"} },
          { name: "avatar",      type: { code: "BYTES" } },
          { name: "project_ids", type: { code: "ARRAY",
                                         arrayElementType: { code: "INT64" } } }
        ]
      }
    }
  }
end

def results_hash_marketing
  {
    metadata: {
      rowType: {
        fields: [
          { name: "marketing_budget",          type: { code: "INT64" } }
        ]
      }
    }
  }
end

def results_hash_marketing_2
  {
    values: [
      { stringValue: "400000" }
    ]
  }
end

def results_enum
  [Google::Spanner::V1::PartialResultSet.decode_json(results_hash1.to_json)].to_enum
end

def results_enum_marketing
  [
    Google::Spanner::V1::PartialResultSet.decode_json(results_hash_marketing.to_json),
    Google::Spanner::V1::PartialResultSet.decode_json(results_hash_marketing_2.to_json)
  ].to_enum
end

def commit_timestamp
  Google::Cloud::Spanner::Convert.time_to_timestamp Time.now
end

def commit_resp
  Google::Spanner::V1::CommitResponse.new commit_timestamp: commit_timestamp
end
