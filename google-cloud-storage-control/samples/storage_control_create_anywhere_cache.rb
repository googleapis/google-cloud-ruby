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

# [START storage_control_create_anywhere_cache]
require "google/cloud/storage/control"

# Creates a new Anywhere Cache for a specified bucket and waits for it
# to become active.
#
# This method initiates the creation of an Anywhere Cache in the given zone for
# the specified bucket. After sending the creation request, it polls the status
# of the cache with an exponential backoff strategy until the cache's state is
# "running". Progress and final status are printed to the console.
#
# @param bucket_name [String] The name of the bucket.
# @param zone [String] The zone where the Anywhere Cache instance should be
#   located (e.g., "us-east1-b").
#
# @example
#   create_anywhere_cache(
#     bucket_name: "your-unique-bucket-name",
#     zone: "us-east1-b"
#   )
#
def create_anywhere_cache bucket_name:, zone:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{zone}"

  anywhere_cache = Google::Cloud::Storage::Control::V2::AnywhereCache.new(
    name: name,
    zone: zone
  )
  # Create a request.
  request = Google::Cloud::Storage::Control::V2::CreateAnywhereCacheRequest.new(
    parent: parent,
    anywhere_cache: anywhere_cache
  )
  # The request creates a new cache in the specified zone.
  # The cache is created in the specified bucket.
  begin
    operation = storage_control_client.create_anywhere_cache request
    puts "AnywhereCache operation created - #{operation.name}"
    get_request = Google::Cloud::Storage::Control::V2::GetAnywhereCacheRequest.new(
      name: name
    )
    result = storage_control_client.get_anywhere_cache get_request
    min_delay = 30 # 30 seconds
    max_delay = 900 # 15 minutes
    start_time = Time.now
    while result.state&.downcase != "running"
      unless ["paused", "disabled", "creating"].include? result.state&.downcase
        raise Google::Cloud::Error,
              "AnywhereCache operation failed on the backend with state #{result.state&.downcase}."
      end
      puts "Cache not running yet, current state is #{result.state&.downcase}. Retrying in #{min_delay} seconds."
      sleep min_delay
      min_delay = [min_delay * 2, max_delay].min # Exponential backoff with a max delay
      result = storage_control_client.get_anywhere_cache get_request
    end
    end_time = Time.now
    duration = end_time - start_time
    puts "Total polling time: #{duration.round(2)} seconds."
    message = "Successfully created anywhereCache - #{result.name}."
  rescue Google::Cloud::Error => e
    message = "Failed to create AnywhereCache. Error: #{e.message}"
  end
  puts message
end
# [END storage_control_create_anywhere_cache]
create_anywhere_cache bucket_name: ARGV.shift, zone: ARGV.shift if $PROGRAM_NAME == __FILE__
