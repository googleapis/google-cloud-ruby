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

# [START storage_list_object_contexts]
def list_object_contexts bucket_name:, custom_context_key:, custom_context_value: nil
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The key of the custom context to be filtered
  # custom_context_key = "your-custom-context-key"
  # The value of the custom context to be filtered
  # custom_context_value = "your-custom-context-value"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  filter_query = if custom_context_value.nil?
                   "contexts.\"#{custom_context_key}\":*"
                 else
                   "contexts.\"#{custom_context_key}\"=\"#{custom_context_value}\""
                 end

  list = bucket.files filter: filter_query
  list.each do |file|
    puts "File: #{file.name} has context key: #{custom_context_key}"
  end
end
# [END storage_list_object_contexts]

if $PROGRAM_NAME == __FILE__
  list_object_contexts bucket_name: ARGV.shift, custom_context_key: ARGV.shift, custom_context_value: ARGV.shift
end
