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
require 'pry'
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
      }
    }
  end

  let(:bucket_name) { "#{$bucket_names.first}-ip-filter" }

  it "creates, gets, updates, and deletes a bucket with ip_filter" do
    # Create a bucket with ip_filter
    puts "*************************Bucket Name**************************"
    puts bucket_name
    puts "*************************Bucket Name**************************"

    bucket = storage.bucket(bucket_name) ||
      safe_gcs_execute {storage.create_bucket bucket_name, ip_filter: ip_filter_disabled}

    # _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    # Get the bucket and verify ip_filter
    bucket = storage.bucket bucket_name
    _(bucket.ip_filter).wont_be_nil
    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["0.0.0.0/0", "::/0"]

    # Update the ip_filter
    safe_gcs_execute do
      bucket.update do |b|
        b.ip_filter = ip_filter_disabled_update
      end
    end

    _(bucket.ip_filter.mode).must_equal "Disabled"
    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_equal ["8.8.8.8/32"]

    # Disable ip_filter
    safe_gcs_execute do
      bucket.ip_filter = {
        mode: "Disabled",
        public_network_source: {
          allowed_ip_cidr_ranges: []
        }
      }
    end

    _(bucket.ip_filter.public_network_source.allowed_ip_cidr_ranges).must_be_nil

    safe_gcs_execute { bucket.delete }
    _(storage.bucket(bucket_name)).must_be :nil?

  end
end
