# Copyright 2026 Google LLC
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

describe Google::Cloud::PubSub::MessageListener, :keepalive_integration, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message2-msg-goes-here", 1112) }

  describe "Happy Path Effectiveness Integration" do
    it "maintains continuous stream liveness across multiple periodic keep-alive ping/pong cycles" do
      pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
      stub = StreamingPullStub.new [[pull_res1], []]
      subscriber.service.mocked_subscription_admin = stub

      messages_received = []
      listener = subscriber.listen streams: 1 do |msg|
        messages_received << msg
        msg.ack!
      end

      stream = listener.instance_variable_get(:@stream_pool).first
      stream.keepalive_monitor.instance_variable_set :@interval, 0.05
      stream.keepalive_monitor.instance_variable_set :@deadline, 0.5

      listener.start

      # Wait for initial message delivery
      wait_until(max: 100, msg: "Initial message not delivered") { messages_received.any? }

      # Allow multiple periodic keep-alive intervals to fire
      sleep 0.15

      monitor = stream.keepalive_monitor
      _(stream.stream_open?).must_equal true
      _(monitor.instance_variable_get(:@last_ping_at)).wont_be_nil
      _(monitor.instance_variable_get(:@last_pong_at)).wont_be_nil
      _(stub.requests.count).must_equal 1

      requests_sent = stub.requests.first.to_a
      _(requests_sent.count).must_be :>=, 2
      _(requests_sent.first.protocol_version).must_equal 1

      listener.stop
      listener.wait!
    end

    it "safely unpauses flow control without triggering false-positive monitor restarts" do
      pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
      stub = StreamingPullStub.new [[pull_res1]]
      subscriber.service.mocked_subscription_admin = stub

      listener = subscriber.listen streams: 1 do |msg|
        msg.ack!
      end
      stream = listener.instance_variable_get(:@stream_pool).first
      monitor = stream.keepalive_monitor

      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stream.instance_variable_set :@stream_open, true
      stream.instance_variable_set :@stopped, false
      stream.instance_variable_set :@paused, true
      monitor.instance_variable_set :@last_ping_at, now - 20.0
      monitor.instance_variable_set :@last_pong_at, now - 25.0

      # 1. When flow control paused, check_liveness! skips evaluation even if deadline exceeded
      monitor.check_liveness!
      _(stream.stream_open?).must_equal true

      # 2. Unpausing refreshes last_pong_at under synchronization so reader thread drains pongs cleanly
      stream.send(:unpause_streaming!)
      _(monitor.instance_variable_get(:@last_pong_at)).must_be :>=, now

      # 3. Liveness monitor firing immediately after unpause does not falsely close stream
      monitor.check_liveness!
      _(stream.stream_open?).must_equal true
    end
  end

  describe "Resiliency & Failure Recovery Integration" do
    it "recovers from silent network black holes by pushing stream-closing sentinel and raising RestartStream" do
      pull_res2 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg2_grpc]
      stub = StreamingPullStub.new [[], [pull_res2]]
      subscriber.service.mocked_subscription_admin = stub

      recovered_msg = nil
      listener = subscriber.listen streams: 1 do |msg|
        recovered_msg = msg
        msg.ack!
      end

      stream = listener.instance_variable_get(:@stream_pool).first
      stream.keepalive_monitor.instance_variable_set :@interval, 0.05
      stream.keepalive_monitor.instance_variable_set :@deadline, 0.05

      listener.start

      # First stream pull returns empty and triggers keep-alive timeout recovery,
      # which pushes the sentinel self onto request_queue and raises RestartStream,
      # cleanly recovering onto the second stream pull response.
      wait_until(max: 300, msg: "Stream did not recover from keep-alive timeout") { recovered_msg }

      _(recovered_msg.message_id).must_equal "msg-id-1112"
      _(stub.requests.count).must_equal 2

      listener.stop
      listener.wait!
    end

    it "isolates exponential backoff progression and re-initializes clean timestamps on reconnect" do
      pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
      response_groups = [[GRPC::Unavailable.new], [pull_res1]]
      stub = StreamingPullStub.new response_groups
      subscriber.service.mocked_subscription_admin = stub

      delivered = false
      listener = subscriber.listen streams: 1 do |msg|
        delivered = true
        msg.ack!
      end

      stream = listener.instance_variable_get(:@stream_pool).first
      monitor = stream.keepalive_monitor

      listener.start

      wait_until(max: 300, msg: "Stream did not reconnect after GRPC::Unavailable backoff") { delivered }

      _(stream.stream_open?).must_equal true
      _(monitor.instance_variable_get(:@last_ping_at)).wont_be_nil
      _(monitor.instance_variable_get(:@last_pong_at)).wont_be_nil

      listener.stop
      listener.wait!
    end
  end
end
