# Copyright 2016 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "uri"
require "google/cloud/storage"

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

class MockStorage < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:storage) { Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new(project, credentials)) }

  # Register this spec type for when :mock_storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_storage
  end

  def random_bucket_hash(name=random_bucket_name,
    url_root="https://www.googleapis.com/storage/v1", location="US",
    storage_class="STANDARD", versioning=nil, logging_bucket=nil,
    logging_prefix=nil, website_main=nil, website_404=nil, cors=[], requester_pays=nil,
    lifecycle=nil)
    versioning_config = { "enabled" => versioning } if versioning
    { "kind" => "storage#bucket",
      "id" => name,
      "selfLink" => "#{url_root}/b/#{name}",
      "projectNumber" => "1234567890",
      "name" => name,
      "timeCreated" => Time.now,
      "metageneration" => "1",
      "owner" => { "entity" => "project-owners-1234567890" },
      "location" => location,
      "cors" => cors,
      "lifecycle" => lifecycle,
      "logging" => logging_hash(logging_bucket, logging_prefix),
      "storageClass" => storage_class,
      "versioning" => versioning_config,
      "website" => website_hash(website_main, website_404),
      "billing" => billing_hash(requester_pays),
      "etag" => "CAE=" }.delete_if { |_, v| v.nil? }
  end

  def logging_hash(bucket, prefix)
    { "logBucket"       => bucket,
      "logObjectPrefix" => prefix,
    }.delete_if { |_, v| v.nil? } if bucket || prefix
  end

  def website_hash(website_main, website_404)
    { "mainPageSuffix" => website_main,
      "notFoundPage"   => website_404,
    }.delete_if { |_, v| v.nil? } if website_main || website_404
  end

  def billing_hash(requester_pays)
    { "requesterPays" => requester_pays} unless requester_pays.nil?
  end

  def random_file_hash bucket=random_bucket_name, name=random_file_path, generation="1234567890", kms_key_name="path/to/encryption_key_name"
    { "kind" => "storage#object",
      "id" => "#{bucket}/#{name}/1234567890",
      "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
      "name" => "#{name}",
      "timeCreated" => Time.now,
      "bucket" => "#{bucket}",
      "generation" => generation,
      "metageneration" => "1",
      "cacheControl" => "public, max-age=3600",
      "contentDisposition" => "attachment; filename=filename.ext",
      "contentEncoding" => "gzip",
      "contentLanguage" => "en",
      "contentType" => "text/plain",
      "updated" => Time.now,
      "storageClass" => "STANDARD",
      "size" => rand(10_000),
      "md5Hash" => "HXB937GQDFxDFqUGi//weQ==",
      "mediaLink" => "https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
      "metadata" => { "player" => "Alice", "score" => "101" },
      "owner" => { "entity" => "user-1234567890", "entityId" => "abc123" },
      "crc32c" => "Lm1F3g==",
      "etag" => "CKih16GjycICEAE=",
      "kmsKeyName" => kms_key_name,
      "temporaryHold" => true,
      "eventBasedHold" => true,
      "retentionExpirationTime" => Time.now }
  end

  def random_bucket_name
    (0...50).map { ("a".."z").to_a[rand(26)] }.join
  end

  def random_file_path
    [(0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join + ".txt"].join "/"
  end

  def done_rewrite gapi
    Google::Apis::StorageV1::RewriteResponse.new done: true, resource: gapi
  end

  def undone_rewrite token
    Google::Apis::StorageV1::RewriteResponse.new done: false, rewrite_token: token
  end

  def random_notification_gapi id: "1", topic: "//pubsub.googleapis.com/projects/test/topics/my-topic", payload: "NONE"
    gapi = Google::Apis::StorageV1::Notification.new(
      custom_attributes: { "foo" => "bar" },
      event_types: ["OBJECT_FINALIZE"],
      object_name_prefix: "my-prefix",
      payload_format: payload,
      topic: topic
    )
    gapi.id = id if id
    gapi
  end

  # Stub for the `http_res` that is returned in the Apis::Core::DownloadCommand monkey-patch in Service.
  def download_http_resp gzip: nil
    headers = {}
    headers["Content-Encoding"] = ["gzip"] if gzip
    OpenStruct.new(header: headers)
  end

  def encryption_gapi key_name
    Google::Apis::StorageV1::Bucket::Encryption.new default_kms_key_name: key_name
  end

  def lifecycle_gapi *rules
    Google::Apis::StorageV1::Bucket::Lifecycle.new rule: Array(rules)
  end

  def lifecycle_rule_gapi action, storage_class: nil, age: nil,
                     created_before: nil, is_live: nil,
                     matches_storage_class: nil, num_newer_versions: nil
    Google::Apis::StorageV1::Bucket::Lifecycle::Rule.new(
      action: Google::Apis::StorageV1::Bucket::Lifecycle::Rule::Action.new(
        storage_class: storage_class,
        type: action
      ),
      condition: Google::Apis::StorageV1::Bucket::Lifecycle::Rule::Condition.new(
        age: age,
        created_before: created_before,
        is_live: is_live,
        matches_storage_class: Array(matches_storage_class),
        num_newer_versions: num_newer_versions
      )
    )
  end
end
