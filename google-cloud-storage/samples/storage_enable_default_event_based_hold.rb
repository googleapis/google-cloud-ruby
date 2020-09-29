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

def enable_default_event_based_hold bucket_name:
  # [START storage_enable_default_event_based_hold]
  # bucket_name = "Name of your Google Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.update do |b|
    b.default_event_based_hold = true
  end

  puts "Default event-based hold was enabled for #{bucket_name}."
  # [END storage_enable_default_event_based_hold]
end

enable_default_event_based_hold bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
