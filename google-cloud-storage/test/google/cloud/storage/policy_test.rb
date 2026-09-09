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

require "helper"

describe Google::Cloud::Storage::Policy, :mock_storage do
  let(:etag)       { "etag-1" }

  describe "version 1" do
    let(:policy_gapi_v1) {
      policy_gapi(
        etag: etag,
        version: 1,
        bindings: [
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/viewer",
            members: [
              "allUsers"
            ]
          )
        ]
      )
    }
    let(:policy) { Google::Cloud::Storage::PolicyV1.from_gapi policy_gapi_v1 }

    it "knows its attributes" do
      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal etag
      _(policy.version).must_equal 1
    end

    it "knows its roles" do
      _(policy.roles.keys.sort).must_equal ["roles/viewer"]
      _(policy.roles.values.sort).must_equal [["allUsers"]]
    end

    it "returns an empty array for missing role" do
      role = policy.role "roles/does-not-exist"
      _(role).must_be_kind_of Array
      _(role).must_be :empty?
      _(role.frozen?).must_equal false
    end

    it "raises for unsupported method calls" do
      expect { policy.bindings }.must_raise RuntimeError
    end

    it "creates a Google::Apis::StorageV1::Policy object with the equivalent de-duped roles" do
      # Add a duplicate entry.
      existing_role, existing_members = policy.roles.first
      policy.add(existing_role, existing_members.first)

      gapi_policy = policy.to_gapi

      _(gapi_policy.class).must_equal Google::Apis::StorageV1::Policy
      _(gapi_policy.bindings.size).must_equal policy.roles.size
      gapi_policy.bindings.each do |binding|
        _(binding.members.sort).must_equal policy.roles[binding.role].uniq.sort
      end
    end

    it "creates from an empty Google::Apis::StorageV1::Policy object" do
      gapi = Google::Apis::StorageV1::Policy.new version: 1

      policy = Google::Cloud::Storage::PolicyV1.from_gapi gapi

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_be :nil?
      _(policy.version).must_equal 1
      _(policy.roles).must_be :empty?
    end
  end

  describe "version 3" do
    let(:policy_gapi_v3) {
      policy_gapi(
        etag: etag,
        version: 3,
        bindings: [
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "user:viewer@example.com"
            ]
          ),
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "serviceAccount:1234567890@developer.gserviceaccount.com"
            ],
            condition: {
              title: "always-true",
              description: "test condition always-true",
              expression: "true"
            }
          )
        ]
      )
    }
    let(:policy) { Google::Cloud::Storage::PolicyV3.from_gapi policy_gapi_v3 }

    it "knows its attributes" do
      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal etag
      _(policy.version).must_equal 3
    end

    it "knows its bindings" do
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 2
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
      _(policy.bindings.to_a[1]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[1].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[1].members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
      _(policy.bindings.to_a[1].condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
      _(policy.bindings.to_a[1].condition.title).must_equal "always-true"
      _(policy.bindings.to_a[1].condition.description).must_equal "test condition always-true"
      _(policy.bindings.to_a[1].condition.expression).must_equal "true"
    end

    it "raises for unsupported method calls" do
      expect { policy.roles }.must_raise RuntimeError
      expect { policy.add "roles/viewer", "allUsers" }.must_raise RuntimeError
      expect { policy.remove "roles/viewer", "allUsers" }.must_raise RuntimeError
      expect { policy.role "roles/viewer" }.must_raise RuntimeError
      expect { policy.deep_dup }.must_raise RuntimeError
    end

    it "creates from an empty Google::Apis::StorageV1::Policy object" do
      gapi = Google::Apis::StorageV1::Policy.new version: 3

      policy = Google::Cloud::Storage::PolicyV3.from_gapi gapi

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_be :nil?
      _(policy.version).must_equal 3
      _(policy.bindings.to_a).must_be :empty?
    end
  end
end
