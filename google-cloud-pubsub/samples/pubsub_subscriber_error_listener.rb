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

def listen_for_messages_with_error_handler subscription_id:
  # [START pubsub_subscriber_error_listener]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new

  subscriber = pubsub.subscriber subscription_id
  listener   = subscriber.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  # Propagate expection from child threads to the main thread as soon as it is
  # raised. Exceptions happened in the callback thread are collected in the
  # callback thread pool and do not propagate to the main thread
  Thread.abort_on_exception = true

  begin
    listener.start
    # Let the main thread sleep for 60 seconds so the thread for listening
    # messages does not quit
    sleep 60
    listener.stop.wait!
  rescue StandardError => e
    puts "Exception #{e.inspect}: #{e.message}"
    raise "Stopped listening for messages."
  end
  # [END pubsub_subscriber_error_listener]
end
