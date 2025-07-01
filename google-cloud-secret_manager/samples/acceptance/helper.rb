# Copyright 2020 Google, Inc
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

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "google/cloud/secret_manager"
require "google/cloud/resource_manager"

require_relative "../../../.toys/.lib/sample_loader"

class SecretManagerSnippetSpec < Minitest::Spec
  let(:client) { Google::Cloud::SecretManager.secret_manager_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/secrets/#{secret_id}" }

  let(:iam_user) { "user:sethvargo@google.com" }

  let(:annotation_key) { "annotation-key" }
  let(:annotation_value) { "annotation-value" }

  let(:updated_annotation_key) { "updated-annotation-key" }
  let(:updated_annotation_value) { "updated-annotation-value" }

  let(:label_key) { "label-key" }
  let(:label_value) { "label-value" }

  let(:time_to_live) { 86_400 }

  let :tag_key do
    resource_manager_client = Google::Cloud::ResourceManager.tag_keys
    tag_key = Google::Cloud::ResourceManager::V3::TagKey.new(
      parent: "projects/#{project_id}",
      short_name: "sm_tags_sample_tag_key",
      description: "Tag Key for Secret Manager Code Samples"
    )
    begin
      puts "Attempting to create TagKey: '#{short_name}' under '#{parent}'..."
      operation = resource_manager_client.create_tag_key tag_key
      result = operation.wait_until_done!

      if result.response?
        created_tag_key = result.response
        puts "SUCCESS: TagKey created: #{created_tag_key.name} (Short Name: #{created_tag_key.short_name})"
        return created_tag_key
      else
        puts "FAILED to create TagKey '#{short_name}': #{result.error.message}"
        return nil
      end
    rescue Google::Cloud::Error => e
      puts "ERROR creating TagKey '#{short_name}': #{e.message}"
      return nil
    end
  end

  let :tag_value do
    resource_manager_client = Google::Cloud::ResourceManager.tag_values
    tag_value = Google::Cloud::ResourceManager::V3::TagValue.new(
      parent: tag_key.name,
      short_name: "sm_tags_sample_tag_value",
      description: "Tag Value for Secret Manager Code Samples"
    )
    begin
      puts "Attempting to create TagValue: '#{short_name}' for TagKey '#{parent_tag_key_name}'..."
      operation = resource_manager_client.create_tag_value tag_value
      result = operation.wait_until_done!

      if result.response?
        created_tag_value = result.response
        puts "SUCCESS: TagValue created: #{created_tag_value.name} (Short Name: #{created_tag_value.short_name})"
        return created_tag_value
      else
        puts "FAILED to create TagValue '#{short_name}': #{result.error.message}"
        return nil
      end
    rescue Google::Cloud::Error => e
      puts "ERROR creating TagValue '#{short_name}': #{e.message}"
      return nil
    end
  end

  let :secret do
    client.create_secret(
      parent:    "projects/#{project_id}",
      secret_id: secret_id,
      secret:    {
        replication: {
          automatic: {}
        },
        annotations: {
          annotation_key => annotation_value
        },
        labels: {
          label_key => label_value
        }
      }
    )
  end

  let :secret_version do
    client.add_secret_version(
      parent:  secret.name,
      payload: {
        data: "hello world!"
      }
    )
  end

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  register_spec_type(self) { |*descs| descs.include? :secret_manager_snippet }
end
