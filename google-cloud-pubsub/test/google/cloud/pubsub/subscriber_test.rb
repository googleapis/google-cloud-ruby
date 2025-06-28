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

describe Google::Cloud::PubSub::Subscriber, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Cloud::PubSub::V1::Subscription.new(subscription_hash(topic_name, subscription_name)) }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc subscription_grpc, pubsub.service }
  let(:labels) { { "foo" => "bar" } }

  it "knows its name" do
    _(subscriber.name).must_equal subscription_path(subscription_name)
  end

  it "has an ack deadline" do
    _(subscriber).must_respond_to :deadline
  end

  it "can pull a message" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Cloud::PubSub::V1::PullResponse.new rec_messages_hash(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, subscription: subscription_path(subscription_name), max_messages: 100, return_immediately: true
    subscriber.service.mocked_subscription_admin = mock

    rec_messages = subscriber.pull

    mock.verify

    _(rec_messages).wont_be :empty?
    _(rec_messages.first.message.data).must_equal rec_message_msg
  end

  it "can acknowledge one message" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1"]
    subscriber.service.mocked_subscription_admin = mock

    subscriber.acknowledge "ack-id-1"

    mock.verify
  end

  it "can acknowledge many messages" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1", "ack-id-2", "ack-id-3"]
    subscriber.service.mocked_subscription_admin = mock

    subscriber.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"

    mock.verify
  end

  it "can acknowledge with ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1"]
    subscriber.service.mocked_subscription_admin = mock

    subscriber.ack "ack-id-1"

    mock.verify
  end
end
