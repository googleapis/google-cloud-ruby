# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Instances", :spanner do
  it "lists and gets instances" do
    all_instances = spanner.instances.all.to_a
    all_instances.wont_be :empty?
    all_instances.each do |instance|
      instance.must_be_kind_of Google::Cloud::Spanner::Instance
    end

    first_instance = spanner.instance all_instances.first.instance_id
    first_instance.must_be_kind_of Google::Cloud::Spanner::Instance
  end

  describe "IAM Policies and Permissions" do
    let(:service_account) { spanner.service.credentials.client.issuer }

    it "allows policy to be updated on an instance" do
      all_instances = spanner.instances.all.to_a
      instance = spanner.instance all_instances.first.instance_id
      # Check permissions first
      roles = ["spanner.instances.getIamPolicy", "spanner.instances.setIamPolicy"]
      permissions = instance.test_permissions roles
      skip "Don't have permissions to get/set topic's policy" unless permissions == roles

      instance.policy.must_be_kind_of Google::Cloud::Spanner::Policy

      # We need a valid service account in order to update the policy
      service_account.wont_be :nil?
      role = "roles/viewer"
      member = "serviceAccount:#{service_account}"
      instance.policy do |p|
        p.add role, member
        p.add role, member # duplicate member will not be added to request
      end

      instance.policy.role(role).must_equal [member]
    end
  end
end
