# Copyright 2014 Google LLC
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

describe Google::Cloud::PubSub::Project, :mock_pubsub do
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
  let(:dummy_stub) { PubSubServiceTestDummyStub.new }

  it "knows the project identifier" do
    _(pubsub.project).must_equal project
  end

  it "instantiates a TopicAdmin client" do
    client = pubsub.topic_admin_client
    _(client).must_be_kind_of Google::Cloud::PubSub::V1::TopicAdmin::Client
  end

  it "instantiates a SubscriptionAdmin client" do
    client = pubsub.subscription_admin_client
    _(client).must_be_kind_of Google::Cloud::PubSub::V1::SubscriptionAdmin::Client
  end

  it "instantiates a SchemaAdmin client" do
    client = pubsub.schema_admin_client
    _(client).must_be_kind_of Google::Cloud::PubSub::V1::SchemaAdmin::Client
  end


  it "reuses an already instantiated client" do
    new_pubsub = Google::Cloud::PubSub::Project.new Google::Cloud::PubSub::Service.new(project, credentials)

    topic_admin = new_pubsub.topic_admin_client
    _(topic_admin).must_be_kind_of Google::Cloud::PubSub::V1::TopicAdmin::Client

    other_topic_admin = new_pubsub.topic_admin_client
    _(other_topic_admin).must_equal topic_admin
  end


  it "configures the V1::TopicAdmin::Client" do
    credentials = :this_channel_is_insecure
    universe_domain = "googleapis.com"

    lib_name = "gccl"
    lib_version = Google::Cloud::PubSub::VERSION
    expected_metadata = { "google-cloud-resource-prefix": "projects/#{project}" }
    # Clear all environment variables
    ENV.stub :[], nil do
      Google::Auth::Credentials.stub :default, credentials do
        Gapic::ServiceStub.stub :new, dummy_stub do
          other_pubsub = Google::Cloud::PubSub::Project.new Google::Cloud::PubSub::Service.new(project, credentials)
          _(other_pubsub.project).must_equal project
          config = other_pubsub.topic_admin_client.configure
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
end
