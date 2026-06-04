# Copyright 2024 Google LLC
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

# [START storage_create_bucket_with_ip_filter]
def create_bucket_with_ip_filter bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  ip_filter = {
  mode: "Disabled",
  public_network_source: {
    allowed_ip_cidr_ranges: [
      "0.0.0.0/0", "::/0"
    ]
    }
  }

  bucket = storage.create_bucket bucket_name do |b|
    b.ip_filter = ip_filter
    b.uniform_bucket_level_access = true
  end
  puts "Created bucket #{bucket_name} with IP filter enabled."
end

def removes_bucket_ip_filter bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  ip_filter = Google::Apis::StorageV1::Bucket::IpFilter.new(
    mode: "Disabled"
  )
  bucket.update do |b|
    b.ip_filter = ip_filter
  end

  puts "Updated IP filter for bucket #{bucket_name}."
end

def update_bucket_with_ip_filter bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  storage = Google::Cloud::Storage.new
    bucket = storage.bucket bucket_name

  ip_filter = {
    mode: "Disabled",
    public_network_source: {
      allowed_ip_cidr_ranges: [
        "0.0.0.4/0", "::/0"
      ]
    }
  }
  bucket.update do |b|
    b.ip_filter = ip_filter
  end
  puts "Updated bucket #{bucket_name} with IP filter enabled."
end
# [END storage_create_bucket_with_ip_filter]

if $PROGRAM_NAME == __FILE__
  create_bucket_with_ip_filter bucket_name: ARGV.shift
end
