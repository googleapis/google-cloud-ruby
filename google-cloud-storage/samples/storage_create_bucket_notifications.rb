# Copyright 2021 Google LLC
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

# [START storage_create_bucket_notifications]
require "google/cloud/storage"

def create_bucket_notifications bucket_name:, topic_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of the pubsub topic
  # topic_name = "your-unique-topic-name"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  notification = bucket.create_notification topic_name

  puts "Successfully created notification with ID #{notification.id} for bucket #{bucket_name}"
end
# [END storage_create_bucket_notifications]

create_bucket_notifications bucket_name: ARGV.shift, topic_name: ARGV.shift if $PROGRAM_NAME == __FILE__
