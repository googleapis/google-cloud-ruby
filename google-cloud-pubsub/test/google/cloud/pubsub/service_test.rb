# Copyright 2021 Google LLC
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
require "gapic/grpc/service_stub"
require "google/cloud/pubsub/v1"

describe Google::Cloud::PubSub::Service do
  class PubSubServiceTestDummyStub
    def endpoint
      "endpoint.example.com"
    end

    def universe_domain
      "example.com"
    end

    def stub_logger
      nil
    end

    def logger
      nil
    end
  end

  let(:project) { "test" }
  let(:credentials) { :this_channel_is_insecure }
  let(:timeout) { 123.4 }
  let(:endpoint) { "pubsub.googleapis.com" }
  let(:endpoint_2) { "localhost:4567" }
  let(:universe_domain) { "googleapis.com" }
  let(:universe_domain_2) { "mydomain.com" }

  # Values below are hardcoded in Service.
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::PubSub::VERSION }
  let(:expected_metadata) { { "google-cloud-resource-prefix": "projects/#{project}" } }

  let(:subscriber_default_config) do
    Google::Cloud::PubSub::V1::SubscriptionAdmin::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end.configure
  end
  let(:publisher_default_config) do
    Google::Cloud::PubSub::V1::TopicAdmin::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end.configure
  end
  let(:iam_policy_default_config) do
    Google::Cloud::PubSub::V1::IAMPolicy::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end.configure
  end
  let(:schema_service_default_config) do
    Google::Cloud::PubSub::V1::SchemaService::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end.configure
  end
  let(:dummy_stub) { PubSubServiceTestDummyStub.new }

  it "configures the V1::SubscriptionAdmin::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.subscription_admin.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SubscriptionAdmin::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_be :nil?
          _(config.universe_domain).must_equal universe_domain
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals subscriber_default_config.rpcs, 16, config.rpcs
          _(service.universe_domain).must_equal universe_domain
        end
      end
    end
  end

  it "configures the V1::SubscriptionAdmin::Client with host, universe_domain, and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout, universe_domain: universe_domain_2
          _(service.project).must_equal project
          config = service.subscription_admin.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SubscriptionAdmin::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.universe_domain).must_equal universe_domain_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals subscriber_default_config.rpcs, 16, config.rpcs, timeout: timeout
          _(service.universe_domain).must_equal universe_domain_2
        end
      end
    end
  end

  it "configures the V1::TopicAdmin::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.topic_admin.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::TopicAdmin::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_be :nil?
          _(config.universe_domain).must_equal universe_domain
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals publisher_default_config.rpcs, 9, config.rpcs
          _(service.universe_domain).must_equal universe_domain
        end
      end
    end
  end

  it "configures the V1::TopicAdmin::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout, universe_domain: universe_domain_2
          _(service.project).must_equal project
          config = service.topic_admin.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::TopicAdmin::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.universe_domain).must_equal universe_domain_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals publisher_default_config.rpcs, 9, config.rpcs, timeout: timeout
          _(service.universe_domain).must_equal universe_domain_2
        end
      end
    end
  end

  it "configures the V1::SchemaService::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.schemas.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SchemaService::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_be :nil?
          _(config.universe_domain).must_equal universe_domain
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals schema_service_default_config.rpcs, 10, config.rpcs
          _(service.universe_domain).must_equal universe_domain
        end
      end
    end
  end

  it "configures the V1::SchemaService::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout, universe_domain: universe_domain_2
          _(service.project).must_equal project
          config = service.schemas.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SchemaService::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.universe_domain).must_equal universe_domain_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal expected_metadata
          assert_config_rpcs_equals schema_service_default_config.rpcs, 10, config.rpcs, timeout: timeout
          _(service.universe_domain).must_equal universe_domain_2
        end
      end
    end
  end

  it "should raise errors other than grpc on ack" do
    service = Google::Cloud::PubSub::Service.new project, nil
    mocked_subscription_admin = Minitest::Mock.new
    service.mocked_subscription_admin = mocked_subscription_admin
    def mocked_subscription_admin.acknowledge_internal *args
      raise RuntimeError.new "test"
    end
    assert_raises RuntimeError do 
      service.acknowledge "sub","ack_id"
    end
  end

  it "should raise errors other than grpc on modack" do
    service = Google::Cloud::PubSub::Service.new project, nil
    mocked_subscription_admin = Minitest::Mock.new
    service.mocked_subscription_admin = mocked_subscription_admin
    def mocked_subscription_admin.modify_ack_deadline_internal *args
      raise RuntimeError.new "test"
    end
    assert_raises RuntimeError do 
      service.modify_ack_deadline "sub","ack_id", 80
    end
  end

  it "should pass call option with compression header when compress enabled" do
    service = Google::Cloud::PubSub::Service.new project, nil
    mocked_topic_admin = Minitest::Mock.new
    service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/test", messages: "data"}
    expected_options = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    mocked_topic_admin.expect :publish_internal, nil do |actual_request, actual_option|
      actual_request == expected_request && actual_option == expected_options
    end
    service.publish "test", "data", compress: true
    mocked_topic_admin.verify
  end

  it "should not add call option when compress disabled" do
    service = Google::Cloud::PubSub::Service.new project, nil
    mocked_topic_admin = Minitest::Mock.new
    service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/test", messages: "data"}
    mocked_topic_admin.expect :publish_internal, nil do |actual_request, actual_option|
      actual_request == expected_request && actual_option.nil?
    end
    service.publish "test", "data"
    mocked_topic_admin.verify
  end

  # @param [Numeric, nil] timeout Expected non-default timeout.
  def assert_config_rpcs_equals expected_rpcs, expected_rpcs_count, actual_rpcs, timeout: nil
    expected_rpc_names = expected_rpcs.methods - Object.methods
    # Explicit sanity check of the number of expected rpcs
    _(expected_rpc_names.count).must_equal expected_rpcs_count
    _((actual_rpcs.methods - Object.methods).count).must_equal expected_rpcs_count
    expected_rpc_names.each do |rpc_name|
      expected = expected_rpcs.send rpc_name
      actual = actual_rpcs.send rpc_name
      expected_timeout = timeout || expected.timeout
      assert_equal expected_timeout, actual.timeout, "Unexpected timeout for #{rpc_name}" if expected_timeout
      if expected.retry_policy
        assert_equal expected.retry_policy[:initial_delay],
                     actual.retry_policy[:initial_delay],
                     "Unexpected initial_delay for #{rpc_name}"
        assert_equal expected.retry_policy[:max_delay],
                     actual.retry_policy[:max_delay],
                     "Unexpected max_delay for #{rpc_name}"
        assert_equal expected.retry_policy[:multiplier],
                     actual.retry_policy[:multiplier],
                     "Unexpected multiplier for #{rpc_name}"
        assert_equal expected.retry_policy[:retry_codes],
                     actual.retry_policy[:retry_codes],
                     "Unexpected retry_codes for #{rpc_name}"
      end
    end
  end
