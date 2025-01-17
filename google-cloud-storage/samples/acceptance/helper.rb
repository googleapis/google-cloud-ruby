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

require "google/cloud/errors"
require "google/cloud/kms"
require "google/cloud/storage"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "net/http"
require "time"
require "securerandom"
require "uri"


def fixture_bucket
  storage_client = Google::Cloud::Storage.new
  storage_client.bucket($fixture_bucket_name) ||
    retry_resource_exhaustion { storage_client.create_bucket $fixture_bucket_name }
end

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new
  retry_resource_exhaustion do
    storage_client.create_bucket bucket_name
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
    return yield
  rescue Google::Cloud::ResourceExhaustedError => e
    puts "\n#{e} Gonna try again"
    sleep rand(10..16)
  rescue StandardError => e
    puts "\n#{e}"
    raise e
  end
  raise Google::Cloud::ResourceExhaustedError, "Maybe take a break from creating and deleting buckets for a bit"
end

def get_kms_key project_id
  kms_client = Google::Cloud::Kms.key_management_service

  key_ring_id = "ruby_docs_test_ring_id"
  location_path = kms_client.location_path project: project_id, location: "us"
  key_ring_path = kms_client.key_ring_path project: project_id, location: "us", key_ring: key_ring_id
  begin
    kms_client.get_key_ring name: key_ring_path
  rescue Google::Cloud::NotFoundError
    kms_client.create_key_ring parent: location_path, key_ring_id: key_ring_id, key_ring: {}
  end

  crypto_key_id = "ruby_docs_test_key"
  crypto_key = {
    purpose: :ENCRYPT_DECRYPT
  }
  crypto_key_path = kms_client.crypto_key_path project:    project_id,
                                               location:   "us",
                                               key_ring:   key_ring_id,
                                               crypto_key: crypto_key_id
  begin
    kms_client.get_crypto_key(name: crypto_key_path).name
  rescue Google::Cloud::NotFoundError
    kms_client.create_crypto_key(parent: key_ring_path, crypto_key_id: crypto_key_id, crypto_key: crypto_key).name
  end
end

def delete_hmac_key_helper hmac_key
  hmac_key.refresh!
  return if hmac_key.deleted?

  hmac_key.inactive! if hmac_key.active?
  hmac_key.delete!
end

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-storage-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
end

def random_topic_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-storage-samples-test-topic-#{t}-#{SecureRandom.hex 4}".downcase
end

# Create fixture bucket to be shared with all the tests
$fixture_bucket_name = random_bucket_name

def clean_up_fixture_bucket
  storage_client = Google::Cloud::Storage.new
  if (b = storage_client.bucket $fixture_bucket_name)
    puts "Deleting fixture bucket #{$fixture_bucket_name} for #{storage_client.project_id}"
    b.files(versions: true).all do |file|
      file.delete generation: true
    end
    # Add one second delay between bucket deletes to avoid rate limiting errors
    sleep 1
    retry_resource_exhaustion { b.delete }
  end
rescue StandardError => e
  puts "Error while deleting bucket #{$fixture_bucket_name}\n\n#{e}"
  raise e
end

Minitest.after_run do
  clean_up_fixture_bucket
end
