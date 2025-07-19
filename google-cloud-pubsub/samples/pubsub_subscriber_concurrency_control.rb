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

def listen_for_messages_with_concurrency_control subscription_id:
  # [START pubsub_subscriber_concurrency_control]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new

  subscriber = pubsub.subscriber subscription_id

  # Use 2 threads for streaming, 4 threads for executing callbacks and 2 threads
  # for sending acknowledgements and/or delays
  listener = subscriber.listen streams: 2, threads: {
    callback: 4,
    push:     2
  } do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  listener.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  listener.stop.wait!
  # [END pubsub_subscriber_concurrency_control]
end
