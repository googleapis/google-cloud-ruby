# Copyright 2026 Google LLC
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
require "pry"

describe Google::Cloud::Storage::Bucket, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:custom_context_key1) { "my-custom-key" }
  let(:custom_context_value1) { "my-custom-value" }
  let(:custom_context_key2) { "my-custom-key-2" }
  let(:custom_context_value2) { "my-custom-value-2" }

  describe "listing files with contexts" do
    it "lists files with specific contexts" do
      num_files = 2
      expected_filter = "contexts.\"#{custom_context_key1}\"=\"#{custom_context_value1}\""
      mock = Minitest::Mock.new
      mock.expect :list_objects, list_files_gapi(num_files, custom_context_key1, custom_context_value1),
                  [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes: nil, soft_deleted: nil, filter: expected_filter, options: {}

      bucket.service.mocked_service = mock

      files = bucket.files filter: expected_filter

      mock.verify
      _(files.size).must_equal num_files
      files.each do |file|
        _(file).must_be_kind_of Google::Cloud::Storage::File
      end
    end

    it "lists files without specific contexts" do
      num_files = 1
      expected_filter = "-contexts.\"#{custom_context_key1}\"=\"#{custom_context_value1}\""
      mock = Minitest::Mock.new
      mock.expect :list_objects, list_files_gapi(num_files, custom_context_key1, custom_context_value1),
                  [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes: nil, soft_deleted: nil, filter: expected_filter, options: {}

      bucket.service.mocked_service = mock
      files = bucket.files filter: expected_filter
      mock.verify
      _(files.size).must_equal num_files
      files.each do |file|
        _(file).must_be_kind_of Google::Cloud::Storage::File
      end
    end
  end

  describe "setting and deleting contexts" do
    let(:file_name) { "my-file" }
    let(:file_gapi) { create_file_gapi bucket.name, file_name }
    let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
    it "sets contexts for a file" do
      expected_contexts = context_custom_hash custom_context_key: custom_context_key1,
                                              custom_context_value: custom_context_value1
    
      mock = Minitest::Mock.new

      mock.expect :patch_object, file_gapi do |bucket_name, file_name, patch_obj, **args|
        bucket_name == bucket.name &&
          file_name == file.name &&
          patch_obj.contexts == expected_contexts &&
          args[:options][:retries].zero?
      end
      bucket.service.mocked_service = mock
      file.contexts = expected_contexts
      mock.verify
    end

    it "deletes contexts for a file" do
      file_gapi = create_file_gapi_with_contexts bucket.name, file_name, custom_context_key: custom_context_key1,custom_context_value: custom_context_value1
      file = Google::Cloud::Storage::File.from_gapi file_gapi, storage.service
      mock = Minitest::Mock.new

      mock.expect :patch_object, file_gapi do |bucket_name, file_name, patch_obj, **args|
        bucket_name == bucket.name &&
          file_name == file.name &&
          patch_obj.contexts.nil? &&
          args[:options][:retries].zero?
      end
      bucket.service.mocked_service = mock
      file.contexts = nil
      mock.verify
      _(file.contexts).must_be_nil
    end
  end


  def create_file_gapi bucket = nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def create_file_gapi_with_contexts bucket = nil, name = nil, _custom_context_key = nil, _custom_context_value = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name, custom_context_key1,
                                                               custom_context_value1).to_json
  end

  def empty_file_gapi cache_control: nil, content_disposition: nil,
                      content_encoding: nil, content_language: nil,
                      content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                      storage_class: nil
    params = {
      cache_control: cache_control, content_type: content_type,
      content_disposition: content_disposition, md5_hash: md5,
      content_encoding: content_encoding, crc32c: crc32c,
      content_language: content_language, metadata: metadata,
      storage_class: storage_class
    }.delete_if { |_k, v| v.nil? }
    Google::Apis::StorageV1::Object.new(**params)
  end

  def find_file_gapi bucket = nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def list_files_gapi count = 2, custom_context_key = nil, custom_context_value = nil, token = nil, prefixes = nil
    files = count.times.map { Google::Apis::StorageV1::Object.from_json random_file_hash(custom_context_key = custom_context_key, custom_context_value = custom_context_value).to_json }
    Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token,
                                         prefixes: prefixes
  end
end
