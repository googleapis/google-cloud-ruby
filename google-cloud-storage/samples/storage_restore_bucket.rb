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

# [START storage_delete_bucket]
def delete_bucket bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  #{}require "google/cloud/storage"
  require_relative '../lib/google/cloud/storage'
  require_relative '../lib/google/cloud/storage/project'
  require_relative '../lib/google/cloud/storage/bucket'
  # require_relative '../lib/google/cloud/storage/bucket/list'
  require_relative '../lib/google/cloud/storage/service'

  require 'pry'

  storage = Google::Cloud::Storage.new
  deleted_bucket  = storage.create_bucket bucket_name

  deleted_bucket.delete
 
  # fetching generation
  generation = deleted_bucket.generation

  # fetching soft deleted buckets
  deleted_buckets = storage.buckets soft_deleted: true

  #{}storage.bucket deleted_bucket.name, generation: generation, soft_deleted: true

  puts "Deleted bucket: #{deleted_bucket.name}"
  puts deleted_bucket
  puts "bucket generation #{generation}"
  puts "count of soft deleted buckets #{deleted_buckets.count}"
  #{}puts Gem.loaded_specs["google-cloud-storage"].full_gem_path

end
# [END storage_delete_bucket]

bucket_name = "ruby_try_2"
delete_bucket bucket_name: bucket_name

#{}compose_file bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
