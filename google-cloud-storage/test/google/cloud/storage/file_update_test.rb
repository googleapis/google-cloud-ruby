# Copyright 2014 Google LLC
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

describe Google::Cloud::Storage::File, :update, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:custom_time) { DateTime.new 2020, 2, 3, 4, 5, 6 }
  let(:custom_time_2) { DateTime.new 2020, 3, 4, 5, 6, 7 }
  let(:file_hash) { random_file_hash bucket_name, "file.ext", custom_time: custom_time }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:file_user_project) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service, user_project: true }
  let(:generation) { 1234567890 }
  let(:metageneration) { 6 }

  it "updates its cache control" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new cache_control: "private, max-age=0, no-cache"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})
    file.service.mocked_service = mock

    _(file.cache_control).must_equal "public, max-age=3600"
    file.cache_control = "private, max-age=0, no-cache"

    mock.verify
  end

  it "updates its content_disposition" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_disposition: "inline; filename=filename.ext"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.content_disposition).must_equal "attachment; filename=filename.ext"
    file.content_disposition = "inline; filename=filename.ext"

    mock.verify
  end

  it "updates its content_encoding" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_encoding: "deflate"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})
    file.service.mocked_service = mock

    _(file.content_encoding).must_equal "gzip"
    file.content_encoding = "deflate"

    mock.verify
  end

  it "updates its content_language" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.content_language).must_equal "en"
    file.content_language = "de"

    mock.verify
  end

  it "updates its content_type" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_type: "application/json"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.content_type).must_equal "text/plain"
    file.content_type = "application/json"

    mock.verify
  end

  it "updates its custom_time" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new custom_time: custom_time_2
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})
    file.service.mocked_service = mock

    _(file.custom_time).must_equal custom_time
    file.custom_time = custom_time_2

    mock.verify
  end

  it "updates its metadata" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new metadata: { "player" => "Bob", score: 10 }
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.metadata).must_equal({"player"=>"Alice", "score"=>"101"})
    file.metadata = { "player" => "Bob", score: 10 }

    mock.verify
  end

  it "updates its storage_class" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "NEARLINE"
    patched_file_gapi = file_gapi.dup
    patched_file_gapi.storage_class = "NEARLINE"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.storage_class).must_equal "STANDARD"
    file.storage_class = :nearline
    _(file.storage_class).must_equal "NEARLINE"

    mock.verify
  end

  it "updates its storage_class with user_project set to true" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "COLDLINE"
    patched_file_gapi = file_gapi.dup
    patched_file_gapi.storage_class = "COLDLINE"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file.name, bucket_name, file_user_project.name, patch_file_gapi], **rewrite_object_args(user_project: "test", options: {retries: 0})

    file_user_project.service.mocked_service = mock

    _(file_user_project.storage_class).must_equal "STANDARD"
    file_user_project.storage_class = :coldline
    _(file_user_project.storage_class).must_equal "COLDLINE"

    mock.verify
  end

  it "updates its storage_class, calling rewrite_object as many times as is needed" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "ARCHIVE"
    patched_file_gapi = file_gapi.dup
    patched_file_gapi.storage_class = "ARCHIVE"
    mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(options: {retries: 0})
    mock.expect :rewrite_object, undone_rewrite("keeptrying"),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "notyetcomplete", options: {retries: 0})
    mock.expect :rewrite_object, undone_rewrite("almostthere"),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "keeptrying", options: {retries: 0})
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "almostthere", options: {retries: 0})

    file.service.mocked_service = mock

    # mock out sleep to make the test run faster
    def file.sleep *args
    end

    _(file.storage_class).must_equal "STANDARD"
    file.storage_class = :archive
    _(file.storage_class).must_equal "ARCHIVE"

    mock.verify
  end

  it "updates its storage_class, calling rewrite_object as many times as is needed with user_project set to true" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "DURABLE_REDUCED_AVAILABILITY"
    patched_file_gapi = file_gapi.dup
    patched_file_gapi.storage_class = "DURABLE_REDUCED_AVAILABILITY"
    mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi], **rewrite_object_args(user_project: "test", options: {retries: 0})
    mock.expect :rewrite_object, undone_rewrite("keeptrying"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "notyetcomplete", user_project: "test", options: {retries: 0})
    mock.expect :rewrite_object, undone_rewrite("almostthere"),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "keeptrying", user_project: "test", options: {retries: 0})
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file_user_project.name, bucket_name, file_user_project.name, patch_file_gapi], **rewrite_object_args(rewrite_token: "almostthere", user_project: "test", options: {retries: 0})

    file_user_project.service.mocked_service = mock

    # mock out sleep to make the test run faster
    def file_user_project.sleep *args
    end

    _(file_user_project.storage_class).must_equal "STANDARD"
    file_user_project.storage_class = :dra
    _(file_user_project.storage_class).must_equal "DURABLE_REDUCED_AVAILABILITY"

    mock.verify
  end

  it "updates its temporary_hold" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new temporary_hold: false
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})
    file.service.mocked_service = mock

    _(file.temporary_hold?).must_equal true
    file.release_temporary_hold!

    mock.verify
  end

  it "updates its event_based_hold" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new event_based_hold: false
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    _(file.event_based_hold?).must_equal true
    file.release_event_based_hold!

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
      custom_time: custom_time_2,
      metadata: { "player" => "Bob", "score" => "10" }
    )
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    file.update do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.custom_time = custom_time_2
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
      custom_time: custom_time_2,
      metadata: { "player" => "Bob", "score" => "10" }
    )
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(user_project: "test", options: {retries: 0})

    file_user_project.service.mocked_service = mock

    file_user_project.update do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.custom_time = custom_time_2
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
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(options: {retries: 0})
    file.service.mocked_service = mock

    file.update do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "update accepts storage_class" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new storage_class: "NEARLINE"
    patched_file_gapi = file_gapi.dup
    patched_file_gapi.storage_class = "NEARLINE"
    mock.expect :rewrite_object, done_rewrite(patched_file_gapi),
      [bucket_name, file.name, bucket_name, file.name, patch_file_gapi], **rewrite_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    file.update do |f|
      f.storage_class = :nearline
    end

    mock.verify
  end

  it "updates with generation" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(generation: generation, options: {retries: 0})
    file.service.mocked_service = mock

    file.update generation: generation do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "updates with if_generation_match" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(if_generation_match: generation, options: {retries: 0})
    file.service.mocked_service = mock

    file.update if_generation_match: generation do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "updates with if_generation_not_match" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(if_generation_not_match: generation, options: {retries: 0})
    file.service.mocked_service = mock

    file.update if_generation_not_match: generation do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "updates with if_metageneration_match" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(if_metageneration_match: metageneration)
    file.service.mocked_service = mock

    file.update if_metageneration_match: metageneration do |f|
      f.content_language = "de"
    end

    mock.verify
  end

  it "updates with if_metageneration_not_match" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi, [bucket_name, file.name, patch_file_gapi], **patch_object_args(if_metageneration_not_match: metageneration, options: {retries: 0})
    file.service.mocked_service = mock

    file.update if_metageneration_not_match: metageneration do |f|
      f.content_language = "de"
    end

    mock.verify
  end
end
