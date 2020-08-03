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

describe Google::Cloud::PubSub::Topic, :subscribe, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:new_sub_name) { "new-sub-#{Time.now.to_i}" }
  let(:labels) { { "foo" => "bar" } }

  it "creates a subscription when calling subscribe" do
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription with labels" do
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, labels: labels)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, labels: labels

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    _(sub.labels).must_equal labels
    _(sub.labels).must_be :frozen?
  end

  describe "reference topic that exists" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "creates a subscription when calling subscribe" do
      create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
      mock = Minitest::Mock.new
      mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name)
      topic.service.mocked_subscriber = mock

      sub = topic.subscribe new_sub_name

      mock.verify

      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub.name).must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    end
  end

  describe "reference topic that does not exist" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "raises NotFoundError when calling subscribe" do
      stub = Object.new
      def stub.create_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      topic.service.mocked_subscriber = stub

      expect do
        topic.subscribe new_sub_name
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
