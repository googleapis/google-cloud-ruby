# Copyright 2022 Google LLC
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

describe Google::Cloud::PubSub::MessageListener, :stream, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }


  it "should track exactly_once_delivery_enabled from streaming response" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    listener = subscriber.listen streams: 1 do |msg|
      assert msg.subscription.exactly_once_delivery_enabled
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    assert listener.stream_pool.first.exactly_once_delivery_enabled
    listener.stop
    listener.wait!
  end

  it "should update min_duration_per_lease_extension when exactly_once_delivery is modified" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    listener = subscriber.listen streams: 1 do |msg|
      assert msg.subscription.exactly_once_delivery_enabled
      called = true
    end

    listener.on_error do |error|
      # raise error
      p error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    assert_equal listener.stream_pool.first.inventory.min_duration_per_lease_extension, 60
    listener.stop
    listener.wait!
  end

  it "should not update min_duration_per_lease_extension when exactly_once_delivery is not modified" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: false
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    assert_equal listener.stream_pool.first.inventory.min_duration_per_lease_extension, 0 
    listener.stop
    listener.wait!
  end

  it "should send message to callback on receipt modack success of when exactly only delivery is enabled" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      if @modify_ack_deadline_requests.count == 0
        return  @modify_ack_deadline_requests << ["ack_ids"]
      end
      raise Google::Cloud::PermissionDeniedError.new "Test failure"
    end

    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!
  end

  it "should not send message to callback on receipt modack failure when exactly only delivery is enabled" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      raise Google::Cloud::PermissionDeniedError.new "Test failure"
    end
 
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end

    listener.start

    listener_retries = 0
    until listener_retries < 120
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!
    assert_equal called, false
  end

  it "should send message to callback without waiting for receipt modack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: false
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscriber.service.mocked_subscriber = stub
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      raise Google::Cloud::PermissionDeniedError.new "Test failure"
    end

    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!
  end
end
