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

# [START storage_delete_object_contexts]
def delete_object_contexts bucket_name:, file_name:, custom_context_key:, custom_context_value: nil
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

  # If value is nil, the payload itself is nil, which triggers a deletion for that key.
  payload = if custom_context_value
              Google::Apis::StorageV1::ObjectCustomContextPayload.new.tap do |p|
                p.value = custom_context_value
              end
            end
  custom_hash = {
    custom_context_key => payload
  }
  contexts = Google::Apis::StorageV1::Object::Contexts.new(
    custom: custom_hash
  )
  file.update do |file|
    file.contexts = contexts
  end

  puts "Contexts for #{file_name} has been deleted."
end
# [END storage_delete_object_contexts]

if $PROGRAM_NAME == __FILE__
  delete_object_contexts bucket_name: ARGV.shift, file_name: ARGV.shift,
                         custom_context_key: ARGV.shift, custom_context_value: ARGV.shift
end
