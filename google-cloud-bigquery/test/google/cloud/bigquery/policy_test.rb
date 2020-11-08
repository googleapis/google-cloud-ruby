# Copyright 2020 Google LLC
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

describe Google::Cloud::Bigquery::Policy, :mock_bigquery do
  let(:role) { "roles/bigquery.dataViewer" }
  let(:member) { "user:viewer@example.com" }
  let :viewer_policy_gapi do
    policy_gapi(
      bindings: [
        Google::Apis::BigqueryV2::Binding.new(
          role: role,
          members: [member]
        )
      ]
    )
  end
  let(:policy) { Google::Cloud::Bigquery::Policy.from_gapi viewer_policy_gapi }

  it "knows its etag" do
    _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
    _(policy).wont_be :frozen?
    _(policy.etag).must_equal "CAE="
    _(policy.etag).must_be :frozen?
  end

  it "returns mutable bindings when not frozen" do
    bindings = policy.bindings
    _(bindings).must_be_kind_of Array
    _(bindings).wont_be :frozen?
    _(bindings.size).must_equal 1
    _(bindings[0]).wont_be :frozen?
    _(bindings[0].role).wont_be :frozen?
    _(bindings[0].role).must_equal role
    _(bindings[0].members).must_be_kind_of Array
    _(bindings[0].members).wont_be :frozen?
    _(bindings[0].members.size).must_equal 1
    _(bindings[0].members[0]).must_equal member
  end

  it "grants roles" do
    _(policy.bindings.find { |b| b.role == "roles/bigquery.dataOwner" }).must_be :nil?

    policy.grant members: "user:owner@example.com", role: "roles/bigquery.dataOwner"
    binding_owner = policy.bindings.find { |b| b.role == "roles/bigquery.dataOwner" }
    _(binding_owner).wont_be :nil?
    _(binding_owner.members.size).must_equal 1
    _(binding_owner.members[0]).must_equal "user:owner@example.com"
  end

  it "revokes roles" do
    _(policy.bindings.size).must_equal 1
    _(policy.bindings.find { |b| b.role == role }).wont_be :nil?

    policy.revoke role: role

    _(policy.bindings.size).must_equal 0
  end

  describe "freeze" do
    let(:policy_frozen) { policy.freeze }

    it "knows its etag" do
      _(policy_frozen).must_be_kind_of Google::Cloud::Bigquery::Policy
      _(policy_frozen).must_be :frozen?
      _(policy_frozen.etag).must_equal "CAE="
      _(policy_frozen.etag).must_be :frozen?
    end

    it "returns deeply frozen bindings when frozen" do
      bindings = policy_frozen.bindings
      _(bindings).must_be_kind_of Array
      _(bindings).must_be :frozen?
      _(bindings.size).must_equal 1
      _(bindings[0]).must_be :frozen?
      _(bindings[0].role).must_be :frozen?
      _(bindings[0].role).must_equal role
      _(bindings[0].members).must_be_kind_of Array
      _(bindings[0].members).must_be :frozen?
      _(bindings[0].members.size).must_equal 1
      _(bindings[0].members[0]).must_equal member
    end
  end
end
