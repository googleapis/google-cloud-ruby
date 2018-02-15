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

describe Google::Cloud::Pubsub::Subscription, :attributes, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_deadline) { sub_hash["ack_deadline_seconds"] }
  let(:sub_endpoint) { sub_hash["push_config"]["push_endpoint"] }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "gets topic from the Google API object" do
    # No mocked service means no API calls are happening.
    subscription.topic.must_be_kind_of Google::Cloud::Pubsub::Topic
    subscription.topic.must_be :lazy?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "gets deadline from the Google API object" do
    subscription.deadline.must_equal sub_deadline
  end

  it "gets retain_acked from the Google API object" do
    assert subscription.retain_acked
  end

  it "gets its retention from the Google API object" do
    subscription.retention.must_equal 600.9
  end

  it "gets endpoint from the Google API object" do
    subscription.endpoint.must_equal sub_endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"
    push_config = Google::Pubsub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription_path(sub_name), push_config, options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  describe "lazy subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.service
    end

    it "makes an HTTP API call to retrieve topic" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.topic.must_be_kind_of Google::Cloud::Pubsub::Topic

      mock.verify

      subscription.topic.must_be :lazy?
      subscription.topic.name.must_equal topic_path(topic_name)
    end

    it "makes an HTTP API call to retrieve deadline" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.deadline.must_equal sub_deadline

      mock.verify
    end

    it "makes an HTTP API call to retrieve retain_acked" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      assert subscription.retain_acked

      mock.verify
    end

    it "makes an HTTP API call to retrieve endpoint" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.endpoint.must_equal sub_endpoint

      mock.verify
    end

    it "makes an HTTP API call to update endpoint" do
      new_push_endpoint = "https://foo.bar/baz"
      push_config = Google::Pubsub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
      mpc_res = nil
      mock = Minitest::Mock.new
      mock.expect :modify_push_config, mpc_res, [subscription_path(sub_name), push_config, options: default_options]
      pubsub.service.mocked_subscriber = mock

      subscription.endpoint = new_push_endpoint

      mock.verify
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when retrieving topic" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.topic
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving deadline" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.deadline
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving endpoint" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.endpoint
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when updating endpoint" do
      new_push_endpoint = "https://foo.bar/baz"

      stub = Object.new
      def stub.modify_push_config *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.endpoint = new_push_endpoint
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
