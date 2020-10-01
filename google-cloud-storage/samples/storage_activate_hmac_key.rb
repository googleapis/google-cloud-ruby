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

def activate_hmac_key access_id:
  # [START storage_activate_hmac_key]
  # access_id = "ID of an inactive HMAC key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_key = storage.hmac_key access_id

  hmac_key.active!

  puts "The HMAC key is now active."
  puts "The HMAC key metadata is:"
  puts "Key ID:                #{hmac_key.id}"
  puts "Service Account Email: #{hmac_key.service_account_email}"
  puts "Access ID:             #{hmac_key.access_id}"
  puts "Project ID:            #{hmac_key.project_id}"
  puts "Active:                #{hmac_key.active?}"
  puts "Created At:            #{hmac_key.created_at}"
  puts "Updated At:            #{hmac_key.updated_at}"
  puts "Etag:                  #{hmac_key.etag}"
  # [END storage_activate_hmac_key]
end

activate_hmac_key access_id: ARGV.shift if $PROGRAM_NAME == __FILE__
