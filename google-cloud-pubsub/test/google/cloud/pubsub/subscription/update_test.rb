# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Pubsub::Subscription, :update, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_deadline) { sub_hash["ack_deadline_seconds"] }
  let(:sub_endpoint) { sub_hash["push_config"]["push_endpoint"] }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "updates deadline" do
    subscription.deadline.must_equal 60

    update_sub = sub_grpc.dup
    update_sub.ack_deadline_seconds = 30
    update_mask = Google::Protobuf::FieldMask.new paths: ["ack_deadline_seconds"]
    mock = Minitest::Mock.new
    mock.expect :update_subscription, update_sub, [update_sub, update_mask, options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.deadline = 30

    mock.verify

    subscription.deadline.must_equal 30
  end

  it "updates retain_acked" do
    subscription.retain_acked.must_equal true

    update_sub = sub_grpc.dup
    update_sub.retain_acked_messages = false
    update_mask = Google::Protobuf::FieldMask.new paths: ["retain_acked_messages"]
    mock = Minitest::Mock.new
    mock.expect :update_subscription, update_sub, [update_sub, update_mask, options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.retain_acked = false

    mock.verify

    subscription.retain_acked.must_equal false
  end

  it "updates retention" do
    subscription.retention.must_equal 600.9

    update_sub = sub_grpc.dup
    update_sub.message_retention_duration = Google::Cloud::Pubsub::Convert.number_to_duration 600.2
    update_mask = Google::Protobuf::FieldMask.new paths: ["message_retention_duration"]
    mock = Minitest::Mock.new
    mock.expect :update_subscription, update_sub, [update_sub, update_mask, options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.retention = 600.2

    mock.verify

    subscription.retention.must_equal 600.2
  end

  describe :lazy do
    let(:subscription) { Google::Cloud::Pubsub::Subscription.new_lazy sub_name, pubsub.service }

    it "updates deadline" do
      subscription.must_be :lazy?

      update_sub = Google::Pubsub::V1::Subscription.new \
        name: subscription_path(sub_name),
        ack_deadline_seconds: 30
      sub_grpc.ack_deadline_seconds = 30
      update_mask = Google::Protobuf::FieldMask.new paths: ["ack_deadline_seconds"]
      mock = Minitest::Mock.new
      mock.expect :update_subscription, sub_grpc, [update_sub, update_mask, options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.deadline = 30

      mock.verify

      subscription.wont_be :lazy?
      subscription.deadline.must_equal 30
    end

    it "updates retain_acked" do
      subscription.must_be :lazy?

      update_sub = Google::Pubsub::V1::Subscription.new \
        name: subscription_path(sub_name),
        retain_acked_messages: true
      sub_grpc.retain_acked_messages = true
      update_mask = Google::Protobuf::FieldMask.new paths: ["retain_acked_messages"]
      mock = Minitest::Mock.new
      mock.expect :update_subscription, sub_grpc, [update_sub, update_mask, options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.retain_acked = true

      mock.verify

      subscription.wont_be :lazy?
      subscription.retain_acked.must_equal true
    end

    it "updates retention" do
      subscription.must_be :lazy?

      update_sub = Google::Pubsub::V1::Subscription.new \
        name: subscription_path(sub_name),
        message_retention_duration: Google::Cloud::Pubsub::Convert.number_to_duration(600.2)
      sub_grpc.message_retention_duration = Google::Cloud::Pubsub::Convert.number_to_duration 600.2
      update_mask = Google::Protobuf::FieldMask.new paths: ["message_retention_duration"]
      mock = Minitest::Mock.new
      mock.expect :update_subscription, sub_grpc, [update_sub, update_mask, options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.retention = 600.2

      mock.verify

      subscription.wont_be :lazy?
      subscription.retention.must_equal 600.2
    end
  end
end
