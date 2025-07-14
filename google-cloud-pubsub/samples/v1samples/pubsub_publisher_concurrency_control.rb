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

def publish_messages_async_with_concurrency_control topic_id:
  # [START pubsub_old_version_publisher_concurrency_control]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id, async: {
    threads: {
      # Use exactly one thread for publishing message and exactly one thread
      # for executing callbacks
      publish:  1,
      callback: 1
    }
  }
  topic.publish_async "This is a test message." do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_old_version_publisher_concurrency_control]
end
