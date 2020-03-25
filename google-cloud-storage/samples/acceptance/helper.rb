# Copyright 2020 Google, LLC
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

require "google/cloud/errors"
require "google/cloud/kms"
require "google/cloud/storage"
require "minitest/autorun"
require "net/http"
require "securerandom"
require "uri"

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    return storage_client.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    bucket = storage_client.bucket bucket_name
    return unless bucket

    bucket.files.each(&:delete)
    bucket.delete
  end
end

def retry_resource_exhaustion
  5.times do
    begin
      yield
      return
    rescue Google::Cloud::ResourceExhaustedError => e
      puts "\n#{e} Gonna try again"
      sleep rand(3..5)
    rescue StandardError => e
      puts "\n#{e}"
      return
    end
  end
  raise Google::Cloud::ResourceExhaustedError, "Maybe take a break from creating and deleting buckets for a bit"
end

def get_kms_key project_id
  kms_client = Google::Cloud::Kms.new

  key_ring_id = "ruby_docs_test_ring_id"
  location_path = kms_client.location_path project_id, "us"
  key_ring_path = kms_client.key_ring_path project_id, "us", key_ring_id
  begin
    kms_client.get_key_ring key_ring_path
  rescue Google::Gax::RetryError
    kms_client.create_key_ring location_path, key_ring_id, {}
  end

  crypto_key_id = "ruby_docs_test_key"
  crypto_key = {
    purpose: :ENCRYPT_DECRYPT
  }
  crypto_key_path = kms_client.crypto_key_path project_id, "us", key_ring_id, crypto_key_id
  begin
    kms_client.get_crypto_key(crypto_key_path).name
  rescue Google::Gax::GaxError
    kms_client.create_crypto_key(key_ring_path, crypto_key_id, crypto_key).name
  end
end

def delete_hmac_key_helper hmac_key
  hmac_key.refresh!
  return if hmac_key.deleted?

  hmac_key.inactive! if hmac_key.active?
  hmac_key.delete!
end
