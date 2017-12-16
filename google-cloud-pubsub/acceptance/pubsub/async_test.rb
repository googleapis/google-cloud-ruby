# Copyright 2017 Google LLC
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

  let(:nonce) { rand 100 }
  let(:topic) { retrieve_topic "#{$topic_prefix}-async#{nonce}" }
  let(:sub) { retrieve_subscription topic, "#{$topic_prefix}-async-sub#{nonce}" }

  it "publishes and pulls asyncronously" do
    events = sub.pull
    events.must_be :empty?
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
    publish_result.wont_be :nil?
    publish_result.must_be :succeeded?

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
    received_message.wont_be :nil?
    received_message.data.must_equal publish_result.data

    subscriber.stop
    subscriber.wait!

    # Remove the subscription
    sub.delete
  end
end
