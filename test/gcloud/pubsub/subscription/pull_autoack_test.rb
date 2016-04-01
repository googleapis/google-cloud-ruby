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

describe Gcloud::Pubsub::Subscription, :pull, :autoack, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Gcloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_json) { rec_message_json "rec_msg1-msg-goes-here" }
  let(:rec_msg2_json) { rec_message_json "rec_msg2-msg-goes-here" }
  let(:rec_msg3_json) { rec_message_json "rec_msg3-msg-goes-here" }
  let(:rec_msgs_json) do
    {
      "received_messages" => [
        JSON.parse(rec_msg1_json),
        JSON.parse(rec_msg2_json),
        JSON.parse(rec_msg3_json),
      ]
    }.to_json
  end
  let(:empty_rec_msgs_json) do
    {
      "received_messages" => []
    }.to_json
  end
  let(:rec_msg1_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json rec_msg1_json }
  let(:rec_msg2_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json rec_msg2_json }
  let(:rec_msg3_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json rec_msg3_json }
  let(:rec_msg1) { Gcloud::Pubsub::ReceivedMessage.from_grpc rec_msg1_grpc, subscription }
  let(:rec_msg2) { Gcloud::Pubsub::ReceivedMessage.from_grpc rec_msg2_grpc, subscription }
  let(:rec_msg3) { Gcloud::Pubsub::ReceivedMessage.from_grpc rec_msg3_grpc, subscription }

  it "can auto acknowledge when pulling messages" do
    ack_ids = [rec_msg1.ack_id, rec_msg2.ack_id, rec_msg3.ack_id]

    ack_req = Google::Pubsub::V1::AcknowledgeRequest.new(
      subscription: subscription_path(sub_name),
      ack_ids: ack_ids
    )
    ack_res = Google::Protobuf::Empty.new
    pull_req = Google::Pubsub::V1::PullRequest.new(
      subscription: subscription_path(sub_name),
      return_immediately: true,
      max_messages: 100
    )
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_msgs_json
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [ack_req]
    mock.expect :pull, pull_res, [pull_req]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull autoack: true

    mock.verify

    rec_messages.count.must_equal 3
  end

  it "does not auto acknowledge when pulling messages and getting 0 results" do
    pull_req = Google::Pubsub::V1::PullRequest.new(
      subscription: subscription_path(sub_name),
      return_immediately: true,
      max_messages: 100
    )
    pull_res = Google::Pubsub::V1::PullResponse.decode_json empty_rec_msgs_json
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [pull_req]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull autoack: true

    mock.verify

    rec_messages.count.must_equal 0
  end
end
