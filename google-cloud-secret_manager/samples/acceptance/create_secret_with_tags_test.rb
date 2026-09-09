# Copyright 2025 Google, Inc
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

require "uri"

require_relative "helper"

describe "#create_secret_with_tags", :secret_manager_snippet do
  let(:tag_key_short_name) { "my-tag-key-#{(Time.now.to_f * 1000).to_i}" }
  let(:tag_value_short_name) { "my-tag-value-#{(Time.now.to_f * 1000).to_i}" }
  let(:tag_parent) { "projects/#{project_id}" }
  let(:tag_key_client) { Google::Cloud::ResourceManager::V3::TagKeys::Client.new }
  let(:tag_value_client) { Google::Cloud::ResourceManager::V3::TagValues::Client.new }

  let :tag_key do
    tag_key_client.create_tag_key(
      tag_key: {
        parent: tag_parent,
        short_name: tag_key_short_name
      }
    ).wait_until_done!
    tag_key_client.list_tag_keys(parent: tag_parent).to_a.find { |key| key.short_name == tag_key_short_name }
  end

  let :tag_value do
    tag_value_client.create_tag_value(
      tag_value: {
        parent: tag_key.name,
        short_name: tag_value_short_name
      }
    ).wait_until_done!
    tag_value_client.list_tag_values(parent: tag_key.name).to_a.find { |value| value.short_name == tag_value_short_name }
  end

  let(:interval_duration) { 15 }
  let(:max_duration) { 60 }

  def cleanup_tag_value
    return unless defined?(tag_value) && tag_value
    start_time = Time.now
    end_time = start_time + max_duration
    deleted = false

    while start_time < end_time && !deleted
      begin
        start_time += interval_duration
        tag_value_client.delete_tag_value(name: tag_value.name).wait_until_done!
        # Verify if tag value is deleted
        tag_value_to_delete = tag_value_client.list_tag_values(parent: tag_key.name).to_a.find { |value| value.short_name == tag_value_short_name }
        unless tag_value_to_delete
          deleted = true
        end
      rescue Google::Cloud::NotFoundError
        deleted = true
      rescue StandardError => e
        puts "An error occurred while deleting tag value: #{e.message}. Retrying."
      end

      unless deleted
        sleep interval_duration
      end
    end
    return if deleted
    raise "Failed to delete tag value after #{max_duration} seconds."
  end

  def cleanup_tag_key
    return unless tag_key
    start_time = Time.now
    end_time = start_time + max_duration
    deleted = false

    while start_time < end_time && !deleted
      begin
        start_time += interval_duration
        tag_key_client.delete_tag_key(name: tag_key.name).wait_until_done!
        # Verify if tag key is deleted
        tag_key_to_delete = tag_key_client.list_tag_keys(parent: tag_parent).to_a.find { |key| key.short_name == tag_key_short_name }
        unless tag_key_to_delete
          deleted = true
        end
      rescue Google::Cloud::NotFoundError
        deleted = true
      rescue StandardError => e
        puts "An error occurred while deleting tag key: #{e.message}. Retrying..."
      end

      unless deleted
        sleep interval_duration
      end
    end

    return if deleted
    raise "Failed to delete tag key after #{max_duration} seconds."
  end

  it "creates a secret with tags" do
    sample = SampleLoader.load "create_secret_with_tags.rb"

    begin
      out, _err = capture_io do
        sample.run project_id: project_id, secret_id: secret_id, tag_key: tag_key, tag_value: tag_value
      end
      secret_id_regex = Regexp.escape secret_id
      assert_match %r{Created secret with tag: projects/\S+/secrets/#{secret_id_regex}}, out
    ensure
      # Need to delete secret in the test file itself to clear the tag resources
      client.delete_secret name: secret_name

      # Deleting the tag key and value
      cleanup_tag_value
      cleanup_tag_key
    end
  end
end
