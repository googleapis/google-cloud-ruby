# Copyright 2026 Google LLC
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

# [START storage_get_bucket_ip_filter]
def get_bucket_ip_filter bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  ip_filter = bucket.ip_filter

  if ip_filter
    puts "Bucket #{bucket_name} has IP filter mode: #{ip_filter.mode}."
    if ip_filter.public_network_source
      puts "Allowed public network CIDR ranges: #{ip_filter.public_network_source.allowed_ip_cidr_ranges.join(', ')}."
    end
  else
    puts "Bucket #{bucket_name} does not have an IP filter configuration."
  end
end
# [END storage_get_bucket_ip_filter]

if $PROGRAM_NAME == __FILE__
  get_bucket_ip_filter bucket_name: ARGV.shift
end
