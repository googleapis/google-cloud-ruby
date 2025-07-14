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

# [START pubsub_old_version_subscriber_exactly_once]
require "google/cloud/pubsub"

# Shows how to register callback to acknowledge method and access the result passed in
class PubsubSubscriberExactlyOnceDelivery
  def subscriber_exactly_once_delivery project_id:, topic_id:, subscription_id:
    pubsub = Google::Cloud::Pubsub.new project_id: project_id
    topic = pubsub.topic topic_id
    subscription = pubsub.subscription subscription_id
    subscriber   = subscription.listen do |received_message|
      puts "Received message: #{received_message.data}"

      # Pass in callback to access the acknowledge result.
      # For subscription with Exactly once delivery disabled the result will be success always.
      received_message.acknowledge! do |result|
        puts "Acknowledge result's status: #{result.status}"
      end
    end

    subscriber.start
    # Let the main thread sleep for 60 seconds so the thread for listening
    # messages does not quit
    sleep 60
    subscriber.stop.wait!
  end

  def self.run
    # TODO(developer): Replace these variables before running the sample.
    project_id = "your-project-id"
    topic_id = "your-topic-id"
    subscription_id = "id-for-new-subcription" # subscription with exactly once delivery enabled
    PubsubSubscriberExactlyOnceDelivery.new.subscriber_exactly_once_delivery project_id: project_id,
                                                                             topic_id: topic_id,
                                                                             subscription_id: subscription_id
  end
end

if $PROGRAM_NAME == __FILE__
  PubsubSubscriberExactlyOnceDelivery.run
end
# [END pubsub_old_version_subscriber_exactly_once]
