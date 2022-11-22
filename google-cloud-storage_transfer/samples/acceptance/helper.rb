# Copyright 2021 Google LLC
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
require "google/cloud/storage_transfer"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"

def grant_sts_permissions project_id:, bucket_name:
  client = Google::Cloud::StorageTransfer.storage_transfer_service
  request = { project_id: project_id }
  response = client.get_google_service_account request
  email = response.account_email

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  object_viewer = "roles/storage.objectViewer"
  bucket_reader = "roles/storage.legacyBucketReader"
  bucket_writer = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:#{email}"

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3
    policy.bindings.insert(
      role:      object_viewer,
      members:   member
    )
  end

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3
    policy.bindings.insert(
      role:      bucket_reader,
      members:   member
    )
  end

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3
    policy.bindings.insert(
      role:      bucket_writer,
      members:   member
    )
  end
end

def delete_transfer_job project_id:, job_name:
  client = Google::Cloud::StorageTransfer.storage_transfer_service

  transfer_job = {
    name: job_name,
    status: :DELETED
  }

  delete_request = {
    job_name: job_name,
    project_id: project_id,
    transfer_job: transfer_job
  }

  client.update_transfer_job delete_request
end

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-storagetransfer-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
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
