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

describe Gcloud::Storage::Project, :mock_storage do
  it "creates a bucket" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name
  end

  it "lists buckets" do
    num_buckets = 3
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(num_buckets)]
    end

    buckets = storage.buckets
    buckets.size.must_equal num_buckets
  end

  it "finds a bucket" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_bucket_json(bucket_name)]
    end

    bucket = storage.find_bucket bucket_name
  end

  def create_bucket_json
    random_bucket_hash.to_json
  end

  def find_bucket_json name = nil
    random_bucket_hash(name).to_json
  end

  def list_buckets_json count = 2
    buckets = count.times.map { random_bucket_hash }
    {"kind"=>"storage#buckets",
     "items"=>buckets}.to_json
  end

  def random_bucket_hash name=random_bucket_name
    {"kind"=>"storage#bucket",
        "id"=>name,
        "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{name}",
        "projectNumber"=>"1234567890",
        "name"=>name,
        "timeCreated"=>Time.now,
        "metageneration"=>"1",
        "owner"=>{"entity"=>"project-owners-1234567890"},
        "location"=>"US",
        "storageClass"=>"STANDARD",
        "etag"=>"CAE="}
  end

  def random_bucket_name
    (0...50).map { ("a".."z").to_a[rand(26)] }.join
  end
end