# Copyright 2019 Google LLC
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

require "helper"

describe Google::Cloud::PubSub::AsyncPublisher::Batch do
  let(:topic_name) { "topic-name-goes-here" }

  def pubsub_message data, attributes, ordering_key
    data = String(data).dup.force_encoding(Encoding::ASCII_8BIT).freeze
    attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]
    ordering_key = String(ordering_key).freeze

    Google::Cloud::PubSub::V1::PubsubMessage.new(
      data:         data,
      attributes:   attributes,
      ordering_key: ordering_key
    )
  end

  it "adds messsages and indicates batch status using message count" do
    fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
    ordering_key = ""
    batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

    msg = pubsub_message "hello world", {}, ""

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?

    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)

    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?

    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)

    assert_equal true, batch.publishing?
    assert_equal false, batch.stopping?
    assert_equal false, batch.publish!(stop: true)
    assert_equal true, batch.publishing?
    assert_equal true, batch.stopping?

    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 8, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?
  end

  it "adds messsages and indicates batch status using message size" do
    fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 1000, max_bytes: 175
    ordering_key = ""
    batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

    msg = pubsub_message "hello world", {}, ""

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?

    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)

    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    assert_equal false, batch.publishing?
    assert_equal true, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?

    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)
    assert_equal :queued, batch.add(msg.dup, nil)

    assert_equal true, batch.publishing?
    assert_equal false, batch.stopping?
    assert_equal false, batch.publish!(stop: true)
    assert_equal true, batch.publishing?
    assert_equal true, batch.stopping?

    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 10, batch.rebalance!.count
    assert_equal true, batch.reset!
    assert_equal true, batch.publishing?
    assert_equal false, batch.publish!
    assert_equal true, batch.publishing?
    assert_equal 8, batch.rebalance!.count
    assert_equal false, batch.reset!
    assert_equal false, batch.publishing?
  end

  it "raises when adding to a stopped batch" do
    fake_publisher = OpenStruct.new topic_name: topic_name
    ordering_key = ""
    batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

    msg = pubsub_message "hello world", {}, ""

    assert_equal false, batch.stopping?
    assert_equal false, batch.publish!(stop: true)
    assert_equal true, batch.stopping?

    assert_raises Google::Cloud::PubSub::AsyncPublisherStopped do
      batch.add(msg.dup, nil)
    end
  end

  it "returns all messages, even queued one, when canceling" do
    fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
    ordering_key = ""
    batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

    msg = pubsub_message "hello world", {}, ""

    refute batch.canceled?

    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :added, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)
    assert_equal :full, batch.add(msg.dup, nil)

    canceled_items = batch.cancel!

    assert batch.canceled?

    _(canceled_items.count).must_equal 15
  end

  describe :empty? do
    it "knows when it is and isn't empty" do
      fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
      ordering_key = ""
      batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

      msg = pubsub_message "hello world", {}, ""

      assert_equal true, batch.empty?
      batch.add(msg.dup, nil)
      assert_equal false, batch.empty?
    end

    it "is not empty when publishing" do
      fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
      ordering_key = "abc123"
      batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

      msg = pubsub_message "hello world", {}, "abc123"

      assert_equal false, batch.publishing?
      assert_equal true, batch.empty?
      batch.add(msg.dup, nil)
      batch.publish!
      assert_equal true, batch.publishing?
      assert_equal false, batch.empty?
    end

    it "is not empty when stopping" do
      fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
      ordering_key = ""
      batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

      msg = pubsub_message "hello world", {}, ""

      assert_equal false, batch.stopping?
      assert_equal true, batch.empty?
      batch.publish!(stop: true)
      assert_equal true, batch.stopping?
      assert_equal false, batch.empty?
    end

    it "is not empty when canceled" do
      fake_publisher = OpenStruct.new topic_name: topic_name, max_messages: 10, max_bytes: 10000
      ordering_key = ""
      batch = Google::Cloud::PubSub::AsyncPublisher::Batch.new fake_publisher, ordering_key

      msg = pubsub_message "hello world", {}, ""

      assert_equal false, batch.canceled?
      assert_equal true, batch.empty?
      batch.cancel!
      assert_equal true, batch.canceled?
      assert_equal false, batch.empty?
    end
  end
end
