# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../quickstart"
require_relative "helper"

class ComputeQuickstartTest < Minitest::Test
  def setup
    @temp_instances = []
  end

  def teardown
    client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new
    operation_client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    @temp_instances.each do |instance|
      client.delete project: project, zone: zone, instance: instance
    rescue StandardError
    end
  end

  def test_quickstart
    instance_name = random_instance_name
    @temp_instances << instance_name

    assert_output(/Instance #{instance_name} created./) do
      create_instance project: project, zone: zone, instance_name: instance_name
    end

    assert_output(/Instances found in zone #{zone}:.+#{instance_name}/m) do
      list_instances project: project, zone: zone
    end

    assert_output %r{zones/#{zone}.+#{instance_name}}m do
      list_all_instances project: project
    end

    assert_output(/Instance #{instance_name} deleted./) do
      delete_instance project: project, zone: zone, instance_name: instance_name
    end
  end
end
