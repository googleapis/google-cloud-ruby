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

describe Google::Cloud::Storage::Bucket, :update, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_location) { "US" }
  let(:bucket_storage_class) { "STANDARD" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_requester_pays) { true }
  let(:bucket_autoclass_enabled) { true }
  let(:bucket_cors_gapi) { Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
    max_age_seconds: 300,
    origin: ["http://example.org", "https://example.org"],
    http_method: ["*"],
    response_header: ["X-My-Custom-Header"]) }
  let(:bucket_cors_hash) { JSON.parse bucket_cors_gapi.to_json }
  let(:bucket_lifecycle_created_before) { Date.parse "2013-01-15" }
  let(:bucket_lifecycle_custom_time_before) { Date.parse "2019-01-15" }
  let(:bucket_lifecycle_noncurrent_time_before) { Date.parse "2020-01-15" }
  let(:bucket_lifecycle_gapi) do
    lifecycle_gapi lifecycle_rule_gapi("SetStorageClass",
                                       storage_class: "NEARLINE",
                                       age: 32,
                                       created_before: bucket_lifecycle_created_before,
                                       custom_time_before: bucket_lifecycle_custom_time_before,
                                       days_since_custom_time: 4,
                                       days_since_noncurrent_time: 14,
                                       is_live: true,
                                       matches_storage_class: ["STANDARD"],
                                       noncurrent_time_before: bucket_lifecycle_noncurrent_time_before,
                                       num_newer_versions: 3)
  end
  let(:bucket_lifecycle_hash) { JSON.parse bucket_lifecycle_gapi.to_json }
  let(:bucket_hash) { random_bucket_hash name: bucket_name, url_root: bucket_url_root, location: bucket_location, storage_class: bucket_storage_class, autoclass_enabled: bucket_autoclass_enabled, autoclass_terminal_storage_class: "NEARLINE" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:bucket_with_cors_hash) { random_bucket_hash name: bucket_name, url_root: bucket_url_root, location: bucket_location, storage_class: bucket_storage_class,
                                                   cors: [bucket_cors_hash], lifecycle: bucket_lifecycle_hash }
  let(:bucket_with_cors_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_with_cors_hash.to_json }
  let(:bucket_with_cors) { Google::Cloud::Storage::Bucket.from_gapi bucket_with_cors_gapi, storage.service }
  let(:metageneration) { 6 }

  it "updates its autoclass config" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new autoclass: { enabled: false }
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_prefix: bucket_logging_prefix, autoclass_enabled: false).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: { retries: 0 })

    bucket.service.mocked_service = mock

    _(bucket.autoclass_enabled).must_equal true
    bucket.autoclass_enabled= false
    _(bucket.autoclass_enabled).must_equal false

    mock.verify
  end

  it "updates its autoclass terminal storage class config" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new autoclass: { enabled: true, terminal_storage_class: "ARCHIVE" }
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_prefix: bucket_logging_prefix, autoclass_enabled: true, autoclass_terminal_storage_class: "ARCHIVE").to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: { retries: 0 })

    bucket.service.mocked_service = mock

    _(bucket.autoclass_terminal_storage_class).must_equal "NEARLINE"
    bucket.autoclass_terminal_storage_class = "ARCHIVE"
    _(bucket.autoclass_terminal_storage_class).must_equal "ARCHIVE"
    _(bucket.autoclass_enabled).must_equal true

    mock.verify
  end

  it "updates all autoclass configs: enabled & terminal storage class in one call" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new autoclass: { enabled: true, terminal_storage_class: "ARCHIVE" }
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_prefix: bucket_logging_prefix, autoclass_enabled: true, autoclass_terminal_storage_class: "ARCHIVE").to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: { retries: 0 })

    bucket.service.mocked_service = mock

    _(bucket.autoclass_terminal_storage_class).must_equal "NEARLINE"
    bucket.update_autoclass({ enabled: true, terminal_storage_class: 'ARCHIVE' })
    _(bucket.autoclass_terminal_storage_class).must_equal 'ARCHIVE'

    mock.verify
  end

  it "updates its versioning" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, versioning: true).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket).wont_be :versioning?
    bucket.versioning = true
    _(bucket).must_be :versioning?

    mock.verify
  end

  it "updates its versioning with if_metageneration_match" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, versioning: true).to_json
    mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(if_metageneration_match: metageneration)

    bucket.service.mocked_service = mock

    _(bucket).wont_be :versioning?

    bucket.update if_metageneration_match: metageneration do |b|
      b.versioning = true
    end

    _(bucket).must_be :versioning?

    mock.verify
  end

  it "updates its versioning with if_metageneration_not_match" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, versioning: true).to_json
    mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(if_metageneration_not_match: metageneration, options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket).wont_be :versioning?

    bucket.update if_metageneration_not_match: metageneration do |b|
      b.versioning = true
    end

    _(bucket).must_be :versioning?

    mock.verify
  end

  it "updates its versioning with user_project set to true" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, versioning: true).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(user_project: "test", options: {retries: 0})

    bucket.service.mocked_service = mock
    bucket.user_project = true

    _(bucket).wont_be :versioning?
    bucket.versioning = true
    _(bucket).must_be :versioning?

    mock.verify
  end

  it "updates its logging bucket" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_bucket: bucket_logging_bucket).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.logging_bucket).must_be :nil?
    bucket.logging_bucket = bucket_logging_bucket
    _(bucket.logging_bucket).must_equal bucket_logging_bucket

    mock.verify
  end

  it "updates its logging prefix" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_object_prefix: bucket_logging_prefix
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_prefix: bucket_logging_prefix).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.logging_prefix).must_be :nil?
    bucket.logging_prefix = bucket_logging_prefix
    _(bucket.logging_prefix).must_equal bucket_logging_prefix

    mock.verify
  end

  it "updates its logging bucket and prefix" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, logging_bucket: bucket_logging_bucket, logging_prefix: bucket_logging_prefix).to_json
    mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi.class], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.logging_bucket).must_be :nil?
    _(bucket.logging_prefix).must_be :nil?

    bucket.update do |b|
      b.logging_bucket = bucket_logging_bucket
      b.logging_prefix = bucket_logging_prefix
    end

    _(bucket.logging_bucket).must_equal bucket_logging_bucket
    _(bucket.logging_prefix).must_equal bucket_logging_prefix
    _(bucket.location_type).must_equal "multi-region"

    mock.verify
  end

  it "updates its storage class" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new storage_class: "NEARLINE"
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: "NEARLINE", logging_prefix: bucket_logging_prefix).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.storage_class).must_equal bucket_storage_class
    bucket.storage_class = :nearline
    _(bucket.storage_class).must_equal "NEARLINE"

    mock.verify
  end

  it "updates its website main page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, website_main: bucket_website_main).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.website_main).must_be :nil?
    bucket.website_main = bucket_website_main
    _(bucket.website_main).must_equal bucket_website_main

    mock.verify
  end

  it "updates its website not found 404 page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new not_found_page: bucket_website_404
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, website_404: bucket_website_404).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.website_404).must_be :nil?
    bucket.website_404 = bucket_website_404
    _(bucket.website_404).must_equal bucket_website_404

    mock.verify
  end

  it "updates its website main page and not found 404 page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main, not_found_page: bucket_website_404
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, website_main: bucket_website_main, website_404: bucket_website_404).to_json
    mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.website_main).must_be :nil?
    _(bucket.website_404).must_be :nil?

    bucket.update do |b|
      b.website_main = bucket_website_main
      b.website_404 = bucket_website_404
    end

    _(bucket.website_main).must_equal bucket_website_main
    _(bucket.website_404).must_equal bucket_website_404

    mock.verify
  end

  it "updates its requester pays" do
    mock = Minitest::Mock.new
    patch_billing_gapi = Google::Apis::StorageV1::Bucket::Billing.new requester_pays: bucket_requester_pays
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new billing: patch_billing_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, requester_pays: bucket_requester_pays).to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.requester_pays).must_be :nil?
    bucket.requester_pays = bucket_requester_pays
    _(bucket.requester_pays).must_equal bucket_requester_pays

    mock.verify
  end

  it "cannot modify its labels" do
    _(bucket.labels).must_equal Hash.new
    assert_raises do
      bucket.labels["foo"] = "bar"
    end
  end

  it "updates its labels" do
    mock = Minitest::Mock.new
    new_labels = { "env" => "production", "foo" => "bar" }
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new labels: new_labels
    returned_bucket_hash = random_bucket_hash name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class
    returned_bucket_hash[:labels] = new_labels
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json returned_bucket_hash.to_json
    mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.labels).must_equal Hash.new
    bucket.labels = new_labels
    _(bucket.labels).must_equal new_labels

    mock.verify
  end

  it "updates multiple attributes in a block" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main, not_found_page: bucket_website_404
    patch_billing_gapi = Google::Apis::StorageV1::Bucket::Billing.new requester_pays: bucket_requester_pays
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(versioning: patch_versioning_gapi, logging: patch_logging_gapi, storage_class: "NEARLINE", website: patch_website_gapi, billing: patch_billing_gapi, labels: { "env" => "production" })
    returned_bucket_hash = random_bucket_hash name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: "NEARLINE", versioning: true, logging_bucket: bucket_logging_bucket, logging_prefix: bucket_logging_prefix, website_main: bucket_website_main, website_404: bucket_website_404, cors: [], requester_pays: bucket_requester_pays
    returned_bucket_hash[:labels] = { "env" => "production" }
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json returned_bucket_hash.to_json
    mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket).wont_be :versioning?
    _(bucket.logging_bucket).must_be :nil?
    _(bucket.logging_prefix).must_be :nil?
    _(bucket.website_main).must_be :nil?
    _(bucket.website_404).must_be :nil?
    _(bucket.requester_pays).must_be :nil?
    _(bucket.labels).must_equal Hash.new

    bucket.update do |b|
      b.versioning = true
      b.logging_prefix = bucket_logging_prefix
      b.logging_bucket = bucket_logging_bucket
      b.storage_class = :nearline
      b.website_main = bucket_website_main
      b.website_404 = bucket_website_404
      b.requester_pays = bucket_requester_pays
      b.labels["env"] = "production"
    end

    _(bucket.versioning?).must_equal true
    _(bucket.logging_bucket).must_equal bucket_logging_bucket
    _(bucket.logging_prefix).must_equal bucket_logging_prefix
    _(bucket.storage_class).must_equal "NEARLINE"
    _(bucket.website_main).must_equal bucket_website_main
    _(bucket.website_404).must_equal bucket_website_404
    _(bucket.requester_pays).must_equal bucket_requester_pays
    _(bucket.labels).must_equal({ "env" => "production" })

    mock.verify
  end

  describe "CORS" do

    it "sets the cors rules" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [bucket_cors_gapi]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, cors: [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})
      bucket.service.mocked_service = mock

      _(bucket.cors).must_equal []
      bucket.cors do |c|
        c.add_rule ["http://example.org", "https://example.org"],
                   "*",
                   headers: ["X-My-Custom-Header"],
                   max_age: 300
      end

      mock.verify
    end

    it "can't update cors outside of a block" do
      err = expect {
        bucket_with_cors.cors.first.max_age = 600
      }.must_raise RuntimeError
      _(err.message).must_match "can't modify frozen"
    end

    it "can update cors inside of a block" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 600, http_method: ["PUT"], origin: ["http://example.org", "https://example.org", "https://example.com"], response_header: ["X-My-Custom-Header", "X-Another-Custom-Header"]
        ),
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: [], origin: [], response_header: []
        )
      ]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, cors: [bucket_cors_hash]).to_json
      mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      _(bucket_with_cors.cors).must_be :frozen?
      _(bucket_with_cors.cors.class).must_equal Google::Cloud::Storage::Bucket::Cors
      bucket_with_cors.update do |b|
        _(b.cors).wont_be :frozen?
        _(b.cors.first.class).must_equal Google::Cloud::Storage::Bucket::Cors::Rule
        _(b.cors.first).wont_be :frozen?
        b.cors.first.max_age = 600
        b.cors.first.origin << "https://example.com"
        b.cors.first.methods = ["PUT"]
        b.cors.first.headers << "X-Another-Custom-Header"
        # Add a second rule
        b.cors << Google::Cloud::Storage::Bucket::Cors::Rule.new(nil, nil)
      end

      mock.verify
    end

    it "adds CORS rules in a nested block in update" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: ["GET"], origin: ["http://example.org"], response_header: []
        ),
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 300, http_method: ["PUT", "DELETE"], origin: ["http://example.org", "https://example.org"], response_header: ["X-My-Custom-Header"]
        ),
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: ["*"], origin: ["http://example.com"], response_header: ["X-Another-Custom-Header"]
        )
      ]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, cors: [bucket_cors_hash]).to_json
      mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      bucket_with_cors.update do |b|
        b.cors.delete_if { |c| c.max_age = 300 }
        b.cors do |c|
          c.add_rule "http://example.org", "GET"
          c.add_rule ["http://example.org", "https://example.org"],
                     ["PUT", "DELETE"],
                     headers: ["X-My-Custom-Header"],
                     max_age: 300
          c.add_rule "http://example.com",
                     "*",
                     headers: "X-Another-Custom-Header"
        end
      end

      mock.verify
    end

    it "adds CORS rules in a block to cors" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: ["GET"], origin: ["http://example.org"], response_header: []
        ),
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 300, http_method: ["PUT", "DELETE"], origin: ["http://example.org", "https://example.org"], response_header: ["X-My-Custom-Header"]
        ),
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: ["*"], origin: ["http://example.com"], response_header: ["X-Another-Custom-Header"]
        )
      ]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, cors: [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})
      bucket.service.mocked_service = mock

      returned_cors = bucket.cors do |c|
        c.add_rule "http://example.org", "GET"
        c.add_rule ["http://example.org", "https://example.org"],
                   ["PUT", "DELETE"],
                   headers: ["X-My-Custom-Header"],
                   max_age: 300
        c.add_rule "http://example.com",
                   "*",
                   headers: "X-Another-Custom-Header"
      end
      _(returned_cors.frozen?).must_equal true
      _(returned_cors.first.frozen?).must_equal true

      mock.verify
    end

    it "updates CORS rules in a block to cors" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [
        Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
          max_age_seconds: 1800, http_method: ["GET"], origin: ["http://example.net"], response_header: []
        )
      ]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, cors: [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})
      bucket.service.mocked_service = mock

      _(bucket_with_cors.cors.size).must_equal 1
      _(bucket_with_cors.cors[0].origin).must_equal ["http://example.org", "https://example.org"]
      bucket_with_cors.cors do |c|
        c.add_rule "http://example.net", "GET"
        c.add_rule "http://example.net", "POST"
        # Remove the last CORS rule from the array
        c.pop
        # Remove all existing rules with the https protocol
        c.delete_if { |r| r.origin.include? "http://example.org" }
      end

      mock.verify
    end
  end

  describe "lifecycle (Object Lifecycle Management)" do

    it "sets the lifecycle rules" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new lifecycle: bucket_lifecycle_gapi
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, lifecycle: bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})
      bucket.service.mocked_service = mock

      _(bucket.lifecycle).must_equal []
      lifecycle = bucket.lifecycle do |l|
        l.add_set_storage_class_rule "NEARLINE",
                                     age: 32,
                                     created_before: bucket_lifecycle_created_before,
                                     custom_time_before: bucket_lifecycle_custom_time_before,
                                     days_since_custom_time: 4,
                                     days_since_noncurrent_time: 14,
                                     is_live: true,
                                     matches_storage_class: ["STANDARD"],
                                     noncurrent_time_before: bucket_lifecycle_noncurrent_time_before,
                                     num_newer_versions: 3
      end

      mock.verify

      rule = lifecycle.first

      _(rule.action).must_equal "SetStorageClass"
      _(rule.storage_class).must_equal "NEARLINE"
      _(rule.age).must_equal 32
      _(rule.created_before).must_equal bucket_lifecycle_created_before
      _(rule.custom_time_before).must_equal bucket_lifecycle_custom_time_before
      _(rule.days_since_custom_time).must_equal 4
      _(rule.days_since_noncurrent_time).must_equal 14
      _(rule.is_live).must_equal true
      _(rule.matches_storage_class).must_equal ["STANDARD"]
      _(rule.noncurrent_time_before).must_equal bucket_lifecycle_noncurrent_time_before
      _(rule.num_newer_versions).must_equal 3
    end

    it "can't update lifecycle outside of a block" do
      err = expect {
        bucket_with_cors.lifecycle.first.age = 600
      }.must_raise RuntimeError
      _(err.message).must_match "can't modify frozen"
    end

    it "can update lifecycle inside of a block" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
        lifecycle: lifecycle_gapi(
          lifecycle_rule_gapi("SetStorageClass",
                              storage_class: "COLDLINE",
                              age: 32,
                              created_before: bucket_lifecycle_created_before,
                              custom_time_before: bucket_lifecycle_custom_time_before,
                              days_since_custom_time: 4,
                              days_since_noncurrent_time: 14,
                              is_live: true,
                              matches_storage_class: ["STANDARD"],
                              noncurrent_time_before: bucket_lifecycle_noncurrent_time_before,
                              num_newer_versions: 3),
          lifecycle_rule_gapi("Delete", age: 40, is_live: false)
        )
      )

      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, lifecycle: bucket_lifecycle_hash).to_json
      mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      _(bucket_with_cors.lifecycle).must_be :frozen?
      _(bucket_with_cors.lifecycle.class).must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket_with_cors.update do |b|
        _(b.lifecycle).wont_be :frozen?
        _(b.lifecycle.first.class).must_equal Google::Cloud::Storage::Bucket::Lifecycle::Rule
        _(b.lifecycle.first).wont_be :frozen?
        b.lifecycle.first.storage_class = "COLDLINE"
        # Add a second rule
        b.lifecycle.add_delete_rule age: 40, is_live: false
      end

      mock.verify
    end

    it "adds Lifecycle rules in a nested block in update" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
              lifecycle_rule_gapi("Delete", age: 40, is_live: false)
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, lifecycle: bucket_lifecycle_hash).to_json
      mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      bucket_with_cors.update do |b|
        b.lifecycle.delete_if { |r| r.age == 32 }
        b.lifecycle do |l|
          l.add_delete_rule age: 40, is_live: false
        end
      end

      mock.verify
    end

    it "adds Lifecycle rules in a block to lifecycle" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
            lifecycle_rule_gapi("SetStorageClass",
                                storage_class: "NEARLINE",
                                age: 32,
                                created_before: bucket_lifecycle_created_before,
                                custom_time_before: bucket_lifecycle_custom_time_before,
                                days_since_custom_time: 4,
                                days_since_noncurrent_time: 14,
                                is_live: true,
                                matches_storage_class: ["STANDARD"],
                                noncurrent_time_before: bucket_lifecycle_noncurrent_time_before,
                                num_newer_versions: 3),
              lifecycle_rule_gapi("Delete", age: 40, is_live: false),
              lifecycle_rule_gapi("Delete", is_live: false, num_newer_versions: 8),
              lifecycle_rule_gapi("SetStorageClass", storage_class: "COLDLINE", created_before: "2013-01-15", matches_storage_class: ["STANDARD", "NEARLINE"])
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, lifecycle: bucket_lifecycle_hash).to_json
      mock.expect :update_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **update_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      _(bucket_with_cors.lifecycle).must_be :frozen?
      _(bucket_with_cors.lifecycle.class).must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket_with_cors.update do |b|
        b.lifecycle.add_delete_rule age: 40, is_live: false
        b.lifecycle.add_delete_rule is_live: false, num_newer_versions: 8
        b.lifecycle.add_set_storage_class_rule "COLDLINE", created_before: "2013-01-15", matches_storage_class: ["STANDARD", "NEARLINE"]
      end

      mock.verify
    end

    it "updates Lifecycle rules in a block to lifecycle" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
            lifecycle_rule_gapi("SetStorageClass",
                                storage_class: "NEARLINE",
                                age: 32,
                                created_before: bucket_lifecycle_created_before,
                                custom_time_before: bucket_lifecycle_custom_time_before,
                                days_since_custom_time: 4,
                                days_since_noncurrent_time: 14,
                                is_live: true,
                                matches_storage_class: ["STANDARD"],
                                noncurrent_time_before: bucket_lifecycle_noncurrent_time_before,
                                num_newer_versions: 3),
              lifecycle_rule_gapi("Delete", age: 40, is_live: false)
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(name: bucket_name, url_root: bucket_url, location: bucket_location, storage_class: bucket_storage_class, lifecycle: bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi, [bucket_name, patch_bucket_gapi], **patch_bucket_args(options: {retries: 0})
      bucket_with_cors.service.mocked_service = mock

      _(bucket_with_cors.lifecycle).must_be :frozen?
      _(bucket_with_cors.lifecycle.class).must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket_with_cors.lifecycle do |l|
        l.add_set_storage_class_rule :coldline, created_before: "2013-01-15", matches_storage_class: [:STANDARD, :nearline]  # alias: set_storage_class
        l.add_delete_rule age: 40, is_live: false
        l.add_delete_rule is_live: false, num_newer_versions: 8

        # Remove the last Lifecycle rule from the array
        l.pop
        # Remove all existing rules that match predicate
        l.delete_if { |r| r.matches_storage_class.include? "NEARLINE" }
      end

      mock.verify
    end
  end
end
