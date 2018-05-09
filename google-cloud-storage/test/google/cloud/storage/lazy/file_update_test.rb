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

describe Google::Cloud::Storage::File, :update, :lazy, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:file_name) { "file.ext" }
  let(:file) { Google::Cloud::Storage::File.new_lazy bucket_name, file_name, storage.service }
  let(:file_user_project) { Google::Cloud::Storage::File.new_lazy bucket_name, file_name, storage.service, user_project: true }

  it "updates its cache control" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new cache_control: "private, max-age=0, no-cache"
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.cache_control.must_be :nil?
    file.cache_control = "private, max-age=0, no-cache"

    mock.verify
  end

  it "updates its content_disposition" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_disposition: "inline; filename=filename.ext"
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.content_disposition.must_be :nil?
    file.content_disposition = "inline; filename=filename.ext"

    mock.verify
  end

  it "updates its content_encoding" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_encoding: "deflate"
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.content_encoding.must_be :nil?
    file.content_encoding = "deflate"

    mock.verify
  end

  it "updates its content_language" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.content_language.must_be :nil?
    file.content_language = "de"

    mock.verify
  end

  it "updates its content_type" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_type: "application/json"
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.content_type.must_be :nil?
    file.content_type = "application/json"

    mock.verify
  end

  it "updates its metadata" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new metadata: { "player" => "Bob", score: 10 }
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.metadata.must_be :empty?
    file.metadata = { "player" => "Bob", score: 10 }

    mock.verify
  end

  it "updates its storage_class" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "DURABLE_REDUCED_AVAILABILITY"
    patched_file_gapi = Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json)
    patched_file_gapi.storage_class = "DURABLE_REDUCED_AVAILABILITY"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: nil, user_project: nil, options: {}]

    file.service.mocked_service = mock

    file.storage_class.must_be :nil?
    file.storage_class = :dra
    file.storage_class.must_equal "DURABLE_REDUCED_AVAILABILITY"

    mock.verify
  end

  it "updates its storage_class with user_project set to true" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "DURABLE_REDUCED_AVAILABILITY"
    patched_file_gapi = Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json)
    patched_file_gapi.storage_class = "DURABLE_REDUCED_AVAILABILITY"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_name, bucket_name, file_user_project.name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: nil, user_project: "test", options: {}]

    file_user_project.service.mocked_service = mock

    file_user_project.storage_class.must_be :nil?
    file_user_project.storage_class = :dra
    file_user_project.storage_class.must_equal "DURABLE_REDUCED_AVAILABILITY"

    mock.verify
  end

  it "updates its storage_class, calling rewrite_object as many times as is needed" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "DURABLE_REDUCED_AVAILABILITY"
    patched_file_gapi = Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json)
    patched_file_gapi.storage_class = "DURABLE_REDUCED_AVAILABILITY"
    mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: nil, user_project: nil, options: {}]
    mock.expect :rewrite_object, undone_rewrite("keeptrying"),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "notyetcomplete", user_project: nil, options: {}]
    mock.expect :rewrite_object, undone_rewrite("almostthere"),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "keeptrying", user_project: nil, options: {}]
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "almostthere", user_project: nil, options: {}]

    file.service.mocked_service = mock

    # mock out sleep to make the test run faster
    def file.sleep *args
    end

    file.storage_class.must_be :nil?
    file.storage_class = :dra
    file.storage_class.must_equal "DURABLE_REDUCED_AVAILABILITY"

    mock.verify
  end

  it "updates its storage_class, calling rewrite_object as many times as is needed with user_project set to true" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "DURABLE_REDUCED_AVAILABILITY"
    patched_file_gapi = Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json)
    patched_file_gapi.storage_class = "DURABLE_REDUCED_AVAILABILITY"
    mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: nil, user_project: "test", options: {}]
    mock.expect :rewrite_object, undone_rewrite("keeptrying"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "notyetcomplete", user_project: "test", options: {}]
    mock.expect :rewrite_object, undone_rewrite("almostthere"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "keeptrying", user_project: "test", options: {}]
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: "almostthere", user_project: "test", options: {}]

    file_user_project.service.mocked_service = mock

    # mock out sleep to make the test run faster
    def file_user_project.sleep *args
    end

    file_user_project.storage_class.must_be :nil?
    file_user_project.storage_class = :dra
    file_user_project.storage_class.must_equal "DURABLE_REDUCED_AVAILABILITY"

    mock.verify
  end

  it "updates multiple attributes in a block" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new(
      cache_control: "private, max-age=0, no-cache",
      content_disposition: "inline; filename=filename.ext",
      content_encoding: "deflate",
      content_language: "de",
      content_type: "application/json",
      metadata: { "player" => "Bob", "score" => "10" }
    )
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.update do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.metadata["player"] = "Bob"
      f.metadata["score"] = "10"
    end

    mock.verify
  end

  it "updates multiple attributes in a block with user_project set to true" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new(
      cache_control: "private, max-age=0, no-cache",
      content_disposition: "inline; filename=filename.ext",
      content_encoding: "deflate",
      content_language: "de",
      content_type: "application/json",
      metadata: { "player" => "Bob", "score" => "10" }
    )
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_user_project.name, patch_file_gapi, predefined_acl: nil, user_project: "test"]

    file_user_project.service.mocked_service = mock

    file_user_project.update do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.metadata["player"] = "Bob"
      f.metadata["score"] = "10"
    end

    mock.verify
  end

  it "updates does not set metadata if it has not changed" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new(
      content_language: "de"
    )
    mock.expect :patch_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, patch_file_gapi, predefined_acl: nil, user_project: nil]

    file.service.mocked_service = mock

    file.update do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "update accepts storage_class" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "NEARLINE"
    patched_file_gapi = Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json)
    patched_file_gapi.storage_class = "NEARLINE"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_name, bucket_name, file_name, patch_file_gapi, destination_kms_key_name: nil, destination_predefined_acl: nil, source_generation: nil, rewrite_token: nil, user_project: nil, options: {}]

    file.service.mocked_service = mock

    file.update do |f|
      f.storage_class = :nearline
    end

    mock.verify
  end
end
