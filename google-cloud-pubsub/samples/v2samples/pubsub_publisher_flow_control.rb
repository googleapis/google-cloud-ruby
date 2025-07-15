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

def publish_messages_async_with_flow_control topic_id:
  # [START pubsub_old_version_publisher_flow_control]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id, async: {
    # Configure how many messages the publisher client can hold in memory
    # and what to do when messages exceed the limit.
    flow_control: {
      message_limit: 100,
      byte_limit: 10 * 1024 * 1024, # 10 MiB
      # Block more messages from being published when the limit is reached. The
      # other options are :ignore and :error.
      limit_exceeded_behavior: :block
    }
  }
  # Rapidly publishing 1000 messages in a loop may be constrained by flow control.
  1000.times do |i|
    topic.publish_async "message #{i}" do |result|
      raise "Failed to publish the message." unless result.succeeded?
    end
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  puts "Published messages with flow control settings to #{topic_id}."
  # [END pubsub_old_version_publisher_flow_control]
end
