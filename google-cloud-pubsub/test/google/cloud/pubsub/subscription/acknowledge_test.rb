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
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                  rec_message_hash("rec_message1-msg-goes-here") }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                  rec_message_hash("rec_message2-msg-goes-here") }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                  rec_message_hash("rec_message3-msg-goes-here") }
  let(:rec_message1) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg1_grpc, subscription }
  let(:rec_message2) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg2_grpc, subscription }
  let(:rec_message3) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg3_grpc, subscription }

  it "can acknowledge an ack id" do
    ack_id = rec_message1.ack_id
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: [ack_id]]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge ack_id

    mock.verify
  end

  it "can acknowledge many ack ids" do
    ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge(*ack_ids)

    mock.verify
  end

  it "can acknowledge many ack ids in an array" do
    ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge ack_ids

    mock.verify
  end

  it "can acknowledge a message" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: [rec_message1.ack_id]]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge rec_message1

    mock.verify
  end

  it "can acknowledge many messages" do
    rec_messages  = [rec_message1, rec_message3, rec_message3]
    ack_ids = rec_messages.map(&:ack_id)
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge(*rec_messages)

    mock.verify
  end

  it "can acknowledge many messages in an array" do
    rec_messages  = [rec_message1, rec_message3, rec_message3]
    ack_ids = rec_messages.map(&:ack_id)
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge rec_messages

    mock.verify
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "can acknowledge an ack id" do
      ack_id = rec_message1.ack_id
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: [ack_id]]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge ack_id

      mock.verify
    end

    it "can acknowledge many ack ids" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge(*ack_ids)

      mock.verify
    end

    it "can acknowledge many ack ids in an array" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge ack_ids

      mock.verify
    end

    it "can acknowledge a message" do
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: [rec_message1.ack_id]]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge rec_message1

      mock.verify
    end

    it "can acknowledge many messages" do
      rec_messages  = [rec_message1, rec_message3, rec_message3]
      ack_ids = rec_messages.map(&:ack_id)
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge(*rec_messages)

      mock.verify
    end

    it "can acknowledge many messages in an array" do
      rec_messages  = [rec_message1, rec_message3, rec_message3]
      ack_ids = rec_messages.map(&:ack_id)
      ack_res = nil
      mock = Minitest::Mock.new
      mock.expect :acknowledge, ack_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids]
      subscription.service.mocked_subscriber = mock

      subscription.acknowledge rec_messages

      mock.verify
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when acknowledging an ack id" do
      ack_id = rec_message1.ack_id

      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge ack_id
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when acknowledging many ack ids" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]

      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge(*ack_ids)
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when acknowledging many ack ids in an array" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]

      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge ack_ids
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when acknowledging a message" do
      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge rec_message1
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when acknowledging many messages" do
      rec_messages  = [rec_message1, rec_message3, rec_message3]

      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge(*rec_messages)
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when acknowledging many messages in an array" do
      rec_messages  = [rec_message1, rec_message3, rec_message3]

      stub = Object.new
      def stub.acknowledge *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.acknowledge rec_messages
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
