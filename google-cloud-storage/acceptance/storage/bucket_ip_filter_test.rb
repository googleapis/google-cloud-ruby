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

require_relative "../storage_helper"
describe Google::Cloud::Storage::Bucket, :storage do
  let(:ip_filter_disabled) do
    {
      mode: "Disabled",
      public_network_source: {
        allowed_ip_cidr_ranges: ["0.0.0.0/0", "::/0"]
      }
    }
  end

  let(:ip_filter_disabled_update) do
    {
      mode: "Disabled",
      public_network_source: {
        allowed_ip_cidr_ranges: ["8.8.8.8/32"]
      },
      vpc_network_sources: [
        {
          network: "projects/#{storage.project}/global/networks/default",
          allowed_ip_cidr_ranges: ["0.0.0.0/0"]
        }
      ]
    }
  end
  let(:bucket_name) { "#{$bucket_names.first}-ip-filter" }
  let :bucket do
    storage.bucket(bucket_name, projection: "full") ||
    storage.create_bucket(bucket_name, ip_filter: ip_filter_disabled) 
  end

  after(:all) do
    safe_gcs_execute { bucket.delete }
  end

  it "returns a 400 error when provided an invalid IP CIDR range" do
    invalid_ip_filter = {
      mode: "Enabled",
      public_network_source: {
        allowed_ip_cidr_ranges: ["invalid-ip-range"]
      }
    }

    # Verify that creating a bucket with an invalid CIDR raises an error
    err = expect {
      storage.create_bucket "#{bucket_name}-invalid", ip_filter: invalid_ip_filter
    }.must_raise Google::Cloud::InvalidArgumentError

    _(err.message).must_match /invalid/i
  end

  it "creates, gets, updates, and deletes a bucket with ip_filter" do


    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    # Get the bucket and verify ip_filter
    bucket = storage.bucket bucket_name, projection: "full"
    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    # list_bucket_ip_filters
    found = false
    storage.buckets(projection: "full").all do |b|
      found = true if b.name == bucket_name
    end
    _(found).must_equal true

    # Update the ip_filter
    safe_gcs_execute do
      bucket.update do |b|
        b.ip_filter = ip_filter_disabled_update
      end
    end

    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["8.8.8.8/32"]
    _(bucket.ip_filter.vpc_network_sources.first.network).must_equal "projects/#{storage.project}/global/networks/default"
    _(bucket.ip_filter.vpc_network_sources.first.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0"]

    # Disable ip_filter and clear network sources
    safe_gcs_execute do
      bucket.ip_filter = {
        mode: "Disabled",
        public_network_source: {
          allowed_ip_cidr_ranges: []
        },
        vpc_network_sources: []
      }
    end

    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_be_nil
    _(bucket.ip_filter.vpc_network_sources).must_be_nil

  end
end
