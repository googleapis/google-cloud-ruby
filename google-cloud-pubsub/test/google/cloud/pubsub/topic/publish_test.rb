# Copyright 2015 Google LLC
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

describe Google::Cloud::PubSub::Topic, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded2) { message2.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded3) { message3.encode(Encoding::ASCII_8BIT) }

  it "publishes a message" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "publishes a message with multibyte characters" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = topic.publish "あ"

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.data).must_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT)
    _(msg.message_id).must_equal "msg1"
  end

  it "publishes a message using an IO-ish object" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = nil
    Tempfile.open ["message", "txt"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write "あ"
      tmpfile.rewind

      msg = topic.publish tmpfile
    end
    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.data).must_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT)
    _(msg.message_id).must_equal "msg1"
  end

  it "publishes a message with attributes" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"})
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1, format: :text

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
    _(msg.attributes["format"]).must_equal "text"
  end

  it "publishes multiple messages with a block" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1", "msg2", "msg3"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2
      batch.publish message3, format: :none
    end

    mock.verify

    _(msgs.count).must_equal 3
    msgs.each { |msg| _(msg).must_be_kind_of Google::Cloud::PubSub::Message }
    _(msgs.first.message_id).must_equal "msg1"
    _(msgs.last.message_id).must_equal "msg3"
    _(msgs.last.attributes["format"]).must_equal "none"
  end

  describe "reference topic that exists" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "publishes a message" do
     messages = [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1)
      ]
      publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1

      mock.verify

      _(msg).must_be_kind_of Google::Cloud::PubSub::Message
      _(msg.message_id).must_equal "msg1"
    end

    it "publishes a message with attributes" do
     messages = [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, attributes: { "format" => "text" })
      ]
      publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1, format: :text

      mock.verify

      _(msg).must_be_kind_of Google::Cloud::PubSub::Message
      _(msg.message_id).must_equal "msg1"
      _(msg.attributes["format"]).must_equal "text"
    end

    it "publishes multiple messages with a block" do
     messages = [
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1),
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2),
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
      ]
      publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1", "msg2", "msg3"] })
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
      topic.service.mocked_publisher = mock

      msgs = topic.publish do |batch|
        batch.publish message1
        batch.publish message2
        batch.publish message3, format: :none
      end

      mock.verify

      _(msgs.count).must_equal 3
      msgs.each { |msg| _(msg).must_be_kind_of Google::Cloud::PubSub::Message }
      _(msgs.first.message_id).must_equal "msg1"
      _(msgs.last.message_id).must_equal "msg3"
      _(msgs.last.attributes["format"]).must_equal "none"
    end
  end

  describe "reference topic that does not exist" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "publishes a message" do
      stub = Object.new
      def stub.publish *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1
      end.must_raise Google::Cloud::NotFoundError
    end

    it "publishes a message with attributes" do
      stub = Object.new
      def stub.publish *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1, format: :text
      end.must_raise Google::Cloud::NotFoundError
    end

    it "publishes multiple messages with a block" do
      stub = Object.new
      def stub.publish *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish do |batch|
          batch.publish message1
          batch.publish message2
          batch.publish message3, format: :none
        end
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
