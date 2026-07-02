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

# [START storage_delete_ip_filtering_rules]
def delete_bucket_ip_filter bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  # Clear IP filter configuration by setting it to empty/disabled
  bucket.update do |b|
    b.ip_filter = {
      mode: "Disabled",
      public_network_source: {
        allowed_ip_cidr_ranges: []
      }
    }
  end

  puts "Deleted IP filter for bucket #{bucket_name}."
end
# [END storage_delete_ip_filtering_rules]

if $PROGRAM_NAME == __FILE__
  delete_bucket_ip_filter bucket_name: ARGV.shift
end