end

describe Google::Cloud::PubSub::TopicAdmin::Client do
  it "is a subclass of V1::TopicAdmin::Client" do
    assert(Google::Cloud::PubSub::TopicAdmin::Client < Google::Cloud::PubSub::V1::TopicAdmin::Client)
  end

  it "raises when publish is called" do
    client = Google::Cloud::PubSub::TopicAdmin::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end
    assert_raises NotImplementedError do
      client.publish
    end
  end
end

describe Google::Cloud::PubSub::SubscriptionAdmin::Client do
  let(:client) do
    Google::Cloud::PubSub::SubscriptionAdmin::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end
  end

  it "is a subclass of V1::SubscriptionAdmin::Client" do
    assert(Google::Cloud::PubSub::SubscriptionAdmin::Client < Google::Cloud::PubSub::V1::SubscriptionAdmin::Client)
  end

  it "raises when modify_ack_deadline is called" do
    assert_raises NotImplementedError do
      client.modify_ack_deadline
    end
  end

  it "raises when acknowledge is called" do
    assert_raises NotImplementedError do
      client.acknowledge
    end
  end

  it "raises when pull is called" do
    assert_raises NotImplementedError do
      client.pull
    end
  end

  it "raises when streaming_pull is called" do
    assert_raises NotImplementedError do
      client.streaming_pull
    end
  end
end
