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
  let(:bucket_location_type) { "multi-region" }
  let(:bucket_storage_class) { "DURABLE_REDUCED_AVAILABILITY" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_autoclass_enabled) { true }
  let(:bucket_requester_pays) { true }
  let(:bucket_enable_object_retention) { true }
  let(:bucket_cors) { [{ max_age_seconds: 300,
                         origin: ["http://example.org", "https://example.org"],
                         http_method: ["*"],
                         response_header: ["X-My-Custom-Header"] }] }
  let(:bucket_cors_gapi) { bucket_cors.map { |c| Google::Apis::StorageV1::Bucket::CorsConfiguration.new **c } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:bucket_retention_period) { 86400 }
  let(:metageneration) { 6 }

  it "adds custom headers to the request options" do
    headers = {
      "x-goog-1" => 1,
      "x-goog-2" => ["x-goog-", 2]
    }

    storage.add_custom_header "x-goog-3" , "x-goog-3, x-goog-3"
    storage.add_custom_header "x-goog-4" , ["x-goog-4", "x-goog-4"]
    storage.add_custom_headers headers

    headers["x-goog-3"] = "x-goog-3, x-goog-3"
    headers["x-goog-4"] = ["x-goog-4", "x-goog-4"]
    headers.each do |key, value|
      _(storage.service.service.request_options.header[key]).must_equal value
    end
  end

  it "gets and memoizes its service_account_email" do
    mock = Minitest::Mock.new
    mock.expect :get_project_service_account, service_account_resp, [project]
    storage.service.mocked_service = mock

    _(storage.service_account_email).must_equal email
    _(storage.service_account_email).must_equal email # memoized, no request

    mock.verify
  end

  it "creates a bucket" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.location_type).must_equal bucket_location_type
  end

  it "creates a bucket with location" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, location: bucket_location
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, location: bucket_location

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.location).must_equal bucket_location
    _(bucket.location_type).must_equal bucket_location_type
  end

  it "creates a bucket with autoclass config" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, autoclass_enabled: bucket_autoclass_enabled
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, autoclass_enabled: bucket_autoclass_enabled

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.autoclass_enabled).must_equal bucket_autoclass_enabled
  end

  it "creates a bucket with storage_class" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, storage_class: bucket_storage_class
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, storage_class: bucket_storage_class

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.storage_class).must_equal bucket_storage_class
  end

  it "creates a bucket with versioning" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, versioning: Google::Apis::StorageV1::Bucket::Versioning.new(enabled: true)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, versioning: true

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.versioning?).must_equal true
  end

  it "creates a bucket with logging bucket and prefix" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, logging: Google::Apis::StorageV1::Bucket::Logging.new(log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, logging_bucket: bucket_logging_bucket, logging_prefix: bucket_logging_prefix

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.logging_bucket).must_equal bucket_logging_bucket
    _(bucket.logging_prefix).must_equal bucket_logging_prefix
  end

  it "creates a bucket with website main and 404" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, website: Google::Apis::StorageV1::Bucket::Website.new(main_page_suffix: bucket_website_main, not_found_page: bucket_website_404)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, website_main: bucket_website_main, website_404: bucket_website_404

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.website_main).must_equal bucket_website_main
    _(bucket.website_404).must_equal bucket_website_404
  end

  it "creates a bucket with requester pays" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.requester_pays).must_equal bucket_requester_pays
  end

  it "creates a bucket with requester pays and user_project set to true" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: "test", enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, user_project: true do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.requester_pays).must_equal bucket_requester_pays
    _(bucket.user_project).must_equal true
  end

  it "creates a bucket with requester pays and user_project set to another project ID" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, billing: Google::Apis::StorageV1::Bucket::Billing.new(requester_pays: bucket_requester_pays)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: "my-other-project", enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, user_project: "my-other-project" do |b|
      b.requester_pays = bucket_requester_pays
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.requester_pays).must_equal bucket_requester_pays
    _(bucket.user_project).must_equal "my-other-project"
  end

  it "creates a bucket with block CORS" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, cors: bucket_cors_gapi
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.cors.add_rule ["http://example.org", "https://example.org"],
                       "*",
                       headers: "X-My-Custom-Header",
                       max_age: 300
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.cors.class).must_equal Google::Cloud::Storage::Bucket::Cors
  end

  it "creates a bucket with block lifecycle (Object Lifecycle Management)" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name, lifecycle: lifecycle_gapi(lifecycle_rule_gapi("SetStorageClass", storage_class: "NEARLINE", age: 32))
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.lifecycle.add_set_storage_class_rule "NEARLINE", age: 32
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.lifecycle.class).must_equal Google::Cloud::Storage::Bucket::Lifecycle
  end

  it "creates a bucket with block labels" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.labels = { "env" => "production", "foo" => "bar" }
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      _(b.labels).must_equal Hash.new
      b.labels = { "env" => "production" }
      b.labels["foo"] = "bar"
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
    _(bucket.cors.class).must_equal Google::Cloud::Storage::Bucket::Cors
  end

  it "creates a bucket with block encryption" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.encryption = encryption_gapi(kms_key)
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.default_kms_key = kms_key
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.default_kms_key).wont_be :nil?
    _(bucket.default_kms_key).must_be_kind_of String
    _(bucket.default_kms_key).must_equal kms_key
  end

  it "creates a bucket with predefined acl" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: "private", predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, acl: "private"

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
  end

  it "creates a bucket with predefined acl alias" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: "publicRead", predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, acl: :public

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
  end

  it "creates a bucket with predefined default acl" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: "private", user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, default_acl: :private

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
  end

  it "creates a bucket with predefined default acl alias" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: "publicRead", user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, default_acl: "public"

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.name).must_equal bucket_name
  end

  it "creates a bucket with retention_period" do
    mock = Minitest::Mock.new

    created_bucket = create_bucket_gapi bucket_name
    created_bucket.retention_policy = Google::Apis::StorageV1::Bucket::RetentionPolicy.new(
      retention_period: bucket_retention_period
    )
    resp_bucket = bucket_with_location created_bucket
    bucket_retention_effective_at = Time.now
    resp_bucket.retention_policy = Google::Apis::StorageV1::Bucket::RetentionPolicy.new(
        retention_period: bucket_retention_period,
        effective_time: bucket_retention_effective_at
    )
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.retention_period = bucket_retention_period
    end

    mock.verify

    _(bucket.retention_period).must_equal bucket_retention_period
    _(bucket.retention_effective_at).must_be_within_delta bucket_retention_effective_at
    _(bucket.retention_policy_locked?).must_equal false
    _(bucket.default_event_based_hold?).must_equal false
  end

  focus
  it "creates a bucket with object retention enabled" do
    mock = Minitest::Mock.new

    created_bucket = create_bucket_gapi bucket_name, enable_object_retention: bucket_enable_object_retention
    resp_bucket = bucket_with_location created_bucket

    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil,
                  predefined_default_object_acl: nil, user_project: nil,
                  # object_retention: object_retention_param(bucket_enable_object_retention),
                  enable_object_retention: bucket_enable_object_retention,
                  options: {}


    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name, enable_object_retention: bucket_enable_object_retention

    mock.verify

    _(bucket.object_retention).must_be_kind_of Google::Apis::StorageV1::Bucket::ObjectRetention
    _(bucket.object_retention.mode).must_equal "Enabled"
  end

  it "creates a bucket with default_event_based_hold" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.default_event_based_hold = true
    resp_bucket = bucket_with_location created_bucket
    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}

    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.default_event_based_hold = true
    end

    mock.verify

    _(bucket.retention_period).must_be :nil?
    _(bucket.retention_effective_at).must_be :nil?
    _(bucket.retention_policy_locked?).must_equal false
    _(bucket.default_event_based_hold?).must_equal true
  end

  it "creates a bucket with rpo" do
    mock = Minitest::Mock.new
    created_bucket = create_bucket_gapi bucket_name
    created_bucket.rpo = "ASYNC_TURBO"
    resp_bucket = bucket_with_location created_bucket, location_type: "dual-region"

    mock.expect :insert_bucket, resp_bucket, [project, created_bucket], predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil, enable_object_retention: nil, options: {}
    storage.service.mocked_service = mock

    bucket = storage.create_bucket bucket_name do |b|
      b.rpo= :ASYNC_TURBO
    end

    mock.verify

    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.rpo).wont_be :nil?
    _(bucket.rpo).must_be_kind_of String
    _(bucket.rpo).must_equal "ASYNC_TURBO"
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
    mock.expect :list_buckets, list_buckets_gapi(num_buckets), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets

    mock.verify

    _(buckets.size).must_equal num_buckets
    bucket = buckets.first
    _(bucket).must_be_kind_of Google::Cloud::Storage::Bucket
    _(bucket.location_type).must_equal "multi-region"
  end

  it "lists buckets with find_buckets alias" do
    num_buckets = 3

    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(num_buckets), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.find_buckets

    mock.verify

    _(buckets.size).must_equal num_buckets
  end

  it "paginates buckets" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    first_buckets = storage.buckets
    second_buckets = storage.buckets token: first_buckets.token

    mock.verify

    _(first_buckets.count).must_equal 3
    _(first_buckets.token).wont_be :nil?
    _(first_buckets.token).must_equal "next_page_token"

    _(second_buckets.count).must_equal 2
    _(second_buckets.token).must_be :nil?
  end

  it "paginates buckets with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: 3, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil, options: {}

    storage.service.mocked_service = mock

    first_buckets = storage.buckets max: 3
    second_buckets = storage.buckets token: first_buckets.token,  max: 3

    mock.verify

    _(first_buckets.count).must_equal 3
    _(first_buckets.token).wont_be :nil?
    _(first_buckets.token).must_equal "next_page_token"

    _(second_buckets.count).must_equal 2
    _(second_buckets.token).must_be :nil?
  end

  it "paginates buckets without max set" do
    num_buckets = 3

    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets

    mock.verify

    _(buckets.size).must_equal num_buckets

    _(buckets.count).must_equal 3
    _(buckets.token).wont_be :nil?
    _(buckets.token).must_equal "next_page_token"
  end

  it "paginates buckets with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    first_buckets = storage.buckets
    second_buckets = first_buckets.next

    mock.verify

    _(first_buckets.count).must_equal 3
    _(first_buckets.next?).must_equal true

    _(second_buckets.count).must_equal 2
    _(second_buckets.next?).must_equal false
  end

  it "paginates buckets with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: 3, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil, options: {}

    storage.service.mocked_service = mock

    first_buckets = storage.buckets max: 3
    second_buckets = first_buckets.next

    mock.verify

    _(first_buckets.count).must_equal 3
    _(first_buckets.next?).must_equal true

    _(second_buckets.count).must_equal 2
    _(second_buckets.next?).must_equal false
  end

  it "paginates buckets with all" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets.all.to_a

    mock.verify

    _(buckets.count).must_equal 5
  end

  it "paginates buckets with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: 3, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(2), [project], prefix: nil, page_token: "next_page_token", max_results: 3, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets(max: 3).all.to_a

    mock.verify

    _(buckets.count).must_equal 5
  end

  it "iterates buckets with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets.all.take(5)

    mock.verify

    _(buckets.count).must_equal 5
  end

  it "iterates buckets with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: nil, options: {}
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: nil, options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets.all(request_limit: 1).to_a

    mock.verify

    _(buckets.count).must_equal 6
  end

  it "iterates buckets with all and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: "test", options: {}
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: "test", options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets(user_project: true).all(request_limit: 1).to_a

    mock.verify

    _(buckets.count).must_equal 6
    _(buckets.first.user_project).must_equal true
  end

  it "iterates buckets with all and user_project set to another project ID" do
    mock = Minitest::Mock.new
    mock.expect :list_buckets, list_buckets_gapi(3, "next_page_token"), [project], prefix: nil, page_token: nil, max_results: nil, user_project: "my-other-project", options: {}
    mock.expect :list_buckets, list_buckets_gapi(3, "second_page_token"), [project], prefix: nil, page_token: "next_page_token", max_results: nil, user_project: "my-other-project", options: {}

    storage.service.mocked_service = mock

    buckets = storage.buckets(user_project: "my-other-project").all(request_limit: 1).to_a

    mock.verify

    _(buckets.count).must_equal 6
    _(buckets.first.user_project).must_equal "my-other-project"
  end

  it "finds a bucket" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "finds a bucket with find_bucket alias" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args

    storage.service.mocked_service = mock

    bucket = storage.find_bucket bucket_name

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "finds a bucket with if_metageneration_match set to a metageneration" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args(if_metageneration_match: metageneration)

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, if_metageneration_match: metageneration

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "finds a bucket with if_metageneration_not_match set to a metageneration" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args(if_metageneration_not_match: metageneration)

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, if_metageneration_not_match: metageneration

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "finds a bucket with user_project set to true" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args(user_project: "test")

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "finds a bucket with user_project set to another project ID" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args(user_project: "my-other-project")

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: "my-other-project"

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "returns a lazy bucket" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).must_be :lazy?
  end

  it "returns a lazy bucket with find_bucket alias" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.find_bucket bucket_name, skip_lookup: true

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).must_be :lazy?
  end

  it "returns a lazy bucket with user_project set to true" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true, user_project: true

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).must_be :lazy?
  end

  it "returns a lazy bucket with user_project set to another project ID" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, skip_lookup: true, user_project: "my-other-project"

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).must_be :lazy?
  end

  def bucket_with_location created_bucket,
                           location_type: bucket_location_type
    resp_bucket = created_bucket.dup
    resp_bucket.location_type = location_type
    resp_bucket
  end

  def create_bucket_gapi name = nil,
                         location: nil,
                         storage_class: nil,
                         versioning: nil,
                         logging: nil,
                         website: nil,
                         cors: nil,
                         billing: nil,
                         lifecycle: nil,
                         autoclass_enabled: false,
                         enable_object_retention: nil
    options = {
      name: name, location: location, storage_class: storage_class,
      versioning: versioning, logging: logging, website: website,
      cors_configurations: cors, billing: billing, lifecycle: lifecycle,
      autoclass: Google::Apis::StorageV1::Bucket::Autoclass.new( enabled: autoclass_enabled ),
      object_retention: object_retention_param(enable_object_retention)
    }.delete_if { |_, v| v.nil? }
    Google::Apis::StorageV1::Bucket.new **options
  end

  def find_bucket_gapi name = nil
    Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: name).to_json
  end

  def list_buckets_gapi count = 2, token = nil
    buckets = count.times.map { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash.to_json }
    Google::Apis::StorageV1::Buckets.new(
      kind: "storage#buckets", items: buckets, next_page_token: token
    )
  end

  def object_retention_param enable_object_retention
    enable_object_retention ? Google::Apis::StorageV1::Bucket::ObjectRetention.new(mode: "Enabled") : nil
  end
end
