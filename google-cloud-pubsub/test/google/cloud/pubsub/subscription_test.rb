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

describe Google::Cloud::Pubsub::Subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Pubsub::V1::Subscription.decode_json(subscription_json(topic_name, subscription_name)) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc subscription_grpc, pubsub.service }

  it "knows its name" do
    subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its topic" do
    subscription.topic.must_be_kind_of Google::Cloud::Pubsub::Topic
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
    push_config = Google::Pubsub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription_path(subscription_name), push_config, options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "can delete itself" do
    del_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_subscription, del_res, [subscription_path(subscription_name), options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.delete

    mock.verify
  end

  it "can pull a message" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_messages_json(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription_path(subscription_name), 100, return_immediately: true, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull

    mock.verify

    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  it "can acknowledge one message" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1"

    mock.verify
  end

  it "can acknowledge many messages" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1", "ack-id-2", "ack-id-3"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"

    mock.verify
  end

  it "can acknowledge with ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.ack "ack-id-1"

    mock.verify
  end
end
