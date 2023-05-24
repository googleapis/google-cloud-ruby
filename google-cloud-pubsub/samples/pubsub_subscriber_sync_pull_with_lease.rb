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

def subscriber_sync_pull_with_lease subscription_id:
  # [START pubsub_subscriber_sync_pull_with_lease]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  new_ack_deadline = 30
  processed = false

  # The subscriber pulls a specified number of messages.
  received_messages = subscription.pull immediate: false, max: 1

  # Obtain the first message.
  message = received_messages.first

  # Send the message to a non-blocking worker that starts a long-running process, such as writing
  # the message to a table, which may take longer than the default 10-sec acknowledge deadline.
  Thread.new do
    sleep 15
    processed = true
    puts "Finished processing \"#{message.data}\"."
  end

  loop do
    sleep 1
    if processed
      # If the message has been processed, acknowledge the message.
      message.acknowledge!
      puts "Done."
      # Exit after the message is acknowledged.
      break
    else
      # If the message has not yet been processed, reset its ack deadline.
      message.modify_ack_deadline! new_ack_deadline
      puts "Reset ack deadline for \"#{message.data}\" for #{new_ack_deadline} seconds."
    end
  end
  # [END pubsub_subscriber_sync_pull_with_lease]
end
