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

describe Google::Cloud::Pubsub::Subscription, :seek, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:snapshot_name) { "my-snapshot" }
  let(:snapshot_grpc) { Google::Pubsub::V1::Snapshot.decode_json(snapshot_json(topic_name, snapshot_name)) }
  let(:snapshot) { Google::Cloud::Pubsub::Snapshot.from_grpc snapshot_grpc, pubsub.service }

  it "can seek using a time" do
    time = Time.now
    mock = Minitest::Mock.new
    timestamp = Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
    mock.expect :seek, nil, [subscription_path(sub_name), time: timestamp, options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.seek time

    mock.verify
  end

  it "can seek using a snapshot name" do
    mock = Minitest::Mock.new
    mock.expect :seek, nil, [subscription_path(sub_name), snapshot: snapshot_path(snapshot_name), options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.seek snapshot_name

    mock.verify
  end

  it "can seek using a snapshot object" do
    mock = Minitest::Mock.new
    mock.expect :seek, nil, [subscription_path(sub_name), snapshot: snapshot.name, options: default_options]
    subscription.service.mocked_subscriber = mock
    subscription.seek snapshot

    mock.verify
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "can seek using a snapshot name" do
      mock = Minitest::Mock.new
      snapshot_name = "my-snapshot"
      mock.expect :seek, nil, [subscription_path(sub_name), snapshot: snapshot_path(snapshot_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.seek snapshot_name

      mock.verify
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when seeking" do
      stub = Object.new
      def stub.seek *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.seek "my-snapshot"
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
