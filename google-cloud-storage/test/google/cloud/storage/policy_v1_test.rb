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

describe Google::Cloud::Storage::PolicyV1, :mock_storage do
  let(:etag)       { "etag-1" }

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

  it "creates from an empty Google::Apis::StorageV1::Policy object" do
    gapi = Google::Apis::StorageV1::Policy.new version: 1

    policy = Google::Cloud::Storage::PolicyV1.from_gapi gapi

    _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
    _(policy.etag).must_be :nil?
    _(policy.version).must_equal 1
    _(policy.roles).must_be :empty?
  end
end
