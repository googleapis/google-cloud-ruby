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
require "google/cloud/storage"

##
# This is a snippet for showcasing how to set the autoclass
# configuration of a bucket.
#
# Note: Only patch requests that disable autoclass are currently supported.
# To enable autoclass, you must set it at bucket creation time.
#
# @param bucket_name [String] The ID of your GCS bucket (e.g. "your-unique-bucket-name")
# @param toggle [Boolean] if true, enables Autoclass; if false, disables Autoclass
#
def set_autoclass bucket_name:, toggle:
  # Initialize client
  storage = Google::Cloud::Storage.new

  # Fetch the GCS bucket
  bucket = storage.bucket bucket_name

  # Update the autoclass configuration
  bucket.autoclass_enabled = toggle

  # Get autoclass config of the bucket
  puts "Bucket #{bucket.name} has autoclass config set to #{bucket.autoclass_enabled}."
  puts "Bucket #{bucket.name} has autoclass toggle time set to #{bucket.autoclass_toggle_time}."
end

# [END storage_set_autoclass]

if $PROGRAM_NAME == __FILE__
  set_autoclass bucket_name: ARGV.shift,
                toggle: ARGV.shift
end
