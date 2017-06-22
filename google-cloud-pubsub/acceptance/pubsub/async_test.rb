# Copyright 2017 Google Inc. All rights reserved.
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

require "pubsub_helper"

describe Google::Cloud::Pubsub, :async, :pubsub do
  def retrieve_topic topic_name
    pubsub.get_topic(topic_name) || pubsub.create_topic(topic_name)
  end

  def retrieve_subscription topic, subscription_name
    topic.get_subscription(subscription_name) ||
      topic.subscribe(subscription_name)
  end

  let(:topic) { retrieve_topic "#{$topic_prefix}-async" }
  let(:sub) { retrieve_subscription topic, "#{$topic_prefix}-async-sub" }

  it "publishes and pulls asyncronously (topic)" do
    events = sub.pull
    events.must_be :empty?
    # Publish a new message
    unpublished = true
    publish_result = nil
    topic.publish_async "hello" do |result|
      publish_result = result
      unpublished = false
      assert_equal "hello", result.msg.data
    end
    unpublished_retries = 0
    while unpublished
      fail "publish has failed" if unpublished_retries >= 5
      unpublished_retries += 1
      puts "the async publish has not completed yet. sleeping for #{unpublished_retries*unpublished_retries} second(s) and retrying."
      sleep unpublished_retries*unpublished_retries
    end
    publish_result.must_be :succeeded?
    # Check it received the published message
    events = pull_with_retry sub
    events.wont_be :empty?
    events.count.must_equal 1
    event = events.first
    event.wont_be :nil?
    event.msg.data.must_equal publish_result.data
    # Acknowledge the message
    sub.ack event.ack_id
    # Remove the subscription
    sub.delete
  end

  it "publishes and pulls asyncronously (project)" do
    events = sub.pull
    events.must_be :empty?
    # Publish a new message
    unpublished = true
    publish_result = nil
    pubsub.publish_async topic.name, "hello" do |result|
      publish_result = result
      unpublished = false
      assert_equal "hello", result.msg.data
    end
    unpublished_retries = 0
    while unpublished
      fail "publish has failed" if unpublished_retries >= 5
      unpublished_retries += 1
      puts "the async publish has not completed yet. sleeping for #{unpublished_retries*unpublished_retries} second(s) and retrying."
      sleep unpublished_retries*unpublished_retries
    end
    publish_result.must_be :succeeded?
    # Check it received the published message
    events = pull_with_retry sub
    events.wont_be :empty?
    events.count.must_equal 1
    event = events.first
    event.wont_be :nil?
    event.msg.data.must_equal publish_result.data
    # Acknowledge the message
    sub.ack event.ack_id
    # Remove the subscription
    sub.delete
  end

  def pull_with_retry sub
    events = []
    retries = 0
    while retries <= 5 do
      events = sub.pull
      break if events.any?
      retries += 1
      puts "the subscription does not have the message yet. sleeping for #{retries*retries} second(s) and retrying."
      sleep retries*retries
    end
    events
  end
end
