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

# [START storage_set_bucket_public_iam]
def set_bucket_public_iam bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy do |p|
    p.add "roles/storage.objectViewer", "allUsers"
  end

  puts "Bucket #{bucket_name} is now publicly readable"
end
# [END storage_set_bucket_public_iam]

if $PROGRAM_NAME == __FILE__
  set_bucket_public_iam bucket_name: ARGV.shift
end
