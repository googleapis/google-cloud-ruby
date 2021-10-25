# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Bucket, :compose, :mock_storage do
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: "bucket").to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:file_name) { "file.ext" }
  let(:file_hash) { random_file_hash bucket.name, file_name }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:file_user_project) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service, user_project: true }

  let(:file_2_name) { "file-2.ext" }
  let(:file_2_hash) { random_file_hash bucket.name, file_2_name }
  let(:file_2_gapi) { Google::Apis::StorageV1::Object.from_json file_2_hash.to_json }
  let(:file_2) { Google::Cloud::Storage::File.from_gapi file_2_gapi, storage.service }
  let(:file_2_user_project) { Google::Cloud::Storage::File.from_gapi file_2_gapi, storage.service, user_project: true }

  let(:file_3_name) { "file-3.ext" }
  let(:file_3_hash) { random_file_hash bucket.name, file_3_name }
  let(:file_3_gapi) { Google::Apis::StorageV1::Object.from_json file_3_hash.to_json }
  let(:file_3) { Google::Cloud::Storage::File.from_gapi file_3_gapi, storage.service }
  let(:file_3_user_project) { Google::Cloud::Storage::File.from_gapi file_3_gapi, storage.service, user_project: true }

  let(:encryption_key) { "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI\xF8ftA|[z\x1A\xFBE\xDE\x97&\xBC\xC7" }
  let(:encryption_key_sha256) { "5\x04_\xDF\x1D\x8A_d\xFEK\e6p[XZz\x13s]E\xF6\xBB\x10aQH\xF6o\x14f\xF9" }
  let(:key_headers) do {
      "x-goog-encryption-algorithm"  => "AES256",
      "x-goog-encryption-key"        => Base64.strict_encode64(encryption_key),
      "x-goog-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256)
    }
  end
  let(:key_options) { { header: key_headers } }
  let(:generation) { 1234567891 }
  let(:generation_2) { 1234567892 }
  let(:metageneration) { 6 }

  it "can compose a new file with string sources" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_name, file_2_name])

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file_name, file_2_name], file_3_name
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with File sources" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi])

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with File sources that have generations" do
    file_gapi.generation = generation
    file_2_gapi.generation = generation_2

    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi])

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with sources that have if_generation_match preconditions" do
    mock = Minitest::Mock.new
    mock.expect :compose_object,
                file_3_gapi,
                compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], if_source_generation_match: [generation, generation_2])
    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, if_source_generation_match: [generation, generation_2]
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "raises if compose is called with an if_source_generation_match array that does not match sources array" do
    expect do
      new_file = bucket.compose [file, file_2], file_3_name, if_source_generation_match: [generation]
    end.must_raise ArgumentError
  end

  it "can compose a new file with predefined ACL" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], destination_predefined_acl: "private")

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, acl: "private"
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with ACL alias" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], destination_predefined_acl: "publicRead")

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, acl: :public
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with if_generation_match" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], if_generation_match: generation)

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, if_generation_match: generation
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with if_metageneration_match" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], if_metageneration_match: metageneration)

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, if_metageneration_match: metageneration
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], user_project: "test")

    file.service.mocked_service = mock

    new_file = bucket_user_project.compose [file, file_2], file_3_name
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name
    _(new_file.user_project).must_equal true

    mock.verify
  end

  it "can compose a new file with customer-supplied encryption key" do
    mock = Minitest::Mock.new
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], options: key_options)

    file.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name, encryption_key: encryption_key
    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file and set file attributes" do
    mock = Minitest::Mock.new
    update_file_gapi = Google::Apis::StorageV1::Object.new(
      cache_control: "private, max-age=0, no-cache",
      content_disposition: "inline; filename=filename.ext",
      content_encoding: "deflate",
      content_language: "de",
      content_type: "application/json",
      metadata: { "player" => "Bob", "score" => "10" },
      storage_class: "NEARLINE"
    )
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], update_file_gapi)

    bucket.service.mocked_service = mock

    new_file = bucket.compose [file, file_2], file_3_name do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.metadata["player"] = "Bob"
      f.metadata["score"] = "10"
      f.storage_class = :nearline
    end

    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name

    mock.verify
  end

  it "can compose a new file and set file attributes with user_project set to true" do
    mock = Minitest::Mock.new
    update_file_gapi = Google::Apis::StorageV1::Object.new(
      cache_control: "private, max-age=0, no-cache",
      content_disposition: "inline; filename=filename.ext",
      content_encoding: "deflate",
      content_language: "de",
      content_type: "application/json",
      metadata: { "player" => "Bob", "score" => "10" },
      storage_class: "NEARLINE"
    )
    mock.expect :compose_object, file_3_gapi, compose_object_args(bucket.name, file_3_name, [file_gapi, file_2_gapi], update_file_gapi, user_project: "test")

    bucket.service.mocked_service = mock

    new_file = bucket_user_project.compose [file, file_2], file_3_name do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.metadata["player"] = "Bob"
      f.metadata["score"] = "10"
      f.storage_class = :nearline
    end

    _(new_file).must_be_kind_of Google::Cloud::Storage::File
    _(new_file.name).must_equal file_3_name
    _(new_file.user_project).must_equal true

    mock.verify
  end
end
