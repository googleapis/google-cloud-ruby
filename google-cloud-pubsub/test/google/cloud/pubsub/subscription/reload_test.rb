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

describe Google::Cloud::PubSub::Subscription, :name, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_path) { subscription_path sub_name }
  let(:sub_hash_old) { subscription_hash topic_name, sub_name }
  let(:sub_hash_new) { subscription_hash topic_name, sub_name, 30, "http://example.net/endpoint", labels: { "foo" => "bar" } }
  let(:sub_grpc_old) { Google::Cloud::PubSub::V1::Subscription.new sub_hash_old }
  let(:sub_grpc_new) { Google::Cloud::PubSub::V1::Subscription.new sub_hash_new }
  let(:sub_resource) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc_old, pubsub.service }
  let(:sub_reference) { Google::Cloud::PubSub::Subscription.from_name sub_name, pubsub.service }

  it "it has a reload method and a refresh alias" do
    sub_resource.must_respond_to :reload!
    sub_reference.must_respond_to :reload!

    sub_resource.must_respond_to :refresh!
    sub_reference.must_respond_to :refresh!
  end

  it "is reloads a resource by calling get_topic API" do
    sub_resource.name.must_equal sub_path
    sub_resource.topic.name.must_equal topic_path(topic_name)
    sub_resource.deadline.must_equal 60
    sub_resource.endpoint.must_equal "http://example.com/callback"
    sub_resource.labels.must_be :empty?
    sub_resource.wont_be :reference?
    sub_resource.must_be :resource?

    mock = Minitest::Mock.new
    mock.expect :get_subscription, sub_grpc_new, [sub_path, options: default_options]
    pubsub.service.mocked_subscriber = mock

    sub_resource.reload!

    mock.verify

    sub_resource.name.must_equal sub_path
    sub_resource.topic.name.must_equal topic_path(topic_name)
    sub_resource.deadline.must_equal 30
    sub_resource.endpoint.must_equal "http://example.net/endpoint"
    sub_resource.labels.must_equal({ "foo" => "bar" })
    sub_resource.wont_be :reference?
    sub_resource.must_be :resource?
  end

  it "is reloads a reference by calling get_topic API" do
    sub_reference.name.must_equal sub_path
    sub_reference.must_be :reference?
    sub_reference.wont_be :resource?

    mock = Minitest::Mock.new
    mock.expect :get_subscription, sub_grpc_new, [sub_path, options: default_options]
    pubsub.service.mocked_subscriber = mock

    sub_reference.reload!

    mock.verify

    sub_reference.name.must_equal sub_path
    sub_reference.deadline.must_equal 30
    sub_reference.endpoint.must_equal "http://example.net/endpoint"
    sub_reference.labels.must_equal({ "foo" => "bar" })
    sub_reference.wont_be :reference?
    sub_reference.must_be :resource?
  end
end
