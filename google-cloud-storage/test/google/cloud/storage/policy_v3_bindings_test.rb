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

require "helper"

describe Google::Cloud::Storage::PolicyV3, :bindings do
  let(:policy) { Google::Cloud::Storage::PolicyV3.new "etag", 3, [] }
  let :simple_hash do
    {
      role: "roles/storage.objectViewer",
      members: [
        "user:viewer@example.com"
      ]
    }
  end
  let :complex_hash do
    {
      role: "roles/storage.objectViewer",
      members: [
        "serviceAccount:1234567890@developer.gserviceaccount.com"
      ],
      condition: {
        title: "always-true",
        description: "test condition always-true",
        expression: "true"
      }
    }
  end
  let(:simple_binding) { Google::Cloud::Storage::Policy::Binding.new **simple_hash }
  let(:complex_binding) { Google::Cloud::Storage::Policy::Binding.new **complex_hash }

  it "bindings can be added, iterated and removed" do
    _(policy.bindings.to_a.count).must_equal 0
    policy.bindings.insert simple_binding
    _(policy.bindings.to_a.count).must_equal 1
    policy.bindings.insert complex_binding
    _(policy.bindings.to_a.count).must_equal 2

    idx = 0
    policy.bindings.each do |binding|
      _(binding).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      idx += 1
    end
    _(idx).must_equal 2

    enumerator = policy.bindings.each
    _(enumerator.next).must_equal simple_binding
    _(enumerator.next).must_equal complex_binding

    policy.bindings.remove complex_binding
    _(policy.bindings.to_a.count).must_equal 1
    policy.bindings.remove simple_binding
    _(policy.bindings.to_a.count).must_equal 0
  end

  it "multiple bindings can be added and removed in a single call" do
    _(policy.bindings.to_a.count).must_equal 0
    policy.bindings.insert simple_binding, complex_binding
    _(policy.bindings.to_a.count).must_equal 2

    policy.bindings.remove complex_binding, simple_binding
    _(policy.bindings.to_a.count).must_equal 0
  end

  it "bindings can be added and removed using hashes" do
    _(policy.bindings.to_a.count).must_equal 0
    policy.bindings.insert simple_hash
    _(policy.bindings.to_a.count).must_equal 1
    policy.bindings.insert complex_hash
    _(policy.bindings.to_a.count).must_equal 2

    policy.bindings.remove complex_hash
    _(policy.bindings.to_a.count).must_equal 1
    policy.bindings.remove simple_hash
    _(policy.bindings.to_a.count).must_equal 0
  end

  it "multiple bindings can be added and removed using hashes in a single call" do
    _(policy.bindings.to_a.count).must_equal 0
    policy.bindings.insert simple_hash, complex_hash
    _(policy.bindings.to_a.count).must_equal 2

    policy.bindings.remove complex_hash, simple_hash
    _(policy.bindings.to_a.count).must_equal 0
  end

  it "bindings can be changed to create duplicates and all duplicates removed" do
    simple_owner_hash = {
      role: "roles/storage.objectOwner",
      members: [
        "user:owner@example.com"
      ]
    }
    complex_owner_hash = {
      role: "roles/storage.objectOwner",
      members: [
        "serviceAccount:1234567890@developer.gserviceaccount.com"
      ],
      condition: {
        title: "always-false",
        description: "test condition always-false",
        expression: "false"
      }
    }

    _(policy.bindings.to_a.count).must_equal 0
    policy.bindings.insert simple_hash, simple_owner_hash
    _(policy.bindings.to_a.count).must_equal 2
    policy.bindings.insert complex_hash, complex_owner_hash
    _(policy.bindings.to_a.count).must_equal 4

    simple_owner_binding = policy.bindings.find { |b| b.role == simple_owner_hash[:role] && b.members == simple_owner_hash[:members] }
    _(simple_owner_binding).must_be_kind_of Google::Cloud::Storage::PolicyV3::Binding
    _(simple_owner_binding.role).must_equal "roles/storage.objectOwner"
    _(simple_owner_binding.members).must_equal ["user:owner@example.com"]
    _(simple_owner_binding.condition).must_be :nil?

    complex_owner_binding = policy.bindings.find { |b| b.role == complex_owner_hash[:role] && b.members == complex_owner_hash[:members] }
    _(complex_owner_binding).must_be_kind_of Google::Cloud::Storage::PolicyV3::Binding
    _(complex_owner_binding.role).must_equal "roles/storage.objectOwner"
    _(complex_owner_binding.members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
    _(complex_owner_binding.condition).must_be_kind_of Google::Cloud::Storage::PolicyV3::Condition

    # change the binding to be the same as the simple binding
    simple_owner_binding.role = simple_hash[:role]
    simple_owner_binding.members = simple_hash[:members]

    complex_owner_binding.role = complex_hash[:role]
    complex_owner_binding.members = complex_hash[:members]
    complex_owner_binding.condition = complex_hash[:condition]

    # remove the now duplicate values by specifying only one binding value
    _(policy.bindings.to_a.count).must_equal 4
    policy.bindings.remove simple_hash
    _(policy.bindings.to_a.count).must_equal 2
    policy.bindings.remove complex_hash
    _(policy.bindings.to_a.count).must_equal 0
  end
end
