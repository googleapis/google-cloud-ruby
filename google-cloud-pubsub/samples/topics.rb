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

def create_topic topic_id:
  # [START pubsub_create_topic]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.create_topic topic_id

  puts "Topic #{topic.name} created."
  # [END pubsub_create_topic]
end

def list_topics
  # [START pubsub_list_topics]
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topics = pubsub.topics

  puts "Topics in project:"
  topics.each do |topic|
    puts topic.name
  end
  # [END pubsub_list_topics]
end

def list_topic_subscriptions topic_id:
  # [START pubsub_list_topic_subscriptions]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic         = pubsub.topic topic_id
  subscriptions = topic.subscriptions

  puts "Subscriptions in topic #{topic.name}:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END pubsub_list_topic_subscriptions]
end

def delete_topic topic_id:
  # [START pubsub_delete_topic]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id
  topic.delete

  puts "Topic #{topic_id} deleted."
  # [END pubsub_delete_topic]
end

def get_topic_policy topic_id:
  # [START pubsub_get_topic_policy]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic  = pubsub.topic topic_id
  policy = topic.policy

  puts "Topic policy:"
  puts policy.roles
  # [END pubsub_get_topic_policy]
end

def set_topic_policy topic_id:, role:, service_account_email:
  # [START pubsub_set_topic_policy]
  # topic_id              = "your-topic-id"
  # role                  = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id
  topic.policy do |policy|
    policy.add role, service_account_email
  end
  # [END pubsub_set_topic_policy]
end

def test_topic_permissions topic_id:
  # [START pubsub_test_topic_permissions]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic       = pubsub.topic topic_id
  permissions = topic.test_permissions "pubsub.topics.attachSubscription",
                                       "pubsub.topics.publish", "pubsub.topics.update"

  puts "Permission to attach subscription" if permissions.include? "pubsub.topics.attachSubscription"
  puts "Permission to publish" if permissions.include? "pubsub.topics.publish"
  puts "Permission to update" if permissions.include? "pubsub.topics.update"
  # [END pubsub_test_topic_permissions]
end

def create_pull_subscription topic_id:, subscription_id:
  # [START pubsub_create_pull_subscription]
  # topic_id        = "your-topic-id"
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic        = pubsub.topic topic_id
  subscription = topic.subscribe subscription_id

  puts "Pull subscription #{subscription_id} created."
  # [END pubsub_create_pull_subscription]
end

def create_ordered_pull_subscription topic_id:, subscription_id:
  # [START pubsub_enable_subscription_ordering]
  # topic_id        = "your-topic-id"
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic        = pubsub.topic topic_id
  subscription = topic.subscribe subscription_id,
                                 message_ordering: true

  puts "Pull subscription #{subscription_id} created with message ordering."
  # [END pubsub_enable_subscription_ordering]
end

def create_push_subscription topic_id:, subscription_id:, endpoint:
  # [START pubsub_create_push_subscription]
  # topic_id          = "your-topic-id"
  # subscription_id   = "your-subscription-id"
  # endpoint          = "https://your-test-project.appspot.com/push"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic        = pubsub.topic topic_id
  subscription = topic.subscribe subscription_id,
                                 endpoint: endpoint

  puts "Push subscription #{subscription_id} created."
  # [END pubsub_create_push_subscription]
end

def dead_letter_create_subscription topic_id:, subscription_id:, dead_letter_topic_id:
  # [START pubsub_dead_letter_create_subscription]
  # topic_id             = "your-topic-id"
  # subscription_id      = "your-subscription-id"
  # dead_letter_topic_id = "your-dead-letter-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic             = pubsub.topic topic_id
  dead_letter_topic = pubsub.topic dead_letter_topic_id
  subscription      = topic.subscribe subscription_id,
                                      dead_letter_topic:                 dead_letter_topic,
                                      dead_letter_max_delivery_attempts: 10

  puts "Created subscription #{subscription_id} with dead letter topic #{dead_letter_topic_id}."
  puts "To process dead letter messages, remember to add a subscription to your dead letter topic."
  # [END pubsub_dead_letter_create_subscription]
end

def publish_message topic_id:
  # [START pubsub_quickstart_publisher]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id
  topic.publish "This is a test message."

  puts "Message published."
  # [END pubsub_quickstart_publisher]
end

def publish_message_async topic_id:
  # [START pubsub_publish]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id
  topic.publish_async "This is a test message." do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publish]
end

def publish_message_async_with_custom_attributes topic_id:
  # [START pubsub_publish_custom_attributes]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id
  # Add two attributes, origin and username, to the message
  topic.publish_async "This is a test message.",
                      origin:   "ruby-sample",
                      username: "gcp" do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message with custom attributes published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publish_custom_attributes]
end

def publish_messages_async_with_batch_settings topic_id:
  # [START pubsub_publisher_batch_settings]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  topic = pubsub.topic topic_id, async: {
    max_bytes:    1_000_000,
    max_messages: 20
  }
  10.times do |i|
    topic.publish_async "This is message \##{i}."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  puts "Messages published asynchronously in batch."
  # [END pubsub_publisher_batch_settings]
end

def publish_messages_async_with_concurrency_control topic_id:
  # [START pubsub_publisher_concurrency_control]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id, async: {
    threads: {
      # Use exactly one thread for publishing message and exactly one thread
      # for executing callbacks
      publish:  1,
      callback: 1
    }
  }
  topic.publish_async "This is a test message." do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publisher_concurrency_control]
