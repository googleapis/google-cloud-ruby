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

describe Google::Cloud::PubSub::Service, :publisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:msg) { "new-message-here" }
  let(:encoded_msg) { msg.encode Encoding::ASCII_8BIT }
  let(:messages) { [Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg)] }
  let(:publish_res) { Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] }) }

  after do
    # Restore defaults
    Google::Cloud::PubSub::V1::Publisher::Client.configure do |config|
      config.rpcs.publish.timeout = 60.0
    end
  end

  it "does not apply Service#initialize timeout param to #publish RPC CallOptions" do
    service = Google::Cloud::PubSub::Service.new project, :this_channel_is_insecure, timeout: 5
    _(service.timeout).must_equal 5

    mock = Minitest::Mock.new
    mock.expect :call_rpc, publish_res do |method, request, options|
      _(options[:options].timeout).must_equal 60 # Default set in V1::Publisher::Client.configure
      true
    end
    service.publisher.instance_variable_set :@publisher_stub, mock

    service.publish topic_name, messages

    mock.verify
  end

  it "applies V1::Publisher::Client.configure to #publish RPC CallOptions" do
    Google::Cloud::PubSub::V1::Publisher::Client.configure do |config|
      config.rpcs.publish.timeout = 5
    end

    service = Google::Cloud::PubSub::Service.new project, :this_channel_is_insecure

    mock = Minitest::Mock.new
    mock.expect :call_rpc, publish_res do |method, request, options|
      _(options[:options].timeout).must_equal 5
      true
    end
    service.publisher.instance_variable_set :@publisher_stub, mock

    service.publish topic_name, messages

    mock.verify
  end

  it "applies Service#initialize timeout param to #publish RPC CallOptions when value cleared in V1::Publisher::Client.configure" do
    Google::Cloud::PubSub::V1::Publisher::Client.configure do |config|
      config.rpcs.publish.timeout = nil
    end

    service = Google::Cloud::PubSub::Service.new project, :this_channel_is_insecure, timeout: 5

    mock = Minitest::Mock.new
    mock.expect :call_rpc, publish_res do |method, request, options|
      _(options[:options].timeout).must_equal 5
      true
    end
    service.publisher.instance_variable_set :@publisher_stub, mock

    service.publish topic_name, messages

    mock.verify
  end
end
