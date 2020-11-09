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
  let(:role_viewer) { "roles/bigquery.dataViewer" }
  let(:member_viewer) { "user:viewer@example.com" }
  let(:role_editor) { "roles/bigquery.dataEditor" }
  let(:member_editor) { "user:editor@example.com" }
  let(:role_owner) { "roles/bigquery.dataOwner" }
  let(:member_owner) { "user:owner@example.com" }
  let :policy_viewer_gapi do
    policy_gapi(
      bindings: [
        Google::Apis::BigqueryV2::Binding.new(
          role: role_viewer,
          members: [member_viewer]
        )
      ]
    )
  end

  describe "not frozen" do
    let(:policy) { Google::Cloud::Bigquery::Policy.from_gapi policy_viewer_gapi }
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
      _(bindings[0].role).must_equal role_viewer
      _(bindings[0].members).must_be_kind_of Array
      _(bindings[0].members).wont_be :frozen?
      _(bindings[0].members.size).must_equal 1
      _(bindings[0].members[0]).must_equal member_viewer
    end

    it "grants a new role to a new member" do
      policy.grant role: role_editor, members: member_editor

      binding_owner = policy.bindings.find { |b| b.role == role_editor }
      _(binding_owner).wont_be :nil?
      _(binding_owner.role).must_equal role_editor
      _(binding_owner.members.size).must_equal 1
      _(binding_owner.members[0]).must_equal member_editor
    end

    it "grants new roles to a new member" do
      policy.grant role: role_editor, members: [member_editor, member_owner]

      binding_owner = policy.bindings.find { |b| b.role == role_editor }
      _(binding_owner).wont_be :nil?
      _(binding_owner.members.size).must_equal 2
      _(binding_owner.members).must_include member_editor
      _(binding_owner.members).must_include member_owner
    end

    it "grants an existing role to a new member" do
      policy.grant role: role_viewer, members: member_editor

      binding_viewer = policy.bindings.find { |b| b.role == role_viewer }
      _(binding_viewer).wont_be :nil?
      _(binding_viewer.members.size).must_equal 2
      _(binding_viewer.members).must_include member_viewer
      _(binding_viewer.members).must_include member_editor
    end

    it "grants an existing role to new members" do
      policy.grant role: role_viewer, members: [member_editor, member_owner]

      binding_viewer = policy.bindings.find { |b| b.role == role_viewer }
      _(binding_viewer).wont_be :nil?
      _(binding_viewer.role).must_equal role_viewer
      _(binding_viewer.members.size).must_equal 3
      _(binding_viewer.members).must_include member_viewer
      _(binding_viewer.members).must_include member_editor
      _(binding_viewer.members).must_include member_owner
    end

    it "does not grant a new role to duplicate members" do
      policy.grant role: role_editor, members: [member_editor, member_owner, member_editor]

      binding_owner = policy.bindings.find { |b| b.role == role_editor }
      _(binding_owner).wont_be :nil?
      _(binding_owner.role).must_equal role_editor
      _(binding_owner.members.size).must_equal 2
      _(binding_owner.members[0]).must_equal member_editor
    end

    it "does not grant an existing role to duplicate members" do
      policy.grant role: role_viewer, members: [member_viewer, member_editor, member_editor, member_owner]

      binding_viewer = policy.bindings.find { |b| b.role == role_viewer }
      _(binding_viewer).wont_be :nil?
      _(binding_viewer.role).must_equal role_viewer
      _(binding_viewer.members.size).must_equal 3
      _(binding_viewer.members).must_include member_viewer
      _(binding_viewer.members).must_include member_editor
      _(binding_viewer.members).must_include member_owner
    end

    it "does not allow duplicate members to be set in a binding" do
      binding_viewer = policy.bindings.find { |b| b.role == role_viewer }

      binding_viewer.members = [member_viewer, member_editor, member_editor, member_owner]
      _(binding_viewer.members.size).must_equal 3
      _(binding_viewer.members).must_include member_viewer
      _(binding_viewer.members).must_include member_editor
      _(binding_viewer.members).must_include member_owner
    end

    it "revokes an existing role with one member for all members" do
      policy.revoke role: role_viewer

      _(policy.bindings.size).must_equal 0
    end

    it "revokes an existing role with multiple members for all members" do
      policy.grant role: role_viewer, members: member_editor

      policy.revoke role: role_viewer

      _(policy.bindings.size).must_equal 0
    end

    it "revokes an existing role for a subset of members" do
      policy.grant role: role_viewer, members: member_editor

      policy.revoke role: role_viewer, members: member_editor

      binding_viewer = policy.bindings.find { |b| b.role == role_viewer }
      _(binding_viewer.members.size).must_equal 1
      _(binding_viewer.members).must_include member_viewer
    end

    it "revokes a member for multiple roles" do
      policy.grant role: role_viewer, members: member_editor
      policy.grant role: role_editor, members: member_editor

      policy.revoke members: member_editor

      _(policy.bindings.size).must_equal 1
      _(policy.bindings[0].role).must_equal role_viewer
      _(policy.bindings[0].members.size).must_equal 1
      _(policy.bindings[0].members).must_include member_viewer
    end

    it "revokes multiple members for multiple roles" do
      policy.grant role: role_viewer, members: [member_editor, member_owner]
      policy.grant role: role_editor, members: [member_editor, member_owner]

      policy.revoke members: [member_editor, member_owner]

      _(policy.bindings.size).must_equal 1
      _(policy.bindings[0].role).must_equal role_viewer
      _(policy.bindings[0].members.size).must_equal 1
      _(policy.bindings[0].members).must_include member_viewer
    end
  end

  describe "frozen" do
    let(:policy) { Google::Cloud::Bigquery::Policy.from_gapi(policy_viewer_gapi).freeze }

    it "returns deeply frozen bindings when frozen" do
      _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
      _(policy).must_be :frozen?

      bindings = policy.bindings
      _(bindings).must_be_kind_of Array
      _(bindings).must_be :frozen?
      _(bindings.size).must_equal 1
      _(bindings[0]).must_be :frozen?
      _(bindings[0].role).must_be :frozen?
      _(bindings[0].role).must_equal role_viewer
      _(bindings[0].members).must_be_kind_of Array
      _(bindings[0].members).must_be :frozen?
      _(bindings[0].members.size).must_equal 1
      _(bindings[0].members[0]).must_equal member_viewer
    end

    it "raises when grant would change the bindings" do
      expect do
        policy.grant role: role_editor, members: member_editor
      end.must_raise RuntimeError # TODO replace with FrozenError when Ruby > 2.4
    end

    it "raises when revoke would change the bindings" do
      expect do
        policy.revoke role: role_viewer
      end.must_raise RuntimeError # TODO replace with FrozenError when Ruby > 2.4
    end
  end
end
