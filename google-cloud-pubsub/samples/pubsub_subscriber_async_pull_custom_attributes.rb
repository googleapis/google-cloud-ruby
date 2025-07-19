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

def listen_for_messages_with_custom_attributes subscription_id:
  # [START pubsub_subscriber_async_pull_custom_attributes]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new

  subscriber = pubsub.subscriber subscription_id

  listener = subscriber.listen do |received_message|
    puts "Received message: #{received_message.data}"
    unless received_message.attributes.empty?
      puts "Attributes:"
      received_message.attributes.each do |key, value|
        puts "#{key}: #{value}"
      end
    end
    received_message.acknowledge!
  end

  listener.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  listener.stop.wait!
  # [END pubsub_subscriber_async_pull_custom_attributes]
end
