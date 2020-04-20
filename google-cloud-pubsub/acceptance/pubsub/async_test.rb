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

describe Google::Cloud::PubSub, :async, :pubsub do
  def retrieve_topic topic_name
    pubsub.get_topic(topic_name) || pubsub.create_topic(topic_name)
  end

  def retrieve_subscription topic, subscription_name
    topic.get_subscription(subscription_name) ||
      topic.subscribe(subscription_name)
  end

  let(:nonce) { rand 100 }
  let(:topic) { retrieve_topic "#{$topic_prefix}-async#{nonce}" }
  let(:sub) { retrieve_subscription topic, "#{$topic_prefix}-async-sub#{nonce}" }

  it "publishes and pulls asyncronously" do
    events = sub.pull
    _(events).must_be :empty?
    # Publish a new message
    publish_result = nil
    topic.publish_async "hello" do |result|
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
    subscriber = sub.listen do |msg|
      received_message = msg
      # Acknowledge the message
      msg.ack!
    end
    subscriber.start

    subscription_retries = 0
    while received_message.nil?
      fail "published message was never received has failed" if subscription_retries >= 10
      subscription_retries += 1
      puts "received_message has not been received. sleeping for #{subscription_retries} second(s) and retrying."
      sleep subscription_retries
    end
    _(received_message).wont_be :nil?
    _(received_message.data).must_equal publish_result.data

    subscriber.stop
    subscriber.wait!

    # Remove the subscription
    sub.delete
  end

  it "publishes and pulls ordered messages" do
    topic = pubsub.create_topic "#{$topic_prefix}-omt-#{SecureRandom.hex(2)}"
    topic.enable_message_ordering!
    assert topic.message_ordering?

    sub = topic.subscribe "#{$topic_prefix}-oms-#{SecureRandom.hex(2)}", message_ordering: true
    assert sub.message_ordering?

    events = sub.pull
    _(events).must_be :empty?

    # Publish a new message
    publish_result = nil

    topic.publish_async "ordered message 0", ordering_key: "a"
    topic.publish_async "ordered message 1", ordering_key: "a"
    topic.publish_async "ordered message 2", ordering_key: "a"
    topic.publish_async "ordered message 3", ordering_key: "a"
    topic.publish_async "ordered message 4", ordering_key: "a"
    topic.publish_async "ordered message 5", ordering_key: "a" do |result|
      publish_result = result
      assert_equal "ordered message 5", result.msg.data
    end

    topic.publish_async "ordered message 6", ordering_key: "b"
    topic.publish_async "ordered message 7", ordering_key: "b"
    topic.publish_async "ordered message 8", ordering_key: "b"
    topic.publish_async "ordered message 9", ordering_key: "b" do |result|
      publish_result = result
      assert_equal "ordered message 9", result.msg.data
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

    received_message_hash = Hash.new { |hash, key| hash[key] = [] }
    subscriber = sub.listen do |msg|
      received_message_hash[msg.ordering_key].push msg.data
      # Acknowledge the message
      msg.ack!
    end
    subscriber.start

    subscription_retries = 0
    while received_message_hash.values.map(&:count).sum < 10
      fail "published message was never received has failed" if subscription_retries >= 10
      subscription_retries += 1
      puts "received_message has not been received. sleeping for #{subscription_retries} second(s) and retrying."
      sleep subscription_retries
    end

    expected_message_hash = {
      "a" => [
        "ordered message 0",
        "ordered message 1",
        "ordered message 2",
        "ordered message 3",
        "ordered message 4",
        "ordered message 5"
      ],
      "b" => [
        "ordered message 6",
        "ordered message 7",
        "ordered message 8",
        "ordered message 9"
      ]
    }
    _(received_message_hash).must_equal expected_message_hash

    subscriber.stop
    subscriber.wait!

    # Remove the subscription
    sub.delete
  end
end
