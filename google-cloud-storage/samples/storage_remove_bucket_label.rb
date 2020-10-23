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

def remove_bucket_label bucket_name:, label_key:
  # [START storage_remove_bucket_label]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The key of the label to remove from the bucket
  # label_key = "label-key-to-remove"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.update do |bucket|
    bucket.labels[label_key] = nil
  end

  puts "Deleted label #{label_key} from #{bucket_name}"
  # [END storage_remove_bucket_label]
end

remove_bucket_label bucket_name: ARGV.shift, label_key: ARGV.shift if $PROGRAM_NAME == __FILE__
