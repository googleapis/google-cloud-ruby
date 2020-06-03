# Copyright 2019 Google LLC
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

def create_hmac_key service_account_email:
  # [START storage_create_hmac_key]
  # service_account_email = "Service account used to associate generate HMAC key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#create_hmac_key uses the Storage client project_id
  hmac_key = storage.create_hmac_key service_account_email

  puts "The base64 encoded secret is: #{hmac_key.secret}"
  puts "Do not miss that secret, there is no API to recover it."
  puts "\nThe HMAC key metadata is:"
  puts "Key ID:                #{hmac_key.id}"
  puts "Service Account Email: #{hmac_key.service_account_email}"
  puts "Access ID:             #{hmac_key.access_id}"
  puts "Project ID:            #{hmac_key.project_id}"
  puts "Active:                #{hmac_key.active?}"
  puts "Created At:            #{hmac_key.created_at}"
  puts "Updated At:            #{hmac_key.updated_at}"
  puts "Etag:                  #{hmac_key.etag}"
  # [END storage_create_hmac_key]
end

def get_hmac_key access_id:
  # [START storage_get_hmac_key]
  # access_id = "ID of an HMAC key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_key = storage.hmac_key access_id

  puts "The HMAC key metadata is:"
  puts "Key ID:                #{hmac_key.id}"
  puts "Service Account Email: #{hmac_key.service_account_email}"
  puts "Access ID:             #{hmac_key.access_id}"
  puts "Project ID:            #{hmac_key.project_id}"
  puts "Active:                #{hmac_key.active?}"
  puts "Created At:            #{hmac_key.created_at}"
  puts "Updated At:            #{hmac_key.updated_at}"
  puts "Etag:                  #{hmac_key.etag}"
  # [END storage_get_hmac_key]
end

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

def deactivate_hmac_key access_id:
  # [START storage_deactivate_hmac_key]
  # access_id = "ID of an inactive HMAC key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_key = storage.hmac_key access_id

  hmac_key.inactive!

  puts "The HMAC key is now inactive."
  puts "The HMAC key metadata is:"
  puts "Key ID:                #{hmac_key.id}"
  puts "Service Account Email: #{hmac_key.service_account_email}"
  puts "Access ID:             #{hmac_key.access_id}"
  puts "Project ID:            #{hmac_key.project_id}"
  puts "Active:                #{hmac_key.active?}"
  puts "Created At:            #{hmac_key.created_at}"
  puts "Updated At:            #{hmac_key.updated_at}"
  puts "Etag:                  #{hmac_key.etag}"
  # [END storage_deactivate_hmac_key]
end

def delete_hmac_key access_id:
  # [START storage_delete_hmac_key]
  # access_id = "ID of an inactive HMAC key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  # By default Storage#hmac_keys uses the Storage client project_id
  hmac_key = storage.hmac_key access_id

  hmac_key.delete!

  puts "The key is deleted, though it may still appear in Client#hmac_keys results."
  # [END storage_delete_hmac_key]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "list_hmac_keys"
    list_hmac_keys
  when "create_hmac_key"
    create_hmac_key service_account_email: ARGV.shift
  when "get_hmac_key"
    get_hmac_key access_id: ARGV.shift
  when "activate_hmac_key"
    activate_hmac_key access_id: ARGV.shift
  when "deactivate_hmac_key"
    deactivate_hmac_key access_id: ARGV.shift
  when "delete_hmac_key"
    delete_hmac_key access_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby hmac.rb [command] [arguments]

      Commands:
        list_hmac_keys                               List all HMAC keys for a project
        create_hmac_key     <serviceAccountEmail>    Create HMAC Key
        get_hmac_key        <accessId>               Get HMAC Key metadata
        activate_hmac_key   <accessId>               Activate an HMAC Key
        deactivate_hmac_key <accessId>               Deactivate an HMAC Key
        delete_hmac_key     <accessId>               Delete a deactivated HMAC key

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
