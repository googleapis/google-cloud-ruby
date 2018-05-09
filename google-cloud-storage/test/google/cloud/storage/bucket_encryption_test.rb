# Copyright 2018 Google LLC
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

describe Google::Cloud::Storage::Bucket, :encryption, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  describe "customer-supplied encryption key (CSEK)" do
    let(:encryption_key) { "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI\xF8ftA|[z\x1A\xFBE\xDE\x97&\xBC\xC7" }
    let(:encryption_key_sha256) { "5\x04_\xDF\x1D\x8A_d\xFEK\e6p[XZz\x13s]E\xF6\xBB\x10aQH\xF6o\x14f\xF9" }
    let(:key_options) do { header: {
        "x-goog-encryption-algorithm"  => "AES256",
        "x-goog-encryption-key"        => Base64.strict_encode64(encryption_key),
        "x-goog-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256)
    } }
    end

    it "creates a file with customer-supplied encryption key" do
      new_file_name = random_file_path

      Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
        tmpfile.write "Hello world"
        tmpfile.rewind

        mock = Minitest::Mock.new
        mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
                    [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: key_options]

        bucket.service.mocked_service = mock

        bucket.create_file tmpfile, new_file_name, encryption_key: encryption_key

        mock.verify
      end
    end

    it "finds a file with customer-supplied encryption key" do
      file_name = "file.ext"

      mock = Minitest::Mock.new
      mock.expect :get_object, find_file_gapi(bucket.name, file_name),
                  [bucket.name, file_name, generation: nil, user_project: nil, options: key_options]

      bucket.service.mocked_service = mock

      file = bucket.file file_name, encryption_key: encryption_key

      mock.verify

      file.name.must_equal file_name
      file.user_project.must_be :nil?
      file.wont_be :lazy?
    end
  end

  describe "KMS customer-managed encryption key (CMEK)" do
    let(:kms_key) { "path/to/encryption_key_name" }

    it "gets and sets its encryption config" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new encryption: encryption_gapi(kms_key)
      mock.expect :patch_bucket, patch_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

      bucket.service.mocked_service = mock

      bucket.default_kms_key.must_be :nil?
      bucket.default_kms_key = kms_key
      bucket.default_kms_key.wont_be :nil?
      bucket.default_kms_key.must_be_kind_of String
      bucket.default_kms_key.must_equal kms_key
    end

    it "sets its encryption config to nil" do
      bucket_gapi_with_key = bucket_gapi.dup
      bucket_gapi_with_key.encryption = encryption_gapi(kms_key)
      bucket_with_key = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi_with_key, storage.service
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new encryption: encryption_gapi(nil)
      mock = Minitest::Mock.new
      mock.expect :patch_bucket, bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

      bucket_with_key.service.mocked_service = mock

      bucket_with_key.default_kms_key.wont_be :nil?

      bucket_with_key.default_kms_key = nil
      bucket_with_key.default_kms_key.must_be :nil?
    end

    it "creates a file with the kms_key option" do
      new_file_name = random_file_path

      Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
        tmpfile.write "Hello world"
        tmpfile.rewind

        mock = Minitest::Mock.new
        mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
                    [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: kms_key, user_project: nil, options: {}]

        bucket.service.mocked_service = mock

        bucket.create_file tmpfile, new_file_name, kms_key: kms_key

        mock.verify
      end
    end
  end


  def create_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def empty_file_gapi cache_control: nil, content_disposition: nil,
                      content_encoding: nil, content_language: nil,
                      content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                      storage_class: nil
    Google::Apis::StorageV1::Object.new({
      cache_control: cache_control, content_type: content_type,
      content_disposition: content_disposition, md5_hash: md5,
      content_encoding: content_encoding, crc32c: crc32c,
      content_language: content_language, metadata: metadata,
      storage_class: storage_class }.delete_if { |_k, v| v.nil? })
  end

  def find_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def list_files_gapi count = 2, token = nil, prefixes = nil
    files = count.times.map { Google::Apis::StorageV1::Object.from_json random_file_hash.to_json }
    Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token, prefixes: prefixes
  end
end
