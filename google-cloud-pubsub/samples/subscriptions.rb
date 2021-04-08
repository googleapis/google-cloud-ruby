# Copyright 2021 Google, Inc
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

def update_push_configuration subscription_id:, new_endpoint:
  # [START pubsub_update_push_configuration]
  # subscription_id   = "your-subscription-id"
  # new_endpoint      = "Endpoint where your app receives messages""
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription          = pubsub.subscription subscription_id
  subscription.endpoint = new_endpoint

  puts "Push endpoint updated."
  # [END pubsub_update_push_configuration]
end

def list_subscriptions
  # [START pubsub_list_subscriptions]
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscriptions = pubsub.list_subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END pubsub_list_subscriptions]
end

def detach_subscription subscription_id:
  # [START pubsub_detach_subscription]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.detach

  sleep 120
  subscription.reload!
  if subscription.detached?
    puts "Subscription is detached."
  else
    puts "Subscription is NOT detached."
  end
  # [END pubsub_detach_subscription]
end

def delete_subscription subscription_id:
  # [START pubsub_delete_subscription]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.delete

  puts "Subscription #{subscription_id} deleted."
  # [END pubsub_delete_subscription]
end

def get_subscription_policy subscription_id:
  # [START pubsub_get_subscription_policy]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  policy       = subscription.policy

  puts "Subscription policy:"
  puts policy.roles
  # [END pubsub_get_subscription_policy]
end

def set_subscription_policy subscription_id:, role:, service_account_email:
  # [START pubsub_set_subscription_policy]
  # subscription_id       = "your-subscription-id"
  # role                  = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.policy do |policy|
    policy.add role, service_account_email
  end
  # [END pubsub_set_subscription_policy]
end

def test_subscription_permissions subscription_id:
  # [START pubsub_test_subscription_permissions]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  permissions  = subscription.test_permissions "pubsub.subscriptions.consume",
                                               "pubsub.subscriptions.update"

  puts "Permission to consume" if permissions.include? "pubsub.subscriptions.consume"
  puts "Permission to update" if permissions.include? "pubsub.subscriptions.update"
  # [END pubsub_test_subscription_permissions]
end

def dead_letter_update_subscription subscription_id:
  # [START pubsub_dead_letter_update_subscription]
  # subscription_id       = "your-subscription-id"
  # role                  = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.dead_letter_max_delivery_attempts = 20
  puts "Max delivery attempts is now #{subscription.dead_letter_max_delivery_attempts}."
  # [END pubsub_dead_letter_update_subscription]
end

def dead_letter_remove subscription_id:
  # [START pubsub_dead_letter_remove]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.remove_dead_letter_policy
  puts "Removed dead letter topic from #{subscription_id} subscription."
  # [END pubsub_dead_letter_remove]
end

def listen_for_messages subscription_id:
  # [START pubsub_subscriber_async_pull]
  # [START pubsub_quickstart_subscriber]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_async_pull]
  # [END pubsub_quickstart_subscriber]
end

def listen_for_messages_with_custom_attributes subscription_id:
  # [START pubsub_subscriber_async_pull_custom_attributes]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    unless received_message.attributes.empty?
      puts "Attributes:"
      received_message.attributes.each do |key, value|
        puts "#{key}: #{value}"
      end
    end
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_async_pull_custom_attributes]
end

def pull_messages subscription_id:
  # [START pubsub_subscriber_sync_pull]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.pull(immediate: false).each do |message|
    puts "Message pulled: #{message.data}"
    message.acknowledge!
  end
  # [END pubsub_subscriber_sync_pull]
end

def listen_for_messages_with_error_handler subscription_id:
  # [START pubsub_subscriber_error_listener]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  # Propagate expection from child threads to the main thread as soon as it is
  # raised. Exceptions happened in the callback thread are collected in the
  # callback thread pool and do not propagate to the main thread
  Thread.abort_on_exception = true

  begin
    subscriber.start
    # Let the main thread sleep for 60 seconds so the thread for listening
    # messages does not quit
    sleep 60
    subscriber.stop.wait!
  rescue Exception => e
    puts "Exception #{e.inspect}: #{e.message}"
    raise "Stopped listening for messages."
  end
  # [END pubsub_subscriber_error_listener]
