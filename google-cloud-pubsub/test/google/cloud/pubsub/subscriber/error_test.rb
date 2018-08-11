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

describe Google::Cloud::Pubsub::Subscriber, :error, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:sub_path) { sub_grpc.name }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json \
                          rec_message_json("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json \
                          rec_message_json("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Pubsub::V1::ReceivedMessage.decode_json \
                          rec_message_json("rec_message3-msg-goes-here", 1113) }

  it "relays errors to the user" do
    pull_res1 = Google::Pubsub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    pull_res2 = Google::Pubsub::V1::StreamingPullResponse.new received_messages: [rec_msg2_grpc]
    pull_res3 = Google::Pubsub::V1::StreamingPullResponse.new received_messages: [rec_msg3_grpc]
    response_groups = [[pull_res1, ArgumentError.new], [pull_res2, ZeroDivisionError.new], [pull_res3]]

    stub = StreamingPullStub.new response_groups
    called = 0
    errors = []

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |msg|
      assert_kind_of Google::Cloud::Pubsub::ReceivedMessage, msg
      msg.ack!
      called +=1
    end

    subscriber.on_error do |error|
      # raise error
      errors << error
    end

    subscriber.last_error.must_be :nil?

    subscriber.start

    subscriber_retries = 0
    while called < 3
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    errors.count.must_equal 2
    errors[0].must_be_kind_of ArgumentError
    errors[1].must_be_kind_of ZeroDivisionError
    subscriber.last_error.must_be_kind_of ZeroDivisionError

    subscriber.stop
    subscriber.wait!

    # stub requests are not guaranteed, so don't check in this test
  end
end
