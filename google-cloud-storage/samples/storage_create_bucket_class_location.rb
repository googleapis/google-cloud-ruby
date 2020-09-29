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

def create_bucket_class_location bucket_name:, location:, storage_class:
  # [START storage_create_bucket_class_location]
  # bucket_name   = "Name of Google Cloud Storage bucket to create"
  # location      = "Location of where to create Cloud Storage bucket"
  # storage_class = "Storage class of Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.create_bucket bucket_name,
                                  location:      location,
                                  storage_class: storage_class

  puts "Created bucket #{bucket.name} in #{location} with #{storage_class} class"
  # [END storage_create_bucket_class_location]
end

if $PROGRAM_NAME == __FILE__
  create_bucket_class_location bucket_name: ARGV.shift, location: ARGV.shift, storage_class: ARGV.shift
end
