# Copyright 2021 Google, Inc
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

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "google/cloud/video/transcoder"
require "google/cloud/errors"
require "google/cloud/storage"

require "time"
require "securerandom"

def storage
  Google::Cloud::Storage.new
end

def storage_bucket_name
  ENV["GOOGLE_CLOUD_STORAGE_BUCKET"] || "ruby-samples-test"
end

def create_bucket_helper bucket_name
  retry_resource_exhaustion do
    storage.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  retry_resource_exhaustion do
    bucket = storage.bucket bucket_name
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

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-transcoder-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
end
