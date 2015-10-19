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
  # Create a file object with the project's mocked connection object
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:file_hash) { random_file_hash bucket_name, "file.ext" }
  let(:file) { Gcloud::Storage::File.from_gapi file_hash, storage.connection }

  it "updates its cache control" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      JSON.parse(env.body)["cacheControl"].must_equal "private, max-age=0, no-cache"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.cache_control.must_equal "public, max-age=3600"
    file.cache_control = "private, max-age=0, no-cache"
  end

  it "updates its content_disposition" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      JSON.parse(env.body)["contentDisposition"].must_equal "inline; filename=filename.ext"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.content_disposition.must_equal "attachment; filename=filename.ext"
    file.content_disposition = "inline; filename=filename.ext"
  end

  it "updates its content_encoding" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      JSON.parse(env.body)["contentEncoding"].must_equal "deflate"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.content_encoding.must_equal "gzip"
    file.content_encoding = "deflate"
  end

  it "updates its content_language" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      JSON.parse(env.body)["contentLanguage"].must_equal "de"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.content_language.must_equal "en"
    file.content_language = "de"
  end

  it "updates its content_type" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      JSON.parse(env.body)["contentType"].must_equal "application/json"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.content_type.must_equal "text/plain"
    file.content_type = "application/json"
  end

  it "updates its metadata" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      metadata = JSON.parse(env.body)["metadata"]
      metadata.must_be_kind_of Hash
      metadata.size.must_equal 2
      metadata["player"].must_equal "Bob"
      metadata["score"].must_equal 10
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.metadata.must_equal({"player"=>"Alice", "score"=>"101"})
    file.metadata = { "player" => "Bob", score: 10 }
  end

  it "updates multiple attributes in a block" do
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file.name}" do |env|
      json = JSON.parse(env.body)
      json["cacheControl"].must_equal "private, max-age=0, no-cache"
      json["contentDisposition"].must_equal "inline; filename=filename.ext"
      json["contentEncoding"].must_equal "deflate"
      json["contentLanguage"].must_equal "de"
      json["contentType"].must_equal "application/json"
      metadata = json["metadata"]
      metadata.must_be_kind_of Hash
      metadata.size.must_equal 2
      metadata["player"].must_equal "Bob"
      metadata["score"].must_equal "10"
      [200, {"Content-Type"=>"application/json"},
       random_file_hash.to_json]
    end

    file.update do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "inline; filename=filename.ext"
      f.content_encoding = "deflate"
      f.content_language = "de"
      f.content_type = "application/json"
      f.metadata["player"] = "Bob"
      f.metadata["score"] = "10"
    end
  end
end
