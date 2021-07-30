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

require "google/cloud/logging"
require "google/cloud/errors"
require "google/cloud/storage"
require "minitest/autorun"
require "minitest/focus"
require "securerandom"

def get_entries_helper log_name
  entries = []
  5.times do
    entries = logging.entries filter: "logName:#{log_name}", max: 1000, order: "timestamp desc"
    return entries unless entries.empty?

    sleep 5
  end
  entries
end

def delete_log_helper log_name
  5.times do
    logging.delete_log log_name
    return
  rescue Google::Cloud::NotFoundError
    sleep 5
  end
  raise "Unable to find log: #{log_name}"
end

def logging
  Google::Cloud::Logging.new
end

def storage
  Google::Cloud::Storage.new
end

def create_bucket_helper bucket_name
  retry_resource_exhaustion do
    return storage.create_bucket bucket_name
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
    yield
    return
  rescue Google::Cloud::ResourceExhaustedError => e
    puts "\n#{e} Gonna try again"
    sleep rand(3..5)
  rescue StandardError => e
    puts "\n#{e}"
    return
  end
  raise Google::Cloud::ResourceExhaustedError, "Maybe take a break from creating and deleting buckets for a bit"
end
