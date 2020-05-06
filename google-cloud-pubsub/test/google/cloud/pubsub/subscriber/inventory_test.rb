# Copyright 2019 Google LLC
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

describe Google::Cloud::PubSub::Subscriber, :inventory, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message3-msg-goes-here", 1113) }
  let(:client_id) { "my-client-uuid" }

  it "removes a single message from inventory, even when ack or nack are not called" do
    rec_message_msg = "pulled-message"
    rec_message_ack_id = 123456789
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new rec_messages_hash(rec_message_msg, rec_message_ack_id)
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscription.service.mocked_subscriber = stub
    subscription.service.client_id = client_id

    subscriber = subscription.listen streams: 1 do |result|
      # flush the initial buffer before any callbacks are processed
      subscriber.buffer.flush! unless called

      assert_equal ["ack-id-123456789"], subscriber.stream_pool.first.inventory.ack_ids

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, result
      assert_equal rec_message_msg, result.data
      assert_equal "ack-id-#{rec_message_ack_id}", result.ack_id
      sleep 0.01

      called = true
    end
    subscriber.start

    subscriber_retries = 0
    while !called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    sleep 0.01
    assert_empty subscriber.stream_pool.first.inventory.ack_ids

    subscriber.stop
    subscriber.wait!

    _(stub.requests.map(&:to_a)).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        client_id: client_id,
        subscription: sub_path,
        stream_ack_deadline_seconds: 60
      )]
    ]

    # pusher thread pool may deliver out of order, which stinks...
    ack_msg_ids = []
    stub.acknowledge_requests.each do |ack_sub_path, msg_ids|
      assert_equal ack_sub_path, sub_path
      ack_msg_ids += msg_ids
    end
    assert_empty ack_msg_ids

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
  end

  it "removes multiple messages from inventory, even when ack or nack are not called" do
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc, rec_msg2_grpc, rec_msg3_grpc]
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = 0

    subscription.service.mocked_subscriber = stub
    subscription.service.client_id = client_id

    subscriber = subscription.listen streams: 1 do |msg|
      # flush the initial buffer before any callbacks are processed
      subscriber.buffer.flush! if called.zero?

      refute_empty subscriber.stream_pool.first.inventory.ack_ids

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      called += 1
    end
    subscriber.start

    subscriber_retries = 0
    while called < 3
      fail "total number of calls were never made" if subscriber_retries > 200
      subscriber_retries += 1
      sleep 0.01
    end

    sleep 0.01
    assert_empty subscriber.stream_pool.first.inventory.ack_ids

    subscriber.stop
    subscriber.wait!

    _(stub.requests.map(&:to_a)).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        client_id: client_id,
        subscription: sub_path,
        stream_ack_deadline_seconds: 60
      )]
    ]

    # pusher thread pool may deliver out of order, which stinks...
    ack_msg_ids = []
    stub.acknowledge_requests.each do |ack_sub_path, msg_ids|
      assert_equal ack_sub_path, sub_path
      ack_msg_ids += msg_ids
    end
    assert_empty ack_msg_ids

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
  end

  it "knows its count limit" do
    subscriber_mock = Minitest::Mock.new
    inventory = Google::Cloud::PubSub::Subscriber::Inventory.new subscriber_mock, limit: 2, bytesize: 100_000, extension: 3600, max_duration_per_lease_extension: 0

    inventory.add rec_msg1_grpc
    _(inventory).wont_be :full?
    _(inventory.count).must_equal 1
    inventory.add rec_msg2_grpc, rec_msg3_grpc
    _(inventory.count).must_equal 3
    _(inventory).must_be :full?
  end

  it "knows its bytesize limit" do
    subscriber_mock = Minitest::Mock.new
    inventory = Google::Cloud::PubSub::Subscriber::Inventory.new subscriber_mock, limit: 1000, bytesize: 100, extension: 3600, max_duration_per_lease_extension: 0

    inventory.add rec_msg1_grpc
    _(inventory).wont_be :full?
    _(inventory.total_bytesize).must_equal 58
    inventory.add rec_msg2_grpc, rec_msg3_grpc
    _(inventory.total_bytesize).must_equal 174
    _(inventory).must_be :full?
  end

  it "removes expired items" do
    subscriber_mock = Minitest::Mock.new
    inventory = Google::Cloud::PubSub::Subscriber::Inventory.new subscriber_mock, limit: 1000, bytesize: 100_000, extension: 3600, max_duration_per_lease_extension: 0

    expired_time = Time.now - 7200

    Time.stub :now, expired_time do
      inventory.add rec_msg1_grpc
    end
    _(inventory.ack_ids).must_equal ["ack-id-1111"]
    inventory.add rec_msg2_grpc, rec_msg3_grpc
    _(inventory.ack_ids).must_equal ["ack-id-1111", "ack-id-1112", "ack-id-1113"]

    inventory.remove_expired!

    _(inventory.ack_ids).must_equal ["ack-id-1112", "ack-id-1113"]
  end

  it "knows its max_duration_per_lease_extension limit" do
    subscriber_mock = Minitest::Mock.new
    inventory = Google::Cloud::PubSub::Subscriber::Inventory.new subscriber_mock, limit: 1000, bytesize: 100, extension: 3600, max_duration_per_lease_extension: 10

    _(inventory.max_duration_per_lease_extension).must_equal 10
  end
end
