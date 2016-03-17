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

class Gcloud::Pubsub::ListenMustStopInTests < StandardError; end

describe Gcloud::Pubsub::Subscription, :listen, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Gcloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:empty_json) { { "received_messages" => [] }.to_json }

  it "can listen for messages" do
    stub = Object.new
    def stub.pull *args
      @count ||= 0
      @count +=1
      raise Gcloud::Pubsub::ListenMustStopInTests if @count >= 3
      Google::Pubsub::V1::PullResponse.decode_json \
        "{\"received_messages\":[{\"ack_id\":\"ack-id-529967\",\"message\":{\"data\":\"cHVsbGVkLW1lc3NhZ2U=\\n\",\"attributes\":{},\"message_id\":\"msg-id-529967\"}}]}"
    end
    pubsub.service.mocked_subscriber = stub

    expect do
      subscription.listen do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests
  end

  it "sleeps when there are no results returned" do
    stub = Object.new
    def stub.pull *args
      @count ||= 0
      @count +=1
      raise Gcloud::Pubsub::ListenMustStopInTests if @count >= 3
      Google::Pubsub::V1::PullResponse.decode_json \
        "{\"received_messages\":[]}"
    end
    pubsub.service.mocked_subscriber = stub

    $listen_sleep_mock = Minitest::Mock.new
    $listen_sleep_mock.expect :mock_sleep, nil, [1]
    $listen_sleep_mock.expect :mock_sleep, nil, [1]
    def subscription.sleep delay
      $listen_sleep_mock.mock_sleep delay
    end

    expect do
      subscription.listen do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests

    $listen_sleep_mock.verify
    $listen_sleep_mock = nil
  end

  it "sleeps for the value passed in :delay" do
    stub = Object.new
    def stub.pull *args
      @count ||= 0
      @count +=1
      raise Gcloud::Pubsub::ListenMustStopInTests if @count >= 3
      Google::Pubsub::V1::PullResponse.decode_json \
        "{\"received_messages\":[]}"
    end
    pubsub.service.mocked_subscriber = stub

    $listen_sleep_mock = Minitest::Mock.new
    $listen_sleep_mock.expect :mock_sleep, nil, [999]
    $listen_sleep_mock.expect :mock_sleep, nil, [999]
    def subscription.sleep delay
      $listen_sleep_mock.mock_sleep delay
    end

    expect do
      subscription.listen(delay: 999) do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests

    $listen_sleep_mock.verify
    $listen_sleep_mock = nil
  end
end
