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
    if block_given?
      yield service.mocked_client, service.mocked_instances, service.mocked_tables
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
    end
  end

  doctest.before "Google::Cloud::Bigtable.new" do
    mock_bigtable do |mock, mocked_instances, mocked_tables|
    end
  end

  #doctest.skip "Google::Cloud::Bigtable::Credentials" # occasionally getting "This code example is not yet mocked"

  # Instance

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

  # Google::Cloud::Bigtable::ColumnFamily
  # Google::Cloud::Bigtable::ColumnFamily#create
  # Google::Cloud::Bigtable::ColumnFamily#save
  #
  # Google::Cloud::Bigtable::ColumnFamily#delete
  # Google::Cloud::Bigtable::ColumnFamily.create_modification
  # Google::Cloud::Bigtable::ColumnFamily.update_modification
  # Google::Cloud::Bigtable::ColumnFamily.drop_modification
  # Google::Cloud::Bigtable::Cluster
  # Google::Cloud::Bigtable::Cluster::Job
  # Google::Cloud::Bigtable::Cluster::Job#cluster
  # Google::Cloud::Bigtable::Cluster::List#next?
  # Google::Cloud::Bigtable::Cluster::List#next
  # Google::Cloud::Bigtable::Cluster::List#all
  # Google::Cloud::Bigtable::Cluster::List#all
  # Google::Cloud::Bigtable::ColumnRange
  # Google::Cloud::Bigtable::ColumnRange#from
  # Google::Cloud::Bigtable::ColumnRange#from
  # Google::Cloud::Bigtable::ColumnRange#to
  # Google::Cloud::Bigtable::ColumnRange#to
  # Google::Cloud::Bigtable::ColumnRange#between
  # Google::Cloud::Bigtable::ColumnRange#of
  # Google::Cloud::Bigtable::Project
  # Google::Cloud::Bigtable::Project#project_id
  # Google::Cloud::Bigtable::Project#instances
  # Google::Cloud::Bigtable::Project#instance
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
  # Google::Cloud::Bigtable::Cluster#save
  # Google::Cloud::Bigtable::Cluster#update
  # Google::Cloud::Bigtable::Cluster#delete
  # Google::Cloud::Bigtable::ValueRange
  # Google::Cloud::Bigtable::ValueRange#from
  # Google::Cloud::Bigtable::ValueRange#from
  # Google::Cloud::Bigtable::ValueRange#to
  # Google::Cloud::Bigtable::ValueRange#to
  # Google::Cloud::Bigtable::ValueRange#between
  # Google::Cloud::Bigtable::ValueRange#of
  # Google::Cloud::Bigtable::ReadModifyWriteRule
  # Google::Cloud::Bigtable::ReadModifyWriteRule
  # Google::Cloud::Bigtable::ReadModifyWriteRule.append
  # Google::Cloud::Bigtable::ReadModifyWriteRule.increment
  # Google::Cloud::Bigtable::Policy
  # Google::Cloud::Bigtable::Policy#add
  # Google::Cloud::Bigtable::Policy#remove
  # Google::Cloud::Bigtable::Policy#role
  # Google::Cloud::Bigtable::MutationEntry
  # Google::Cloud::Bigtable::MutationEntry
  # Google::Cloud::Bigtable::MutationEntry#set_cell
  # Google::Cloud::Bigtable::MutationEntry#set_cell
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_cells
  # Google::Cloud::Bigtable::MutationEntry#delete_from_family
  # Google::Cloud::Bigtable::MutationEntry#delete_from_row
  # Google::Cloud::Bigtable::RowRange
  # Google::Cloud::Bigtable::RowRange#from
  # Google::Cloud::Bigtable::RowRange#from
  # Google::Cloud::Bigtable::RowRange#to
  # Google::Cloud::Bigtable::RowRange#to
  # Google::Cloud::Bigtable::RowRange#between
  # Google::Cloud::Bigtable::RowRange#of
  # Google::Cloud::Bigtable::Table::ColumnFamilyMap
  # Google::Cloud::Bigtable::Table::ColumnFamilyMap#add
  # Google::Cloud::Bigtable::Table::List#next?
  # Google::Cloud::Bigtable::Table::List#next
  # Google::Cloud::Bigtable::Table::List#all
  # Google::Cloud::Bigtable::Table::List#all
  # Google::Cloud::Bigtable::Instance
  # Google::Cloud::Bigtable::Instance::ClusterMap
  # Google::Cloud::Bigtable::Instance::Job
  # Google::Cloud::Bigtable::Instance::Job#instance
  # Google::Cloud::Bigtable::Instance::List#next?
  # Google::Cloud::Bigtable::Instance::List#next
  # Google::Cloud::Bigtable::Instance::List#all
  # Google::Cloud::Bigtable::Instance::List#all
  # Google::Cloud::Bigtable::AppProfile
  # Google::Cloud::Bigtable::AppProfile#routing_policy=
  # Google::Cloud::Bigtable::AppProfile#routing_policy=
  # Google::Cloud::Bigtable::AppProfile#delete
  # Google::Cloud::Bigtable::AppProfile#save
  # Google::Cloud::Bigtable::AppProfile#save
  # Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
  # Google::Cloud::Bigtable::AppProfile.single_cluster_routing
  # Google::Cloud::Bigtable::SampleRowKey
  # Google::Cloud::Bigtable::AppProfile::Job
  # Google::Cloud::Bigtable::AppProfile::Job#app_profile
  # Google::Cloud::Bigtable::AppProfile::List#next?
  # Google::Cloud::Bigtable::AppProfile::List#next
  # Google::Cloud::Bigtable::AppProfile::List#all
  # Google::Cloud::Bigtable::AppProfile::List#all
  # Google::Cloud::Bigtable::Instance#save
  #
  # Google::Cloud::Bigtable::Instance#delete
  # Google::Cloud::Bigtable::Instance#clusters
  # Google::Cloud::Bigtable::Instance#cluster
  # Google::Cloud::Bigtable::Instance#create_cluster
  # Google::Cloud::Bigtable::Instance#tables
  # Google::Cloud::Bigtable::Instance#table
  # Google::Cloud::Bigtable::Instance#table
  # Google::Cloud::Bigtable::Instance#create_table
  # Google::Cloud::Bigtable::Instance#create_table
  # Google::Cloud::Bigtable::Instance#create_app_profile
  # Google::Cloud::Bigtable::Instance#create_app_profile
  # Google::Cloud::Bigtable::Instance#create_app_profile
  # Google::Cloud::Bigtable::Instance#app_profile
  # Google::Cloud::Bigtable::Instance#app_profiles
  # Google::Cloud::Bigtable::Instance#policy
  # Google::Cloud::Bigtable::Instance#policy
  # Google::Cloud::Bigtable::Instance#update_policy
  #
  # Google::Cloud::Bigtable::Instance#test_iam_permissions
  # Google::Cloud::Bigtable::GcRule
  # Google::Cloud::Bigtable::GcRule
  # Google::Cloud::Bigtable::GcRule
  # Google::Cloud::Bigtable::GcRule

end

# Stubs

# Fixtures
def project
  "my-project"
end

def instance_hash name: nil, display_name: nil, state: nil, type: nil, labels: {}
  {
    name: name,
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
      name: "found-instance",
      display_name: "Test instance",
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
