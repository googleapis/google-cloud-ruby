# Copyright 2018 Google LLC
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

describe Google::Cloud::Storage::Bucket, :lock_retention_policy, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_metageneration) { 1 } # same value as in random_bucket_hash
  let(:bucket_retention_period) { 86400 }
  let(:bucket_retention_effective_at) { Time.now }
  let(:bucket_retention_policy_gapi) { Google::Apis::StorageV1::Bucket::RetentionPolicy.new(
      retention_period: bucket_retention_period,
      effective_time: bucket_retention_effective_at,
      is_locked: true) }
  let(:bucket_retention_policy_hash) { JSON.parse bucket_retention_policy_gapi.to_json }

  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:bucket_with_retention_policy_gapi) do
    g = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    g.retention_policy = bucket_retention_policy_gapi
    g.default_event_based_hold = true
    g
  end
  let(:bucket_with_retention_policy) { Google::Cloud::Storage::Bucket.from_gapi bucket_with_retention_policy_gapi, storage.service }

  it "knows its retention policy attributes" do
    bucket_with_retention_policy.retention_period.must_equal bucket_retention_period
    bucket_with_retention_policy.retention_effective_at.must_be_within_delta bucket_retention_effective_at
    bucket_with_retention_policy.retention_policy_locked?.must_equal true
    bucket_with_retention_policy.default_event_based_hold?.must_equal true
  end

  it "updates its retention_period" do
    mock = Minitest::Mock.new
    patch_retention_policy_gapi = Google::Apis::StorageV1::Bucket::RetentionPolicy.new retention_period: bucket_retention_period
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new retention_policy: patch_retention_policy_gapi
    mock.expect :patch_bucket, bucket_with_retention_policy_gapi,
                [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    bucket.service.mocked_service = mock

    bucket.retention_period.must_be :nil?

    bucket.retention_period = bucket_retention_period

    bucket.retention_period.must_equal bucket_retention_period
    bucket.retention_effective_at.must_be_within_delta bucket_retention_effective_at

    mock.verify
  end

  it "updates its default_event_based_hold" do
    mock = Minitest::Mock.new
    patch_bucket_gapi = Google::Apis::StorageV1::Bucket.new default_event_based_hold: true
    mock.expect :patch_bucket, bucket_with_retention_policy_gapi,
                [bucket_name, patch_bucket_gapi, predefined_acl: nil, predefined_default_object_acl: nil, user_project: nil]
    bucket.service.mocked_service = mock

    bucket.default_event_based_hold?.must_equal false

    bucket.default_event_based_hold = true

    bucket.default_event_based_hold?.must_equal true

    mock.verify
  end

  it "locks its retention policy" do
    mock = Minitest::Mock.new
    mock.expect :lock_bucket_retention_policy, bucket_with_retention_policy_gapi,
                [bucket_name, bucket_metageneration, user_project: nil]
    bucket.service.mocked_service = mock

    bucket.lock_retention_policy!

    mock.verify
  end

  it "locks its retention policy with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :lock_bucket_retention_policy, bucket_with_retention_policy_gapi,
                [bucket_name, bucket_metageneration, user_project: "test"]
    bucket_user_project.service.mocked_service = mock

    bucket_user_project.lock_retention_policy!

    mock.verify
  end
end