# Copyright 2022 Google LLC
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

# Sample for storage_create_bucket_dual_region
class StorageCreateBucketDualRegion
  def storage_create_bucket_dual_region bucket_name:, region_1:, region_2:
    # [START storage_create_bucket_dual_region]
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"

    # The bucket's pair of regions. Case-insensitive.
    # See this documentation for other valid locations:
    # https://cloud.google.com/storage/docs/locations
    # region_1 = "US-EAST1"
    # region_2 = "US-WEST1"

    require "google/cloud/storage"

    storage = Google::Cloud::Storage.new
    bucket  = storage.create_bucket bucket_name,
                                    custom_placement_config: { data_locations: [region_1, region_2] }

    puts "Bucket #{bucket.name} created:"
    puts "- location: #{bucket.location}"
    puts "- location_type: #{bucket.location_type}"
    puts "- custom_placement_config:"
    puts "  - data_locations: #{bucket.data_locations}"
    # [END storage_create_bucket_dual_region]
  end
end

if $PROGRAM_NAME == __FILE__
  StorageCreateBucketDualRegion.new.storage_create_bucket_dual_region bucket_name: ARGV.shift,
                                                                      region_1: ARGV.shift,
                                                                      region_2: ARGV.shift
end
