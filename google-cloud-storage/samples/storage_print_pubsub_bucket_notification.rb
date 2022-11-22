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

# [START storage_print_pubsub_bucket_notification]
require "google/cloud/storage"

def print_pubsub_bucket_notification bucket_name:, notification_id:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your notification configured for the bucket
  # notification_id = "your-notification-id"


  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  notification = bucket.notification notification_id

  puts "Notification ID: #{notification.id}"
  puts "Topic Name: #{notification.topic}"
  puts "Event Types: #{notification.event_types}"
  puts "Kind of Notification: #{notification.kind}"
  puts "Custom Attributes: #{notification.custom_attrs}"
  puts "Payload Format: #{notification.payload}"
  puts "Blob Name Prefix: #{notification.prefix}"
  puts "Self Link: #{notification.api_url}"
end
# [END storage_print_pubsub_bucket_notification]

print_pubsub_bucket_notification bucket_name: ARGV.shift, notification_id: ARGV.shift if $PROGRAM_NAME == __FILE__
