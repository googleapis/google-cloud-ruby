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
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: labels) }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc topic_grpc, pubsub.service }

  it "updates labels" do
    topic.labels.must_equal labels

    update_grpc = topic_grpc.dup
    update_grpc.labels = new_labels_map
    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [update_grpc, update_mask, options: default_options]
    topic.service.mocked_publisher = mock

    topic.labels = new_labels

    mock.verify

    topic.labels.must_equal new_labels
  end

  it "updates labels to empty hash" do
    topic.labels.must_equal labels

    update_grpc = topic_grpc.dup
    update_grpc.labels = Google::Protobuf::Map.new(:string, :string)

    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [update_grpc, update_mask, options: default_options]
    topic.service.mocked_publisher = mock

    topic.labels = {}

    mock.verify

    topic.labels.wont_be :nil?
    topic.labels.must_be :empty?
  end

  it "raises when setting labels to nil" do
    topic.labels.must_equal labels

    expect { topic.labels = nil }.must_raise ArgumentError

    topic.labels.must_equal labels
  end

  it "updates kms_key" do
    topic_grpc.kms_key_name = kms_key_name
    topic.kms_key.must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: new_kms_key_name
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [update_grpc, update_mask, options: default_options]
    topic.service.mocked_publisher = mock

    topic.kms_key = new_kms_key_name

    mock.verify

    topic.kms_key.must_equal new_kms_key_name
  end

  it "updates kms_key to empty string" do
    topic_grpc.kms_key_name = kms_key_name
    topic.kms_key.must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: ""
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [update_grpc, update_mask, options: default_options]
    topic.service.mocked_publisher = mock

    topic.kms_key = ""

    mock.verify

    topic.kms_key.must_be :empty?
  end

  it "updates kms_key to nil" do
    topic_grpc.kms_key_name = kms_key_name
    topic.kms_key.must_equal kms_key_name

    update_grpc = Google::Cloud::PubSub::V1::Topic.new \
      name: topic_path(topic_name),
      kms_key_name: ""
    update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
    mock = Minitest::Mock.new
    mock.expect :update_topic, update_grpc, [update_grpc, update_mask, options: default_options]
    topic.service.mocked_publisher = mock

    topic.kms_key = nil

    mock.verify

    topic.kms_key.must_be :empty?
  end

  describe :reference do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "updates labels" do
      topic.must_be :reference?
      topic.wont_be :resource?

      update_grpc = Google::Cloud::PubSub::V1::Topic.new \
        name: topic_path(topic_name),
        labels: new_labels
      topic_grpc.labels = new_labels_map
      update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
      mock = Minitest::Mock.new
      mock.expect :update_topic, topic_grpc, [update_grpc, update_mask, options: default_options]
      topic.service.mocked_publisher = mock

      topic.labels = new_labels

      mock.verify

      topic.wont_be :reference?
      topic.must_be :resource?
      topic.labels.must_equal new_labels
    end

    it "updates kms_key" do
      topic.must_be :reference?
      topic.wont_be :resource?

      update_grpc = Google::Cloud::PubSub::V1::Topic.new \
        name: topic_path(topic_name),
        kms_key_name: new_kms_key_name
      topic_grpc.kms_key_name = new_kms_key_name
      update_mask = Google::Protobuf::FieldMask.new paths: ["kms_key_name"]
      mock = Minitest::Mock.new
      mock.expect :update_topic, topic_grpc, [update_grpc, update_mask, options: default_options]
      topic.service.mocked_publisher = mock

      topic.kms_key = new_kms_key_name

      mock.verify

      topic.wont_be :reference?
      topic.must_be :resource?
      topic.kms_key.must_equal new_kms_key_name
    end
  end
end
