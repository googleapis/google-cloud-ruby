# Copyright 2025 Google LLC
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
require "google/cloud/storage"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "net/http"
require "time"
require "securerandom"

def create_bucket_helper bucket_name
  retry_resource_exhaustion do
    storage_client.create_bucket bucket_name
  end
end

def storage_client
  @storage_client ||= Google::Cloud::Storage.new
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
  attempts = 5
  start_time = Time.now
  last_error = nil

  attempts.times do |i|
    begin
      return yield
    rescue Google::Cloud::ResourceExhaustedError => e
      last_error = e
      puts "\nAttempt #{i + 1} failed with #{e.class}. Retrying..."
      sleep rand(10..16)
    rescue StandardError => e
      raise e
    end
  end

  elapsed_time = Time.now - start_time
  raise last_error, "Failed after #{attempts} attempts in #{elapsed_time.round 2} seconds. Last error: #{last_error.message}", last_error.backtrace
end

def random_bucket_name
  t = Time.now.utc.iso8601.gsub ":", "-"
  "ruby-sbo-samples-test-#{t}-#{SecureRandom.hex 4}".downcase
end
