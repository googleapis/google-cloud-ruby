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

describe Google::Cloud::Pubsub::Subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:subscription_grpc) { Google::Pubsub::V1::Subscription.decode_json(subscription_json(topic_name, subscription_name)) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc subscription_grpc, pubsub.service }
  let(:labels) { { "foo" => "bar" } }

  it "knows its name" do
    subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its topic" do
    subscription.topic.must_be_kind_of Google::Cloud::Pubsub::Topic
    subscription.topic.must_be :reference?
    subscription.topic.wont_be :resource?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "has an ack deadline" do
    subscription.must_respond_to :deadline
  end

  it "knows its retain_acked" do
    subscription.must_respond_to :retain_acked
  end

  it "knows its retention_duration" do
    subscription.must_respond_to :retention
  end

  it "has an endpoint" do
    subscription.must_respond_to :endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"
    push_config = Google::Pubsub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription_path(subscription_name), push_config, options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "can delete itself" do
    del_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_subscription, del_res, [subscription_path(subscription_name), options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.delete

    mock.verify
  end

  it "can pull a message" do
    rec_message_msg = "pulled-message"
    pull_res = Google::Pubsub::V1::PullResponse.decode_json rec_messages_json(rec_message_msg)
    mock = Minitest::Mock.new
    mock.expect :pull, pull_res, [subscription_path(subscription_name), 100, return_immediately: true, options: default_options]
    subscription.service.mocked_subscriber = mock

    rec_messages = subscription.pull

    mock.verify

    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  it "can acknowledge one message" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1"

    mock.verify
  end

  it "can acknowledge many messages" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1", "ack-id-2", "ack-id-3"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"

    mock.verify
  end

  it "can acknowledge with ack" do
    ack_res = nil
    mock = Minitest::Mock.new
    mock.expect :acknowledge, ack_res, [subscription_path(subscription_name), ["ack-id-1"], options: default_options]
    subscription.service.mocked_subscriber = mock

    subscription.ack "ack-id-1"

    mock.verify
  end

  it "creates a snapshot" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Snapshot.decode_json snapshot_json(subscription_name, new_snapshot_name)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [snapshot_path(new_snapshot_name), subscription_path(subscription_name), labels: nil, options: default_options]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.create_snapshot new_snapshot_name

    mock.verify

    snapshot.wont_be :nil?
    snapshot.must_be_kind_of Google::Cloud::Pubsub::Snapshot
  end

  it "creates a snapshot with new_snapshot alias" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Snapshot.decode_json snapshot_json(subscription_name, new_snapshot_name)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [snapshot_path(new_snapshot_name), subscription_path(subscription_name), labels: nil, options: default_options]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.new_snapshot new_snapshot_name

    mock.verify

    snapshot.wont_be :nil?
    snapshot.must_be_kind_of Google::Cloud::Pubsub::Snapshot
  end

  it "creates a snapshot with labels" do
    new_snapshot_name = "new-snapshot-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Snapshot.decode_json snapshot_json(subscription_name, new_snapshot_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_snapshot, create_res, [snapshot_path(new_snapshot_name), subscription_path(subscription_name), labels: labels, options: default_options]
    subscription.service.mocked_subscriber = mock

    snapshot = subscription.create_snapshot new_snapshot_name, labels: labels

    mock.verify

    snapshot.wont_be :nil?
    snapshot.must_be_kind_of Google::Cloud::Pubsub::Snapshot
    snapshot.labels.must_equal labels
    snapshot.labels.must_be :frozen?
  end

  it "raises when creating a snapshot that already exists" do
    existing_snapshot_name = "existing-snapshot"

    stub = Object.new
    def stub.create_snapshot *args
      gax_error = Google::Gax::GaxError.new "already exists"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(6, "already exists")
      raise gax_error
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
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    subscription.service.mocked_subscriber = stub

    assert_raises Google::Cloud::NotFoundError do
      # Let's assume the subscription has been deleted before calling create.
      subscription.create_snapshot new_snapshot_name
    end
  end
end
