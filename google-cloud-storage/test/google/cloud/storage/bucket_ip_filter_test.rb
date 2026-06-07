# Copyright 2026 Google LLC
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

describe Google::Cloud::Storage::Bucket, :ip_filter, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:ip_filter_hash) do
    {
      "mode" => "Disabled",
      "publicNetworkSource" => {
        "allowedIpCidrRanges" => ["0.0.0.0/0", "::/0"]
      }
    }
  end
  let(:ip_filter_gapi) { Google::Apis::StorageV1::Bucket::IpFilter.from_json ip_filter_hash.to_json }

  it "knows its ip_filter value" do
    _(bucket.ip_filter).must_be_nil

    bucket_gapi.ip_filter = ip_filter_gapi
    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]
  end


  it "updates its ip_filter" do
    mock = Minitest::Mock.new
    mock.expect :update_bucket, resp_bucket_gapi(bucket_hash, ip_filter: ip_filter_gapi),
                [bucket_name, patch_bucket_gapi(ip_filter: ip_filter_gapi)], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    _(bucket.ip_filter).must_be_nil

    bucket.update do |b|
      b.ip_filter = ip_filter_gapi
    end

    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    mock.verify
  end

  it "enables its ip_filter" do
    enable_ip_filter_hash = {
      "mode" => "Enabled",
      "allowAllServiceAgentAccess" => true,
      "publicNetworkSource" => {
        "allowedIpCidrRanges" => ["0.0.0.0/0", "::/0"]
      }
    }
    enable_ip_filter_gapi = Google::Apis::StorageV1::Bucket::IpFilter.from_json enable_ip_filter_hash.to_json

    mock = Minitest::Mock.new
    mock.expect :update_bucket, resp_bucket_gapi(bucket_hash, ip_filter: enable_ip_filter_gapi),
                [bucket_name, patch_bucket_gapi(ip_filter: enable_ip_filter_gapi)], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.update do |b|
      b.ip_filter = {
        mode: "Enabled",
        allow_all_service_agent_access: true,
        public_network_source: {
          allowed_ip_cidr_ranges: ["0.0.0.0/0", "::/0"]
        }
      }
    end

    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Enabled"
    _(bucket.ip_filter.allow_all_service_agent_access).must_equal true
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    mock.verify
  end

  it "deletes its ip_filter" do
    delete_ip_filter_hash = {
      "mode" => "Disabled",
      "publicNetworkSource" => {
        "allowedIpCidrRanges" => []
      }
    }
    delete_ip_filter_gapi = Google::Apis::StorageV1::Bucket::IpFilter.from_json delete_ip_filter_hash.to_json

    mock = Minitest::Mock.new
    mock.expect :update_bucket, resp_bucket_gapi(bucket_hash, ip_filter: delete_ip_filter_gapi),
                [bucket_name, patch_bucket_gapi(ip_filter: delete_ip_filter_gapi)], **update_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.update do |b|
      b.ip_filter = {
        mode: "Disabled",
        public_network_source: {
          allowed_ip_cidr_ranges: []
        }
      }
    end

    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_be_empty

    mock.verify
  end

  it "clears its ip_filter with nil" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, ip_filter: Google::Apis::StorageV1::Bucket::IpFilter.new),
                [bucket_name, patch_bucket_gapi(ip_filter: Google::Apis::StorageV1::Bucket::IpFilter.new)], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.ip_filter = nil

    mock.verify
  end

  def patch_bucket_gapi ip_filter: nil
    Google::Apis::StorageV1::Bucket.new(
      ip_filter: ip_filter
    )
  end

  def resp_bucket_gapi bucket_hash, ip_filter: nil
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.ip_filter = ip_filter
    b
  end
end
