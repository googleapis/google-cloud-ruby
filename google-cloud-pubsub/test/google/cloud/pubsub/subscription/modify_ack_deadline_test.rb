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

describe Google::Cloud::PubSub::Subscription, :modify_ack_deadline, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_hash("rec_message1-msg-goes-here") }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_hash("rec_message2-msg-goes-here") }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_hash("rec_message3-msg-goes-here") }
  let(:rec_message1) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg1_grpc, subscription }
  let(:rec_message2) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg2_grpc, subscription }
  let(:rec_message3) { Google::Cloud::PubSub::ReceivedMessage.from_grpc rec_msg3_grpc, subscription }

  it "can modify_ack_deadline an ack id" do
    ack_id = rec_message1.ack_id
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: [ack_id], ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, ack_id

    mock.verify
  end

  it "can modify_ack_deadline many ack ids" do
    ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids, ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, *ack_ids

    mock.verify
  end

  it "can modify_ack_deadline many ack ids in an array" do
    ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids, ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, ack_ids

    mock.verify
  end

  it "can modify_ack_deadline a message" do
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: [rec_message1.ack_id], ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, rec_message1

    mock.verify
  end

  it "can modify_ack_deadline many messages" do
    rec_messages = [rec_message1, rec_message3, rec_message3]
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: rec_messages.map(&:ack_id), ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, *rec_messages

    mock.verify
  end

  it "can modify_ack_deadline many messages in an array" do
    rec_messages = [rec_message1, rec_message3, rec_message3]
    new_deadline = 42
    mad_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: rec_messages.map(&:ack_id), ack_deadline_seconds: new_deadline]
    subscription.service.mocked_subscriber = mock

    subscription.modify_ack_deadline new_deadline, rec_messages

    mock.verify
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "can modify_ack_deadline an ack id" do
      ack_id = rec_message1.ack_id
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: [ack_id], ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, ack_id

      mock.verify
    end

    it "can modify_ack_deadline many ack ids" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids, ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, *ack_ids

      mock.verify
    end

    it "can modify_ack_deadline many ack ids in an array" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: ack_ids, ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, ack_ids

      mock.verify
    end

    it "can modify_ack_deadline a message" do
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: [rec_message1.ack_id], ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, rec_message1

      mock.verify
    end

    it "can modify_ack_deadline many messages" do
      rec_messages = [rec_message1, rec_message3, rec_message3]
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: rec_messages.map(&:ack_id), ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, *rec_messages

      mock.verify
    end

    it "can modify_ack_deadline many messages in an array" do
      rec_messages = [rec_message1, rec_message3, rec_message3]
      new_deadline = 42
      mad_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_ack_deadline, mad_res, [subscription: subscription_path(sub_name), ack_ids: rec_messages.map(&:ack_id), ack_deadline_seconds: new_deadline]
      subscription.service.mocked_subscriber = mock

      subscription.modify_ack_deadline new_deadline, rec_messages

      mock.verify
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when modify_ack_deadlineing an ack id" do
      ack_id = rec_message1.ack_id
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, ack_id
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when modify_ack_deadlineing many ack ids" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, *ack_ids
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when modify_ack_deadlineing many ack ids in an array" do
      ack_ids = [rec_message1.ack_id, rec_message3.ack_id, rec_message3.ack_id]
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, ack_ids
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when modify_ack_deadlineing a message" do
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, rec_message1
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when modify_ack_deadlineing many messages" do
      rec_messages = [rec_message1, rec_message3, rec_message3]
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, *rec_messages
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when modify_ack_deadlineing many messages in an array" do
      rec_messages = [rec_message1, rec_message3, rec_message3]
      new_deadline = 42

      stub = Object.new
      def stub.modify_ack_deadline *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.modify_ack_deadline new_deadline, rec_messages
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
