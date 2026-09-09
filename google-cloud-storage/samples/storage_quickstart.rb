# Copyright 2016 Google LLC
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

# [START storage_quickstart]
def quickstart bucket_name:
  # Imports the Google Cloud client library
  require "google/cloud/storage"

  # Instantiates a client
  storage = Google::Cloud::Storage.new

  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # Creates the new bucket
  bucket = storage.create_bucket bucket_name

  puts "Bucket #{bucket.name} was created."
end
# [END storage_quickstart]

if $PROGRAM_NAME == __FILE__
  quickstart "quickstart_bucket"
end
