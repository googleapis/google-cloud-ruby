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

describe Google::Cloud::PubSub::Publisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name, labels: labels)), pubsub.service }

  it "knows its name" do
    _(publisher.name).must_equal topic_path(topic_name)
  end

  it "can publish a message" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request, actual_option|
      actual_request == expected_request && actual_option.nil?
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish message

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "can publish a message with compression" do
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "d"*238)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    mock.expect :publish, publish_res do |actual_request, actual_option|
      actual_request == expected_request && actual_option == expected_option
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish "d"*238, compress: true

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "can publish a message with compression_bytes_threshold " do
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: "d"*138)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    mock.expect :publish, publish_res do |actual_request, actual_option|
      actual_request == expected_request && actual_option == expected_option
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish "d"*138, compress: true, compression_bytes_threshold: 140

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "can publish a message with attributes" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg, attributes: { "format" => "text" })
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request|
      actual_request == expected_request
    end
    publisher.service.mocked_topic_admin = mock

    msg = publisher.publish message, format: :text

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
    _(msg.attributes["format"]).must_equal "text"
  end

  it "can publish multiple messages with a block" do
    message1 = "first-new-message"
    message2 = "second-new-message"
    encoded_msg1 = message1.encode(Encoding::ASCII_8BIT)
    encoded_msg2 = message2.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg1),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg2, attributes: { "format" => "none" })
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1", "msg2"] })
    mock = Minitest::Mock.new
    expected_request = {topic: topic_path(topic_name), messages: messages}
    mock.expect :publish, publish_res do |actual_request|
      actual_request == expected_request
    end
    publisher.service.mocked_topic_admin = mock

    msgs = publisher.publish do |batch|
      batch.publish message1
      batch.publish message2, format: :none
    end

    mock.verify

    _(msgs.count).must_equal 2
    _(msgs.first).must_be_kind_of Google::Cloud::PubSub::Message
    _(msgs.first.message_id).must_equal "msg1"
    _(msgs.last).must_be_kind_of Google::Cloud::PubSub::Message
    _(msgs.last.message_id).must_equal "msg2"
    _(msgs.last.attributes["format"]).must_equal "none"
  end
end
