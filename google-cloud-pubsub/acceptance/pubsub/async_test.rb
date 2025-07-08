# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "pubsub_helper"
require "concurrent/atomics"

describe Google::Cloud::PubSub, :async, :pubsub do
  def retrieve_topic topic_name, async: nil
    topic_path = pubsub.service.topic_path topic_name
    $topic_admin.get_topic(topic: topic_path) rescue $topic_admin.create_topic(name: topic_path)
  end

  def retrieve_subscription topic, subscription_name, enable_message_ordering: false
    subscription_path = pubsub.service.subscription_path subscription_name
    $subscription_admin.get_subscription(subscription: subscription_path) \
      rescue $subscription_admin.create_subscription(name: subscription_path, topic: topic.name, enable_message_ordering: enable_message_ordering)
  end

  let(:nonce) { rand 100 }
  let(:topic) { retrieve_topic "#{$topic_prefix}-async#{nonce}" }
  let(:sub) { retrieve_subscription topic, "#{$topic_prefix}-async-sub#{nonce}" }
  let(:async_flow_control) do
    {
      interval: 30,
      flow_control: {
        message_limit: 2,
        limit_exceeded_behavior: :error
      }
    }
  end
  let(:topic_flow_control) { retrieve_topic "#{$topic_prefix}-async#{nonce}", async: async_flow_control }

  it "publishes and pulls asyncronously" do
    subscriber = pubsub.subscriber sub.name
    events = subscriber.pull
    _(events).must_be :empty?
    # Publish a new message
    publish_result = nil
    publisher = pubsub.publisher topic.name
    publisher.publish_async "hello" do |result|
      publish_result = result
      assert_equal "hello", result.msg.data
    end

    unpublished_retries = 0
    while publish_result.nil?
      fail "publish has failed" if unpublished_retries >= 5
      unpublished_retries += 1
      puts "the async publish has not completed yet. sleeping for #{unpublished_retries*unpublished_retries} second(s) and retrying."
      sleep unpublished_retries*unpublished_retries
    end
    _(publish_result).wont_be :nil?
    _(publish_result).must_be :succeeded?

    received_message = nil
    listener = subscriber.listen do |msg|
      received_message = msg
      # Acknowledge the message
      msg.ack!
    end
    listener.start

    subscription_retries = 0
    while received_message.nil?
      fail "published message was never received has failed" if subscription_retries >= 10
      subscription_retries += 1
      puts "received_message has not been received. sleeping for #{subscription_retries} second(s) and retrying."
      sleep subscription_retries
    end
    _(received_message).wont_be :nil?
    _(received_message.data).must_equal publish_result.data

    listener.stop
    listener.wait!

    # Remove the subscription
    $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))
  end

  it "publishes and pulls ordered messages" do
    topic = retrieve_topic "#{$topic_prefix}-omt-#{SecureRandom.hex(2)}"
 
    sub = retrieve_subscription topic, "#{$topic_prefix}-oms2-#{SecureRandom.hex(2)}", enable_message_ordering: true

    assert sub.enable_message_ordering

    publisher = pubsub.publisher topic.name
    publisher.enable_message_ordering!
    subscriber = pubsub.subscriber sub.name

    events = subscriber.pull
    _(events).must_be :empty?

    expected_message_hash = {
      "a" => [
        "ordered message 0",
        "ordered message 1",
        "ordered message 2",
        "ordered message 3",
        "ordered message 4"
      ],
      "b" => [
        "ordered message 5",
        "ordered message 6",
        "ordered message 7",
        "ordered message 8",
        "ordered message 9"
      ]
    }

    expected_message_hash.keys.each do |key|
      publish_result = nil
      expected_message_hash[key].each do |data|
        # Publish a new message with ordering key
        publisher.publish_async data, ordering_key: key do |result|
          publish_result = result
          assert_equal data, result.msg.data
        end
      end
      sleep 1
      # Verify the final publish_result
      unpublished_retries = 0
      while publish_result.nil?
        fail "publish a has failed" if unpublished_retries >= 5
        unpublished_retries += 1
        puts "the async publish a has not completed yet. sleeping for #{unpublished_retries*unpublished_retries} second(s) and retrying."
        sleep unpublished_retries*unpublished_retries
      end
      _(publish_result).wont_be :nil?
      _(publish_result).must_be :succeeded?
    end

    received_message_hash = Hash.new { |hash, key| hash[key] = [] }
    listener = subscriber.listen do |msg|
      received_message_hash[msg.ordering_key].push msg.data
      # Acknowledge the message
      msg.ack!
    end
    listener.on_error do |error|
      fail error.inspect
    end
    listener.start
    
    counter = 0
    deadline = 300 # 5 min
    while received_message_hash.values.map(&:count).sum < 10 && counter < deadline
      sleep 1
      counter += 1
    end

    listener.stop
    listener.wait!
    # Remove the subscription
    $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))

    _(received_message_hash).must_equal expected_message_hash
  end

  it "will acknowledge asyncronously after subscriber stop wait!" do
    subscriber = pubsub.subscriber sub.name 
    publisher = pubsub.publisher topic.name

    msgs = subscriber.pull
    _(msgs).must_be :empty?

    # Publish a new message
    publisher.publish "ack me please"

    received_message = nil
    acked = false
    listener = subscriber.listen do |msg|
      received_message = msg
      sleep 3 # Provide enough delay to execute subscriber.stop before msg.ack!
      msg.ack!
      acked = true
    end
    listener.start

    subscription_retries = 0
    while received_message.nil?
      fail "published message was never received has failed" if subscription_retries >= 100
      subscription_retries += 1
      sleep 0.1
    end
    _(received_message).wont_be :nil?
    _(received_message.data).must_equal "ack me please"

    listener.stop # Should return before msg.ack! is called in the callback above.

    listener.wait! # Should block until TimedUnaryBuffer finally flushes the msg.ack! in the callback above.

    _(acked).must_equal true

    msgs = subscriber.pull immediate: false
    _(msgs).must_be :empty?

    # Remove the subscription
    $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))
  end

  it "will acknowledge asyncronously after subscriber stop only" do
    publisher = pubsub.publisher topic.name
    subscriber = pubsub.subscriber sub.name
    msgs = subscriber.pull
    _(msgs).must_be :empty?

    # Publish a new message
    publisher.publish "ack me please"

    received_message = nil
    acked = false
    listener = subscriber.listen do |msg|
      received_message = msg
      sleep 3 # Provide enough delay to execute subscriber.stop before msg.ack!
      msg.ack!
      acked = true
    end
    listener.start

    subscription_retries = 0
    while received_message.nil?
      fail "published message was never received has failed" if subscription_retries >= 100
      subscription_retries += 1
      sleep 0.1
    end
    _(received_message).wont_be :nil?
    _(received_message.data).must_equal "ack me please"

    listener.stop # Should return before msg.ack! is called in the callback above.

    sleep 4 # Do not call subscriber.wait!

    _(acked).must_equal true

    msgs = subscriber.pull immediate: false
    _(msgs).must_be :empty?

    # Remove the subscription
    $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))
  end

  it "will acknowledge asyncronously after subscriber wait! followed by stop in a different thread" do
    publisher = pubsub.publisher topic.name
    subscriber = pubsub.subscriber sub.name

    msgs = subscriber.pull
    _(msgs).must_be :empty?

    # Publish a new message
    publisher.publish "ack me please"

    received_message = nil
    acked = false
    listener = subscriber.listen do |msg|
      received_message = msg
      sleep 3 # Provide enough delay to execute subscriber.stop before msg.ack!
      msg.ack!
      acked = true
    end
    listener.start

    subscription_retries = 0
    while received_message.nil?
      fail "published message was never received has failed" if subscription_retries >= 100
      subscription_retries += 1
      sleep 0.1
    end
    _(received_message).wont_be :nil?
    _(received_message.data).must_equal "ack me please"

    Thread.new do
      sleep 4
      listener.stop # Follows wait!, below.
    end

    listener.wait! # Should block until TimedUnaryBuffer finally flushes the msg.ack! in the callback above.

    _(acked).must_equal true

    msgs = subscriber.pull immediate: false
    _(msgs).must_be :empty?

    # Remove the subscription
    $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))
  end

  it "publishes asyncronously with publisher flow control" do
    publish_1_done = Concurrent::Event.new
    publish_2_done = Concurrent::Event.new
    publish_3_done = Concurrent::Event.new
    publisher = pubsub.publisher topic_flow_control.name, async: async_flow_control 

    publisher.publish_async("a") { publish_1_done.set }

    flow_controller = publisher.async_publisher.flow_controller
    _(flow_controller.outstanding_messages).must_equal 1

    publisher.publish_async("b") { publish_2_done.set }
    _(flow_controller.outstanding_messages).must_equal 2 # Limit

    expect do
      publisher.publish_async "c"
    end.must_raise Google::Cloud::PubSub::FlowControlLimitError

    # Force the queued messages to be published and wait for events.
    publisher.async_publisher.flush
    assert publish_1_done.wait(1), "Publishing message 1 errored."
    assert publish_2_done.wait(1), "Publishing message 2 errored."

    _(flow_controller.outstanding_messages).must_equal 0

    publisher.publish_async("c") { publish_3_done.set }

    _(flow_controller.outstanding_messages).must_equal 1

    # Force the queued message to be published and wait for event.
    publisher.async_publisher.stop!
    assert publish_3_done.wait(1), "Publishing message 3 errored."

    _(flow_controller.outstanding_messages).must_equal 0
  end
end
