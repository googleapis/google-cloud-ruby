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

def create_bucket_helper bucket_name, uniform_bucket_level_access: nil, hierarchical_namespace: nil
  retry_resource_exhaustion do
    storage_client.create_bucket bucket_name do |b|
      b.uniform_bucket_level_access = uniform_bucket_level_access
      b.hierarchical_namespace = hierarchical_namespace
    end
  end
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
  min_delay = 180 # 3 minutes
  max_delay = 900 # 15 minutes
  while result.response.anywhere_caches.count != 0
    puts "Cache not deleted yet, Retrying in #{min_delay} seconds."
    sleep min_delay
    min_delay = [min_delay * 2, max_delay].min # Exponential backoff with a max delay
    result = storage_control_client.list_anywhere_caches request
  end

  result.response.anywhere_caches.count
end 
