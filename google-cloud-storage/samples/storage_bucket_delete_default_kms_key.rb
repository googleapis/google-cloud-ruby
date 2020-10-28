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

# [START storage_bucket_delete_default_kms_key]
def bucket_delete_default_kms_key bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.default_kms_key = nil

  puts "Default KMS key was removed from #{bucket_name}"
end
# [END storage_bucket_delete_default_kms_key]

if $PROGRAM_NAME == __FILE__
  bucket_delete_default_kms_key bucket_name: ARGV.shift
end
