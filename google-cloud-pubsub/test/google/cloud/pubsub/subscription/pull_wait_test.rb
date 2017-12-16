# Copyright 2015 Google LLC
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

describe Google::Cloud::Pubsub::Subscription, :pull, :wait, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "can pull messages without returning immediately" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_messages_json(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription_path(sub_name), 100, return_immediately: false, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull immediate: false

    mock.verify

    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  it "can pull messages by calling wait_for_messages" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_messages_json(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription_path(sub_name), 100, return_immediately: false, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.wait_for_messages

    mock.verify

    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  it "will not error when a request times out with Google::Cloud::DeadlineExceededError" do
    stub = Object.new
    def stub.pull *args
      raise Google::Cloud::DeadlineExceededError
    end
    subscription.service.mocked_subscriber = stub

    rec_messages = subscription.pull immediate: false
    rec_messages.must_be :empty?
  end
end
