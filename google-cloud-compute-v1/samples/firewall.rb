# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START compute_firewall_list]
# [START compute_firewall_create]
# [START compute_firewall_patch]
# [START compute_firewall_delete]

require "google/cloud/compute/v1"

# [END compute_firewall_delete]
# [END compute_firewall_patch]
# [END compute_firewall_create]
# [END compute_firewall_list]

require_relative "quickstart"

# [START compute_firewall_list]
# Return a list of all the firewall rules in specified project. Also prints the
# list of firewall names and their descriptions.
#
# @param [String] project project ID or project number of the project you want to use.
# @return [Array<::Google::Cloud::Compute::V1::Firewall>]
#     A list of all firewall rules defined for the given project.
def list_firewall_rules project:
  client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
  firewalls = client.list project: project

  firewall_list = []
  firewalls.each do |firewall|
    puts " - #{firewall.name}: #{firewall.description}"
    firewall_list << firewall
  end

  firewall_list
end
# [END compute_firewall_list]


# [START compute_firewall_create]
# Creates a simple firewall rule allowing for incoming HTTP and HTTPS access from the entire Internet.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] name: name of the rule that is created.
# @param network: name of the network the rule will be applied to. Available name formats:
#         * https://www.googleapis.com/compute/v1/projects/{project_id}/global/networks/{network}
#         * projects/{project_id}/global/networks/{network}
#         * global/networks/{network}
def create_firewall_rule project:, name:, network: "global/networks/default"
  rule = {
    name: name,
    direction: "INGRESS",
    allowed: [{
      I_p_protocol: "tcp",
      ports: ["80", "443"]
    }],
    source_ranges: ["0.0.0.0/0"],
    network: network,
    description: "Allowing TCP traffic on port 80 and 443 from Internet.",
    target_tags: ["web"]
  }

  # Note that the default value of priority for the firewall API is 1000.
  # If you want to create a rule that has priority == 0, you need to explicitly set it:
  #   rule[:priority] = 0
  # Use `rule.has_key? :priority` to check if the priority has been set.
  # Use `rule.delete :priority` method to unset the priority.

  request = {
    firewall_resource: rule,
    project: project
  }

  client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
  operation = client.insert request

  wait_until_done project: project, operation: operation.operation
end
# [END compute_firewall_create]

# [START compute_firewall_patch]
# Modifies the priority of a given firewall rule.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] name name of the rule you want to modify.
# @param [Integer] priority the new priority to be set for the rule.
def patch_firewall_priority project:, name:, priority:
  rule = {
    priority: priority
  }

  request = {
    project: project,
    firewall: name,
    firewall_resource: rule
  }

  # The patch operation doesn't require the full definition of a Firewall object. It will only update
  # the values that were set in it, in this case it will only change the priority.
  client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
  operation = client.patch request

  wait_until_done project: project, operation: operation.operation
end
# [END compute_firewall_patch]


# [START compute_firewall_delete]
# Deletes a firewall rule from the project.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] name name of the firewall rule you want to delete.
def delete_firewall_rule project:, name:
  client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
  operation = client.delete project: project, firewall: name

  wait_until_done project: project, operation: operation.operation
end
# [END compute_firewall_delete]
