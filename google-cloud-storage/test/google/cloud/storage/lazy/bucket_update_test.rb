# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Bucket, :update, :lazy, :mock_storage do
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
  let(:bucket_cors_gapi) { Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
    max_age_seconds: 300,
    origin: ["http://example.org", "https://example.org"],
    http_method: ["*"],
    response_header: ["X-My-Custom-Header"]) }
  let(:bucket_cors_hash) { JSON.parse bucket_cors_gapi.to_json }
  let(:bucket_lifecycle_gapi) { lifecycle_gapi lifecycle_rule_gapi("SetStorageClass", storage_class: "NEARLINE", age: 32) }
  let(:bucket_lifecycle_hash) { JSON.parse bucket_lifecycle_gapi.to_json }

  let(:bucket) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service }

  it "updates its versioning" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, true).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.wont_be :versioning?
    bucket.versioning = true
    bucket.must_be :versioning?

    mock.verify
  end

  it "updates its versioning with user_project set to true" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new versioning: patch_versioning_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, true).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: "test"]

    bucket.service.mocked_service = mock
    bucket.user_project = true

    bucket.wont_be :versioning?
    bucket.versioning = true
    bucket.must_be :versioning?

    mock.verify
  end

  it "updates its logging bucket" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, bucket_logging_bucket).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.logging_bucket.must_be :nil?
    bucket.logging_bucket = bucket_logging_bucket
    bucket.logging_bucket.must_equal bucket_logging_bucket

    mock.verify
  end

  it "updates its logging prefix" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_object_prefix: bucket_logging_prefix
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, bucket_logging_prefix).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.logging_prefix.must_be :nil?
    bucket.logging_prefix = bucket_logging_prefix
    bucket.logging_prefix.must_equal bucket_logging_prefix

    mock.verify
  end

  it "updates its logging bucket and prefix" do
    mock = Minitest::Mock.new
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new logging: patch_logging_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, bucket_logging_bucket, bucket_logging_prefix).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi.class, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.logging_bucket.must_be :nil?
    bucket.logging_prefix.must_be :nil?

    bucket.update do |b|
      b.logging_bucket = bucket_logging_bucket
      b.logging_prefix = bucket_logging_prefix
    end

    bucket.logging_bucket.must_equal bucket_logging_bucket
    bucket.logging_prefix.must_equal bucket_logging_prefix

    mock.verify
  end

  it "updates its storage class" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new storage_class: "NEARLINE"
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, "NEARLINE", nil, nil, bucket_logging_prefix).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.storage_class.must_be :nil?
    bucket.storage_class = :nearline
    bucket.storage_class.must_equal "NEARLINE"

    mock.verify
  end

  it "updates its website main page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, bucket_website_main).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.website_main.must_be :nil?
    bucket.website_main = bucket_website_main
    bucket.website_main.must_equal bucket_website_main

    mock.verify
  end

  it "updates its website not found 404 page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new not_found_page: bucket_website_404
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, bucket_website_404).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.website_404.must_be :nil?
    bucket.website_404 = bucket_website_404
    bucket.website_404.must_equal bucket_website_404

    mock.verify
  end

  it "updates its website main page and not found 404 page" do
    mock = Minitest::Mock.new
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main, not_found_page: bucket_website_404
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new website: patch_website_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, bucket_website_main, bucket_website_404).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.website_main.must_be :nil?
    bucket.website_404.must_be :nil?

    bucket.update do |b|
      b.website_main = bucket_website_main
      b.website_404 = bucket_website_404
    end

    bucket.website_main.must_equal bucket_website_main
    bucket.website_404.must_equal bucket_website_404

    mock.verify
  end

  it "updates its requester pays" do
    mock = Minitest::Mock.new
    patch_billing_gapi = Google::Apis::StorageV1::Bucket::Billing.new requester_pays: bucket_requester_pays
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new billing: patch_billing_gapi
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
      random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, [], bucket_requester_pays).to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.requester_pays.must_be :nil?
    bucket.requester_pays = bucket_requester_pays
    bucket.requester_pays.must_equal bucket_requester_pays

    mock.verify
  end

  it "cannot modify its labels" do
    bucket.labels.must_equal Hash.new
    assert_raises do
      bucket.labels["foo"] = "bar"
    end
  end

  it "updates its labels" do
    mock = Minitest::Mock.new
    new_labels = { "env" => "production", "foo" => "bar" }
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new labels: new_labels
    returned_bucket_hash = random_bucket_hash bucket_name, bucket_url, bucket_location, bucket_storage_class
    returned_bucket_hash[:labels] = new_labels
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json returned_bucket_hash.to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.labels.must_equal Hash.new
    bucket.labels = new_labels
    bucket.labels.must_equal new_labels

    mock.verify
  end

  it "updates multiple attributes in a block" do
    mock = Minitest::Mock.new
    patch_versioning_gapi = Google::Apis::StorageV1::Bucket::Versioning.new enabled: true
    patch_logging_gapi = Google::Apis::StorageV1::Bucket::Logging.new log_bucket: bucket_logging_bucket, log_object_prefix: bucket_logging_prefix
    patch_website_gapi = Google::Apis::StorageV1::Bucket::Website.new main_page_suffix: bucket_website_main, not_found_page: bucket_website_404
    patch_billing_gapi = Google::Apis::StorageV1::Bucket::Billing.new requester_pays: bucket_requester_pays
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(versioning: patch_versioning_gapi, logging: patch_logging_gapi, storage_class: "NEARLINE", website: patch_website_gapi, billing: patch_billing_gapi, labels: { "env" => "production" })
    returned_bucket_hash = random_bucket_hash bucket_name, bucket_url, bucket_location, "NEARLINE", true, bucket_logging_bucket, bucket_logging_prefix, bucket_website_main, bucket_website_404, [], bucket_requester_pays
    returned_bucket_hash[:labels] = { "env" => "production" }
    returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json returned_bucket_hash.to_json
    mock.expect :patch_bucket, returned_bucket_gapi,
      [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.wont_be :versioning?
    bucket.logging_bucket.must_be :nil?
    bucket.logging_prefix.must_be :nil?
    bucket.website_main.must_be :nil?
    bucket.website_404.must_be :nil?
    bucket.requester_pays.must_be :nil?
    bucket.labels.must_equal Hash.new

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

    bucket.versioning?.must_equal true
    bucket.logging_bucket.must_equal bucket_logging_bucket
    bucket.logging_prefix.must_equal bucket_logging_prefix
    bucket.storage_class.must_equal "NEARLINE"
    bucket.website_main.must_equal bucket_website_main
    bucket.website_404.must_equal bucket_website_404
    bucket.requester_pays.must_equal bucket_requester_pays
    bucket.labels.must_equal({ "env" => "production" })

    mock.verify
  end

  describe "CORS" do

    it "sets the cors rules" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new cors_configurations: [bucket_cors_gapi]
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
        [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.cors.must_equal []
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
        bucket.cors.add_rule ["http://example.org", "https://example.org"],
                              "*",
                              headers: ["X-My-Custom-Header"],
                              max_age: 300
      }.must_raise RuntimeError
      err.message.must_match "can't modify frozen"
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
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
        [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.cors.must_be :frozen?
      bucket.cors.class.must_equal Google::Cloud::Storage::Bucket::Cors
      bucket.update do |b|
        b.cors.wont_be :frozen?
        b.cors.must_be :empty?
        b.cors.add_rule ["http://example.org", "https://example.org", "https://example.com"],
                         "PUT",
                         headers: ["X-My-Custom-Header", "X-Another-Custom-Header"],
                         max_age: 600
        # Add a rule
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
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
        [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.update do |b|
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
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, [bucket_cors_hash]).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
        [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
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
      returned_cors.frozen?.must_equal true
      returned_cors.first.frozen?.must_equal true

      mock.verify
    end
  end

  describe "lifecycle (Object Lifecycle Management)" do

    it "sets the lifecycle rules" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
              lifecycle_rule_gapi("SetStorageClass", storage_class: "NEARLINE", age: 32)
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, nil, nil, bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.lifecycle.must_equal []
      bucket.lifecycle do |l|
        l.add_set_storage_class_rule "NEARLINE", age: 32
      end

      mock.verify
    end

    it "can't update lifecycle outside of a block" do
      err = expect {
        bucket.lifecycle.add_set_storage_class_rule "NEARLINE", age: 32
      }.must_raise RuntimeError
      err.message.must_match "can't modify frozen"
    end

    it "can update lifecycle inside of a block" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
              lifecycle_rule_gapi("Delete", age: 40, is_live: false)
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, nil, nil, bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.lifecycle.must_be :frozen?
      bucket.lifecycle.class.must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket.update do |b|
        b.lifecycle.wont_be :frozen?
        b.lifecycle.must_be :empty?
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
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, nil, nil, bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.update do |b|
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
              lifecycle_rule_gapi("Delete", age: 40, is_live: false),
              lifecycle_rule_gapi("Delete", is_live: false, num_newer_versions: 8),
              lifecycle_rule_gapi("SetStorageClass", storage_class: "COLDLINE", created_before: "2013-01-15", matches_storage_class: ["MULTI_REGIONAL", "REGIONAL"])
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, nil, nil, bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.lifecycle.must_be :frozen?
      bucket.lifecycle.class.must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket.update do |b|
        b.lifecycle.add_delete_rule age: 40, is_live: false
        b.lifecycle.add_delete_rule is_live: false, num_newer_versions: 8
        b.lifecycle.add_set_storage_class_rule "COLDLINE", created_before: "2013-01-15", matches_storage_class: ["MULTI_REGIONAL", "REGIONAL"]
      end

      mock.verify
    end

    it "updates Lifecycle rules in a block to lifecycle" do
      mock = Minitest::Mock.new
      patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new(
          lifecycle: lifecycle_gapi(
              lifecycle_rule_gapi("Delete", age: 40, is_live: false)
          )
      )
      returned_bucket_gapi = Google::Apis::StorageV1::Bucket.from_json \
        random_bucket_hash(bucket_name, bucket_url, bucket_location, bucket_storage_class, nil, nil, nil, nil, nil, nil, nil, bucket_lifecycle_hash).to_json
      mock.expect :patch_bucket, returned_bucket_gapi,
                  [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
      bucket.service.mocked_service = mock

      bucket.lifecycle.must_be :frozen?
      bucket.lifecycle.class.must_equal Google::Cloud::Storage::Bucket::Lifecycle
      bucket.lifecycle do |l|
        l.add_set_storage_class_rule "COLDLINE", created_before: "2013-01-15", matches_storage_class: ["MULTI_REGIONAL", "REGIONAL"]
        l.add_delete_rule age: 40, is_live: false
        l.add_delete_rule is_live: false, num_newer_versions: 8

        # Remove the last Lifecycle rule from the array
        l.pop
        # Remove all existing rules that match predicate
        l.delete_if { |r| r.matches_storage_class.include? "MULTI_REGIONAL" }
      end

      mock.verify
    end
  end
end
