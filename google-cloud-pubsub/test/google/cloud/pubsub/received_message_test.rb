 # Copyright 2015 Google LLC
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

describe Google::Cloud::Pubsub::ReceivedMessage, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Pubsub::V1::Subscription.decode_json(subscription_json(topic_name, subscription_name)) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc subscription_grpc, pubsub.service }
  let(:rec_message_name) { "rec_message-name-goes-here" }
  let(:rec_message_msg)  { "rec_message-msg-goes-here" }
  let(:rec_message_json_full)  { rec_message_json(rec_message_msg) }
  let(:rec_message_data)  { JSON.parse rec_message_json_full }
  let(:rec_message_grpc)  { Google::Pubsub::V1::ReceivedMessage.decode_json rec_message_json_full }
  let(:rec_message) { Google::Cloud::Pubsub::ReceivedMessage.from_grpc rec_message_grpc, subscription }

  it "knows its subscription" do
    rec_message.subscription.wont_be :nil?
    rec_message.subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its ack_id" do
    rec_message.ack_id.must_equal rec_message_data["ack_id"]
  end

  it "has a message" do
    rec_message.message.wont_be :nil?
    rec_message.message.data.must_equal rec_message_msg
    rec_message.message.attributes.keys.sort.must_equal   rec_message_data["message"]["attributes"].keys.sort
    rec_message.message.attributes.values.sort.must_equal rec_message_data["message"]["attributes"].values.sort
    rec_message.message.msg_id.must_equal rec_message_data["message"]["message_id"]
    rec_message.message.message_id.must_equal rec_message_data["message"]["message_id"]
  end

  it "knows the message's data" do
    rec_message.data.must_equal rec_message.message.data
  end

  it "knows the message's attributes" do
    rec_message.attributes.must_equal rec_message.message.attributes
  end

  it "knows the message's message_id" do
    rec_message.msg_id.must_equal     rec_message.message.msg_id
    rec_message.message_id.must_equal rec_message.message.message_id
  end

  it "knows its published_at" do
    rec_message.published_at.must_be :nil?
    rec_message.publish_time.must_be :nil?

    publish_time = Time.now
    rec_message_grpc.message.publish_time = Google::Cloud::Pubsub::Convert.time_to_timestamp publish_time

    rec_message.published_at.must_equal publish_time
    rec_message.publish_time.must_equal publish_time
  end

  it "can acknowledge" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), [rec_message.ack_id], options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.acknowledge!

    mock.verify
  end

  it "can ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), [rec_message.ack_id], options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.ack!

    mock.verify
  end

  it "can delay" do
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription_path(subscription_name), [rec_message.ack_id], new_deadline, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.delay! new_deadline

    mock.verify
  end

  it "can reject" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription_path(subscription_name), [rec_message.ack_id], 0, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.reject!

    mock.verify
  end

  it "can nack" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription_path(subscription_name), [rec_message.ack_id], 0, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.nack!

    mock.verify
  end

  it "can ignore" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription_path(subscription_name), [rec_message.ack_id], 0, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_message.ignore!

    mock.verify
  end
end
