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

describe Google::Cloud::Pubsub::Topic, :subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:found_sub_name) { "found-sub-#{Time.now.to_i}" }
  let(:not_found_sub_name) { "found-sub-#{Time.now.to_i}" }

  it "gets an existing subscription" do
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(found_sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscription found_sub_name

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets an existing subscription with get_subscription alias" do
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(found_sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.get_subscription found_sub_name

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets an existing subscription with find_subscription alias" do
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, found_sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(found_sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.find_subscription found_sub_name

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "returns nil when getting an non-existant subscription" do
    stub = Object.new
    def stub.get_subscription *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    topic.service.mocked_subscriber = stub

    sub = topic.subscription found_sub_name
    sub.must_be :nil?
  end

  it "gets a subscription with skip_lookup option" do
    # No HTTP mock needed, since the lookup is not made

    sub = topic.find_subscription found_sub_name, skip_lookup: true
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.must_be :lazy?
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "gets an existing subscription" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, found_sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(found_sub_name), options: default_options]
      topic.service.mocked_subscriber = mock

      sub = topic.subscription found_sub_name

      mock.verify

      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    it "returns nil when getting an non-existant subscription" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      topic.service.mocked_subscriber = stub

      sub = topic.subscription found_sub_name
      sub.must_be :nil?
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "returns nil when getting an non-existant subscription" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      topic.service.mocked_subscriber = stub

      sub = topic.subscription found_sub_name
      sub.must_be :nil?
    end
  end
end
