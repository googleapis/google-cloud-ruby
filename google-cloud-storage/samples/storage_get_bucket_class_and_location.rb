# Copyright 2020 Google LLC
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

# [START storage_get_bucket_class_and_location]

def get_bucket_class_and_location bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  require "google/cloud/storage"

  # Initialize Google Cloud Storage client
  storage = Google::Cloud::Storage.new

  # Fetch bucket metadata
  bucket = storage.bucket bucket_name

  # Handle the case where the bucket is not found
  raise "Bucket not found: #{bucket_name}" if bucket.nil?

  # Output the bucket's default storage class and location
  puts "Bucket #{bucket.name} default storage class is #{bucket.storage_class}, and the location is #{bucket.location}"
end
# [END storage_get_bucket_class_and_location]

get_bucket_class_and_location bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
