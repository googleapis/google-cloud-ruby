# Copyright 2019 Google LLC
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

describe Google::Cloud::PubSub::Topic, :reload, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:old_labels) { { "foo" => "bar" } }
  let(:topic_grpc_old) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: old_labels) }
  let(:new_labels) { { "baz" => "bif" } }
  let(:topic_grpc_new) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: new_labels) }
  let(:topic_resource) { Google::Cloud::PubSub::Topic.from_grpc topic_grpc_old, pubsub.service }
  let(:topic_reference) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

  it "it has a reload method and a refresh alias" do
    _(topic_resource).must_respond_to :reload!
    _(topic_reference).must_respond_to :reload!

    _(topic_resource).must_respond_to :refresh!
    _(topic_reference).must_respond_to :refresh!
  end

  it "is reloads a resource by calling get_topic API" do
    _(topic_resource.name).must_equal topic_path(topic_name)
    _(topic_resource.labels).must_equal old_labels
    _(topic_resource).wont_be :reference?
    _(topic_resource).must_be :resource?

    mock = Minitest::Mock.new
    mock.expect :get_topic, topic_grpc_new, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic_resource.reload!

    mock.verify

    _(topic_resource.name).must_equal topic_path(topic_name)
    _(topic_resource.labels).must_equal new_labels
    _(topic_resource).wont_be :reference?
    _(topic_resource).must_be :resource?
  end

  it "is reloads a reference by calling get_topic API" do
    _(topic_reference.name).must_equal topic_path(topic_name)
    _(topic_reference).must_be :reference?
    _(topic_reference).wont_be :resource?

    mock = Minitest::Mock.new
    mock.expect :get_topic, topic_grpc_new, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic_reference.reload!

    mock.verify

    _(topic_reference.name).must_equal topic_path(topic_name)
    _(topic_reference.labels).must_equal new_labels
    _(topic_reference).wont_be :reference?
    _(topic_reference).must_be :resource?
  end
end
