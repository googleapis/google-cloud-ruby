# frozen_string_literal: true

# Copyright 2018 Google LLC
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

require "minitest/autorun"
require "minitest/spec"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "grpc"
require "google/cloud/bigtable"
require "google/cloud/bigtable/project"

class BigtableServiceWithMock < Google::Cloud::Bigtable::Service
  attr_accessor :mocked_instances, :mocked_tables, :mocked_client

  def instances
    mocked_instances || super
  end

  def tables
    mocked_tables || super
  end

  def client
    mocked_client || super
  end
end

class MockBigtable < Minitest::Spec
  let(:project_id) { "test" }
  let(:credentials) do
    OpenStruct.new(client: OpenStruct.new(updater_proc: proc {}))
  end
  let(:service) { BigtableServiceWithMock.new(project_id, credentials) }
  let(:bigtable) { Google::Cloud::Bigtable::Project.new(service) }

  register_spec_type(self) do |_desc, *addl|
    addl.include? :mock_bigtable
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

  def gc_rule_hash(max_versions: nil, max_age: nil, intersection: nil, union: nil)
    {
      max_num_versions: max_versions,
      max_age: max_age ? { seconds: max_age} : nil,
      intersection: intersection ?  { rules: intersection } : nil,
      union: union ? { rules: union } : nil
    }.delete_if { |_, v| v.nil? }
  end

  def column_family_hash(max_versions: nil, max_age: nil, intersection: nil, union: nil)
    {
      gc_rule: gc_rule_hash(max_versions: max_versions, max_age: max_age, intersection: intersection, union: union)
    }
  end

  def column_families_hash num: 3, start_id: 1, max_versions: 3
    num.times.each_with_object({}) do |i, r|
      r["cf#{i + start_id}"] = column_family_hash(max_versions: max_versions)
    end
  end

  def column_families_grpc num: 3, start_id: 1, max_versions: 3
    column_families_hash(num: num, start_id: start_id, max_versions: max_versions)
      .each_with_object({}) do |(k,v), r|
        r[k] = Google::Bigtable::Admin::V2::ColumnFamily.new(v)
      end
  end

  def cluster_state_hash state = nil
    { replication_state: state }
  end

  def cluster_state_grpc state = nil
     Google::Bigtable::Admin::V2::Table::ClusterState.new(
       cluster_state_hash(state)
     )
  end

  def clusters_state_grpc num: 3, start_id: 1
    num.times.each_with_object({}) do |i, r|
      r["cluster-#{i + start_id }"] = cluster_state_grpc(:READY)
    end
  end

  def multi_cluster_routing_grpc
    Google::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny.new
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
        name: table_path(instance_id, "table-#{start_id + i}"),
        cluster_states: clusters_state_grpc,
        column_families: column_families_grpc,
        granularity: :MILLIS
      )
    end

    { tables: tables }
  end

  def tables_grpc instance_id, num: 3, start_id: 1
   tables_hash(instance_id, num: num, start_id: start_id)[:tables].map do |t|
     Google::Bigtable::Admin::V2::Table.new(t)
   end
  end

  def app_profile_grpc instance_id, app_profile_id
    Google::Bigtable::Admin::V2::AppProfile.new(
      name: "projects/test/instances/#{instance_id}/appProfiles/#{app_profile_id}"
    )
  end

  def app_profiles_grpc count: 2
    arr = Array.new(count) do |i|
      app_profile_grpc "my-instance", "my-app-profile-#{i}"
    end
    Google::Bigtable::Admin::V2::ListAppProfilesResponse.new app_profiles: arr
  end

  def backup_grpc instance_id,
                  cluster_id,
                  backup_id,
                  source_table_id,
                  expire_time,
                  start_time: nil,
                  end_time: nil,
                  size_bytes: 123456,
                  state: :READY
    now = Time.now.round 0
    start_time ||= now + 60
    end_time ||= now + 120

    Google::Bigtable::Admin::V2::Backup.new(
      name: backup_path(instance_id, cluster_id, backup_id),
      source_table: table_path(instance_id, source_table_id),
      expire_time: expire_time,
      start_time: start_time,
      end_time: end_time,
      size_bytes: size_bytes,
      state: state
    )
  end

  def backups_grpc count: 2, expire_time: (Time.now + 60 * 60 * 7)
    expire_time = Time.now.round(0) + 60 * 60 * 7
    arr = Array.new(count) do |i|
      backup_grpc "my-instance", "my-cluster", "my-backup-#{i}", "my-source-table", expire_time
    end
    Google::Bigtable::Admin::V2::ListBackupsResponse.new backups: arr
  end

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

  def backup_path instance_id, cluster_id, backup_id
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.backup_path(
      project_id,
      instance_id,
      cluster_id,
      backup_id
    )
  end

  def paged_enum_struct response
    OpenStruct.new(page: OpenStruct.new(response: response))
  end

  # A microseconds integer rounded to the nearest millisecond. For example: `1564257960168000`.
  def timestamp_micros
    (Time.now.to_f * 1000000).round(-3)
  end

  def operation_pending_grpc ops_name, metadata_type_url
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: metadata_type_url,
        value: ""
      )
    )
  end

  def operation_done_grpc ops_name, metadata_type_url, metadata_value_grpc, response_type_url, response_value_grpc
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: metadata_type_url,
        value: metadata_value_grpc.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: response_type_url,
        value: response_value_grpc.to_proto
      )
    )
  end
end

class MockPagedEnumerable
  def initialize(responses = [])
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

def read_rows_acceptance_test_data
  file = "#{File.dirname(__FILE__)}/../acceptance/data/read-rows-acceptance-test.json"
  data = JSON.parse(File.read(file))

  tests = { with_errors: [], without_errors: [] }
  data["tests"].each do |t|
    if t["results"] && t["results"].any? { |r| r["error"] }
      tests[:with_errors] << t
    else
      tests[:without_errors] << t
    end
  end

  tests
end
