# Copyright 2024 Google LLC
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
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/storage/control"

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-storage-control-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
end

def random_folder_name prefix: "ruby-storage-control-folder-samples-test-"
  t = Time.now.utc.iso8601.gsub ":", "-"
  "#{prefix}-#{t}-#{SecureRandom.hex 4}".downcase
end

def storage_client
  @storage_client ||= Google::Cloud::Storage.new
end

def create_bucket_helper bucket_name, uniform_bucket_level_access: nil, hierarchical_namespace: nil, location: nil
  retry_resource_exhaustion do
    storage_client.create_bucket bucket_name, location: location do |b|
      b.uniform_bucket_level_access = uniform_bucket_level_access
      b.hierarchical_namespace = hierarchical_namespace
    end
  end
end

# Returns the region of a zone, e.g. "us-east1" for "us-east1-b".
def zone_region zone
  zone.sub(/-[a-z]\z/, "")
end

# Returns whether a bucket has a Rapid Cache that has not been disabled.
#
# @param bucket_name [String] The name of the Google Cloud Storage bucket.
# @param cache_id [String] The ID of the Rapid Cache, which is the same as its
#   zone.
def rapid_cache_active? bucket_name, cache_id
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  name = storage_control_client.rapid_cache_path project: "_", bucket: bucket_name, rapid_cache: cache_id
  storage_control_client.get_rapid_cache(name: name).state != "disabled"
rescue Google::Cloud::NotFoundError
  false
end

# Best-effort deletion of a bucket that had a Rapid Cache.
#
# A bucket cannot be deleted until its Rapid Cache has been fully removed,
# which can take more than 30 minutes after the cache is disabled. This method
# retries briefly and then leaves the bucket for the stale bucket cleanup job.
#
# @param bucket_name [String] The name of the Google Cloud Storage bucket.
def delete_bucket_with_rapid_cache_helper bucket_name, attempts: 6, interval: 20
  attempts.times do |attempt|
    delete_bucket_helper bucket_name
    return true
  rescue Google::Cloud::FailedPreconditionError, Google::Cloud::AlreadyExistsError => e
    puts "\nBucket #{bucket_name} not deleted yet (attempt #{attempt + 1}/#{attempts}): #{e.message}"
    sleep interval
  end
  puts "\nLeaving bucket #{bucket_name} for the stale bucket cleanup job."
  false
end

def delete_bucket_helper bucket_name
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

# Waits until all Anywhere Caches for a given bucket are deleted.
#
# This method polls the Storage Control API, listing the Anywhere Caches
# associated with the specified bucket. If caches are found, it waits and
# retries with an exponential backoff strategy until no caches remain.
#
# @param bucket_name [String] The name of the Google Cloud Storage bucket.
# @return [Integer] The final count of Anywhere Caches, which will be 0
# the method completes successfully after all caches are deleted.
def count_anywhere_caches bucket_name
  storage_control_client = Google::Cloud::Storage::Control.storage_control

  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  request = Google::Cloud::Storage::Control::V2::ListAnywhereCachesRequest.new(
    parent: parent
  )
  result = storage_control_client.list_anywhere_caches request
  min_delay = 30 # 30 seconds
  max_delay = 900 # 15 minutes
  start_time = Time.now
  while result.response.anywhere_caches.count != 0
    puts "Cache not deleted yet, Retrying in #{min_delay} seconds."
    sleep min_delay
    min_delay = [min_delay * 2, max_delay].min # Exponential backoff with a max delay
    result = storage_control_client.list_anywhere_caches request
  end
  end_time = Time.now
  duration = end_time - start_time
  puts "Total waiting time : #{duration.round 2} seconds."
  result.response.anywhere_caches.count
end
