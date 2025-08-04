# Copyright 2023 Google LLC
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

##
# Shows how to create a BigQuery subscription where messages published
# to a topic populates a BigQuery table.
#
def pubsub_publisher_with_compression project_id:, topic_id:
  # [START pubsub_publisher_with_compression]
  # project_id = "your-project-id"
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::PubSub.new project_id: project_id
  # Enable compression and configure the compression threshold to 10 bytes
  # (default to 240 B).
  # Publish requests of sizes > 10 B (excluding the request headers) will get
  # compressed.
  publisher = pubsub.publisher topic_id, async: {
    compress: true,
    compression_bytes_threshold: 10
  }

  begin
    publisher.publish_async "This is a test message." do |result|
      raise "Failed to publish the message." unless result.succeeded?
      puts "Published a compressed message of message ID: #{result.message_id}"
    end
    # Stop the async_publisher to send all queued messages immediately.
    publisher.async_publisher.stop.wait!
  rescue StandardError => e
    puts "Received error while publishing: #{e.message}"
  end
  # [END pubsub_publisher_with_compression]
end
