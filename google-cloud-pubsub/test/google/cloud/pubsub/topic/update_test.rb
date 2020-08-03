# Copyright 2018 Google LLC
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

describe Google::Cloud::PubSub::Topic, :update, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:new_labels) { { "baz" => "qux" } }
  let(:new_labels_map) do
    labels_map = Google::Protobuf::Map.new(:string, :string)
    new_labels.each { |k, v| labels_map[String(k)] = String(v) }
    labels_map
  end
  let(:kms_key_name) { "projects/a/locations/b/keyRings/c/cryptoKeys/d" }
  let(:new_kms_key_name) { "projects/d/locations/c/keyRings/b/cryptoKeys/a" }
  let(:persistence_regions) { ["us-west1", "us-west2"] }
  let(:new_persistence_regions) { ["us-central1", "us-central2"] }
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: labels) }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc topic_grpc, pubsub.service }

  it "updates labels" do
    _(topic.labels).must_equal labels

    update_grpc = topic_grpc.dup
    update_grpc.labels = new_labels_map
    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.labels = new_labels

    mock.verify

    _(topic.labels).must_equal new_labels
  end

  it "updates labels to empty hash" do
    _(topic.labels).must_equal labels

    update_grpc = topic_grpc.dup
    update_grpc.labels = Google::Protobuf::Map.new(:string, :string)

    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.labels = {}

    mock.verify

    _(topic.labels).wont_be :nil?
    _(topic.labels).must_be :empty?
  end

  it "raises when setting labels to nil" do
    _(topic.labels).must_equal labels

    expect { topic.labels = nil }.must_raise ArgumentError

    _(topic.labels).must_equal labels
  end

  it "updates kms_key" do
    topic_grpc.kms_key_name = kms_key_name
    _(topic.kms_key).must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: new_kms_key_name
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.kms_key = new_kms_key_name

    mock.verify

    _(topic.kms_key).must_equal new_kms_key_name
  end

  it "updates kms_key to empty string" do
    topic_grpc.kms_key_name = kms_key_name
    _(topic.kms_key).must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: ""
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.kms_key = ""

    mock.verify

    _(topic.kms_key).must_be :empty?
  end

  it "updates kms_key to nil" do
    topic_grpc.kms_key_name = kms_key_name
    _(topic.kms_key).must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: ""
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.kms_key = nil

    mock.verify

    _(topic.kms_key).must_be :empty?
  end

  it "updates persistence_regions" do
    topic_grpc.message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new(
      allowed_persistence_regions: persistence_regions
    )
    _(topic.persistence_regions).must_equal persistence_regions

    update_grpc = Google::Cloud::PubSub::V1::Topic.new(
      name: topic_path(topic_name),
      message_storage_policy: { allowed_persistence_regions: new_persistence_regions }
    )
    update_mask = Google::Protobuf::FieldMask.new paths: ["message_storage_policy"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.persistence_regions = new_persistence_regions

    mock.verify

    _(topic.persistence_regions).must_equal new_persistence_regions
  end

  it "updates persistence_regions to empty array" do
    topic_grpc.message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new(
      allowed_persistence_regions: persistence_regions
    )
    _(topic.persistence_regions).must_equal persistence_regions

    update_grpc = Google::Cloud::PubSub::V1::Topic.new(
      name: topic_path(topic_name),
      message_storage_policy: { allowed_persistence_regions: [] }
    )
    update_mask = Google::Protobuf::FieldMask.new paths: ["message_storage_policy"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.persistence_regions = []

    mock.verify

    _(topic.persistence_regions).must_be :empty?
  end

  it "updates persistence_regions to nil" do
    topic_grpc.message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new(
      allowed_persistence_regions: persistence_regions
    )
    _(topic.persistence_regions).must_equal persistence_regions

    update_grpc = Google::Cloud::PubSub::V1::Topic.new(
      name: topic_path(topic_name),
      message_storage_policy: { allowed_persistence_regions: [] }
    )
    update_mask = Google::Protobuf::FieldMask.new paths: ["message_storage_policy"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [topic: update_grpc, update_mask: update_mask]
    topic.service.mocked_publisher = mock

    topic.persistence_regions = nil

    mock.verify

    _(topic.persistence_regions).must_be :empty?
  end

  describe :reference do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "updates labels" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      update_grpc = Google::Cloud::PubSub::V1::Topic.new \
        name: topic_path(topic_name),
        labels: new_labels
      topic_grpc.labels = new_labels_map
      update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
      mock = Minitest::Mock.new
      mock.expect :update_topic, topic_grpc, [topic: update_grpc, update_mask: update_mask]
      topic.service.mocked_publisher = mock

      topic.labels = new_labels

      mock.verify

      _(topic).wont_be :reference?
      _(topic).must_be :resource?
      _(topic.labels).must_equal new_labels
    end

    it "updates kms_key" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      update_grpc = Google::Cloud::PubSub::V1::Topic.new \
        name: topic_path(topic_name),
        kms_key_name: new_kms_key_name
      topic_grpc.kms_key_name = new_kms_key_name
      update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
      mock = Minitest::Mock.new
      mock.expect :update_topic, topic_grpc, [topic: update_grpc, update_mask: update_mask]
      topic.service.mocked_publisher = mock

      topic.kms_key = new_kms_key_name

      mock.verify

      _(topic).wont_be :reference?
      _(topic).must_be :resource?
      _(topic.kms_key).must_equal new_kms_key_name
    end
  end
end
