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

def list_hmac_keys
  # [START storage_list_hmac_keys]
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_keys = storage.hmac_keys

  puts "HMAC Keys:"
  hmac_keys.all do |hmac_key|
    puts "Service Account Email: #{hmac_key.service_account_email}"
    puts "Access ID: #{hmac_key.access_id}"
  end
  # [END storage_list_hmac_keys]
end

list_hmac_keys if $PROGRAM_NAME == __FILE__
