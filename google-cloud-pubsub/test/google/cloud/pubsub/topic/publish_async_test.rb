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

describe Google::Cloud::Pubsub::Topic, :publish_async, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                       pubsub.service }

  it "publishes a message" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    topic.async_publisher.must_be :nil?

    topic.publish_async "async-message"

    topic.async_publisher.wont_be :nil?

    topic.async_publisher.batch.messages.must_equal messages
    topic.async_publisher.batch.callbacks.count.must_equal 1
    topic.async_publisher.batch.callbacks.must_equal [nil]

    topic.async_publisher.must_be :started?
    topic.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop.wait!

    topic.async_publisher.wont_be :started?
    topic.async_publisher.must_be :stopped?

    topic.async_publisher.batch.must_be :nil?

    mock.verify
  end

  it "publishes a message with a callback" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    topic.async_publisher.must_be :nil?

    callback_called = false

    topic.publish_async "async-message" do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      callback_called = true
    end

    topic.async_publisher.wont_be :nil?

    topic.async_publisher.batch.messages.must_equal messages
    topic.async_publisher.batch.callbacks.count.must_equal 1
    topic.async_publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    topic.async_publisher.must_be :started?
    topic.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop.wait!

    topic.async_publisher.wont_be :started?
    topic.async_publisher.must_be :stopped?

    topic.async_publisher.batch.must_be :nil?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message with multibyte characters" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    topic.async_publisher.must_be :nil?

    callback_called = false

    topic.publish_async "あ" do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      assert_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), result.data
      callback_called = true
    end

    topic.async_publisher.wont_be :nil?

    topic.async_publisher.batch.messages.must_equal messages
    topic.async_publisher.batch.callbacks.count.must_equal 1
    topic.async_publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    topic.async_publisher.must_be :started?
    topic.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop.wait!

    topic.async_publisher.wont_be :started?
    topic.async_publisher.must_be :stopped?

    topic.async_publisher.batch.must_be :nil?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message using an IO-ish object" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    topic.async_publisher.must_be :nil?

    callback_called = false

    Tempfile.open ["message", "txt"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write "あ"
      tmpfile.rewind

      topic.publish_async tmpfile do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg1", result.msg_id
        assert_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT), result.data
        callback_called = true
      end
    end

    topic.async_publisher.wont_be :nil?

    topic.async_publisher.batch.messages.must_equal messages
    topic.async_publisher.batch.callbacks.count.must_equal 1
    topic.async_publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    topic.async_publisher.must_be :started?
    topic.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop.wait!

    topic.async_publisher.wont_be :started?
    topic.async_publisher.must_be :stopped?

    topic.async_publisher.batch.must_be :nil?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message with attributes" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT), attributes: {"format" => "text"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    topic.async_publisher.must_be :nil?

    callback_called = false

    topic.publish_async "async-message", format: :text do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      assert_equal "async-message".force_encoding(Encoding::ASCII_8BIT), result.data
      assert_equal "text", result.attributes["format"]
      callback_called = true
    end

    topic.async_publisher.wont_be :nil?

    topic.async_publisher.batch.messages.must_equal messages
    topic.async_publisher.batch.callbacks.count.must_equal 1
    topic.async_publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    topic.async_publisher.must_be :started?
    topic.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop.wait!

    topic.async_publisher.wont_be :started?
    topic.async_publisher.must_be :stopped?

    topic.async_publisher.batch.must_be :nil?
    callback_called.must_equal true

    mock.verify
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "publishes a message" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      topic.service.mocked_publisher = mock

      topic.async_publisher.must_be :nil?

      topic.publish_async "async-message"

      topic.async_publisher.wont_be :nil?

      topic.async_publisher.batch.messages.must_equal messages
      topic.async_publisher.batch.callbacks.count.must_equal 1
      topic.async_publisher.batch.callbacks.must_equal [nil]

      topic.async_publisher.must_be :started?
      topic.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      topic.async_publisher.stop.wait!

      topic.async_publisher.wont_be :started?
      topic.async_publisher.must_be :stopped?

      topic.async_publisher.batch.must_be :nil?

      mock.verify
    end

    it "publishes a message with attributes" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT), attributes: { "format" => "text" })
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      topic.service.mocked_publisher = mock

      topic.async_publisher.must_be :nil?

      callback_called = false

      topic.publish_async "async-message", format: :text do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg1", result.msg_id
        assert_equal "async-message".force_encoding(Encoding::ASCII_8BIT), result.data
        assert_equal "text", result.attributes["format"]
        callback_called = true
      end

      topic.async_publisher.wont_be :nil?

      topic.async_publisher.batch.messages.must_equal messages
      topic.async_publisher.batch.callbacks.count.must_equal 1
      topic.async_publisher.batch.callbacks.each do |block|
        block.must_be_kind_of Proc
      end

      topic.async_publisher.must_be :started?
      topic.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      topic.async_publisher.stop.wait!

      topic.async_publisher.wont_be :started?
      topic.async_publisher.must_be :stopped?

      topic.async_publisher.batch.must_be :nil?
      callback_called.must_equal true

      mock.verify
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }
    let(:gax_error) do
      Google::Gax::GaxError.new("not found").tap do |e|
        e.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      end
    end

    it "publishes a message" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode(Encoding::ASCII_8BIT))
      ]

      stub = Object.new
      def stub.publish *args
        err = Google::Gax::GaxError.new("not found").tap do |e|
          e.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        end
        raise err
      end
      pubsub.service.mocked_publisher = stub

      topic.async_publisher.must_be :nil?

      callback_called = false

      topic.publish_async "async-message" do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        refute result.succeeded?
        assert result.failed?
        assert_equal "async-message".force_encoding(Encoding::ASCII_8BIT), result.data
        assert_kind_of Google::Cloud::NotFoundError, result.error
        callback_called = true
      end

      topic.async_publisher.wont_be :nil?

      topic.async_publisher.batch.messages.must_equal messages
      topic.async_publisher.batch.callbacks.count.must_equal 1
      topic.async_publisher.batch.callbacks.each do |block|
        block.must_be_kind_of Proc
      end

      topic.async_publisher.must_be :started?
      topic.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      topic.async_publisher.stop.wait!

      topic.async_publisher.wont_be :started?
      topic.async_publisher.must_be :stopped?

      topic.async_publisher.batch.must_be :nil?
      callback_called.must_equal true
    end
  end
end
