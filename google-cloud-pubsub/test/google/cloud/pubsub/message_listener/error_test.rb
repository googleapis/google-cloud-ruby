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

describe Google::Cloud::PubSub::MessageListener, :error, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { subscription_path sub_name }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message3-msg-goes-here", 1113) }

  it "relays errors to the user" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    pull_res2 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg2_grpc]
    pull_res3 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg3_grpc]
    response_groups = [[pull_res1, ArgumentError.new], [pull_res2, ZeroDivisionError.new], [pull_res3]]

    stub = StreamingPullStub.new response_groups
    called = 0
    errors = []

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      msg.ack!
      called += 1
    end

    listener.on_error do |error|
      # raise error
      errors << error
    end

    _(listener.last_error).must_be :nil?

    listener.start

    listener_retries = 0
    while called < 3
      fail "total number of calls were never made" if listener_retries > 100
      listener_retries += 1
      sleep 0.01
    end

    _(errors.count).must_equal 2
    _(errors[0]).must_be_kind_of ArgumentError
    _(errors[1]).must_be_kind_of ZeroDivisionError
    _(listener.last_error).must_be_kind_of ZeroDivisionError

    listener.stop
    listener.wait!

    # stub requests are not guaranteed, so don't check in this test
  end
end
