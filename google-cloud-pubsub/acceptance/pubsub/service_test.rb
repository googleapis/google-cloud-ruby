# frozen_string_literal: true

# Copyright 2020 Google LLC
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


require "pubsub_helper"

describe Google::Cloud::PubSub::Service, :pubsub do
  let(:config_metadata) { { "google-cloud-resource-prefix": "projects/#{pubsub.project_id}" } }

  it "passes the correct configuration to its v1 subscriber client" do
    _(pubsub.project_id).wont_be :empty?
    config = pubsub.service.subscriber.configure
    _(config).must_be_kind_of Google::Cloud::PubSub::V1::Subscriber::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::PubSub::VERSION
    _(config.metadata).must_equal config_metadata
  end

  it "passes the correct configuration to its v1 publisher client" do
    _(pubsub.project_id).wont_be :empty?
    config = pubsub.service.publisher.configure
    _(config).must_be_kind_of Google::Cloud::PubSub::V1::Publisher::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::PubSub::VERSION
    _(config.metadata).must_equal config_metadata
  end
end
