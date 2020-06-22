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
require_relative "../iam.rb"

describe "IAM Snippets" do
  let :bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}"
  end

  let(:role)                  { "roles/storage.admin" }
  let(:member)                { "user:test@test.com" }

  after do
    delete_bucket_helper bucket.name
  end

  describe "view_bucket_iam_members" do
    it "puts the members for each IAM role" do
      bucket.policy do |policy|
        policy.add role, member
      end

      out, _err = capture_io do
        view_bucket_iam_members bucket_name: bucket.name
      end

      assert_includes out, "Role: #{role}"
      assert_includes out, member
    end
  end

  describe "add_bucket_iam_member" do
    it "adds an IAM member" do
      assert_output "Added #{member} with role #{role} to #{bucket.name}\n" do
        add_bucket_iam_member bucket_name: bucket.name,
                              role:        role,
                              member:      member
      end

      assert bucket.policy.roles.any? do |p_role, p_members|
        p_role == role && p_members.includes?(member)
      end
    end
  end

  describe "remove_bucket_iam_member" do
    it "removes an IAM member" do
      assert_output "Removed #{member} with role #{role} from #{bucket.name}\n" do
        remove_bucket_iam_member bucket_name: bucket.name,
                                 role:        role,
                                 member:      member
      end

      refute bucket.policy.roles.none? do |p_role, p_members|
        p_role == role && p_members.includes?(member)
      end
    end
  end

  describe "add_bucket_conditional_iam_binding" do
    it "adds conditional IAM binding to a bucket" do
      title = "title"
      description = "description"
      expression = "resource.name.startsWith(\"projects/_/buckets/bucket-name/objects/prefix-a-\")"
      bucket.uniform_bucket_level_access = true
      assert_output "Added #{member} with role #{role} to #{bucket.name} with condition #{title} #{description} #{expression}\n" do
        add_bucket_conditional_iam_binding bucket_name: bucket.name,
                                           role:        role,
                                           member:      member,
                                           title:       title,
                                           description: description,
                                           expression:  expression
      end

      policy = bucket.policy(requested_policy_version: 3).bindings.select(&:condition).first
      assert_equal policy.role, role
      assert_includes policy.members, member
      assert_equal policy.condition.title, title
      assert_equal policy.condition.description, description
      assert_equal policy.condition.expression, expression
    end
  end

  describe "remove_bucket_conditional_iam_binding" do
    it "remove conditional IAM binding to a bucket" do
      title = "title"
      description = "description"
      expression = "resource.name.startsWith('projects/_/buckets/bucket-name/objects/prefix-a-')"
      bucket.uniform_bucket_level_access = true
      capture_io do
        add_bucket_conditional_iam_binding bucket_name: bucket.name,
                                           role:        role,
                                           member:      member,
                                           title:       title,
                                           description: description,
                                           expression:  expression
      end
      assert_output "Conditional Binding was removed.\n" do
        remove_bucket_conditional_iam_binding bucket_name: bucket.name,
                                              role:        role,
                                              title:       title,
                                              description: description,
                                              expression:  expression
      end
      bindings = bucket.policy(requested_policy_version: 3).bindings.select(&:condition)
      assert_equal bindings.size, 0
    end
  end
end
