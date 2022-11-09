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

require "minitest/autorun"
require "minitest/focus"
require "securerandom"

require "google/cloud/datastore/admin/v1"
require "google/cloud/storage"
    

def storage_bucket_name
  ENV["GOOGLE_CLOUD_STORAGE_BUCKET"] || "ruby-samples-test"
end

def create_bucket
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket storage_bucket_name
  storage.create_bucket storage_bucket_name if bucket.nil? 
end

def random_storage_file_prefix
  "datastore-admin-v1-#{SecureRandom.hex 4}"
end

# Returns URL to sample image in the fixtures storage bucket
def storage_url prefix: "datastore-admin-v1"
  "gs://#{storage_bucket_name}/#{prefix}"
end
