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

require_relative "../firewall"
require_relative "helper"


class ComputeFirewallTest < Minitest::Test
  def setup
    @firewalls = []
  end
  
  def teardown
    client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
    @firewalls.each do |firewall|
      client.delete project: project, firewall: firewall
    rescue StandardError
    end
  end

  def test_create_list_delete
    firewall_name = random_firewall_name
    @firewalls << firewall_name
    create_firewall_rule project: project, name: firewall_name
    list = list_firewall_rules project: project
    assert list.any? { |f| f.name == firewall_name }
    delete_firewall_rule project: project, name: firewall_name
    list = list_firewall_rules project: project
    assert list.all? { |f| f.name != firewall_name }
  end

  def test_patch_priority
    firewall_name = random_firewall_name
    @firewalls << firewall_name
    create_firewall_rule project: project, name: firewall_name
    
    client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
    firewall = client.get project: project, firewall: firewall_name
    assert_equal 1000, firewall.priority
    patch_firewall_priority project: project, name: firewall_name, priority: 500
    firewall = client.get project: project, firewall: firewall_name
    assert_equal 500, firewall.priority
    delete_firewall_rule project: project, name: firewall_name
  end
end
