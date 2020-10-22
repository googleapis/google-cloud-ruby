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

require "helper"

Thread.abort_on_exception = true

describe Google::Cloud::PubSub::AsyncPublisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic_name2) { "differnt-topic-name" }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded2) { message2.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded3) { message3.encode(Encoding::ASCII_8BIT) }

  it "knows its defaults" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
    _(publisher.max_bytes).must_equal 1_000_000
    _(publisher.max_messages).must_equal 100
    _(publisher.interval).must_equal 0.01
    _(publisher.publish_threads).must_equal 2
    _(publisher.callback_threads).must_equal 4
  end

  it "knows its given attributes" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new(
      topic_name,
      pubsub.service,
      max_bytes: 2_000_000,
      max_messages: 200,
      interval: 0.02,
      threads: {
        publish: 3,
        callback: 5
      }
    )

    _(publisher.max_bytes).must_equal 2_000_000
    _(publisher.max_messages).must_equal 200
    _(publisher.interval).must_equal 0.02
    _(publisher.publish_threads).must_equal 3
    _(publisher.callback_threads).must_equal 5
  end

  it "knows given attributes and retains its defaults" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new(
      topic_name,
      pubsub.service,
      max_bytes: 2_000_000,
      threads: {
        publish: 3
      }
    )

    _(publisher.max_bytes).must_equal 2_000_000
    _(publisher.max_messages).must_equal 100
    _(publisher.interval).must_equal 0.01
    _(publisher.publish_threads).must_equal 3
    _(publisher.callback_threads).must_equal 4
  end

  it "publishes a message" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1)
    ]

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes a message with attributes" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"})
    ]

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1, format: :text

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes a message with a callback" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_called = false

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_called = true
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  it "publishes multiple messages" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1
    publisher.publish message2
    publisher.publish message3, format: :none

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes multiple messages with callbacks" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0"),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2, message_id: "msg1"),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"}, message_id: "msg2")
    ]
    callback_count = 0

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message2 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message3, format: :none do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_count).must_equal 3
  end

  it "publishes multiple batches when message count limit is reached" do
    # break messages up into batches of 10
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_messages: 10, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_count = 0

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    30.times do |count|
      publisher.publish message1 do |msg|
        callback_count += 1
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = Array.new(3) do
      Array.new(10) do |count|
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg#{count}")
      end
    end

    assert_equal expected_messages, publisher.service.mocked_publisher.messages
    _(callback_count).must_equal 30
  end

  it "publishes multiple batches when message size limit is reached" do
    # 250 is slightly bigger than 10 messages, and less than 11.
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 250, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_count = 0

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    30.times do
      publisher.publish message1 do |msg|
        callback_count += 1
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = Array.new(3) do
      Array.new(10) do |count|
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg#{count}")
      end
    end

    assert_equal expected_messages.map(&:count), publisher.service.mocked_publisher.messages.map(&:count)
    assert_equal expected_messages, publisher.service.mocked_publisher.messages
    _(callback_count).must_equal 30
  end

  it "publishes when message size is greater than the limit" do
    skip "this test is problematic on CI"
    # second message will force a separate batch
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 100
    big_msg_data = SecureRandom.random_bytes 120
    callback_count = 0

    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.publish message1 do |msg|
      callback_count += 1
    end
    publisher.publish big_msg_data do |msg|
      callback_count += 1
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = [
      [Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")],
      [Google::Cloud::PubSub::V1::PubsubMessage.new(data: big_msg_data, message_id: "msg1")]
    ]
    assert_equal publisher.service.mocked_publisher.messages, expected_messages
    _(callback_count).must_equal 2
  end

  def wait_until delay: 0.01, max: 10, output: nil, msg: "criteria not met", &block
    attempts = 0
    while !block.call
      fail msg if attempts >= max
      attempts += 1
      puts "Retrying #{attempts} out of #{max}." if output
      sleep delay
    end
  end
end
