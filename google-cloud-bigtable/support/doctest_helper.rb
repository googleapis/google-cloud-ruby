# Copyright 2019 Google LLC
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

require "minitest/focus"

require "google/cloud/bigtable"
require "grpc/errors"

module Google
  module Cloud
    module Bigtable
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

def mock_bigtable
  Google::Cloud::Bigtable.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    bigtable = Google::Cloud::Bigtable::Project.new(Google::Cloud::Bigtable::Service.new("my-project", credentials))

    service = bigtable.service
    service.mocked_client = Minitest::Mock.new
    service.mocked_instances = Minitest::Mock.new
    service.mocked_tables = Minitest::Mock.new
    mocked_job = Minitest::Mock.new
    if block_given?
      yield service.mocked_client, service.mocked_instances, service.mocked_tables, mocked_job
    end
    bigtable
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Bigtable::V2"
  doctest.skip "Google::Cloud::Bigtable::Admin::V2"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Bigtable::AppProfile#update"
  doctest.skip "Google::Cloud::Bigtable::Cluster#update"
  doctest.skip "Google::Cloud::Bigtable::ColumnFamily#update"
  doctest.skip "Google::Cloud::Bigtable::Instance#update"
  doctest.skip "Google::Cloud::Bigtable::Instance#policy="

  doctest.before "Google::Cloud#bigtable" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      #mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud.bigtable" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
    end
  end

  doctest.before "Google::Cloud::Bigtable" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable.new" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
    end
  end

  # AppProfile

  doctest.before "Google::Cloud::Bigtable::AppProfile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_instances.expect :delete_app_profile, nil, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile", ignore_warnings: false]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#delete" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :delete_app_profile, nil, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile", ignore_warnings: true]
      mocked_instances.expect :delete_app_profile, nil, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile", ignore_warnings: false]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile.multi_cluster_routing" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#routing_policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#routing_policy=" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile.single_cluster_routing" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#save" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#save@Update with single cluster routing." do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :reload!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile::Job" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :reload!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile::List" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, [parent: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, [parent: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :update_backup, backup_resp, [Hash]
      mocked_tables.expect :delete_backup, nil, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup#policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup#test_iam_permissions" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :test_iam_permissions, backup_iam_permissions_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup#update_policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup#restore" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-other-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :restore_table, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup::Job" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :create_backup, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Backup::List" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :list_backups, backups_resp, [parent: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :update_cluster, mocked_job, [Hash]
      mocked_instances.expect :delete_cluster, true, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster#create_backup" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :create_backup, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster#backup" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster#backups" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :list_backups, backups_resp, [parent: "projects/my-project/instances/my-instance/clusters/my-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster#save" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :update_cluster, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster::Job" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_cluster, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :reload!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster::List" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :list_clusters, clusters_resp, [parent: "projects/my-project/instances/-", page_token: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::ColumnFamily" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::ColumnFamilyMap" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :create_table, table_resp, [Hash]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::EncryptionInfo" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::EncryptionInfo@Retrieve a table with cluster states containing encryption info." do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :ENCRYPTION_VIEW]
    end
  end

  doctest.before "Google::Cloud::Bigtable::GcRule" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :create_table, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :create_instance, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#app_profile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, [name: "projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#app_profiles" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, [parent: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#clusters" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_clusters, clusters_resp, [parent: "projects/my-project/instances/my-instance", page_token: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_app_profile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_app_profile@Create an app profile with a single cluster routing policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_cluster, mocked_job,[Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :create_table, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#delete" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :delete_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#save" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :partial_update_instance, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :NAME_ONLY]
      mock.expect :mutate_row, mutate_row_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#tables" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :list_tables, tables_resp, [parent: "projects/my-project/instances/my-instance", view: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#test_iam_permissions" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :test_iam_permissions, instance_iam_permissions_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#update_policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance::Job" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :create_instance, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :reload!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, false, []
      mocked_job.expect :grpc_op, OpenStruct.new(result: instance_resp), []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance::List" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :list_instances, instances_resp, [parent: "projects/my-project", page_token: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MultiClusterRoutingUseAny" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :mutate_row, nil, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations#check_and_mutate_row" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :check_and_mutate_row, OpenStruct.new(predicate_matched: true), [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations#mutate_rows" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :mutate_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations#read_modify_write_row" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :read_modify_write_row, OpenStruct.new(row: OpenStruct.new(key: "123", families: [])), [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations#sample_row_keys" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :sample_row_keys, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::MutationOperations::Response" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :mutate_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_clusters, clusters_resp, [parent: "projects/my-project/instances/-", page_token: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#create_instance" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :create_instance, mocked_job, [Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#create_table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :create_table, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#delete_table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :delete_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#instance" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#instances" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :list_instances, instances_resp, [parent: "projects/my-project", page_token: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#modify_column_families" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mock.expect :mutate_row, nil, [Hash]
      mock.expect :read_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#table@Retrieve a table with all fields, cluster states, and column families." do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :FULL]
      mock.expect :mutate_row, nil, [Hash]
      mock.expect :read_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#tables" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :list_tables, tables_resp, [parent: "projects/my-project/instances/my-instance", view: nil]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table-1", view: :SCHEMA_VIEW]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table-2", view: :SCHEMA_VIEW]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table-3", view: :SCHEMA_VIEW]
    end
  end

  doctest.before "Google::Cloud::Bigtable::ReadOperations" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mock.expect :read_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::ReadOperations#sample_row_keys" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mock.expect :sample_row_keys, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::RoutingPolicy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::SampleRowKey" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mock.expect :sample_row_keys, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Status" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mock.expect :mutate_rows, [], [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::SingleClusterRouting" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :NAME_ONLY]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#check_consistency" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :check_consistency, OpenStruct.new(consistent: true), [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#cluster_states" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :FULL]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#column_families" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#column_family" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
      mocked_tables.expect :modify_column_families, table_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#delete" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :delete_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#delete_all_rows" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :drop_row_range, nil, [Hash, nil]
      mocked_tables.expect :drop_row_range, nil, [Hash, Gapic::CallOptions]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#delete_rows_by_prefix" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :drop_row_range, nil, [Hash, nil]
      mocked_tables.expect :drop_row_range, nil, [Hash, Gapic::CallOptions]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#drop_row_range" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :drop_row_range, nil, [Hash, nil]
      mocked_tables.expect :drop_row_range, nil, [Hash, Gapic::CallOptions]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#generate_consistency_token" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :generate_consistency_token, OpenStruct.new(consistency_token: ""), [name: "projects/my-project/instances/my-instance/tables/my-table"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#exists?" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :NAME_ONLY]
      mocked_tables.expect :check_consistency, OpenStruct.new(consistent: true), [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance/tables/my-table"]
      mocked_tables.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#test_iam_permissions" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :test_iam_permissions, table_iam_permissions_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#update_policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :get_iam_policy, policy_resp, [resource: "projects/my-project/instances/my-instance/tables/my-table"]
      mocked_tables.expect :set_iam_policy, policy_resp, [Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table#wait_for_replication" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :generate_consistency_token, OpenStruct.new(consistency_token: "123"), [name: "projects/my-project/instances/my-instance/tables/my-table"]
      mocked_tables.expect :check_consistency, OpenStruct.new(consistent: true), [name: "projects/my-project/instances/my-instance/tables/my-table", consistency_token: "123"]
      mocked_tables.expect :generate_consistency_token, OpenStruct.new(consistency_token: "123"), [name: "projects/my-project/instances/my-instance/tables/my-table"]
      mocked_tables.expect :check_consistency, OpenStruct.new(consistent: true), [name: "projects/my-project/instances/my-instance/tables/my-table", consistency_token: "123"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table::ClusterState" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :FULL]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table::List" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_tables.expect :get_table, table_resp, [name: "projects/my-project/instances/my-instance/tables/my-table", view: :SCHEMA_VIEW]
      mocked_tables.expect :list_tables, tables_resp, [parent: "projects/my-project/instances/my-instance", view: nil]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Table::RestoreJob" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, [name: "projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_tables.expect :get_backup, backup_resp, [name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/my-backup"]
      mocked_tables.expect :restore_table, mocked_job, [Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

end

# Stubs

# Fixtures
def project
  "my-project"
end
alias project_id project

def project_path
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths.project_path(project: project_id)
end

def instance_path instance_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths.instance_path(
    project: project_id,
    instance: instance_id
  )
end

def cluster_path instance_id, cluster_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths.cluster_path(
    project: project_id,
    instance: instance_id,
    cluster: cluster_id
  )
end

def location_path location
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths.location_path(
    project: project_id,
    location: location
  )
end

def table_path instance_id, table_id
  Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Paths.table_path(
    project: project_id,
    instance: instance_id,
    table: table_id
  )
end

def snapshot_path instance_id, cluster_id, snapshot_id
  Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Paths.snapshot_path(
    project: project_id,
    instance: instance_id,
    cluster: cluster_id,
    snapshot: snapshot_id
  )
end

def app_profile_path instance_id, app_profile_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths.app_profile_path(
    project: project_id,
    instance: instance_id,
    app_profile: app_profile_id
  )
end

def app_profile_create single_cluster_routing = false
  if single_cluster_routing
    Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      description: "App profile for user data instance",
      single_cluster_routing: Google::Cloud::Bigtable::Admin::V2::AppProfile::SingleClusterRouting.new(
        cluster_id: "my-cluster",
        allow_transactional_writes: true
      )
    )
  else
    Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      description: "App profile for user data instance",
      multi_cluster_routing_use_any: Google::Cloud::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny.new
    )
 end
end

def app_profile_resp name = "my-app-profile"
  Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
    name: "projects/my-project/instances/my-instance/appProfiles/#{name}"
  )
end

def app_profiles_resp count = 2
  arr = Array.new(count) do |i|
    app_profile_resp "my-app-profile-#{i}"
  end
  response_struct(
    OpenStruct.new app_profiles: arr
  )
end

def backup_hash name:, source_table:, expire_time: nil
  {
    name: name,
    source_table: source_table,
    expire_time: expire_time,
    encryption_info: {
      encryption_type: :GOOGLE_DEFAULT_ENCRYPTION
    }
  }.delete_if { |_, v| v.nil? }
end

def backup_resp backup_id = "my-backup"
  Google::Cloud::Bigtable::Admin::V2::Backup.new(
    backup_hash(
      name: "projects/my-project/instances/my-instance/clusters/my-cluster/backups/#{backup_id}",
      source_table: "projects/my-project/instances/my-instance/tables/my-table"
    )
  )
end

def backups_resp count = 2
  arr = Array.new(count) do |i|
    backup_resp "my-backup-#{i}"
  end
  response_struct(
    OpenStruct.new backups: arr
  )
end

def cluster_hash name: nil, nodes: nil, location: nil, storage_type: nil, state: nil
  {
    name: name,
    serve_nodes: nodes,
    location: location ? location_path(location) : nil,
    default_storage_type: storage_type,
    state: state
  }.delete_if { |_, v| v.nil? }
end

def clusters_hash num: 3, start_id: 1
  clusters = num.times.map do |i|
    cluster_hash(
      name: "instance-#{start_id + i}",
      nodes: 3,
      location: "us-east-1b",
      storage_type: :SSD,
      state: :READY
    )
  end

  { clusters: clusters }
end

def cluster_resp
  Google::Cloud::Bigtable::Admin::V2::Cluster.new(
    cluster_hash(
      name: cluster_path("my-instance", "my-cluster"),
      nodes: 3,
      location: "us-east-1b",
      storage_type: :SSD,
      state: :READY
    )
  )
end

def clusters_resp
  Google::Cloud::Bigtable::Admin::V2::ListClustersResponse.new(clusters_hash)
end

def cluster_state_hash state = nil
  {
    replication_state: state,
    encryption_info: [
      {
        encryption_type: :GOOGLE_DEFAULT_ENCRYPTION
      }
    ]
  }
end

def cluster_state_grpc state = nil
  Google::Cloud::Bigtable::Admin::V2::Table::ClusterState.new(
    cluster_state_hash(state)
  )
end

def cluster_states_grpc num: 3, start_id: 1
  num.times.each_with_object({}) do |i, r|
    r["cluster-#{i + start_id }"] = cluster_state_grpc(:READY)
  end
end

def column_family_hash(max_versions: nil, max_age: nil, intersection: nil, union: nil)
  gc_rule = {
    max_num_versions: max_versions,
    max_age: max_age ? { seconds: max_age} : nil,
    intersection: intersection ?  { rules: intersection } : nil,
    union: union ? { rules: union } : nil
  }.delete_if { |_, v| v.nil? }

  { gc_rule: gc_rule }
end

def column_families_hash num: 3
  num.times.each_with_object({}) do |i, r|
    r["cf#{i+1}"] = column_family_hash(max_versions: 3)
  end
end

def column_families_grpc num: 3
  column_families_hash(num: num)
    .each_with_object({}) do |(k,v), r|
    r[k] = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(v)
  end
end

def backup_iam_permissions_resp
  OpenStruct.new(
    permissions: ["bigtable.backups.get"]
  )
end

def instance_iam_permissions_resp
  OpenStruct.new(
    permissions: ["bigtable.instances.get"]
  )
end

def table_iam_permissions_resp
  OpenStruct.new(
    permissions: ["bigtable.tables.get"]
  )
end

def instance_hash name: nil, display_name: nil, state: nil, type: nil, labels: {}
  {
    name: name && instance_path(name),
    display_name: display_name,
    state: state,
    type: type,
    labels: labels
  }.delete_if { |_, v| v.nil? }
end

def instances_hash num: 3, start_id: 1
  instances = num.times.map do |i|
    instance_hash(
      name: "instance-#{start_id + i}",
      display_name: "Test instance #{start_id + i}",
      state: :READY,
      type: :PRODUCTION
    )
  end

  { instances: instances }
end

def instance_resp
  get_res = Google::Cloud::Bigtable::Admin::V2::Instance.new(
    instance_hash(
      name: "my-instance",
      display_name: "My instance",
      state: :READY,
      type: :PRODUCTION
    )
  )
end

def instances_resp token: nil
  h = instances_hash
  h[:next_page_token] = token if token
  response = Google::Cloud::Bigtable::Admin::V2::ListInstancesResponse.new h
  #paged_enum_struct response
end

def job_grpc done: false
  Google::Longrunning::Operation.new(
    name: nil,
    metadata: Google::Protobuf::Any.new(
      type_url: "type.googleapis.com/google.bigtable.admin.v2.UpdateClusterMetadata",
      value: Google::Cloud::Bigtable::Admin::V2::UpdateClusterMetadata.new.to_proto
    ),
    done: done,
    response: Google::Protobuf::Any.new(
      type_url: "type.googleapis.com/google.bigtable.admin.v2.AppProfile",
      value: nil
    )
  )
end

def mutate_row_resp
  Google::Cloud::Bigtable::V2::MutateRowResponse.new
end

def viewer_policy_json
  {
    etag: "YWJj",
    bindings: [{
                 role: "roles/viewer",
                 members: [
                   "user:viewer@example.com",
                   "serviceAccount:1234567890@developer.gserviceaccount.com"
                 ]
               }]
  }.to_json
end

def owner_policy_json
  {
    etag: "YWJj",
    bindings: [{
                 role: "roles/owner",
                 members: [
                   "user:owner@example.com",
                   "serviceAccount:0987654321@developer.gserviceaccount.com"
                 ]
               }]
  }.to_json
end

def policy_resp
  Google::Iam::V1::Policy.decode_json(viewer_policy_json)
end

def table_hash name: nil, cluster_states: nil, column_families: nil, granularity: nil
  {
    name: name,
    cluster_states: cluster_states,
    column_families: column_families,
    granularity: granularity
  }.delete_if { |_, v| v.nil? }
end

def tables_hash instance_id, num: 3, start_id: 1
  tables = num.times.map do |i|
    table_hash(
      name: table_path(instance_id, "my-table-#{start_id + i}"),
      cluster_states: cluster_states_grpc,
      column_families: column_families_grpc,
      granularity: :MILLIS
    )
  end

  { tables: tables }
end

def table_resp
  Google::Cloud::Bigtable::Admin::V2::Table.new(
    table_hash(
      name: "projects/my-project/instances/my-instance/tables/my-table",
      cluster_states: cluster_states_grpc,
      column_families: column_families_grpc,
      granularity: :MILLIS
    )
  )
end

def tables_resp
  response_struct(
    OpenStruct.new(
      tables: tables_hash("my-instance", num: 3, start_id: 1)[:tables].map do |t|
        Google::Cloud::Bigtable::Admin::V2::Table.new(t)
      end
    )
  )
end

def paged_enum_struct response
  OpenStruct.new page: response_struct(response)
end

def response_struct response
  OpenStruct.new(response: response)
end
