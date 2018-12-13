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

describe Google::Cloud::Pubsub::Topic, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)), pubsub.service }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded2) { message2.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded3) { message3.encode(Encoding::ASCII_8BIT) }

  it "publishes a message" do
   messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1

    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message with multibyte characters" do
   messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = topic.publish "あ"

    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.data.must_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT)
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message using an IO-ish object" do
   messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = nil
    Tempfile.open ["message", "txt"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write "あ"
      tmpfile.rewind

      msg = topic.publish tmpfile
    end
    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.data.must_equal "\xE3\x81\x82".force_encoding(Encoding::ASCII_8BIT)
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message with attributes" do
   messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1, format: :text

    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
    msg.attributes["format"].must_equal "text"
  end

  it "publishes multiple messages with a block" do
   messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2
      batch.publish message3, format: :none
    end

    mock.verify

    msgs.count.must_equal 3
    msgs.each { |msg| msg.must_be_kind_of Google::Cloud::Pubsub::Message }
    msgs.first.message_id.must_equal "msg1"
    msgs.last.message_id.must_equal "msg3"
    msgs.last.attributes["format"].must_equal "none"
  end

  describe "reference topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.from_name topic_name, pubsub.service }

    it "publishes a message" do
     messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1

      mock.verify

      msg.must_be_kind_of Google::Cloud::Pubsub::Message
      msg.message_id.must_equal "msg1"
    end

    it "publishes a message with attributes" do
     messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1, attributes: { "format" => "text" })
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1, format: :text

      mock.verify

      msg.must_be_kind_of Google::Cloud::Pubsub::Message
      msg.message_id.must_equal "msg1"
      msg.attributes["format"].must_equal "text"
    end

    it "publishes multiple messages with a block" do
     messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1),
        Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded2),
        Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      topic.service.mocked_publisher = mock

      msgs = topic.publish do |batch|
        batch.publish message1
        batch.publish message2
        batch.publish message3, format: :none
      end

      mock.verify

      msgs.count.must_equal 3
      msgs.each { |msg| msg.must_be_kind_of Google::Cloud::Pubsub::Message }
      msgs.first.message_id.must_equal "msg1"
      msgs.last.message_id.must_equal "msg3"
      msgs.last.attributes["format"].must_equal "none"
    end
  end

  describe "reference topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.from_name topic_name, pubsub.service }

    it "publishes a message" do
      stub = Object.new
      def stub.publish *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1
      end.must_raise Google::Cloud::NotFoundError
    end

    it "publishes a message with attributes" do
      stub = Object.new
      def stub.publish *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1, format: :text
      end.must_raise Google::Cloud::NotFoundError
    end

    it "publishes multiple messages with a block" do
      stub = Object.new
      def stub.publish *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
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
