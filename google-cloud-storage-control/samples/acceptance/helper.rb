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

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-storage-control-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
end

def random_folder_name prefix: "ruby-storage-control-folder-samples-test-"
  t = Time.now.utc.iso8601.gsub ":", "-"
  "#{prefix}-#{t}-#{SecureRandom.hex 4}".downcase
end

def create_bucket_helper bucket_name, uniform_bucket_level_access: nil, hierarchical_namespace: nil
  storage_client = Google::Cloud::Storage.new
  retry_resource_exhaustion do
    storage_client.create_bucket bucket_name do |b|
      b.uniform_bucket_level_access = uniform_bucket_level_access
      b.hierarchical_namespace = hierarchical_namespace
    end
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
