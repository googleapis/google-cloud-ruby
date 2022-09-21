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

# [START storage_set_autoclass]
def set_autoclass bucket_name:, toggle:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # Boolean toggle - if true, enables Autoclass; if false, disables Autoclass
  # toggle = False

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name
  bucket.autoclass= toggle
  unless bucket.autoclass.nil?
    puts "Autoclass enabled is set to #{bucket.autoclass.enabled} for #{bucket.name} at #{bucket.autoclass.toggle_time}."
  end
  return bucket
end
# [END storage_set_autoclass]

if $PROGRAM_NAME == __FILE__
  set_autoclass bucket_name: ARGV.shift,
                toggle: ARGV.shift
end
