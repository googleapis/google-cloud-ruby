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
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_location) { "EU" }
  let(:bucket_storage_class) { "DURABLE_REDUCED_AVAILABILITY" }

  it "creates a bucket" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      env.params.wont_include "predefinedAcl"
      env.params.wont_include "predefinedDefaultObjectAcl"
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name
  end

  it "creates a bucket with location" do

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal bucket_name
      JSON.parse(env.body)["location"].must_equal bucket_location

      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name, bucket_url, bucket_location).to_json]
    end

    bucket = storage.create_bucket bucket_name, location: bucket_location
    bucket.location.must_equal bucket_location
  end

  it "creates a bucket with storage_class" do

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal bucket_name
      JSON.parse(env.body)["storageClass"].must_equal bucket_storage_class

      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class).to_json]
    end

    bucket = storage.create_bucket bucket_name, storage_class: :dra
    bucket.storage_class.must_equal bucket_storage_class
  end

  it "creates a bucket with versioning" do

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      JSON.parse(env.body)["name"].must_equal bucket_name
      JSON.parse(env.body)["versioning"]["enabled"].must_equal true

      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, true).to_json]
    end

    bucket = storage.create_bucket bucket_name, versioning: true
    bucket.versioning?.must_equal true
  end

  it "creates a bucket with predefined acl" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      env.params.must_include "predefinedAcl"
      env.params["predefinedAcl"].must_equal "private"
      env.params.wont_include "predefinedDefaultObjectAcl"
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name, acl: "private"
  end

  it "creates a bucket with predefined acl alias" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      env.params.must_include "predefinedAcl"
      env.params["predefinedAcl"].must_equal "publicRead"
      env.params.wont_include "predefinedDefaultObjectAcl"
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name, acl: :public
  end

  it "creates a bucket with predefined default acl" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      env.params.wont_include "predefinedAcl"
      env.params.must_include "predefinedDefaultObjectAcl"
      env.params["predefinedDefaultObjectAcl"].must_equal "private"
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name, default_acl: "private"
  end

  it "creates a bucket with predefined default acl" do
    new_bucket_name = "new-bucket-#{Time.now.to_i}"

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      env.params.wont_include "predefinedAcl"
      env.params.must_include "predefinedDefaultObjectAcl"
      env.params["predefinedDefaultObjectAcl"].must_equal "publicRead"
      JSON.parse(env.body)["name"].must_equal new_bucket_name
      [200, {"Content-Type"=>"application/json"},
       create_bucket_json]
    end

    storage.create_bucket new_bucket_name, default_acl: :public
  end

  it "raises when creating a bucket with a blank name" do
    bucket_name = ""

    mock_connection.post "/storage/v1/b?project=#{project}" do |env|
      [400, { "Content-Type" => "application/json" },
       invalid_bucket_name_error_json(bucket_name)]
    end

    assert_raises Gcloud::Storage::ApiError do
      storage.create_bucket bucket_name
    end
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

  it "lists buckets with find_buckets alias" do
    num_buckets = 3
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(num_buckets)]
    end

    buckets = storage.find_buckets
    buckets.size.must_equal num_buckets
  end

  it "paginates buckets" do
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(3, "next_page_token")]
    end
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(2)]
    end

    first_buckets = storage.buckets
    first_buckets.count.must_equal 3
    first_buckets.token.wont_be :nil?
    first_buckets.token.must_equal "next_page_token"

    second_buckets = storage.buckets token: first_buckets.token
    second_buckets.count.must_equal 2
    second_buckets.token.must_be :nil?
  end

  it "paginates buckets with max set" do
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(3, "next_page_token")]
    end

    subs = storage.buckets max: 3
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

  it "paginates buckets without max set" do
    mock_connection.get "/storage/v1/b?project=#{project}" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_buckets_json(3, "next_page_token")]
    end

    subs = storage.buckets
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

  it "finds a bucket" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_bucket_json(bucket_name)]
    end

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
  end

  it "finds a bucket with find_bucket alias" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_bucket_json(bucket_name)]
    end

    bucket = storage.find_bucket bucket_name
    bucket.name.must_equal bucket_name
  end

  def create_bucket_json
    random_bucket_hash.to_json
  end

  def find_bucket_json name = nil
    random_bucket_hash(name).to_json
  end

  def list_buckets_json count = 2, token = nil
    buckets = count.times.map { random_bucket_hash }
    hash = {"kind"=>"storage#buckets", "items"=>buckets}
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
