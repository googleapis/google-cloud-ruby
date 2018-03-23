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

require 'helper'
require 'google/cloud/bigtable/instance_set'

describe Google::Cloud::Bigtable::InstanceSet do
  let(:project_id) {"project_#{Time.now.to_i}"}
  let(:config) {Google::Cloud::Bigtable::Config.new project_id}
  let(:instance_set) {Google::Cloud::Bigtable::InstanceSet.new config}
  let(:instance_id) {"instance_id_#{Time.now.to_i}"}

  describe '#initialize' do
    it 'should be Enumerable' do
      assert_includes Google::Cloud::Bigtable::InstanceSet.included_modules, Enumerable
    end
  end

  describe '#instances' do
    it 'should allow enumeration over empty set of instances' do
      response = OpenStruct.new instances: []
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [config.project_path, page_token: nil]

      instance_set.stub(:client, mock_instance_client) do
        assert_equal instance_set.to_a.count, 0
      end

      mock_instance_client.verify
    end

    it 'should allow enumeration over single page of instances' do
      instance_objects = [OpenStruct.new(name: config.instance_path(instance_id))]*10
      response = OpenStruct.new instances: instance_objects
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [config.project_path, page_token: nil]

      instance_set.stub(:client, mock_instance_client) do
        ary = instance_set.map { |m| m.name}.to_a
        assert_equal ary.count, instance_objects.count
        instance_objects.each do |ob|
          assert_includes ary, ob.name
        end
      end

      mock_instance_client.verify
    end

    it 'should allow enumeration over multiple pages of instances' do
      token = "token_#{Time.now}"

      instance_objects = [OpenStruct.new(name: config.instance_path(instance_id))]*10
      response = OpenStruct.new instances: instance_objects, next_page_token: token
      
      instance_objects2 = [OpenStruct.new(name: config.instance_path(instance_id))]*5
      response2 = OpenStruct.new instances: instance_objects2, next_page_token: nil
      
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [config.project_path, page_token: nil]
      mock_instance_client.expect :list_instances, response2, [config.project_path, page_token: token]

      instance_set.stub(:client, mock_instance_client) do
        ary = instance_set.map { |m| m.name}.to_a
        assert_equal ary.count, 15
        instance_objects.each do |ob|
          assert_includes ary, ob.name
        end
        instance_objects2.each do |ob|
          assert_includes ary, ob.name
        end
      end

      mock_instance_client.verify
    end


    it 'should break iteration if next_page_token is blank' do
      instance_objects = [OpenStruct.new(name: config.instance_path(instance_id))]*10
      response = OpenStruct.new instances: instance_objects, next_page_token: ''
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [config.project_path, page_token: nil]

      instance_set.stub(:client, mock_instance_client) do
        ary = instance_set.map { |m| m.name}.to_a
        assert_equal ary.count, instance_objects.count
        instance_objects.each do |ob|
          assert_includes ary, ob.name
        end
      end

      mock_instance_client.verify
    end
  end

  describe '#find' do
    it 'should return an instance for a given id' do
      response = OpenStruct.new name: instance_id, state: :READY, display_name: 'Instance Name'
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :get_instance, response, [config.instance_path(instance_id)]

      instance_set.stub(:client, mock_instance_client) do
        instance = instance_set.find instance_id
        assert_equal instance.name, instance_id
        assert_equal instance.display_name, 'Instance Name'
      end

      mock_instance_client.verify
    end
  end

  describe '#create!' do
    let(:instance_id) {"instance_id_#{Time.now.to_i}"}

    it 'should create an instance with the given instance id/name' do
      clusters = [Google::Cloud::Bigtable::Cluster.new(cluster_id: 'cluster_name', location: 'zone')]
      mock_operation = Minitest::Mock.new
      mock_operation.expect :wait_until_done!, nil
      mock_operation.expect :response, OpenStruct.new(name: instance_id)
      
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :create_instance, mock_operation, 
        [config.project_path, instance_id, {"display_name"=>"name", "type"=>:DEVELOPMENT, "labels"=>{}}, 
          {'cluster_name' => clusters.first.to_proto_ob}, {}]

      instance_set.stub(:client, mock_instance_client) do
        instance = instance_set.create! instance_id: instance_id,
                                        display_name: "name",
                                        clusters: clusters
        assert_equal instance.name, instance_id
        assert_instance_of Google::Cloud::Bigtable::Instance, instance
      end

      mock_instance_client.verify
      mock_operation.verify
    end
  end
end
