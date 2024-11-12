# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../storage_add_bucket_conditional_iam_binding"
require_relative "../storage_add_bucket_iam_member"
require_relative "../storage_remove_bucket_conditional_iam_binding"
require_relative "../storage_remove_bucket_iam_member"
require_relative "../storage_set_bucket_public_iam"
require_relative "../storage_view_bucket_iam_members"

describe "IAM Snippets" do
  let(:member) { "group:example@google.com" }
  let(:member_public) { "allUsers" }
  let(:role) { "roles/storage.objectViewer" }
  let(:bucket) { fixture_bucket }

  it "add_bucket_iam_member, view_bucket_iam_members, remove_bucket_iam_member" do
    # add_bucket_iam_member
    assert_output "Added #{member} with role #{role} to #{bucket.name}\n" do
      add_bucket_iam_member bucket_name: bucket.name
    end

    assert bucket.policy.roles.any? do |p_role, p_members|
      p_role == role && p_members.includes?(member)
    end

    # view_bucket_iam_members
    out, _err = capture_io do
      view_bucket_iam_members bucket_name: bucket.name
    end

    assert_includes out, "Role: #{role}"
    assert_includes out, member

    # remove_bucket_iam_member
    assert_output "Removed #{member} with role #{role} from #{bucket.name}\n" do
      remove_bucket_iam_member bucket_name: bucket.name
    end

    refute bucket.policy.roles.none? do |p_role, p_members|
      p_role == role && p_members.includes?(member)
    end
  end

  it "set_bucket_public_iam" do
    # set_bucket_public_iam
    assert_output "Bucket #{bucket.name} is now publicly readable\n" do
      set_bucket_public_iam bucket_name: bucket.name
    end

    assert bucket.policy.roles.any? do |p_role, p_members|
      p_role == role && p_members.includes?(member_public)
    end

    # teardown
    capture_io do
      bucket.policy requested_policy_version: 3 do |policy|
        policy.bindings.each do |binding|
          if binding.role == role && binding.condition.nil?
            binding.members.delete member_public
          end
        end
      end
    end
  end

  it "add_bucket_conditional_iam_binding, remove_bucket_conditional_iam_binding" do
    title = "Title"
    description = "Description"
    expression = "resource.name.startsWith(\"projects/_/buckets/bucket-name/objects/prefix-a-\")"
    bucket.uniform_bucket_level_access = true

    # add_bucket_conditional_iam_binding
    expected = "Added #{member} with role #{role} to #{bucket.name} with condition " \
               "#{title} #{description} #{expression}\n"
    assert_output expected do
      add_bucket_conditional_iam_binding bucket_name: bucket.name
    end

    policy = bucket.policy(requested_policy_version: 3).bindings.select(&:condition).first
    assert_equal policy.role, role
    assert_includes policy.members, member
    assert_equal policy.condition.title, title
    assert_equal policy.condition.description, description
    assert_equal policy.condition.expression, expression

    # remove_bucket_conditional_iam_binding
    assert_output "Conditional Binding was removed.\n" do
      remove_bucket_conditional_iam_binding bucket_name: bucket.name
    end
    bindings = bucket.policy(requested_policy_version: 3).bindings.select(&:condition)
    assert_equal bindings.size, 0
  end
end
