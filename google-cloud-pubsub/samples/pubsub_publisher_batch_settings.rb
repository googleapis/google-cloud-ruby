# Copyright 2023 Google, Inc
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

require "google/cloud/pubsub"

def publish_messages_async_with_batch_settings topic_id:
  # [START pubsub_publisher_batch_settings]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::PubSub.new

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  publisher = pubsub.publisher topic_id, async: {
    max_bytes:    1_000_000,
    max_messages: 20
  }
  10.times do |i|
    publisher.publish_async "This is message ##{i}."
  end

  # Stop the async_publisher to send all queued messages immediately.
  publisher.async_publisher.stop.wait!
  puts "Messages published asynchronously in batch."
  # [END pubsub_publisher_batch_settings]
end
