# Copyright 2017 Google LLC
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

def view_bucket_iam_members bucket_name:
  # [START view_bucket_iam_members]
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  policy = bucket.policy requested_policy_version: 3
  policy.bindings.each do |binding|
    puts "Role: #{binding.role}"
    puts "Members: #{binding.members}"

    # if a conditional binding exists print the condition.
    if binding.condition
      puts "Condition Title: #{binding.condition.title}"
      puts "Condition Description: #{binding.condition.description}"
      puts "Condition Expression: #{binding.condition.expression}"
    end
  end
  # [END view_bucket_iam_members]
end

def add_bucket_iam_member bucket_name:, role:, member:
  # [START add_bucket_iam_member]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.bindings.insert role: role, members: [member]
  end

  puts "Added #{member} with role #{role} to #{bucket_name}"
  # [END add_bucket_iam_member]
end

def remove_bucket_iam_member bucket_name:, role:, member:
  # [START remove_bucket_iam_member]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.bindings.each do |binding|
      if binding.role == role && binding.condition.nil?
        binding.members.delete member
      end
    end
  end

  puts "Removed #{member} with role #{role} from #{bucket_name}"
  # [END remove_bucket_iam_member]
end

def add_bucket_conditional_iam_binding bucket_name:, role:, member:, title:, description:, expression:
  # [START storage_add_bucket_conditional_iam_binding]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"
  # title       = "Condition Title"
  # description = "Condition Description"
  # expression  = "Condition Expression"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3
    policy.bindings.insert(
      role:      role,
      members:   member,
      condition: {
        title:       title,
        description: description,
        expression:  expression
      }
    )
  end

  puts "Added #{member} with role #{role} to #{bucket_name} with condition #{title} #{description} #{expression}"
  # [END storage_add_bucket_conditional_iam_binding]
end

# rubocop:disable Lint/UselessAssignment
def remove_bucket_conditional_iam_binding bucket_name:, role:, title:, description:, expression:
  # [START storage_remove_bucket_conditional_iam_binding]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # title       = "Condition Title"
  # description = "Condition Description"
  # expression  = "Condition Expression"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3

    binding_to_remove = nil
    policy.bindings.each do |b|
      condition = {
        title:       title,
        description: description,
        expression:  expression
      }
      if (b.role == role) && (b.condition &&
        b.condition.title == title &&
        b.condition.description == description &&
        b.condition.expression == expression)
        binding_to_remove = b
      end
    end
    if binding_to_remove
      policy.bindings.remove binding_to_remove
      puts "Conditional Binding was removed."
    else
      puts "No matching conditional binding found."
    end
  end
  # [END storage_remove_bucket_conditional_iam_binding]
end
# rubocop:enable Lint/UselessAssignment

def run_sample arguments
  command = arguments.shift

  case command
  when "view_bucket_iam_members"
    view_bucket_iam_members bucket_name: arguments.shift
  when "add_bucket_iam_member"
    add_bucket_iam_member bucket_name: arguments.shift,
                          role:        arguments.shift,
                          member:      arguments.shift
  when "add_bucket_conditional_iam_binding"
    add_bucket_conditional_iam_binding project_id:  project_id,
                                       bucket_name: arguments.shift,
                                       role:        arguments.shift,
                                       member:      arguments.shift,
                                       title:       arguments.shift,
                                       description: arguments.shift,
                                       expression:  arguments.shift
  when "remove_bucket_iam_member"
    remove_bucket_iam_member bucket_name: arguments.shift,
                             role:        arguments.shift,
                             member:      arguments.shift
  when "remove_bucket_conditional_iam_binding"
    remove_bucket_conditional_iam_binding bucket_name: arguments.shift,
                                          role:        arguments.shift,
                                          title:       arguments.shift,
                                          description: arguments.shift,
                                          expression:  arguments.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby iam.rb [command] [arguments]

      Commands:
        view_bucket_iam_members  <bucket>                                                                                View bucket-level IAM members
        add_bucket_iam_member    <bucket> <iam_role> <iam_member>                                                        Add a bucket-level IAM member
        add_bucket_conditional_iam_binding <bucket> <iam_role> <iam_member> <cond_title> <cond_description> <cond_expr>  Add a conditional bucket-level binding
        remove_bucket_iam_member <bucket> <iam_role> <iam_member>                                                        Remove a bucket-level IAM member
        remove_bucket_conditional_iam_binding <bucket> <iam_member> <cond_title> <cond_description> <cond_expr>          Remove a conditional bucket-level binding

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
