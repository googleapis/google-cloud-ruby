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

describe Google::Cloud::PubSub::Subscription, :attributes, :mock_pubsub do
  let(:labels) { { "foo" => "bar" } }
  let(:topic_name) { "topic-name-goes-here" }
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
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "gets topic from the Google API object" do
    # No mocked service means no API calls are happening.
    _(subscription.topic).must_be_kind_of Google::Cloud::PubSub::Topic
    _(subscription.topic).must_be :reference?
    _(subscription.topic).wont_be :resource?
    _(subscription.topic.name).must_equal topic_path(topic_name)
  end

  it "gets deadline from the Google API object" do
    _(subscription.deadline).must_equal sub_deadline
  end

  it "gets retain_acked from the Google API object" do
    assert subscription.retain_acked
  end

  it "gets its retention from the Google API object" do
    _(subscription.retention).must_equal 600.9
  end

  it "gets endpoint from the Google API object" do
    _(subscription.endpoint).must_equal sub_endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"
    push_config = Google::Cloud::PubSub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription: subscription_path(sub_name), push_config: push_config]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "gets expires_in from the Google API object" do
    two_days_seconds = 60*60*24*2
    _(subscription.expires_in).must_equal two_days_seconds
  end

  it "gets push_config from the Google API object" do
    _(subscription.push_config).must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
    _(subscription.push_config.endpoint).must_equal sub_endpoint
    _(subscription.push_config.authentication).must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig::OidcToken
    _(subscription.push_config.authentication.email).must_equal "user@example.com"
    _(subscription.push_config.authentication.audience).must_equal "client-12345"
    _(subscription.push_config).must_be :oidc_token?
  end

  it "gets labels from the Google API object" do
    _(subscription.labels).must_equal labels
  end

  it "gets filter from the Google API object" do
    _(subscription.filter).must_equal filter
  end

  it "gets dead_letter_topic from the Google API object" do
    _(subscription.dead_letter_topic.name).must_equal dead_letter_topic_path
  end

  it "gets dead_letter_max_delivery_attempts from the Google API object" do
    _(subscription.dead_letter_max_delivery_attempts).must_equal 6
  end

  it "gets retry_minimum_backoff from the Google API object" do
    _(subscription.retry_policy.minimum_backoff).must_equal retry_minimum_backoff
  end

  it "gets retry_maximum_backoff from the Google API object" do
    _(subscription.retry_policy.maximum_backoff).must_equal retry_maximum_backoff
  end

  it "gets detached from the Google API object" do
    _(subscription.detached?).must_equal true
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "makes an HTTP API call to retrieve topic" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.topic).must_be_kind_of Google::Cloud::PubSub::Topic

      mock.verify

      _(subscription.topic).must_be :reference?
      _(subscription.topic).wont_be :resource?
      _(subscription.topic.name).must_equal topic_path(topic_name)
    end

    it "makes an HTTP API call to retrieve deadline" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.deadline).must_equal sub_deadline

      mock.verify
    end

    it "makes an HTTP API call to retrieve retain_acked" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      assert subscription.retain_acked

      mock.verify
    end

    it "makes an HTTP API call to retrieve endpoint" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.endpoint).must_equal sub_endpoint

      mock.verify
    end

    it "makes an HTTP API call to retrieve expires_in" do
      two_days_seconds = 60*60*24*2

      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.expires_in).must_equal two_days_seconds

      mock.verify
    end

    it "makes an HTTP API call to retrieve labels" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, labels: labels)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.labels).must_equal labels

      mock.verify
    end

    it "makes an HTTP API call to retrieve filter" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, filter: filter)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.filter).must_equal filter

      mock.verify
    end

    it "makes an HTTP API call to retrieve dead_letter_topic and dead_letter_max_delivery_attempts" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, dead_letter_topic: dead_letter_topic_path, max_delivery_attempts: 7)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.dead_letter_topic.name).must_equal dead_letter_topic_path
      _(subscription.dead_letter_max_delivery_attempts).must_equal 7

      mock.verify
    end

    it "makes an HTTP API call to retrieve retry_minimum_backoff" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, retry_minimum_backoff: retry_minimum_backoff)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.retry_policy.minimum_backoff).must_equal retry_minimum_backoff

      mock.verify
    end

    it "makes an HTTP API call to retrieve retry_maximum_backoff" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, retry_maximum_backoff: retry_maximum_backoff)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription.retry_policy.maximum_backoff).must_equal retry_maximum_backoff

      mock.verify
    end

    it "makes an HTTP API call to retrieve detached" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, detached: true)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      _(subscription.detached?).must_equal true

      mock.verify
    end

    it "does not make an HTTP API call to access push_config" do
      _(subscription.push_config).must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
      _(subscription.push_config.endpoint).must_be :empty?
      _(subscription.push_config.authentication).must_be :nil?
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when retrieving topic" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.topic
      end.must_raise Google::Cloud::NotFoundError
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

    it "raises NotFoundError when retrieving endpoint" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.endpoint
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving expires_in" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.expires_in
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving labels" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.labels
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving filter" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.filter
      end.must_raise Google::Cloud::NotFoundError
    end

    it "does not raise NotFoundError when accessing push_config" do
      _(subscription.push_config).must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
      _(subscription.push_config.endpoint).must_be :empty?
      _(subscription.push_config.authentication).must_be :nil?
    end

    it "raises NotFoundError when retrieving dead_letter_topic" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.dead_letter_topic
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving dead_letter_max_delivery_attempts" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.dead_letter_max_delivery_attempts
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving retry_policy" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.retry_policy
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving detached" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.detached?
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
