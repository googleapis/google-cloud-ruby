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

describe Gcloud::Storage::Bucket, :update, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_location) { "US" }
  let(:bucket_storage_class) { "STANDARD" }
  let(:bucket_hash) { random_bucket_hash bucket_name, bucket_url, bucket_location, bucket_storage_class }
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi bucket_hash, storage.connection }

  it "updates its versioning" do

    mock_connection.patch "/storage/v1/b/#{bucket_name}" do |env|
      json = JSON.parse env.body
      json["versioning"]["enabled"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, true).to_json]
    end

    bucket.versioning?.must_equal false
    bucket.versioning = true
    bucket.versioning?.must_equal true
  end
end
