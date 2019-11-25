# Copyright 2019 Google LLC
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

require "storage_helper"

describe Google::Cloud::Storage::Bucket, :storage do
  let(:bucket_name) { $bucket_names[1] } # Policy version 1
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:bucket_name_policy_v3) { $bucket_names[2] }
  let :bucket_policy_v3 do
    storage.bucket(bucket_name_policy_v3) ||
      safe_gcs_execute { storage.create_bucket(bucket_name_policy_v3) }
  end

  describe "Policy version 1" do
    it "allows policy to be updated" do
      # Check permissions first
      roles = ["storage.buckets.getIamPolicy", "storage.buckets.setIamPolicy"]
      permissions = bucket.test_permissions roles
      skip "Don't have permissions to get/set bucket's policy" unless permissions == roles

      bucket.policy.must_be_kind_of Google::Cloud::Storage::Policy

      # We need a valid service account in order to update the policy
      service_account = storage.service.credentials.client.issuer
      service_account.wont_be :nil?
      role = "roles/storage.objectCreator"
      member = "serviceAccount:#{service_account}"
      bucket.policy do |p|
        p.add role, member
        p.add role, member # duplicate member will not be added to request
      end

      role_member = bucket.policy.role(role).select { |x| x == member }
      role_member.count.must_equal 1
    end

    it "allows permissions to be tested" do
      roles = ["storage.buckets.delete", "storage.buckets.get"]
      permissions = bucket.test_permissions roles
      permissions.must_equal roles
    end
  end

  describe "Policy version 3" do
    it "allows policy version to be set to 3" do
      bucket_policy_v3.uniform_bucket_level_access = true
      # Check permissions first
      roles = ["storage.buckets.getIamPolicy", "storage.buckets.setIamPolicy"]
      permissions = bucket_policy_v3.test_permissions roles
      skip "Don't have permissions to get/set bucket's policy" unless permissions == roles

      policy = bucket_policy_v3.policy
      policy.must_be_kind_of Google::Cloud::Storage::Policy
      policy.version.must_equal 1
      policy.roles.count.must_equal 2
      expect { policy.bindings }.must_raise RuntimeError

      # We need a valid service account in order to update the policy
      service_account = storage.service.credentials.client.issuer
      service_account.wont_be :nil?
      role = "roles/storage.admin"
      member = "serviceAccount:#{service_account}"
      bucket_policy_v3.policy do |p|
        p.version = 3
        p.bindings.push({
                          role: role,
                          members: [member],
                          condition: {
                            title: "always-true",
                            description: "test condition always-true",
                            expression: "true"
                          }
                        })

        expect { p.add role, member }.must_raise RuntimeError
        expect { p.remove role, member }.must_raise RuntimeError
        expect { p.role role }.must_raise RuntimeError
      end

      bucket_policy_v3 = storage.bucket bucket_name_policy_v3
      # Requested policy version (1) cannot be less than the existing policy version (3).
      # expect { bucket_policy_v3.policy requested_policy_version: 1 }.must_raise Google::Cloud::Error  TODO: uncomment after project is whitelisted
      policy = bucket_policy_v3.policy requested_policy_version: 3
      policy.version.must_equal 3
      expect { policy.roles }.must_raise RuntimeError
      expect { policy.deep_dup }.must_raise RuntimeError
      policy.bindings.count.must_equal 3
    end
  end
end
