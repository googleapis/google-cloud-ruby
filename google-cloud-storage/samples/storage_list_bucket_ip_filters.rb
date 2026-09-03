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

# [START storage_list_bucket_ip_filters]
def list_bucket_ip_filters
  # The ID of your GCP project
  # project_id = "your-project-id"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  
  puts "Buckets:"
  # Use projection: "full" to ensure IP filter metadata is returned
  storage.buckets(projection: "full").all do |bucket|
    ip_filter = bucket.ip_filter
    mode = ip_filter ? ip_filter.mode : "Not Configured"
    
    puts "Bucket Name: #{bucket.name}, IP Filtering Mode: #{mode}"
  end
end
# [END storage_list_bucket_ip_filters]

if $PROGRAM_NAME == __FILE__
  list_bucket_ip_filters
end
