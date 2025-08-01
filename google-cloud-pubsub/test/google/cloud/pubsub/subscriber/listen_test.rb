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

describe Google::Cloud::PubSub::Subscriber, :listen, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new sub_hash }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }

  it "will create a MessageListener" do
    listener = subscriber.listen do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set deadline while creating a MessageListener" do
    listener = subscriber.listen deadline: 120 do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 120
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set deadline while creating a MessageListener" do
    listener = subscriber.listen streams: 2 do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 2
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory (deprecated) while creating a MessageListener" do
    listener = subscriber.listen inventory: 500 do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 500
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory max_outstanding_messages while creating a MessageListener" do
    listener = subscriber.listen inventory: { max_outstanding_messages: 500 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 500
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory limit alias while creating a MessageListener" do
    listener = subscriber.listen inventory: { limit: 500 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 500
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory max_outstanding_bytes while creating a MessageListener" do
    listener = subscriber.listen inventory: { max_outstanding_bytes: 50_000 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 50_000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory bytesize alias while creating a MessageListener" do
    listener = subscriber.listen inventory: { bytesize: 50_000 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 50_000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory max_total_lease_duration while creating a MessageListener" do
    listener = subscriber.listen inventory: { max_total_lease_duration: 7_200 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 7200
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory extension alias while creating a MessageListener" do
    listener = subscriber.listen inventory: { extension: 7_200 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 7200
    _(listener.max_duration_per_lease_extension).must_equal 0
  end

  it "will set inventory max_duration_per_lease_extension while creating a MessageListener" do
    listener = subscriber.listen inventory: { max_duration_per_lease_extension: 10 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 10
  end

  it "will set inventory min_duration_per_lease_extension while creating a MessageListener" do
    listener = subscriber.listen inventory: { min_duration_per_lease_extension: 10 } do |msg|
      puts msg.msg_id
    end
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.subscription_name).must_equal subscriber.name
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100000000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
    _(listener.min_duration_per_lease_extension).must_equal 10
  end
end