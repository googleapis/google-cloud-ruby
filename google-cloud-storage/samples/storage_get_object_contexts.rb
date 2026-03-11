# Copyright 2026 Google LLC
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

require "google/cloud/storage"

# [START storage_get_object_contexts]
def get_object_contexts bucket_name:, file_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The key and value of the custom context to be added
  # custom_context_key = "your-custom-context-key"
  # custom_context_value = "your-custom-context-value"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  contexts = file.contexts
  custom_context_key = contexts.custom.keys.first
  custom_context_value = contexts.custom[custom_context_key].value
  puts "Custom Contexts for #{file_name} are: #{custom_context_key} with value: #{custom_context_value}"
end
# [END storage_get_object_contexts]

if $PROGRAM_NAME == __FILE__
  get_object_contexts bucket_name: ARGV.shift, file_name: ARGV.shift
end

