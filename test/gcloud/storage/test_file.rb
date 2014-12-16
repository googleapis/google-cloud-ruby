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

describe Gcloud::Storage::Bucket, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash("bucket"),
                                                   storage.connection }

  # Create a file object with the project's mocked connection object
  let(:file) { Gcloud::Storage::File.from_gapi random_file_hash(bucket.name, "file.ext"),
                                               storage.connection }

  it "can delete itself" do
    mock_connection.delete "/storage/v1/b/#{bucket.name}/o/#{file.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    file.delete
  end

  it "can download itself" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file.name}?alt=media" do |env|
      [200, {"Content-Type"=>"text/plain"},
       "yay!"]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      file.download tmpfile
      File.read(tmpfile).must_equal "yay!"
    end
  end

  it "can copy itself in the same bucket" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/#{bucket.name}/o/new-file.ext" do |env|
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-file.ext"
  end

  it "can copy itself to a different bucket" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/new-bucket/o/new-file.ext" do |env|
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-bucket", "new-file.ext"
  end
end