end

def publish_messages_async_with_flow_control topic_id:
  # [START pubsub_publisher_flow_control]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

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
  # [END pubsub_publisher_flow_control]
end

def publish_with_error_handler topic_id:
  # [START pubsub_publish_with_error_handler]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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

def publish_ordered_messages topic_id:
  # [START pubsub_publish_with_ordering_keys]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  topic = pubsub.topic topic_id, async: {
    max_bytes:    1_000_000,
    max_messages: 20
  }
  topic.enable_message_ordering!
  10.times do |i|
    topic.publish_async "This is message \##{i}.",
                        ordering_key: "ordering-key"
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop!
  puts "Messages published with ordering key."
  # [END pubsub_publish_with_ordering_keys]
end

def publish_resume_publish topic_id:
  # [START pubsub_resume_publish_with_ordering_keys]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  topic = pubsub.topic topic_id, async: {
    max_bytes:    1_000_000,
    max_messages: 20
  }
  topic.enable_message_ordering!
  10.times do |i|
    topic.publish_async "This is message \##{i}.",
                        ordering_key: "ordering-key" do |result|
      if result.succeeded?
        puts "Message \##{i} successfully published."
      else
        puts "Message \##{i} failed to publish"
        # Allow publishing to continue on "ordering-key" after processing the
        # failure.
        topic.resume_publish "ordering-key"
      end
    end
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop!
  # [END pubsub_resume_publish_with_ordering_keys]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_topic"
    create_topic topic_id: ARGV.shift
  when "list_topics"
    list_topics
  when "list_topic_subscriptions"
    list_topic_subscriptions topic_id: ARGV.shift
  when "delete_topic"
    delete_topic topic_id: ARGV.shift
  when "get_topic_policy"
    get_topic_policy topic_id: ARGV.shift
  when "set_topic_policy"
    set_topic_policy topic_id: ARGV.shift, role: ARGV.shift, service_account_email: ARGV.shift
  when "test_topic_permissions"
    test_topic_permissions topic_id: ARGV.shift
  when "create_pull_subscription"
    create_pull_subscription topic_id:        ARGV.shift,
                             subscription_id: ARGV.shift
  when "create_ordered_pull_subscription"
    create_ordered_pull_subscription topic_id:        ARGV.shift,
                                     subscription_id: ARGV.shift
  when "create_push_subscription"
    create_push_subscription topic_id:        ARGV.shift,
                             subscription_id: ARGV.shift,
                             endpoint:        ARGV.shift
  when "dead_letter_create_subscription"
    dead_letter_create_subscription topic_id:             ARGV.shift,
                                    subscription_id:      ARGV.shift,
                                    dead_letter_topic_id: ARGV.shift
  when "publish_message"
    publish_message topic_id: ARGV.shift
  when "publish_message_async"
    publish_message_async topic_id: ARGV.shift
  when "publish_message_async_with_custom_attributes"
    publish_message_async_with_custom_attributes topic_id: ARGV.shift
  when "publish_messages_async_with_batch_settings"
    publish_messages_with_batch_settings topic_id: ARGV.shift
  when "publish_messages_async_with_concurrency_control"
    publish_messages_async_with_concurrency_control topic_id: ARGV.shift
  when "publish_with_error_handler"
    publish_with_error_handler topic_id: ARGV.shift
  when "publish_ordered_messages"
    publish_ordered_messages topic_id: ARGV.shift
  when "publish_resume_publish"
    publish_resume_publish topic_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby topics.rb [command] [arguments]

      Commands:
        create_topic                                    <topic_id>                                          Create a topic
        list_topics                                                                                         List topics in a project
        list_topic_subscriptions                        <topic_id>                                          List subscriptions in a topic
        delete_topic                                    <topic_id>                                          Delete topic policies
        get_topic_policy                                <topic_id>                                          Get topic policies
        set_topic_policy                                <topic_id> <role> <service_account_email>           Set topic policies
        test_topic_permissions                          <topic_id>                                          Test topic permissions
        create_pull_subscription                        <topic_id> <subscription_id>                        Create a pull subscription
        create_ordered_pull_subscription                <topic_id> <subscription_id>                        Create a pull subscription with ordering enabled
        create_push_subscription                        <topic_id> <subscription_id> <endpoint>             Create a push subscription
        dead_letter_create_subscription                 <topic_id> <subscription_id> <dead_letter_topic_id> Create a subscription with a dead letter topic
        publish_message                                 <topic_id>                                          Publish message
        publish_message_async                           <topic_id>                                          Publish messages asynchronously
        publish_message_async_with_custom_attributes    <topic_id>                                          Publish messages asynchronously with custom attributes
        publish_messages_async_with_batch_settings      <topic_id>                                          Publish messages asynchronously in batch
        publish_messages_async_with_concurrency_control <topic_id>                                          Publish messages asynchronously with concurrency control
        publish_with_error_handler                      <topic_id>                                          Publish messages asynchronously with error handling
        publish_ordered_messages                        <topic_id>                                          Publish messages asynchronously with ordering keys
        publish_resume_publish                          <topic_id>                                          Publish messages asynchronously with ordering keys and resume on failure
    USAGE
  end
end
