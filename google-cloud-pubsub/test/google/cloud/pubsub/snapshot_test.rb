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

describe Google::Cloud::PubSub::Snapshot, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:snapshot_name) { "snapshot-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:snapshot_grpc) { Google::Cloud::PubSub::V1::Snapshot.new(snapshot_hash(topic_name, snapshot_name, labels: labels)) }
  let(:snapshot) { Google::Cloud::PubSub::Snapshot.from_grpc snapshot_grpc, pubsub.service }
  let(:new_labels) { { "baz" => "qux" } }
  let(:new_labels_map) do
    labels_map = Google::Protobuf::Map.new(:string, :string)
    new_labels.each { |k, v| labels_map[String(k)] = String(v) }
    labels_map
  end

  it "knows its name" do
    _(snapshot.name).must_equal snapshot_path(snapshot_name)
  end

  it "knows its topic" do
    _(snapshot.topic).must_be_kind_of Google::Cloud::PubSub::Topic
    _(snapshot.topic).must_be :reference?
    _(snapshot.topic).wont_be :resource?
    _(snapshot.topic.name).must_equal topic_path(topic_name)
  end

  it "knows its expiration_time" do
    _(snapshot.expiration_time).must_be_kind_of ::Time
  end

  it "knows its labels" do
    _(snapshot.labels).must_equal labels
  end


  it "updates labels" do
    _(snapshot.labels).must_equal labels

    update_sub = snapshot_grpc.dup
    update_sub.labels = new_labels_map
    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_snapshot, update_sub, snapshot: update_sub, update_mask: update_mask
    snapshot.service.mocked_subscriber = mock

    snapshot.labels = new_labels

    mock.verify

    _(snapshot.labels).must_equal new_labels
  end

  it "updates labels to empty hash" do
    _(snapshot.labels).must_equal labels

    update_sub = snapshot_grpc.dup
    update_sub.labels = Google::Protobuf::Map.new(:string, :string)

    update_mask = Google::Protobuf::FieldMask.new paths: ["labels"]
    mock = Minitest::Mock.new
    mock.expect :update_snapshot, update_sub, snapshot: update_sub, update_mask: update_mask
    snapshot.service.mocked_subscriber = mock

    snapshot.labels = {}

    mock.verify

    _(snapshot.labels).wont_be :nil?
    _(snapshot.labels).must_be :empty?
  end

  it "raises when setting labels to nil" do
    _(snapshot.labels).must_equal labels

    expect { snapshot.labels = nil }.must_raise ArgumentError

    _(snapshot.labels).must_equal labels
  end

  it "can delete itself" do
    del_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_snapshot, del_res, snapshot: snapshot_path(snapshot_name)
    pubsub.service.mocked_subscriber = mock

    snapshot.delete

    mock.verify
  end
end
