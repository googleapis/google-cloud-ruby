# Copyright 2015 Google LLC
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

describe Google::Cloud::Pubsub::Subscription, :listen, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "will create a Subscriber" do
    subscriber = subscription.listen do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::Pubsub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 4
  end

  it "will set deadline while creating a Subscriber" do
    subscriber = subscription.listen deadline: 120 do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::Pubsub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 120
    subscriber.streams.must_equal 4
  end

  it "will set deadline while creating a Subscriber" do
    subscriber = subscription.listen streams: 2 do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::Pubsub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
  end
end
