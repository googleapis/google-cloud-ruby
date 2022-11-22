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

describe Google::Cloud::PubSub::Subscriber, :stream, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }
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

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |msg|
      assert msg.subscription.exactly_once_delivery_enabled
      called = true
    end

    subscriber.start

    subscriber_retries = 0
    until called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    assert subscriber.stream_pool.first.exactly_once_delivery_enabled
    subscriber.stop
    subscriber.wait!
  end

  it "should update min_duration_per_lease_extension when exactly_once_delivery is modified" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |msg|
      assert msg.subscription.exactly_once_delivery_enabled
      called = true
    end

    subscriber.on_error do |error|
      # raise error
      p error
    end

    subscriber.start

    subscriber_retries = 0
    until called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    assert_equal subscriber.stream_pool.first.inventory.min_duration_per_lease_extension, 60 
    subscriber.stop
    subscriber.wait!
  end

  it "should not update min_duration_per_lease_extension when exactly_once_delivery is not modified" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                         exactly_once_delivery_enabled: false
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |msg|
      called = true
    end

    subscriber.start

    subscriber_retries = 0
    until called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    assert_equal subscriber.stream_pool.first.inventory.min_duration_per_lease_extension, 0 
    subscriber.stop
    subscriber.wait!
  end
end
