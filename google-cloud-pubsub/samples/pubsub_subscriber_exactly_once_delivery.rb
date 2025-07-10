# Copyright 2022 Google LLC
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

def subscriber_exactly_once_delivery project_id:, subscription_id:
  # [START pubsub_subscriber_exactly_once]
  # project_id = "your-project-id"
  # subscription_id = "your-subscription-id"
  pubsub = Google::Cloud::Pubsub.new project_id: project_id
  subscriber = pubsub.subscriber subscription_id
  listener = subscriber.listen do |received_message|
    puts "Received message: #{received_message.data}"

    # Pass in callback to access the acknowledge result.
    # For subscription with Exactly once delivery disabled the result will be success always.
    received_message.acknowledge! do |result|
      puts "Acknowledge result's status: #{result.status}"
    end
  end

  listener.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  listener.stop.wait!
  # [END pubsub_subscriber_exactly_once]
end