end

def listen_for_messages_with_flow_control subscription_id:
  # [START pubsub_subscriber_flow_settings]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscriber   = subscription.listen inventory: 10 do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_flow_settings]
end

def listen_for_messages_with_concurrency_control subscription_id:
  # [START pubsub_subscriber_concurrency_control]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  # Use 2 threads for streaming, 4 threads for executing callbacks and 2 threads
  # for sending acknowledgements and/or delays
  subscriber   = subscription.listen streams: 2, threads: {
    callback: 4,
    push:     2
  } do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_concurrency_control]
end

def dead_letter_delivery_attempt subscription_id:
  # [START pubsub_dead_letter_delivery_attempt]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.pull(immediate: false).each do |message|
    puts "Received message: #{message.data}"
    puts "Delivery Attempt: #{message.delivery_attempt}"
    message.acknowledge!
  end
  # [END pubsub_dead_letter_delivery_attempt]
end

def subscriber_sync_pull_with_lease subscription_id:
  # [START pubsub_subscriber_sync_pull_with_lease]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

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

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "update_push_configuration"
    update_push_configuration subscription_id: ARGV.shift,
                              new_endpoint:    ARGV.shift
  when "list_subscriptions"
    list_subscriptions
  when "detach_subscription"
    detach_subscription subscription_id: ARGV.shift
  when "delete_subscription"
    delete_subscription subscription_id: ARGV.shift
  when "get_subscription_policy"
    get_subscription_policy psubscription_id: ARGV.shift
  when "set_subscription_policy"
    set_subscription_policy subscription_id: ARGV.shift
  when "test_subscription_permissions"
    test_subscription_permissions subscription_id: ARGV.shift
  when "dead_letter_update_subscription"
    dead_letter_update_subscription subscription_id: ARGV.shift
  when "dead_letter_remove"
    dead_letter_remove subscription_id: ARGV.shift
  when "listen_for_messages"
    listen_for_messages subscription_id: ARGV.shift
  when "listen_for_messages_with_custom_attributes"
    listen_for_messages_with_custom_attributes subscription_id: ARGV.shift
  when "pull_messages"
    pull_messages subscription_id: ARGV.shift
  when "listen_for_messages_with_error_handler"
    listen_for_messages_with_error_handler subscription_id: ARGV.shift
  when "listen_for_messages_with_flow_control"
    listen_for_messages_with_flow_control subscription_id: ARGV.shift
  when "listen_for_messages_with_concurrency_control"
    listen_for_messages_with_concurrency_control subscription_id: ARGV.shift
  when "dead_letter_delivery_attempt"
    dead_letter_delivery_attempt subscription_id: ARGV.shift
  when "subscriber_sync_pull_with_lease"
    subscriber_sync_pull_with_lease subscription_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby subscriptions.rb [command] [arguments]

      Commands:
        update_push_configuration                    <subscription_id> <endpoint> Update the endpoint of a push subscription
        list_subscriptions                                                        List subscriptions of a project
        detach_subscription                          <subscription_id>            Detach a subscription
        delete_subscription                          <subscription_id>            Delete a subscription
        get_subscription_policy                      <subscription_id>            Get policies of a subscription
        set_subscription_policy                      <subscription_id>            Set policies of a subscription
        test_subscription_permissions                <subscription_id>            Test policies of a subscription
        dead_letter_update_subscription              <subscription_id>            Update a subscription's dead letter policy
        dead_letter_remove                           <subscription_id>            Delete a subscription's dead letter policy
        listen_for_messages                          <subscription_id>            Listen for messages
        listen_for_messages_with_custom_attributes   <subscription_id>            Listen for messages with custom attributes
        pull_messages                                <subscription_id>            Pull messages
        listen_for_messages_with_error_handler       <subscription_id>            Listen for messages with an error handler
        listen_for_messages_with_flow_control        <subscription_id>            Listen for messages with flow control
        listen_for_messages_with_concurrency_control <subscription_id>            Listen for messages with concurrency control
        dead_letter_delivery_attempt                 <subscription_id>            Pull messages that have a delivery attempts field
        subscriber_sync_pull_with_lease              <subscription_id>            Pull messages and reset their acknowledgement deadlines
    USAGE
  end
end
