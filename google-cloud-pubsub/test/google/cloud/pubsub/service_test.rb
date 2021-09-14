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
  let(:endpoint) { "pubsub.googleapis.com" }
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::PubSub::VERSION }
  let(:metadata) { { "google-cloud-resource-prefix": "projects/#{project}" } }

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
        end
      end
    end
  end
end
