# Copyright 2022 Google LLC
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

# [START storage_get_requester_pays_status]
def get_requester_pays_status bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  if bucket.requester_pays
    puts "Requester pays status is enabled for #{bucket_name}"
  else
    puts "Requester pays status is disabled for #{bucket_name}"
  end
end
# [END storage_get_requester_pays_status]

get_requester_pays_status bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
