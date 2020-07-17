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

describe Google::Cloud::PubSub::Subscription, :seek, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:snapshot_name) { "my-snapshot" }
  let(:snapshot_grpc) { Google::Cloud::PubSub::V1::Snapshot.new(snapshot_hash(topic_name, snapshot_name)) }
  let(:snapshot) { Google::Cloud::PubSub::Snapshot.from_grpc snapshot_grpc, pubsub.service }

  it "can seek using a time" do
    time = Time.now
    mock = Minitest::Mock.new
    timestamp = Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
    mock.expect :seek, nil, [subscription: subscription_path(sub_name), time: timestamp]
    subscription.service.mocked_subscriber = mock

    subscription.seek time

    mock.verify
  end

  it "can seek using a snapshot name" do
    mock = Minitest::Mock.new
    mock.expect :seek, nil, [subscription: subscription_path(sub_name), snapshot: snapshot_path(snapshot_name)]
    subscription.service.mocked_subscriber = mock

    subscription.seek snapshot_name

    mock.verify
  end

  it "can seek using a snapshot object" do
    mock = Minitest::Mock.new
    mock.expect :seek, nil, [subscription: subscription_path(sub_name), snapshot: snapshot.name]
    subscription.service.mocked_subscriber = mock
    subscription.seek snapshot

    mock.verify
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "can seek using a snapshot name" do
      mock = Minitest::Mock.new
      snapshot_name = "my-snapshot"
      mock.expect :seek, nil, [subscription: subscription_path(sub_name), snapshot: snapshot_path(snapshot_name)]
      subscription.service.mocked_subscriber = mock

      subscription.seek snapshot_name

      mock.verify
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when seeking" do
      stub = Object.new
      def stub.seek *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.seek "my-snapshot"
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
