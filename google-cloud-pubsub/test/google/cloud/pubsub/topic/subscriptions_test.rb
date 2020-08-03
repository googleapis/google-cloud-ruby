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

describe Google::Cloud::PubSub::Topic, :subscriptions, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:subscriptions_with_token) do
    Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(3, "next_page_token")
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  describe "reference topic that exists" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "lists subscriptions" do
      mock = Minitest::Mock.new
      mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
      topic.service.mocked_publisher = mock

      subs = topic.subscriptions

      mock.verify

      _(subs.count).must_equal 3
      subs.each do |sub|
        _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
        _(sub).must_be :reference?
        _(sub).wont_be :resource?
      end
    end
  end

  describe "reference topic that does not exist" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "lists subscriptions" do
      stub = Object.new
      def stub.list_topic_subscriptions *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      topic.service.mocked_publisher = stub

      expect do
        topic.subscriptions
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
