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

describe Google::Cloud::PubSub::Subscription, :pull, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "can pull messages" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Cloud::PubSub::V1::PullResponse.new rec_messages_hash(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription: subscription_path(sub_name), max_messages: 100, return_immediately: true]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull

    mock.verify

    _(rec_messages).wont_be :empty?
    _(rec_messages.first.message.data).must_equal rec_message_msg
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name, pubsub.service
    end

    it "can pull messages" do
      rec_message_msg = "pulled-message"
      pull_res = Google::Cloud::PubSub::V1::PullResponse.new rec_messages_hash(rec_message_msg)
      mock = Minitest::Mock.new
      mock.expect :pull, pull_res, [subscription: subscription_path(sub_name), max_messages: 100, return_immediately: true]
      subscription.service.mocked_subscriber = mock

      rec_messages = subscription.pull

      mock.verify

      _(rec_messages).wont_be :empty?
      _(rec_messages.first.message.data).must_equal rec_message_msg
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when pulling messages" do
      stub = Object.new
      def stub.pull *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.pull
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
