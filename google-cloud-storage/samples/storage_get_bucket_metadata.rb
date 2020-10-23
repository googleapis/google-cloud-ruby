# Copyright 2020 Google LLC
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

def get_bucket_metadata bucket_name:
  # [START storage_get_bucket_metadata]
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  puts "ID:                       #{bucket.id}"
  puts "Name:                     #{bucket.name}"
  puts "Storage Class:            #{bucket.storage_class}"
  puts "Location:                 #{bucket.location}"
  puts "Location Type:            #{bucket.location_type}"
  puts "Cors:                     #{bucket.cors}"
  puts "Default Event Based Hold: #{bucket.default_event_based_hold?}"
  puts "Default KMS Key Name:     #{bucket.default_kms_key}"
  puts "Logging Bucket:           #{bucket.logging_bucket}"
  puts "Logging Prefix:           #{bucket.logging_prefix}"
  puts "Metageneration:           #{bucket.metageneration}"
  puts "Retention Effective Time: #{bucket.retention_effective_at}"
  puts "Retention Period:         #{bucket.retention_period}"
  puts "Retention Policy Locked:  #{bucket.retention_policy_locked?}"
  puts "Requester Pays:           #{bucket.requester_pays}"
  puts "Self Link:                #{bucket.api_url}"
  puts "Time Created:             #{bucket.created_at}"
  puts "Versioning Enabled:       #{bucket.versioning?}"
  puts "Index Page:               #{bucket.website_main}"
  puts "Not Found Page:           #{bucket.website_404}"
  puts "Labels:"
  bucket.labels.each do |key, value|
    puts " - #{key} = #{value}"
  end
  puts "Lifecycle Rules:"
  bucket.lifecycle.each do |rule|
    puts "#{rule.action} - #{rule.storage_class} - #{rule.age} - #{rule.matches_storage_class}"
  end
  # [END storage_get_bucket_metadata]
end

get_bucket_metadata bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
