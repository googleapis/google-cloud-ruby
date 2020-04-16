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

describe Google::Cloud::Storage::Policy::Binding do
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

  it "knows itself" do
    _(simple_binding).must_be_kind_of Google::Cloud::Storage::Policy::Binding
    _(simple_binding.role).must_equal "roles/storage.objectViewer"
    _(simple_binding.members).must_equal ["user:viewer@example.com"]
    _(simple_binding.condition).must_be :nil?

    _(complex_binding).must_be_kind_of Google::Cloud::Storage::Policy::Binding
    _(complex_binding.role).must_equal "roles/storage.objectViewer"
    _(complex_binding.members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
    _(complex_binding.condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
    _(complex_binding.condition.title).must_equal "always-true"
    _(complex_binding.condition.description).must_equal "test condition always-true"
    _(complex_binding.condition.expression).must_equal "true"
  end

  it "can be changed" do
    simple_binding.role = "roles/storage.objectOwner"
    simple_binding.members = ["serviceAccount:1234567890@developer.gserviceaccount.com"]
    simple_binding.condition = {
      title: "always-false",
      description: "test condition always-false",
      expression: "false"
    }

    _(simple_binding).must_be_kind_of Google::Cloud::Storage::Policy::Binding
    _(simple_binding.role).must_equal "roles/storage.objectOwner"
    _(simple_binding.members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
    _(simple_binding.condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
    _(simple_binding.condition.title).must_equal "always-false"
    _(simple_binding.condition.description).must_equal "test condition always-false"
    _(simple_binding.condition.expression).must_equal "false"

    simple_binding.role = "roles/storage.objectAdmin"
    simple_binding.members = ["user:admin@example.com"]
    simple_binding.condition = nil

    _(simple_binding).must_be_kind_of Google::Cloud::Storage::Policy::Binding
    _(simple_binding.role).must_equal "roles/storage.objectAdmin"
    _(simple_binding.members).must_equal ["user:admin@example.com"]
    _(simple_binding.condition).must_be :nil?

    new_condition = Google::Cloud::Storage::Policy::Condition.new(
      title: "always-true",
      description: "test condition always-true",
      expression: "true"
    )

    simple_binding.condition = new_condition

    _(simple_binding.condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
    _(simple_binding.condition.title).must_equal "always-true"
    _(simple_binding.condition.description).must_equal "test condition always-true"
    _(simple_binding.condition.expression).must_equal "true"
  end
end
