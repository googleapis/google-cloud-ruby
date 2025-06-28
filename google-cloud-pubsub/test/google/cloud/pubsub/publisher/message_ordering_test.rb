# Copyright 2021 Google LLC
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

describe Google::Cloud::PubSub::Publisher, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded2) { message2.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded3) { message3.encode(Encoding::ASCII_8BIT) }
  let(:ordering_key) { "my-ordering-key" }

  it "publishes a message with ordering_key" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, ordering_key: ordering_key)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request|
      actual_request == expected_request
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish message1, ordering_key: ordering_key

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "publishes a message with attributes and ordering_key" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"}, ordering_key: ordering_key)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request|
      actual_request == expected_request
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish message1, format: :text, ordering_key: ordering_key

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
    _(msg.attributes["format"]).must_equal "text"
  end

  it "publishes multiple messages with ordering_key with a block" do
   messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, ordering_key: ordering_key),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2, ordering_key: ordering_key),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"}, ordering_key: ordering_key)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1", "msg2", "msg3"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request|
      actual_request == expected_request
    end
    publisher.service.mocked_topic_admin = mock

    msgs = publisher.publish do |batch|
      batch.publish message1, ordering_key: ordering_key
      batch.publish message2, ordering_key: ordering_key
      batch.publish message3, ordering_key: ordering_key, format: :none
    end

    mock.verify

    _(msgs.count).must_equal 3
    msgs.each { |msg| _(msg).must_be_kind_of Google::Cloud::PubSub::Message }
    _(msgs.first.message_id).must_equal "msg1"
    _(msgs.last.message_id).must_equal "msg3"
    _(msgs.last.attributes["format"]).must_equal "none"
  end
end
