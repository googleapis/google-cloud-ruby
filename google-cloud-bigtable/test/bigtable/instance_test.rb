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
require 'bigtable/instance'

describe Bigtable::Instance do
  let(:project_id) {"project_#{Time.now.to_i}"}
  let(:instance_id) {"instance_#{Time.now.to_i}"}
  let(:instance_name) {"projects/#{project_id}/instances/#{instance_id}"}

  describe "#delete!" do
    it 'should delete the given instance' do
      options = {}

      mock_client = Minitest::Mock.new
      mock_client.expect :delete_instance, nil, [instance_name, options]

      instance = Bigtable::Instance.new name: instance_name, 
                                        display_name: 'Name'
      instance.send :client=, mock_client

      instance.delete! options

      mock_client.verify
    end
  end

  describe "#save!" do
    it 'should update the display name the given instance' do
      options = {}
      new_display_name = "New Name #{Time.now.to_i}"
      instance = Bigtable::Instance.new name: instance_name, 
                                        display_name: 'Name'

      mock_client = Minitest::Mock.new
      mock_client.expect :update_instance, nil, [instance_name, new_display_name, instance.type, instance.labels, options]

      instance.send :client=, mock_client

      instance.display_name = new_display_name
      instance.save! options

      mock_client.verify
    end
  end
end
