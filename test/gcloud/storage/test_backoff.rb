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

describe "Gcloud Storage Backoff", :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash,
                                                   storage.connection }

  it "creates a bucket even when rate limited" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [429, {"Content-Type"=>"application/json"},
       rate_limit_exceeded_json]
    end
    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [429, {"Content-Type"=>"application/json"},
       rate_limit_exceeded_json]
    end
    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    # Should be delayed ~3 seconds
    assert_execution_time 3 do
      storage.create_bucket new_bucket_name
    end
  end

  it "deletes a bucket even when rate limited" do
    mock_connection.delete "/storage/v1/b/#{bucket.name}" do |env|
      [429, {"Content-Type"=>"application/json"},
       rate_limit_exceeded_json]
    end
    mock_connection.delete "/storage/v1/b/#{bucket.name}" do |env|
      [429, {"Content-Type"=>"application/json"},
       rate_limit_exceeded_json]
    end
    mock_connection.delete "/storage/v1/b/#{bucket.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    # Should be delayed ~3 seconds
    assert_execution_time 3 do
      bucket.delete
    end
  end

  def assert_execution_time seconds, delta = 0.1
    begin_time = Time.now
    yield
    finish_time = Time.now
    assert_in_delta seconds, (finish_time - begin_time), delta
  end

  def create_bucket_json
    random_bucket_hash.to_json
  end

  def rate_limit_exceeded_json
    { "error" => { "errors" => [{ "domain" => "usageLimits",
                                  "reason" => "rateLimitExceeded",
                                  "message" => "The project exceeded the rate limit for creating and deleting buckets."}], "code"=>429, "message"=>"The project exceeded the rate limit for creating and deleting buckets."
                                }
    }.to_json
  end
end
