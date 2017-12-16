# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Pubsub::Topic, :subscriptions, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:subscriptions_with_token) do
    response = Google::Pubsub::V1::ListTopicSubscriptionsResponse.decode_json topic_subscriptions_json(3, "next_page_token")
    paged_enum_struct response
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "lists subscriptions" do
      mock = Minitest::Mock.new
      mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
      topic.service.mocked_publisher = mock

      subs = topic.subscriptions

      mock.verify

      subs.count.must_equal 3
      subs.each do |sub|
        sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
        sub.must_be :lazy?
      end
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "lists subscriptions" do
      stub = Object.new
      def stub.list_topic_subscriptions *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      topic.service.mocked_publisher = stub

      expect do
        topic.subscriptions
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
