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

describe Google::Cloud::PubSub::Topic, :subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }
  let(:found_sub_name) { "found-sub-#{Time.now.to_i}" }
  let(:not_found_sub_name) { "found-sub-#{Time.now.to_i}" }

  it "gets an existing subscription" do
    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(found_sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.subscription found_sub_name

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets an existing subscription with get_subscription alias" do
    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(found_sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.get_subscription found_sub_name

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets an existing subscription with find_subscription alias" do
    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(found_sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.find_subscription found_sub_name

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "returns nil when getting an non-existant subscription" do
    stub = Object.new
    def stub.get_subscription *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    topic.service.mocked_subscriber = stub

    sub = topic.subscription found_sub_name
    _(sub).must_be :nil?
  end

  it "gets a subscription with skip_lookup option" do
    # No HTTP mock needed, since the lookup is not made

    sub = topic.find_subscription found_sub_name, skip_lookup: true
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).must_be :reference?
    _(sub).wont_be :resource?
  end

  describe "reference topic that exists" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "gets an existing subscription" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, found_sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(found_sub_name)]
      topic.service.mocked_subscriber = mock

      sub = topic.subscription found_sub_name

      mock.verify

      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end

    it "returns nil when getting an non-existant subscription" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      topic.service.mocked_subscriber = stub

      sub = topic.subscription found_sub_name
      _(sub).must_be :nil?
    end
  end

  describe "reference topic that does not exist" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "returns nil when getting an non-existant subscription" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      topic.service.mocked_subscriber = stub

      sub = topic.subscription found_sub_name
      _(sub).must_be :nil?
    end
  end
end
