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

def delete_hmac_key access_id:
  # [START storage_delete_hmac_key]
  # The access ID of the HMAC key
  # access_id = "GOOG0234230X00"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_key = storage.hmac_key access_id

  hmac_key.delete!

  puts "The key is deleted, though it may still appear in Client#hmac_keys results."
  # [END storage_delete_hmac_key]
end

delete_hmac_key access_id: ARGV.shift if $PROGRAM_NAME == __FILE__
