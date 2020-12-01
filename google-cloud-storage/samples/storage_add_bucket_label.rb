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

# [START storage_add_bucket_label]
def add_bucket_label bucket_name:, label_key:, label_value:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The key of the label to add
  # label_key = "label-key-to-add"

  # The value of the label to add
  # label_value = "label-value-to-add"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.update do |bucket|
    bucket.labels[label_key] = label_value
  end

  puts "Added label #{label_key} with value #{label_value} to #{bucket_name}"
end
# [END storage_add_bucket_label]

if $PROGRAM_NAME == __FILE__
  add_bucket_label bucket_name: ARGV.shift, label_key: ARGV.shift, label_value: ARGV.shift
end
