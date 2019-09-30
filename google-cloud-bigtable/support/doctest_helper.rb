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
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable.new" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
    end
  end

  # AppProfile

  doctest.before "Google::Cloud::Bigtable::AppProfile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Google::Bigtable::Admin::V2::AppProfile, Google::Protobuf::FieldMask, Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_instances.expect :delete_app_profile, nil, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile", false]

    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#delete" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :delete_app_profile, nil, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile", true]
      mocked_instances.expect :delete_app_profile, nil, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile", false]
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#save@Update" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Google::Bigtable::Admin::V2::AppProfile, Google::Protobuf::FieldMask, Hash]
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error, nil, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::AppProfile#save@Update with single cluster routing" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Google::Bigtable::Admin::V2::AppProfile, Google::Protobuf::FieldMask, Hash]
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
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
      mocked_instances.expect :update_app_profile, mocked_job, [Google::Bigtable::Admin::V2::AppProfile, Google::Protobuf::FieldMask, Hash]
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
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, ["projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :update_cluster, mocked_job, ["projects/my-project/instances/my-instance/clusters/my-cluster", "projects/my-project/locations/us-east-1b", 3]
      mocked_instances.expect :delete_cluster, true, ["projects/my-project/instances/my-instance/clusters/my-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Cluster#save" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, ["projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :update_cluster, mocked_job, ["projects/my-project/instances/my-instance/clusters/my-cluster", "projects/my-project/locations/us-east-1b", 3]
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
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_cluster, mocked_job,  ["projects/my-project/instances/my-instance", "my-new-cluster", Google::Bigtable::Admin::V2::Cluster]
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
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, ["projects/my-project/instances/my-instance/clusters/my-cluster"]
      mocked_instances.expect :list_clusters, clusters_resp, ["projects/my-project/instances/-", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::ColumnFamily" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_tables.expect :get_table, table_resp, ["projects/my-project/instances/my-instance/tables/my-table", { view: :SCHEMA_VIEW }]
      mocked_tables.expect :modify_column_families, table_resp, ["projects/my-project/instances/my-instance/tables/my-table", Array]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :create_instance, mocked_job, ["projects/my-project", "my-instance", Google::Bigtable::Admin::V2::Instance, Hash]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#app_profile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance/appProfiles/my-app-profile"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#app_profiles" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_app_profiles, app_profiles_resp, ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :get_cluster, cluster_resp, ["projects/my-project/instances/my-instance/clusters/my-instance-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#clusters" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :list_clusters, clusters_resp, ["projects/my-project/instances/my-instance", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_app_profile" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance", "my-app-profile", app_profile_create, Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_app_profile@Create an app profile with a single cluster routing policy" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_app_profile, app_profile_resp, ["projects/my-project/instances/my-instance", "my-app-profile", app_profile_create(true), Hash]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#create_cluster" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :create_cluster, cluster_resp, ["projects/my-project/instances/my-instance/clusters/my-instance-cluster"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Instance#save" do
    mock_bigtable do |mock, mocked_instances, mocked_tables, mocked_job|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
      mocked_instances.expect :partial_update_instance, mocked_job, [Google::Bigtable::Admin::V2::Instance, Google::Protobuf::FieldMask]
      mocked_job.expect :done?, false, []
      mocked_job.expect :wait_until_done!, nil, []
      mocked_job.expect :done?, true, []
      mocked_job.expect :error?, true, []
      mocked_job.expect :error?, false, []
    end
  end



  # Google::Cloud::Bigtable::Instance
  # Google::Cloud::Bigtable::Instance#delete
  # Google::Cloud::Bigtable::Instance#create_cluster
  # Google::Cloud::Bigtable::Instance#tables
  # Google::Cloud::Bigtable::Instance#table
  # Google::Cloud::Bigtable::Instance#table
  # Google::Cloud::Bigtable::Instance#create_table
  # Google::Cloud::Bigtable::Instance#create_table
  # Google::Cloud::Bigtable::Instance#policy
  # Google::Cloud::Bigtable::Instance#policy
  # Google::Cloud::Bigtable::Instance#update_policy
  # Google::Cloud::Bigtable::Instance#test_iam_permissions
  # Google::Cloud::Bigtable::Instance::ClusterMap
  # Google::Cloud::Bigtable::Instance::Job
  # Google::Cloud::Bigtable::Instance::Job#instance
  # Google::Cloud::Bigtable::Instance::List#next?
  # Google::Cloud::Bigtable::Instance::List#next
  # Google::Cloud::Bigtable::Instance::List#all
  # Google::Cloud::Bigtable::Instance::List#all
  # Google::Cloud::Bigtable::MutationEntry
  # Google::Cloud::Bigtable::MutationEntry
  # Google::Cloud::Bigtable::MutationEntry#set_cell
  # Google::Cloud::Bigtable::MutationEntry#set_cell
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_from_family
  # Google::Cloud::Bigtable::MutationEntry#delete_from_row
  # Google::Cloud::Bigtable::MutationOperations#mutate_row
  # Google::Cloud::Bigtable::MutationOperations#mutate_row
  # Google::Cloud::Bigtable::MutationOperations#mutate_rows
  # Google::Cloud::Bigtable::MutationOperations#read_modify_write_row
  # Google::Cloud::Bigtable::MutationOperations#read_modify_write_row
  # Google::Cloud::Bigtable::MutationOperations#check_and_mutate_row
  # Google::Cloud::Bigtable::MutationOperations#sample_row_keys
  # Google::Cloud::Bigtable::MutationOperations#new_mutation_entry
  # Google::Cloud::Bigtable::MutationOperations#new_read_modify_write_rule
  # Google::Cloud::Bigtable::MutationOperations#new_read_modify_write_rule
  # Google::Cloud::Bigtable::Policy
  # Google::Cloud::Bigtable::Policy#add
  # Google::Cloud::Bigtable::Policy#remove
  # Google::Cloud::Bigtable::Policy#role
  # Google::Cloud::Bigtable::Project
  # Google::Cloud::Bigtable::Project#project_id
  # Google::Cloud::Bigtable::Project#instances
  # Google::Cloud::Bigtable::Project#instance

  doctest.before "Google::Cloud::Bigtable::Project#instance" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :get_instance, instance_resp, ["projects/my-project/instances/my-instance"]
    end
  end

  doctest.before "Google::Cloud::Bigtable::Project#instances" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
      mocked_instances.expect :list_instances, instances_resp, ["projects/my-project", { page_token: nil }]
    end
  end
  # Google::Cloud::Bigtable::Project#create_instance
  # Google::Cloud::Bigtable::Project#create_instance
  # Google::Cloud::Bigtable::Project#clusters
  # Google::Cloud::Bigtable::Project#tables
  # Google::Cloud::Bigtable::Project#table
  # Google::Cloud::Bigtable::Project#table
  # Google::Cloud::Bigtable::Project#table
  # Google::Cloud::Bigtable::Project#table
  # Google::Cloud::Bigtable::Project#table
  # Google::Cloud::Bigtable::Project#create_table
  # Google::Cloud::Bigtable::Project#create_table
  # Google::Cloud::Bigtable::Project#delete_table
  # Google::Cloud::Bigtable::Project#modify_column_families
  # Google::Cloud::Bigtable::ReadModifyWriteRule
  # Google::Cloud::Bigtable::ReadModifyWriteRule
  # Google::Cloud::Bigtable::ReadModifyWriteRule.append
  # Google::Cloud::Bigtable::ReadModifyWriteRule.increment
  # Google::Cloud::Bigtable::ReadOperations#sample_row_keys
  # Google::Cloud::Bigtable::ReadOperations#read_rows
  # Google::Cloud::Bigtable::ReadOperations#read_rows
  # Google::Cloud::Bigtable::ReadOperations#read_rows
  # Google::Cloud::Bigtable::ReadOperations#read_rows
  # Google::Cloud::Bigtable::ReadOperations#read_rows
  # Google::Cloud::Bigtable::ReadOperations#read_row
  # Google::Cloud::Bigtable::ReadOperations#read_row
  # Google::Cloud::Bigtable::ReadOperations#new_value_range
  # Google::Cloud::Bigtable::ReadOperations#new_value_range
  # Google::Cloud::Bigtable::ReadOperations#new_column_range
  # Google::Cloud::Bigtable::ReadOperations#new_column_range
  # Google::Cloud::Bigtable::ReadOperations#new_row_range
  # Google::Cloud::Bigtable::ReadOperations#new_row_range
  # Google::Cloud::Bigtable::ReadOperations#filter
  # Google::Cloud::Bigtable::RowFilter
  # Google::Cloud::Bigtable::RowFilter.chain
  # Google::Cloud::Bigtable::RowFilter.chain
  # Google::Cloud::Bigtable::RowFilter.interleave
  # Google::Cloud::Bigtable::RowFilter.interleave
  # Google::Cloud::Bigtable::RowFilter.condition
  # Google::Cloud::Bigtable::RowFilter.pass
  # Google::Cloud::Bigtable::RowFilter.block
  # Google::Cloud::Bigtable::RowFilter.sink
  # Google::Cloud::Bigtable::RowFilter.strip_value
  # Google::Cloud::Bigtable::RowFilter.key
  # Google::Cloud::Bigtable::RowFilter.sample
  # Google::Cloud::Bigtable::RowFilter.family
  # Google::Cloud::Bigtable::RowFilter.qualifier
  # Google::Cloud::Bigtable::RowFilter.value
  # Google::Cloud::Bigtable::RowFilter.label
  # Google::Cloud::Bigtable::RowFilter.cells_per_row_offset
  # Google::Cloud::Bigtable::RowFilter.cells_per_row
  # Google::Cloud::Bigtable::RowFilter.cells_per_column
  # Google::Cloud::Bigtable::RowFilter.timestamp_range
  # Google::Cloud::Bigtable::RowFilter.value_range
  # Google::Cloud::Bigtable::RowFilter.value_range
  # Google::Cloud::Bigtable::RowFilter.column_range
  # Google::Cloud::Bigtable::RowFilter::ChainFilter
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#chain
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#interleave
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#condition
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#pass
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#block
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#sink
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#strip_value
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#key
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#sample
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#family
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#qualifier
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#value
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#label
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#cells_per_row_offset
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#cells_per_row
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#cells_per_column
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#timestamp_range
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#value_range
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#value_range
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#column_range
  # Google::Cloud::Bigtable::RowFilter::ChainFilter#length
  # Google::Cloud::Bigtable::RowFilter::ConditionFilter
  # Google::Cloud::Bigtable::RowFilter::ConditionFilter#on_match
  # Google::Cloud::Bigtable::RowFilter::ConditionFilter#otherwise
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#chain
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#interleave
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#condition
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#pass
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#block
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#sink
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#strip_value
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#key
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#sample
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#family
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#qualifier
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#value
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#label
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#cells_per_row_offset
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#cells_per_row
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#cells_per_column
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#timestamp_range
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#value_range
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#value_range
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#column_range
  # Google::Cloud::Bigtable::RowFilter::InterleaveFilter#length
  # Google::Cloud::Bigtable::RowRange
  # Google::Cloud::Bigtable::RowRange#from
  # Google::Cloud::Bigtable::RowRange#from
  # Google::Cloud::Bigtable::RowRange#to
  # Google::Cloud::Bigtable::RowRange#to
  # Google::Cloud::Bigtable::RowRange#between
  # Google::Cloud::Bigtable::RowRange#of
  # Google::Cloud::Bigtable::SampleRowKey
  # Google::Cloud::Bigtable::Table
  # Google::Cloud::Bigtable::Table#delete
  # Google::Cloud::Bigtable::Table#exists?
  # Google::Cloud::Bigtable::Table#exists?
  # Google::Cloud::Bigtable::Table#column_family
  # Google::Cloud::Bigtable::Table#column_family
  # Google::Cloud::Bigtable::Table#column_family
  # Google::Cloud::Bigtable::Table#modify_column_families
  # Google::Cloud::Bigtable::Table#generate_consistency_token
  # Google::Cloud::Bigtable::Table#check_consistency
  # Google::Cloud::Bigtable::Table#wait_for_replication
  # Google::Cloud::Bigtable::Table#delete_all_rows
  # Google::Cloud::Bigtable::Table#delete_rows_by_prefix
  # Google::Cloud::Bigtable::Table#drop_row_range
  # Google::Cloud::Bigtable::Table::ColumnFamilyMap
  # Google::Cloud::Bigtable::Table::ColumnFamilyMap#add
  # Google::Cloud::Bigtable::Table::List#next?
  # Google::Cloud::Bigtable::Table::List#next
  # Google::Cloud::Bigtable::Table::List#all
  # Google::Cloud::Bigtable::Table::List#all
  # Google::Cloud::Bigtable::ValueRange
  # Google::Cloud::Bigtable::ValueRange#from
  # Google::Cloud::Bigtable::ValueRange#from
  # Google::Cloud::Bigtable::ValueRange#to
  # Google::Cloud::Bigtable::ValueRange#to
  # Google::Cloud::Bigtable::ValueRange#between
  # Google::Cloud::Bigtable::ValueRange#of

end

# Stubs

# Fixtures
def project
  "my-project"
end
alias project_id project

def project_path
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path(project_id)
end

def instance_path instance_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path(
    project_id,
    instance_id
  )
end

def cluster_path instance_id, cluster_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path(
    project_id,
    instance_id,
    cluster_id
  )
end

def location_path location
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.location_path(
    project_id,
    location
  )
end

def table_path instance_id, table_id
  Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path(
    project_id,
    instance_id,
    table_id
  )
end

def snapshot_path instance_id, cluster_id, snapshot_id
  Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path(
    project_id,
    instance_id,
    cluster_id,
    snapshot_id
  )
end

def app_profile_path instance_id, app_profile_id
  Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path(
    project_id,
    instance_id,
    app_profile_id
  )
end

def app_profile_create single_cluster_routing = false
  if single_cluster_routing
    Google::Bigtable::Admin::V2::AppProfile.new(
      description: "App profile for user data instance",
      single_cluster_routing: Google::Bigtable::Admin::V2::AppProfile::SingleClusterRouting.new(
        cluster_id: "my-instance-cluster-1",
        allow_transactional_writes: true
      )
    )
  else
    Google::Bigtable::Admin::V2::AppProfile.new(
      description: "App profile for user data instance",
      multi_cluster_routing_use_any: Google::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny.new
    )
 end
end

def app_profile_resp name = "my-app-profile"
  Google::Bigtable::Admin::V2::AppProfile.new(
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
  Google::Bigtable::Admin::V2::Cluster.new(
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
  Google::Bigtable::Admin::V2::ListClustersResponse.new(clusters_hash)
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

def column_families_hash num: 3, start_id: 1
  num.times.each_with_object({}) do |i, r|
    r["cf"] = column_family_hash(max_versions: 3)
  end
end

def column_families_grpc num: 3, start_id: 1
  column_families_hash(num: num, start_id: start_id)
    .each_with_object({}) do |(k,v), r|
    r[k] = Google::Bigtable::Admin::V2::ColumnFamily.new(v)
  end
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
  get_res = Google::Bigtable::Admin::V2::Instance.new(
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
  response = Google::Bigtable::Admin::V2::ListInstancesResponse.new h
  #paged_enum_struct response
end

def job_grpc done: false
  Google::Longrunning::Operation.new(
    name: nil,
    metadata: Google::Protobuf::Any.new(
      type_url: "type.googleapis.com/google.bigtable.admin.v2.UpdateClusterMetadata",
      value: Google::Bigtable::Admin::V2::UpdateClusterMetadata.new.to_proto
    ),
    done: done,
    response: Google::Protobuf::Any.new(
      type_url: "type.googleapis.com/google.bigtable.admin.v2.AppProfile",
      value: nil
    )
  )
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
      cluster_states: clusters_state_grpc,
      column_families: column_families_grpc,
      granularity: :MILLIS
    )
  end

  { tables: tables }
end

def table_resp
  Google::Bigtable::Admin::V2::Table.new(
    table_hash(
      name: "my-table",
      column_families: column_families_grpc,
      granularity: :MILLIS
    )
  )
end

def tables_resp
  tables_hash("my-instance", num: 3, start_id: 1)[:tables].map do |t|
    Google::Bigtable::Admin::V2::Table.new(t)
  end
end

def paged_enum_struct response
  OpenStruct.new page: response_struct(response)
end

def response_struct response
  OpenStruct.new(response: response)
end
