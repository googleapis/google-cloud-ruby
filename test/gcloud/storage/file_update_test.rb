# Copyright 2014 Google Inc. All rights reserved.
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

require "helper"
require "json"
require "uri"

describe Gcloud::Storage::File, :update, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:file_hash) { random_file_hash bucket_name, "file.ext" }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Gcloud::Storage::File.from_gapi file_gapi, storage.service }

  it "updates its cache control" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new cache_control: "private, max-age=0, no-cache"
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.cache_control.must_equal "public, max-age=3600"
    file.cache_control = "private, max-age=0, no-cache"

    mock.verify
  end

  it "updates its content_disposition" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_disposition: "inline; filename=filename.ext"
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.content_disposition.must_equal "attachment; filename=filename.ext"
    file.content_disposition = "inline; filename=filename.ext"

    mock.verify
  end

  it "updates its content_encoding" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_encoding: "deflate"
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.content_encoding.must_equal "gzip"
    file.content_encoding = "deflate"

    mock.verify
  end

  it "updates its content_language" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_language: "de"
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.content_language.must_equal "en"
    file.content_language = "de"

    mock.verify
  end

  it "updates its content_type" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new content_type: "application/json"
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.content_type.must_equal "text/plain"
    file.content_type = "application/json"

    mock.verify
  end

  it "updates its metadata" do
    mock = Minitest::Mock.new
    patch_file_gapi = Google::Apis::StorageV1::Object.new metadata: { "player" => "Bob", score: 10 }
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

    file.service.mocked_service = mock

    file.metadata.must_equal({"player"=>"Alice", "score"=>"101"})
    file.metadata = { "player" => "Bob", score: 10 }

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
    mock.expect :patch_object, file_gapi,
      [bucket_name, file.name, patch_file_gapi, predefined_acl: nil]

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
end
