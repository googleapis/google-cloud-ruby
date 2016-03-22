# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"

describe Gcloud::Pubsub::Topic, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_packed1) { [message1].pack("m").encode("ASCII-8BIT") }
  let(:msg_packed2) { [message2].pack("m").encode("ASCII-8BIT") }
  let(:msg_packed3) { [message3].pack("m").encode("ASCII-8BIT") }

  it "publishes a message" do
    publish_req = Google::Pubsub::V1::PublishRequest.new(
      topic: topic_path(topic_name),
      messages: [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1)
      ]
    )
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [publish_req]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1

    mock.verify

    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message with attributes" do
    publish_req = Google::Pubsub::V1::PublishRequest.new(
      topic: topic_path(topic_name),
      messages: [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1, attributes: {"format" => "text"})
      ]
    )
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [publish_req]
    topic.service.mocked_publisher = mock

    msg = topic.publish message1, format: :text

    mock.verify

    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
    msg.attributes["format"].must_equal "text"
  end

  it "publishes multiple messages with a block" do
    publish_req = Google::Pubsub::V1::PublishRequest.new(
      topic: topic_path(topic_name),
      messages: [
        Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1),
        Google::Pubsub::V1::PubsubMessage.new(data: msg_packed2),
        Google::Pubsub::V1::PubsubMessage.new(data: msg_packed3, attributes: {"format" => "none"})
      ]
    )
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [publish_req]
    topic.service.mocked_publisher = mock

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2
      batch.publish message3, format: :none
    end

    mock.verify

    msgs.count.must_equal 3
    msgs.each { |msg| msg.must_be_kind_of Gcloud::Pubsub::Message }
    msgs.first.message_id.must_equal "msg1"
    msgs.last.message_id.must_equal "msg3"
    msgs.last.attributes["format"].must_equal "none"
  end

  describe "lazy topic that exists" do
    let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "publishes a message" do
      publish_req = Google::Pubsub::V1::PublishRequest.new(
        topic: topic_path(topic_name),
        messages: [
          Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1)
        ]
      )
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [publish_req]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1

      mock.verify

      msg.must_be_kind_of Gcloud::Pubsub::Message
      msg.message_id.must_equal "msg1"
    end

    it "publishes a message with attributes" do
      publish_req = Google::Pubsub::V1::PublishRequest.new(
        topic: topic_path(topic_name),
        messages: [
          Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1, attributes: { "format" => "text" })
        ]
      )
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [publish_req]
      topic.service.mocked_publisher = mock

      msg = topic.publish message1, format: :text

      mock.verify

      msg.must_be_kind_of Gcloud::Pubsub::Message
      msg.message_id.must_equal "msg1"
      msg.attributes["format"].must_equal "text"
    end

    it "publishes multiple messages with a block" do
      publish_req = Google::Pubsub::V1::PublishRequest.new(
        topic: topic_path(topic_name),
        messages: [
          Google::Pubsub::V1::PubsubMessage.new(data: msg_packed1),
          Google::Pubsub::V1::PubsubMessage.new(data: msg_packed2),
          Google::Pubsub::V1::PubsubMessage.new(data: msg_packed3, attributes: {"format" => "none"})
        ]
      )
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [publish_req]
      topic.service.mocked_publisher = mock

      msgs = topic.publish do |batch|
        batch.publish message1
        batch.publish message2
        batch.publish message3, format: :none
      end

      mock.verify

      msgs.count.must_equal 3
      msgs.each { |msg| msg.must_be_kind_of Gcloud::Pubsub::Message }
      msgs.first.message_id.must_equal "msg1"
      msgs.last.message_id.must_equal "msg3"
      msgs.last.attributes["format"].must_equal "none"
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "publishes a message" do
      stub = Object.new
      def stub.publish *args
        raise GRPC::BadStatus.new(5, "not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1
      end.must_raise Gcloud::NotFoundError
    end

    it "publishes a message with attributes" do
      stub = Object.new
      def stub.publish *args
        raise GRPC::BadStatus.new(5, "not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish message1, format: :text
      end.must_raise Gcloud::NotFoundError
    end

    it "publishes multiple messages with a block" do
      stub = Object.new
      def stub.publish *args
        raise GRPC::BadStatus.new(5, "not found")
      end
      pubsub.service.mocked_publisher = stub

      expect do
        topic.publish do |batch|
          batch.publish message1
          batch.publish message2
          batch.publish message3, format: :none
        end
      end.must_raise Gcloud::NotFoundError
    end
  end
end
