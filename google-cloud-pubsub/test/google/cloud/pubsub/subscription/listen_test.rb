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

describe Google::Cloud::PubSub::Subscription, :listen, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "will create a Subscriber" do
    subscriber = subscription.listen do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set deadline while creating a Subscriber" do
    subscriber = subscription.listen deadline: 120 do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 120
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set deadline while creating a Subscriber" do
    subscriber = subscription.listen streams: 2 do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory (deprecated) while creating a Subscriber" do
    subscriber = subscription.listen inventory: 500 do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 500
    subscriber.inventory_limit.must_equal 500
    subscriber.max_outstanding_messages.must_equal 500
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory max_outstanding_messages while creating a Subscriber" do
    subscriber = subscription.listen inventory: { max_outstanding_messages: 500 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 500
    subscriber.inventory_limit.must_equal 500
    subscriber.max_outstanding_messages.must_equal 500
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory limit alias while creating a Subscriber" do
    subscriber = subscription.listen inventory: { limit: 500 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 500
    subscriber.inventory_limit.must_equal 500
    subscriber.max_outstanding_messages.must_equal 500
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory max_outstanding_bytes while creating a Subscriber" do
    subscriber = subscription.listen inventory: { max_outstanding_bytes: 50_000 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 50_000
    subscriber.max_outstanding_bytes.must_equal 50_000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory bytesize alias while creating a Subscriber" do
    subscriber = subscription.listen inventory: { bytesize: 50_000 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 50_000
    subscriber.max_outstanding_bytes.must_equal 50_000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory max_total_lease_duration while creating a Subscriber" do
    subscriber = subscription.listen inventory: { max_total_lease_duration: 7_200 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 7200
    subscriber.max_total_lease_duration.must_equal 7200
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory extension alias while creating a Subscriber" do
    subscriber = subscription.listen inventory: { extension: 7_200 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 7200
    subscriber.max_total_lease_duration.must_equal 7200
    subscriber.max_duration_per_lease_extension.must_equal 0
  end

  it "will set inventory max_duration_per_lease_extension while creating a Subscriber" do
    subscriber = subscription.listen inventory: { max_duration_per_lease_extension: 10 } do |msg|
      puts msg.msg_id
    end
    subscriber.must_be_kind_of Google::Cloud::PubSub::Subscriber
    subscriber.subscription_name.must_equal subscription.name
    subscriber.deadline.must_equal 60
    subscriber.streams.must_equal 2
    subscriber.inventory.must_equal 1000
    subscriber.inventory_limit.must_equal 1000
    subscriber.max_outstanding_messages.must_equal 1000
    subscriber.inventory_bytesize.must_equal 100000000
    subscriber.max_outstanding_bytes.must_equal 100000000
    subscriber.inventory_extension.must_equal 3600
    subscriber.max_total_lease_duration.must_equal 3600
    subscriber.max_duration_per_lease_extension.must_equal 10
  end
end
