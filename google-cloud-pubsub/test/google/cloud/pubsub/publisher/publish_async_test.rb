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

describe Google::Cloud::PubSub::Publisher, :publish_async, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }

  it "publishes a message" do
    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    publisher.publish_async "async-message"

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    expected_messages_hash = {
      "" => [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
      ]
    }
    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes a message with a callback" do
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT), message_id: "msg0")
    ]
    callback_called = false

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    publisher.publish_async "async-message" do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg0", result.msg_id
      callback_called = true
    end

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  it "publishes multiple messages with callbacks" do
    mutex = Mutex.new
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message 0".encode(Encoding::ASCII_8BIT), message_id: "msg0"),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message 1".encode(Encoding::ASCII_8BIT), message_id: "msg1")
    ]
    callbacks_called = 0

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    publisher.publish_async "async-message 0" do |result|
      assert_equal "msg0", result.msg_id
      mutex.synchronize { callbacks_called += 1 }
    end

    publisher.publish_async "async-message 1" do |result|
      assert_equal "msg1", result.msg_id
      mutex.synchronize { callbacks_called += 1 }
    end

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callbacks_called).must_equal 2
  end

  it "publishes a message with multibyte characters" do
    callback_called = false

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    publisher.publish_async "あ" do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg0", result.msg_id
      assert_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), result.data
      callback_called = true
    end

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    expected_messages_hash = {
      "" => [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), message_id: "msg0")
      ]
    }
    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  it "publishes a message using an IO-ish object" do
    callback_called = false

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    Tempfile.open ["message", "txt"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write "あ"
      tmpfile.rewind

      publisher.publish_async tmpfile do |result|
        assert_kind_of Google::Cloud::PubSub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg0", result.msg_id
        assert_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), result.data
        callback_called = true
      end
    end

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    expected_messages_hash = {
      "" => [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), message_id: "msg0")
      ]
    }
    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  it "publishes a message with attributes" do
    callback_called = false

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.async_publisher).must_be :nil?

    publisher.publish_async "async-message", format: :text do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg0", result.msg_id
      assert_equal "async-message".force_encoding(Encoding::ASCII_8BIT), result.data
      assert_equal "text", result.attributes["format"]
      callback_called = true
    end

    _(publisher.async_publisher).wont_be :nil?

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    expected_messages_hash = {
      "" => [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT), attributes: {"format" => "text"}, message_id: "msg0")
      ]
    }
    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  describe "reference topic that exists" do
    let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), 
                                                 pubsub.service }

    it "publishes a message" do
      publisher.service.mocked_topic_admin = AsyncPublisherStub.new

      _(publisher.async_publisher).must_be :nil?

      publisher.publish_async "async-message"

      _(publisher.async_publisher).wont_be :nil?

      _(publisher.async_publisher).must_be :started?
      _(publisher.async_publisher).wont_be :stopped?

      # force the queued messages to be published
      publisher.async_publisher.stop!

      _(publisher.async_publisher).wont_be :started?
      _(publisher.async_publisher).must_be :stopped?

      expected_messages_hash = {
        "" => [
          Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
        ]
      }
      published_messages_hash = publisher.service.mocked_topic_admin.message_hash
      assert_equal expected_messages_hash, published_messages_hash
    end

    it "publishes a message with attributes" do
      callback_called = false

      publisher.service.mocked_topic_admin = AsyncPublisherStub.new

      _(publisher.async_publisher).must_be :nil?

      publisher.publish_async "async-message", format: :text do |result|
        assert_kind_of Google::Cloud::PubSub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg0", result.msg_id
        assert_equal "async-message".force_encoding(Encoding::ASCII_8BIT), result.data
        assert_equal "text", result.attributes["format"]
        callback_called = true
      end

      _(publisher.async_publisher).wont_be :nil?

      _(publisher.async_publisher).must_be :started?
      _(publisher.async_publisher).wont_be :stopped?

      # force the queued messages to be published
      publisher.async_publisher.stop!

      _(publisher.async_publisher).wont_be :started?
      _(publisher.async_publisher).must_be :stopped?

      expected_messages_hash = {
        "" => [
          Google::Cloud::PubSub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT), attributes: { "format" => "text" }, message_id: "msg0")
        ]
      }
      published_messages_hash = publisher.service.mocked_topic_admin.message_hash
      assert_equal expected_messages_hash, published_messages_hash
      _(callback_called).must_equal true
    end
  end
end
