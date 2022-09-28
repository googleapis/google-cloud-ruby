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

require "google/cloud/bigquery"
require "google/cloud/errors"
require "google/cloud/storage"
require "minitest/autorun"
require "securerandom"

RESOURCE_EXHAUSTION_FAILURE_MESSAGE = "Maybe take a break from creating and deleting buckets for a bit".freeze

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_action Google::Cloud::ResourceExhaustedError, RESOURCE_EXHAUSTION_FAILURE_MESSAGE do
    return storage_client.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_action Google::Cloud::ResourceExhaustedError, RESOURCE_EXHAUSTION_FAILURE_MESSAGE do
    bucket = storage_client.bucket bucket_name
    return unless bucket
    bucket.files.each(&:release_event_based_hold!)
    bucket.files.each(&:delete)
    bucket.delete
  end
end

def create_dataset_helper dataset_id
  bigquery_client = Google::Cloud::Bigquery.new

  retry_action Google::Cloud::ResourceExhaustedError, RESOURCE_EXHAUSTION_FAILURE_MESSAGE do
    return bigquery_client.create_dataset dataset_id, location: "US"
  end
end

def delete_dataset_helper dataset_id
  bigquery_client = Google::Cloud::Bigquery.new

  retry_action Google::Cloud::ResourceExhaustedError, RESOURCE_EXHAUSTION_FAILURE_MESSAGE do
    dataset = bigquery_client.dataset dataset_id
    return unless dataset
    dataset.delete
  end
end

def retry_action error, message = nil
  5.times do
    yield
    return
  rescue error => e
    puts "\n#{e} Gonna try again"
    sleep rand(1..3)
  rescue StandardError => e
    puts "\n#{e}"
    return
  end
  raise error, message
end
