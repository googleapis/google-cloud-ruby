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

describe Google::Cloud::PubSub::Subscriber, :attributes, :mock_pubsub do
  let(:labels) { { "foo" => "bar" } }
  let(:topic_name) { "topic-name-goes-here" }
  let(:table_id) { "table_id" }
  let(:dead_letter_topic_path) { topic_path("topic-name-dead-letter") }
  let(:retry_minimum_backoff) { 12.123 }
  let(:retry_maximum_backoff) { 123.321 }
  let(:filter) { "attributes.event_type = \"1\"" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) do
    subscription_hash topic_name, sub_name, labels: labels, dead_letter_topic: dead_letter_topic_path, \
      max_delivery_attempts: 6, retry_minimum_backoff: retry_minimum_backoff, retry_maximum_backoff: retry_maximum_backoff, \
      filter: filter, detached: true
  end
  let(:sub_deadline) { sub_hash[:ack_deadline_seconds] }
  let(:sub_endpoint) { sub_hash[:push_config][:push_endpoint] }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:bq_subscriber) do
     Google::Cloud::PubSub::Subscriber.from_grpc Google::Cloud::PubSub::V1::Subscription.new(sub_hash.merge!({
                                                     bigquery_config: {
                                                       table: table_id,
                                                       write_metadata: true
                                                     }
                                                   })),
                                                   pubsub.service
  end

  it "gets deadline from the Google API object" do
    _(subscriber.deadline).must_equal sub_deadline
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscriber do
      Google::Cloud::PubSub::Subscriber.from_name sub_name, pubsub.service
    end

    it "makes an HTTP API call to retrieve deadline" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, subscription: subscription_path(sub_name)
      subscriber.service.mocked_subscriber = mock

      _(subscriber.deadline).must_equal sub_deadline

      mock.verify
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscriber.from_name sub_name, pubsub.service
    end

    it "raises NotFoundError when retrieving deadline" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.deadline
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
