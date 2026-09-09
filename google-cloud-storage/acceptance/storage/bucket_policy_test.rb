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

describe Google::Cloud::Storage::Bucket, :policy, :storage do
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

      _(bucket.policy).must_be_kind_of Google::Cloud::Storage::PolicyV1

      # We need a valid service account in order to update the policy
      service_account = storage.service.credentials.client.issuer
      _(service_account).wont_be :nil?
      role = "roles/storage.objectCreator"
      member = "serviceAccount:#{service_account}"
      bucket.policy do |p|
        p.add role, member
        p.add role, member # duplicate member will not be added to request
      end

      role_member = bucket.policy.role(role).select { |x| x == member }
      _(role_member.count).must_equal 1
    end

    it "allows permissions to be tested" do
      roles = ["storage.buckets.delete", "storage.buckets.get"]
      permissions = bucket.test_permissions roles
      _(permissions).must_equal roles
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
      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.version).must_equal 1
      _(policy.roles.count).must_equal 2
      expect { policy.bindings }.must_raise RuntimeError

      policy = bucket_policy_v3.policy requested_policy_version: 1
      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.version).must_equal 1
      _(policy.roles.count).must_equal 2
      expect { policy.bindings }.must_raise RuntimeError

      bucket_policy_v3.policy requested_policy_version: 3 do |p|
        _(p.version).must_equal 1
        p.version = 3 # Won't be persisted by the service.
      end

      policy = bucket_policy_v3.policy requested_policy_version: 3
      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.version).must_equal 1
      expect { policy.roles }.must_raise RuntimeError
      _(policy.bindings.count).must_equal 2

      # We need a valid service account in order to update the policy
      service_account = storage.service.credentials.client.issuer
      _(service_account).wont_be :nil?
      role = "roles/storage.admin"
      member = "serviceAccount:#{service_account}"

      # expect do
      #   bucket_policy_v3.policy requested_policy_version: 3 do |p|
      #     p.version.must_equal 1
      #     expect { p.roles }.must_raise RuntimeError
      #     expect { p.add role, member }.must_raise RuntimeError
      #     expect { p.remove role, member }.must_raise RuntimeError
      #     expect { p.role role }.must_raise RuntimeError
      #     p.bindings.push({
      #                       role: role,
      #                       members: [member],
      #                       condition: {
      #                         title: "always-true",
      #                         description: "test condition always-true",
      #                         expression: "true"
      #                       }
      #                     })
      #   end
      # end.must_raise Google::Cloud::Error # Fails without version = 3 TODO: uncomment after project is whitelisted

      bucket_policy_v3.policy requested_policy_version: 3 do |p|
        _(p.version).must_equal 1
        expect { p.roles }.must_raise RuntimeError
        expect { p.add role, member }.must_raise RuntimeError
        expect { p.remove role, member }.must_raise RuntimeError
        expect { p.role role }.must_raise RuntimeError
        p.bindings.insert({
                            role: role,
                            members: [member],
                            condition: {
                              title: "always-true",
                              description: "test condition always-true",
                              expression: "true"
                            }
                          })
        p.version = 3 # This must be set before update RPC, either before or after addition of binding with condition.
      end

      expect do
        bucket_policy_v3.policy requested_policy_version: 3 do |p|
          _(p.version).must_equal 3
          p.version = 1 # Not allowed.
        end
      end.must_raise RuntimeError

      bucket_policy_v3 = storage.bucket bucket_name_policy_v3
      # Requested policy version (1) cannot be less than the existing policy version (3).
      # expect { bucket_policy_v3.policy requested_policy_version: 1 }.must_raise Google::Cloud::Error # TODO: uncomment after project is whitelisted
      policy = bucket_policy_v3.policy requested_policy_version: 3
      _(policy.version).must_equal 3
      expect { policy.roles }.must_raise RuntimeError
      expect { policy.deep_dup }.must_raise RuntimeError
      _(policy.bindings.count).must_equal 3
      binding = policy.bindings.find do |b|
        b.role == role
      end
      _(binding).wont_be :nil?
      _(binding.role).must_equal role
      _(binding.members.count).must_equal 1
      _(binding.members[0]).must_equal member
      _(binding.condition).wont_be :nil?
      _(binding.condition.title).must_equal "always-true"
      _(binding.condition.description).must_equal "test condition always-true"
      _(binding.condition.expression).must_equal "true"
    end
  end
end
