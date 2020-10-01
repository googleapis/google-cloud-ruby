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

def get_metadata bucket_name:, file_name:
  # [START storage_get_metadata]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "Name: #{file.name}"
  puts "Bucket: #{bucket.name}"
  puts "Storage class: #{bucket.storage_class}"
  puts "ID: #{file.id}"
  puts "Size: #{file.size} bytes"
  puts "Created: #{file.created_at}"
  puts "Updated: #{file.updated_at}"
  puts "Generation: #{file.generation}"
  puts "Metageneration: #{file.metageneration}"
  puts "Etag: #{file.etag}"
  puts "Owners: #{file.acl.owners.join ','}"
  puts "Crc32c: #{file.crc32c}"
  puts "md5_hash: #{file.md5}"
  puts "Cache-control: #{file.cache_control}"
  puts "Content-type: #{file.content_type}"
  puts "Content-disposition: #{file.content_disposition}"
  puts "Content-encoding: #{file.content_encoding}"
  puts "Content-language: #{file.content_language}"
  puts "KmsKeyName: #{file.kms_key}"
  puts "Event-based hold enabled?: #{file.event_based_hold?}"
  puts "Temporary hold enaled?: #{file.temporary_hold?}"
  puts "Retention Expiration: #{file.retention_expires_at}"
  puts "Custom Time: #{file.custom_time}"
  puts "Metadata:"
  file.metadata.each do |key, value|
    puts " - #{key} = #{value}"
  end
  # [END storage_get_metadata]
end

get_metadata bucket_name: ARGV.shift, file_name: ARGV.shift if $PROGRAM_NAME == __FILE__
