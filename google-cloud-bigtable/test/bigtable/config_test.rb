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
require 'bigtable/instance_set'

describe Bigtable::Config do
  before do
    @project_id = "project_#{Time.now.to_i}"
  end

  describe '#project_id' do
    it 'should return project_id' do
      config = Bigtable::Config.new @project_id

      assert_equal config.project_id, @project_id
    end
  end

  describe '#project_path' do
    it 'should return project_path for current project' do
      config = Bigtable::Config.new @project_id

      assert_equal config.project_path, "projects/#{@project_id}"
    end
  end

  describe '#instance_path' do
    it 'should return instance_path for current project and instance id' do
      instance_id = "instance_#{Time.now.to_i}"
      config = Bigtable::Config.new @project_id

      assert_equal config.instance_path(instance_id), 
      "projects/#{@project_id}/instances/#{instance_id}"
    end
  end

  describe '#location_path' do
    it 'should return location_path for current project and zone' do
      zone = "instance_#{Time.now.to_i}"
      config = Bigtable::Config.new @project_id

      assert_equal config.location_path(zone), 
      "projects/#{@project_id}/locations/#{zone}"
    end
  end
end
