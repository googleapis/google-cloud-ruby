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

def publish_with_error_handler topic_id:
  # [START pubsub_publish_with_error_handler]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::PubSub.new

  topic = pubsub.topic topic_id

  begin
    topic.publish_async "This is a test message." do |result|
      raise "Failed to publish the message." unless result.succeeded?
      puts "Message published asynchronously."
    end

    # Stop the async_publisher to send all queued messages immediately.
    topic.async_publisher.stop.wait!
  rescue StandardError => e
    puts "Received error while publishing: #{e.message}"
  end
  # [END pubsub_publish_with_error_handler]
end
