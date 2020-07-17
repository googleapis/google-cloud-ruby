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

describe Google::Cloud::PubSub::ReceivedMessage, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Cloud::PubSub::V1::Subscription.new(subscription_hash(topic_name, subscription_name)) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc subscription_grpc, pubsub.service }
  let(:rec_message_name) { "rec_message-name-goes-here" }
  let(:rec_message_msg)  { "rec_message-msg-goes-here" }
  let(:rec_message_data)  { rec_message_hash(rec_message_msg) }
  let(:rec_message_grpc)  { Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_data }
  let(:rec_message) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_message_grpc, subscription }

  it "knows its subscription" do
    _(rec_message.subscription).wont_be :nil?
    _(rec_message.subscription.name).must_equal subscription_path(subscription_name)
  end

  it "knows its ack_id" do
    _(rec_message.ack_id).must_equal rec_message_data[:ack_id]
  end

  it "has a message" do
    _(rec_message.message).wont_be :nil?
    _(rec_message.message.data).must_equal rec_message_msg
    _(rec_message.message.attributes.keys.sort).must_equal   rec_message_data[:message][:attributes].keys.sort
    _(rec_message.message.attributes.values.sort).must_equal rec_message_data[:message][:attributes].values.sort
    _(rec_message.message.msg_id).must_equal rec_message_data[:message][:message_id]
    _(rec_message.message.message_id).must_equal rec_message_data[:message][:message_id]
  end

  it "knows the message's data" do
    _(rec_message.data).must_equal rec_message.message.data
  end

  it "knows the message's attributes" do
    _(rec_message.attributes).must_equal rec_message.message.attributes
  end

  it "knows the message's message_id" do
    _(rec_message.msg_id).must_equal     rec_message.message.msg_id
    _(rec_message.message_id).must_equal rec_message.message.message_id
  end

  it "knows its published_at" do
    _(rec_message.published_at).must_be :nil?
    _(rec_message.publish_time).must_be :nil?

    publish_time = Time.now
    rec_message_grpc.message.publish_time = Google::Cloud::PubSub::Convert.time_to_timestamp publish_time

    _(rec_message.published_at).must_equal publish_time
    _(rec_message.publish_time).must_equal publish_time
  end

  it "knows its delivery_attempt counter" do
    _(rec_message.delivery_attempt).must_equal 10
  end

  it "returns nil for delivery_attempt when delivery_attempt is 0" do
    rec_message_data_non_dlq = rec_message_hash rec_message_msg, delivery_attempt: 0
    rec_message_grpc_non_dlq = Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_data_non_dlq
    rec_message_non_dlq = Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_message_grpc_non_dlq, subscription
    _(rec_message_non_dlq.delivery_attempt).must_be :nil?
  end

  it "can acknowledge" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id]]
    subscription.service.mocked_subscriber = mock

    rec_message.acknowledge!

    mock.verify
  end

  it "can ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id]]
    subscription.service.mocked_subscriber = mock

    rec_message.ack!

    mock.verify
  end

  it "can modify_ack_deadline" do
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id], ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    rec_message.modify_ack_deadline! new_deadline

    mock.verify
  end

  it "can reject" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id], ack_deadline_seconds: 0]
    subscription.service.mocked_subscriber = mock

    rec_message.reject!

    mock.verify
  end

  it "can nack" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id], ack_deadline_seconds: 0]
    subscription.service.mocked_subscriber = mock

    rec_message.nack!

    mock.verify
  end

  it "can ignore" do
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, nil, [subscription: subscription_path(subscription_name), ack_ids: [rec_message.ack_id], ack_deadline_seconds: 0]
    subscription.service.mocked_subscriber = mock

    rec_message.ignore!

    mock.verify
  end
end
