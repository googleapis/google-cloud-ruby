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

describe Gcloud::Pubsub::Subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Pubsub::V1::Subscription.decode_json(subscription_json(topic_name, subscription_name)) }
  let(:subscription) { Gcloud::Pubsub::Subscription.from_grpc subscription_grpc, pubsub.connection, pubsub.service }

  it "knows its name" do
    subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its topic" do
    subscription.topic.must_be_kind_of Gcloud::Pubsub::Topic
    subscription.topic.must_be :lazy?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "has an ack deadline" do
    subscription.must_respond_to :deadline
  end

  it "has an endpoint" do
    subscription.must_respond_to :endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"

    mpc_req = Google::Pubsub::V1::ModifyPushConfigRequest.new(
                subscription: "projects/#{project}/subscriptions/#{subscription_name}",
                push_config: Google::Pubsub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
              )
    mpc_res = Google::Protobuf::Empty.new
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [mpc_req]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "can delete itself" do
    del_req = Google::Pubsub::V1::DeleteSubscriptionRequest.new subscription: "projects/#{project}/subscriptions/#{subscription_name}"
    del_res = Google::Protobuf::Empty.new
    mock = Minitest::Mock.new
    mock.expect :delete_subscription, del_res, [del_req]
    pubsub.service.mocked_subscriber = mock

    subscription.delete

    mock.verify
  end

  it "can pull a message" do
    rec_message_msg = "pulled-message"

    pull_req = Google::Pubsub::V1::PullRequest.new(
      subscription: subscription_path(subscription_name),
      return_immediately: true,
      max_messages: 100
    )
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_messages_json(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [pull_req]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull

    mock.verify

    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  it "can acknowledge one message" do
    ack_req = Google::Pubsub::V1::AcknowledgeRequest.new(
      subscription: subscription_path(subscription_name),
      ack_ids: ["ack-id-1"]
    )
    ack_res = Google::Protobuf::Empty.new
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [ack_req]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1"

    mock.verify
  end

  it "can acknowledge many messages" do
    ack_req = Google::Pubsub::V1::AcknowledgeRequest.new(
      subscription: subscription_path(subscription_name),
      ack_ids: ["ack-id-1", "ack-id-2", "ack-id-3"]
    )
    ack_res = Google::Protobuf::Empty.new
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [ack_req]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"

    mock.verify
  end

  it "can acknowledge with ack" do
    ack_req = Google::Pubsub::V1::AcknowledgeRequest.new(
      subscription: subscription_path(subscription_name),
      ack_ids: ["ack-id-1"]
    )
    ack_res = Google::Protobuf::Empty.new
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [ack_req]
    subscription.service.mocked_subscriber = mock

    subscription.ack "ack-id-1"

    mock.verify
  end
end
