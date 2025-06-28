# Copyright 2017 Google LLC
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

describe Google::Cloud::PubSub::MessageListener, :modify_ack_deadline, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message3-msg-goes-here", 1113) }
  let(:client_id) { "my-client-uuid" }

  it "can modify_ack_deadline a single message" do
    rec_message_msg = "pulled-message"
    rec_message_ack_id = 123456789
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new rec_messages_hash(rec_message_msg, rec_message_ack_id)
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscription_admin = stub
    subscriber.service.client_id = client_id

    listener = subscriber.listen streams: 1 do |msg|
      # flush the initial buffer before any callbacks are processed
      listener.buffer.flush! unless called

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      assert_equal rec_message_msg, msg.data
      assert_equal "ack-id-#{rec_message_ack_id}", msg.ack_id

      msg.modify_ack_deadline! 42
      called = true
    end
    listener.start

    listener_retries = 0
    while !called
      fail "total number of calls were never made" if listener_retries > 100
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!

    _(stub.requests.map(&:to_a)).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        client_id: client_id,
        subscription: sub_path,
        stream_ack_deadline_seconds: 60,
        max_outstanding_messages: 1000,
        max_outstanding_bytes: 100 * 1000 * 1000
      )]
    ]

    _(stub.acknowledge_requests).must_equal []

    # pusher thread pool may deliver out of order, which stinks...
    mod_ack_hash = {}
    stub.modify_ack_deadline_requests.each do |ack_sub_path, msg_ids, deadline|
      assert_equal ack_sub_path, sub_path
      if mod_ack_hash.key? deadline
        mod_ack_hash[deadline] += msg_ids
      else
        mod_ack_hash[deadline] = msg_ids
      end
    end
    _(mod_ack_hash[60].sort).must_equal ["ack-id-123456789"]
    _(mod_ack_hash[42].sort).must_equal ["ack-id-123456789"]
  end

  it "can modify_ack_deadline multiple messages" do
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc, rec_msg2_grpc, rec_msg3_grpc]
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = 0

    subscriber.service.mocked_subscription_admin = stub
    subscriber.service.client_id = client_id

    listener = subscriber.listen streams: 1 do |msg|
      # flush the initial buffer before any callbacks are processed
      listener.buffer.flush! if called.zero?

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      msg.modify_ack_deadline! 42
      called +=1
    end
    listener.start

    listener_retries = 0
    while called < 3
      fail "total number of calls were never made" if listener_retries > 100
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!

    _(stub.requests.map(&:to_a)).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        client_id: client_id,
        subscription: sub_path,
        stream_ack_deadline_seconds: 60,
        max_outstanding_messages: 1000,
        max_outstanding_bytes: 100 * 1000 * 1000
      )]
    ]

    _(stub.acknowledge_requests).must_equal []

    # pusher thread pool may deliver out of order, which stinks...
    mod_ack_hash = {}
    stub.modify_ack_deadline_requests.each do |ack_sub_path, msg_ids, deadline|
      assert_equal ack_sub_path, sub_path
      if mod_ack_hash.key? deadline
        mod_ack_hash[deadline] += msg_ids
      else
        mod_ack_hash[deadline] = msg_ids
      end
    end
    _(mod_ack_hash[60].sort).must_equal ["ack-id-1111", "ack-id-1112", "ack-id-1113"]
    _(mod_ack_hash[42].sort).must_equal ["ack-id-1111", "ack-id-1112", "ack-id-1113"]
  end
end
