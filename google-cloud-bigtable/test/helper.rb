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
  attr_accessor :mocked_instances

  def instances
    mocked_instances || super
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

  def paged_enum_struct response
    OpenStruct.new(page: OpenStruct.new(response: response))
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

def load_acceptance_test_json_data file_name
  file = "#{File.dirname(__FILE__)}/../acceptance/data/#{file_name}.json"
  JSON.parse(File.read(file))
end
