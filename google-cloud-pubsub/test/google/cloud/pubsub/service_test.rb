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

describe Google::Cloud::PubSub::Service do
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(project_id: "project-id") }
  let(:timeout) { 123.4 }
  let(:endpoint) { "pubsub.googleapis.com" }
  let(:endpoint_2) { "localhost:4567" }

  # Values below are hardcoded in Service.
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::PubSub::VERSION }
  let(:metadata) { { "google-cloud-resource-prefix": "projects/#{project}" } }

  let(:subscriber_default_config) do
    Google::Cloud::PubSub::V1::Subscriber::Client.new do |config|
      config.credentials = :this_channel_is_insecure
    end.configure
  end
  let(:publisher_default_config) do
    Google::Cloud::PubSub::V1::Publisher::Client.new do |config|
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

  it "configures the V1::Subscriber::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.subscriber.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::Subscriber::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_equal endpoint
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals subscriber_default_config.rpcs, 16, config.rpcs
        end
      end
    end
  end

  it "configures the V1::Subscriber::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout
          _(service.project).must_equal project
          config = service.subscriber.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::Subscriber::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals subscriber_default_config.rpcs, 16, config.rpcs, timeout: timeout
        end
      end
    end
  end

  it "configures the V1::Publisher::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.publisher.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::Publisher::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_equal endpoint
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals publisher_default_config.rpcs, 9, config.rpcs
        end
      end
    end
  end

  it "configures the V1::Publisher::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout
          _(service.project).must_equal project
          config = service.publisher.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::Publisher::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals publisher_default_config.rpcs, 9, config.rpcs, timeout: timeout
        end
      end
    end
  end

  it "configures the V1::IAMPolicy::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.iam.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::IAMPolicy::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_equal endpoint
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals iam_policy_default_config.rpcs, 3, config.rpcs
        end
      end
    end
  end

  it "configures the V1::IAMPolicy::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout
          _(service.project).must_equal project
          config = service.iam.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::IAMPolicy::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals iam_policy_default_config.rpcs, 3, config.rpcs, timeout: timeout
        end
      end
    end
  end

  it "configures the V1::SchemaService::Client" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil
          _(service.project).must_equal project
          config = service.schemas.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SchemaService::Client::Configuration
          _(config.timeout).must_be :nil?
          _(config.endpoint).must_equal endpoint
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals schema_service_default_config.rpcs, 6, config.rpcs
        end
      end
    end
  end

  it "configures the V1::SchemaService::Client with host and timeout" do
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, nil do
          service = Google::Cloud::PubSub::Service.new project, nil, host: endpoint_2, timeout: timeout
          _(service.project).must_equal project
          config = service.schemas.configure
          _(config).must_be_kind_of Google::Cloud::PubSub::V1::SchemaService::Client::Configuration
          _(config.timeout).must_equal timeout
          _(config.endpoint).must_equal endpoint_2
          _(config.lib_name).must_equal lib_name
          _(config.lib_version).must_equal lib_version
          _(config.metadata).must_equal metadata
          assert_config_rpcs_equals schema_service_default_config.rpcs, 6, config.rpcs, timeout: timeout
        end
      end
    end
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
