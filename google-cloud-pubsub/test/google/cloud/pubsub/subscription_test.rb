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

describe Google::Cloud::PubSub::Subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Cloud::PubSub::V1::Subscription.new(subscription_hash(topic_name, subscription_name)) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc subscription_grpc, pubsub.service }
  let(:labels) { { "foo" => "bar" } }

  it "knows its name" do
    _(subscription.name).must_equal subscription_path(subscription_name)
  end

  it "knows its topic" do
    _(subscription.topic).must_be_kind_of Google::Cloud::PubSub::Topic
    _(subscription.topic).must_be :reference?
    _(subscription.topic).wont_be :resource?
    _(subscription.topic.name).must_equal topic_path(topic_name)
  end

  it "has an ack deadline" do
    _(subscription).must_respond_to :deadline
  end

  it "knows its retain_acked" do
    _(subscription).must_respond_to :retain_acked
  end

  it "knows its retention" do
    _(subscription).must_respond_to :retention
  end

  it "knows its topic_retention" do
    _(subscription).must_respond_to :topic_retention
  end

  it "has an endpoint" do
    _(subscription).must_respond_to :endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"
    push_config = Google::Cloud::PubSub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription: subscription_path(subscription_name), push_config: push_config]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "can pull a message" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Cloud::PubSub::V1::PullResponse.new rec_messages_hash(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription: subscription_path(subscription_name), max_messages: 100, return_immediately: true]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull

    mock.verify

    _(rec_messages).wont_be :empty?
    _(rec_messages.first.message.data).must_equal rec_message_msg
  end

  it "can acknowledge one message" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1"]]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1"

    mock.verify
  end

  it "can acknowledge many messages" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1", "ack-id-2", "ack-id-3"]]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"

    mock.verify
  end

  it "can acknowledge with ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription: subscription_path(subscription_name), ack_ids: ["ack-id-1"]]
    subscription.service.mocked_subscriber = mock

    subscription.ack "ack-id-1"

    mock.verify
  end

  it "creates a snapshot" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash(subscription_name, new_snapshot_name)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [name: snapshot_path(new_snapshot_name), subscription: subscription_path(subscription_name), labels: nil]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.create_snapshot new_snapshot_name

    mock.verify

    _(snapshot).wont_be :nil?
    _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
  end

  it "creates a snapshot with fully-qualified snapshot path" do
    new_snapshot_path = "projects/other-project/snapshots/new-snapshot-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash(subscription_name, new_snapshot_path)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [name: snapshot_path(new_snapshot_path), subscription: subscription_path(subscription_name), labels: nil]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.create_snapshot new_snapshot_path

    mock.verify

    _(snapshot.name).must_equal new_snapshot_path
  end

  it "creates a snapshot with new_snapshot alias" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash(subscription_name, new_snapshot_name)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [name: snapshot_path(new_snapshot_name), subscription: subscription_path(subscription_name), labels: nil]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.new_snapshot new_snapshot_name

    mock.verify

    _(snapshot).wont_be :nil?
    _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
  end

  it "creates a snapshot with labels" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash(subscription_name, new_snapshot_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [name: snapshot_path(new_snapshot_name), subscription: subscription_path(subscription_name), labels: labels]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.create_snapshot new_snapshot_name, labels: labels

    mock.verify

    _(snapshot).wont_be :nil?
    _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    _(snapshot.labels).must_equal labels
    _(snapshot.labels).must_be :frozen?
  end

  it "raises when creating a snapshot that already exists" do
    existing_snapshot_name = "existing-snapshot"

    stub = Object.new
    def stub.create_snapshot *args
      raise Google::Cloud::AlreadyExistsError.new("already exists")
    end
    subscription.service.mocked_subscriber = stub

    assert_raises Google::Cloud::AlreadyExistsError do
      subscription.create_snapshot existing_snapshot_name
    end
  end

  it "raises when creating a snapshot on a deleted subscription" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"

    stub = Object.new
    def stub.create_snapshot *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    subscription.service.mocked_subscriber = stub

    assert_raises Google::Cloud::NotFoundError do
      # Let's assume the subscription has been deleted before calling create.
      subscription.create_snapshot new_snapshot_name
    end
  end
end
