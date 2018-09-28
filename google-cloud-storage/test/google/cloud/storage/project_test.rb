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
require "json"

describe Google::Cloud::Storage::Project, :mock_storage do
  let(:email) { "my_service_account@gs-project-accounts.iam.gserviceaccount.com" }
  let(:service_account_resp) { OpenStruct.new email_address: email }
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_location) { "EU" }
  let(:bucket_storage_class) { "DURABLE_REDUCED_AVAILABILITY" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_requester_pays) { true }
  let(:bucket_cors) { [{ max_age_seconds: 300,
                         origin: ["http://example.org", "https://example.org"],
                         http_method: ["*"],
                         response_header: ["X-My-Custom-Header"] }] }
  let(:bucket_cors_gapi) { bucket_cors.map { |c| Google::Apis::StorageV1::Bucket::CorsConfiguration.new c } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:bucket_retention_period) { 86400 }

  it "gets and memoizes its service_account_email" do
    mock = Minitest::Mock.new
    mock.expect :get_project_service_account, service_account_resp, [project]
    storage.service.mocked_service = mock

    storage.service_account_email.must_equal email
    storage.service_account_email.must_equal email # memoized, no request

    mock.verify
  end

  it "creates a bucket" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
  end

  it "creates a bucket with location" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, location: bucket_location
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, location: bucket_location

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.location.must_equal bucket_location
  end

  it "creates a bucket with storage_class" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, storage_class: bucket_storage_class
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, storage_class: bucket_storage_class

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.storage_class.must_equal bucket_storage_class
  end

  it "creates a bucket with versioning" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, versioning: Google::Apis::StorageV1::Bucket::Versioning.new(enabled: true)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, versioning: true

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.versioning?.must_equal true
  end

  it "creates a bucket with logging bucket and prefix" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, logging: Google::Apis::StorageV1::Bucket::Logging.new(log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, logging_bucket: bucket_logging_bucket, logging_prefix: bucket_logging_prefix

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.logging_bucket.must_equal bucket_logging_bucket
    bucket.logging_prefix.must_equal bucket_logging_prefix
  end

  it "creates a bucket with website main and 404" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, website: Google::Apis::StorageV1::Bucket::Website.new(main_page_suffix: bucket_website_main, not_found_page: bucket_website_404)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, website_main: bucket_website_main, website_404: bucket_website_404

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.website_main.must_equal bucket_website_main
    bucket.website_404.must_equal bucket_website_404
  end

  it "creates a bucket with requester pays" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.requester_pays.must_equal bucket_requester_pays
  end

  it "creates a bucket with requester pays and user_project set to true" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: "test"]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, user_project: true do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.requester_pays.must_equal bucket_requester_pays
    bucket.user_project.must_equal true
  end

  it "creates a bucket with requester pays and user_project set to another project ID" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: "my-other-project"]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, user_project: "my-other-project" do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.requester_pays.must_equal bucket_requester_pays
    bucket.user_project.must_equal "my-other-project"
  end

  it "creates a bucket with block CORS" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, cors: bucket_cors_gapi
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.cors.add_rule ["http://example.org", "https://example.org"],
                       "*",
                       headers: "X-My-Custom-Header",
                       max_age: 300
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.cors.class.must_equal Google::Cloud::Storage::Bucket::Cors
  end

  it "creates a bucket with block lifecycle (Object Lifecycle Management)" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, lifecycle: lifecycle_gapi(lifecycle_rule_gapi("SetStorageClass", storage_class: "NEARLINE", age: 32))
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.lifecycle.add_set_storage_class_rule "NEARLINE", age: 32
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.lifecycle.class.must_equal Google::Cloud::Storage::Bucket::Lifecycle
  end

  it "creates a bucket with block labels" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.labels = { "env" => "production", "foo" => "bar" }
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.labels.must_equal Hash.new
      b.labels = { "env" => "production" }
      b.labels["foo"] = "bar"
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
    bucket.cors.class.must_equal Google::Cloud::Storage::Bucket::Cors
  end

  it "creates a bucket with block encryption" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.encryption = encryption_gapi(kms_key)
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.default_kms_key = kms_key
    end

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.default_kms_key.wont_be :nil?
    bucket.default_kms_key.must_be_kind_of String
    bucket.default_kms_key.must_equal kms_key
  end

  it "creates a bucket with predefined acl" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: "private", predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, acl: "private"

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
  end

  it "creates a bucket with predefined acl alias" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: "publicRead", predefined_default_object_acl: nil, user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, acl: :public

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
  end

  it "creates a bucket with predefined default acl" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: "private", user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, default_acl: :private

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
  end

  it "creates a bucket with predefined default acl alias" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: "publicRead", user_project: nil]
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, default_acl: "public"

    mock.verify

    bucket.must_be_kind_of Google::Cloud::Storage::Bucket
    bucket.name.must_equal bucket_name
  end

  it "creates a bucket with retention_period" do
    mock = Minitest::Mock.new

    created_bucket = create_bucket_gapi bucket_name
    created_bucket.retention_policy = Google::Apis::StorageV1::Bucket::RetentionPolicy.new(
      retention_period: bucket_retention_period
    )

    bucket_retention_effective_at = Time.now
    resp_bucket = create_bucket_gapi bucket_name
    resp_bucket.retention_policy = Google::Apis::StorageV1::Bucket::RetentionPolicy.new(
        retention_period: bucket_retention_period,
        effective_time: bucket_retention_effective_at
    )
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.retention_period = bucket_retention_period
    end

    mock.verify

    bucket.retention_period.must_equal bucket_retention_period
    bucket.retention_effective_at.must_be_within_delta bucket_retention_effective_at
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false
  end

  it "creates a bucket with default_event_based_hold" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.default_event_based_hold = true
    mock.expect :insert_bucket, created_bucket, [project, created_bucket, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.default_event_based_hold = true
    end

    mock.verify

    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal true
  end

  it "raises when creating a bucket with a blank name" do
    bucket_name = ""

    stub = Object.new
    def stub.insert_bucket *args
      raise Google::Apis::ClientError.new("invalid argument", status_code: 400)
    end
    storage.service.mocked_service = stub

    assert_raises Google::Cloud::InvalidArgumentError do
      storage.create_bucket bucket_name
    end
  end

  it "lists buckets" do
    num_buckets = 3

    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(num_buckets), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets

    mock.verify

    buckets.size.must_equal num_buckets
  end

  it "lists buckets with find_buckets alias" do
    num_buckets = 3

    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(num_buckets), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.find_buckets

    mock.verify

    buckets.size.must_equal num_buckets
  end

  it "paginates buckets" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    first_buckets = storage.buckets
    second_buckets = storage.buckets token: first_buckets.token

    mock.verify

    first_buckets.count.must_equal 3
    first_buckets.token.wont_be :nil?
    first_buckets.token.must_equal "next_page_token"

    second_buckets.count.must_equal 2
    second_buckets.token.must_be :nil?
  end

  it "paginates buckets with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: 3, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil]

    storage.service.mocked_service = mock

    first_buckets = storage.buckets max: 3
    second_buckets = storage.buckets token: first_buckets.token,  max: 3

    mock.verify

    first_buckets.count.must_equal 3
    first_buckets.token.wont_be :nil?
    first_buckets.token.must_equal "next_page_token"

    second_buckets.count.must_equal 2
    second_buckets.token.must_be :nil?
  end

  it "paginates buckets without max set" do
    num_buckets = 3

    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets

    mock.verify

    buckets.size.must_equal num_buckets

    buckets.count.must_equal 3
    buckets.token.wont_be :nil?
    buckets.token.must_equal "next_page_token"
  end

  it "paginates buckets with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    first_buckets = storage.buckets
    second_buckets = first_buckets.next

    mock.verify

    first_buckets.count.must_equal 3
    first_buckets.next?.must_equal true

    second_buckets.count.must_equal 2
    second_buckets.next?.must_equal false
  end

  it "paginates buckets with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: 3, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil]

    storage.service.mocked_service = mock

    first_buckets = storage.buckets max: 3
    second_buckets = first_buckets.next

    mock.verify

    first_buckets.count.must_equal 3
    first_buckets.next?.must_equal true

    second_buckets.count.must_equal 2
    second_buckets.next?.must_equal false
  end

  it "paginates buckets with all" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets.all.to_a

    mock.verify

    buckets.count.must_equal 5
  end

  it "paginates buckets with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: 3, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(2), [project, prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets(max: 3).all.to_a

    mock.verify

    buckets.count.must_equal 5
  end

  it "iterates buckets with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets.all.take(5)

    mock.verify

    buckets.count.must_equal 5
  end

  it "iterates buckets with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: nil]
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil]

    storage.service.mocked_service = mock

    buckets = storage.buckets.all(request_limit: 1).to_a

    mock.verify

    buckets.count.must_equal 6
  end

  it "iterates buckets with all and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: "test"]
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: "test"]

    storage.service.mocked_service = mock

    buckets = storage.buckets(user_project: true).all(request_limit: 1).to_a

    mock.verify

    buckets.count.must_equal 6
    buckets.first.user_project.must_equal true
  end

  it "iterates buckets with all and user_project set to another project ID" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project, prefix: nil, page_token: nil, max_results: nil, user_project: "my-other-project"]
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project, prefix: nil, page_token: "next_page_token", max_results: nil, user_project: "my-other-project"]

    storage.service.mocked_service = mock

    buckets = storage.buckets(user_project: "my-other-project").all(request_limit: 1).to_a

    mock.verify

    buckets.count.must_equal 6
    buckets.first.user_project.must_equal "my-other-project"
  end

  it "finds a bucket" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name, {user_project: nil}]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.wont_be :lazy?
  end

  it "finds a bucket with find_bucket alias" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name, {user_project: nil}]

    storage.service.mocked_service = mock

    bucket = storage.find_bucket bucket_name

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.wont_be :lazy?
  end

  it "finds a bucket with user_project set to true" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name, { user_project: "test" }]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.wont_be :lazy?
  end

  it "finds a bucket with user_project set to another project ID" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name, { user_project: "my-other-project" }]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: "my-other-project"

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.wont_be :lazy?
  end

  it "returns a lazy bucket" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.must_be :lazy?
  end

  it "returns a lazy bucket with find_bucket alias" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.find_bucket bucket_name, skip_lookup: true

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.must_be :lazy?
  end

  it "returns a lazy bucket with user_project set to true" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true, user_project: true

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.must_be :lazy?
  end

  it "returns a lazy bucket with user_project set to another project ID" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true, user_project: "my-other-project"

    mock.verify

    bucket.name.must_equal bucket_name
    bucket.must_be :lazy?
  end

  def create_bucket_gapi name = nil, location: nil, storage_class: nil,
                         versioning: nil, logging: nil, website: nil, cors: nil,
                         billing: nil, lifecycle: nil
    options = {
      name: name, location: location, storage_class: storage_class,
      versioning: versioning, logging: logging, website: website,
      cors_configurations: cors, billing: billing, lifecycle: lifecycle
    }.delete_if { |_, v| v.nil? }
    Google::Apis::StorageV1::Bucket.new options
  end

  def find_bucket_gapi name = nil
    Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name).to_json
  end

  def list_buckets_gapi count = 2, token = nil
    buckets = count.times.map { random_bucket_hash }
    Google::Apis::StorageV1::Buckets.new(
      kind: "storage#buckets", items: buckets, next_page_token: token
    )
  end
end
