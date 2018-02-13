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

require 'minitest/autorun'
require 'minitest/spec'

require 'bigtable'
require 'bigtable/client'
require 'bigtable/instance_set'

describe Bigtable::InstanceSet do
  before do
    project_id = "project_#{Time.now.to_i}"
    @config = Bigtable::Config.new project_id
  end

  describe '#initialize' do
    it 'should be Enumerable' do
      assert_includes Bigtable::InstanceSet.included_modules, Enumerable
    end
  end

  describe '#instances' do
    it 'should allow enumeration over empty set of instances' do
      instance_set = Bigtable::InstanceSet.new @config
      
      response = OpenStruct.new instances: []
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [@config.project_path, page_token: nil]

      instance_set.stub(:client, mock_instance_client) do
        assert_equal instance_set.to_a.count, 0
      end

      mock_instance_client.verify
    end

    it 'should allow enumeration over single page of instances' do
      instance_set = Bigtable::InstanceSet.new @config
      
      instance_objects = [Object.new]*10
      response = OpenStruct.new instances: instance_objects
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [@config.project_path, page_token: nil]

      instance_set.stub(:client, mock_instance_client) do
        ary = instance_set.to_a
        assert_equal ary.count, instance_objects.count
        instance_objects.each do |ob|
          assert_includes ary, ob
        end
      end

      mock_instance_client.verify
    end

    it 'should allow enumeration over multiple pages of instances' do
      instance_set = Bigtable::InstanceSet.new @config
      token = "token_#{Time.now}"

      instance_objects = [Object.new]*10
      response = OpenStruct.new instances: instance_objects, next_page_token: token
      
      instance_objects2 = [Object.new]*5
      response2 = OpenStruct.new instances: instance_objects2
      
      mock_instance_client = Minitest::Mock.new
      mock_instance_client.expect :list_instances, response, [@config.project_path, page_token: nil]
      mock_instance_client.expect :list_instances, response2, [@config.project_path, page_token: token]

      instance_set.stub(:client, mock_instance_client) do
        ary = instance_set.to_a
        assert_equal ary.count, 15
        instance_objects.each do |ob|
          assert_includes ary, ob
        end
        instance_objects2.each do |ob|
          assert_includes ary, ob
        end
      end

      mock_instance_client.verify
    end
  end
end
