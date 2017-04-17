# Copyright 2015 Google Inc. All rights reserved.
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

describe Google::Cloud::Pubsub::Project, :subscribe, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:new_sub_name) { "new-sub-#{Time.now.to_i}" }

  it "creates a subscription when calling subscribe" do
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, options: default_options]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscribe topic_name, new_sub_name

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription with a retain_acked value" do
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: true, options: default_options]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscribe topic_name, new_sub_name, retain_acked: true

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription and topic when called with autocreate" do
    new_sub_name = "new-sub-using-autocreate"

    # Create multiple stubs, but not verify the arguments passed in.
    # Use this approach because Minitest::Mock can't verify an error is raised.
    stub_subscriber = Object.new
    def stub_subscriber.create_subscription *args
      first_time = @called.nil?
      @called = true
      if first_time
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      Google::Pubsub::V1::Subscription.decode_json(
        "{\"name\":\"projects/test/subscriptions/new-sub-using-autocreate\",\"topic\":\"projects/test/topics/topic-name-goes-here\",\"push_config\":{\"push_endpoint\":\"http://example.com/callback\"},\"ack_deadline_seconds\":60}")
    end
    pubsub.service.mocked_subscriber = stub_subscriber

    stub_publisher = Object.new
    def stub_publisher.create_topic *args
      Google::Pubsub::V1::Topic.decode_json(
        "{\"name\":\"projects/test/topics/topic-name-goes-here\"}")
    end
    pubsub.service.mocked_publisher = stub_publisher

    sub = pubsub.subscribe topic_name, new_sub_name, autocreate: true
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription but not topic even when called with autocreate" do
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, options: default_options]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscribe topic_name, new_sub_name, autocreate: true

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::pubsub.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "creates a subscription when calling subscribe" do
      create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
      mock = Minitest::Mock.new
      mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, options: default_options]
      pubsub.service.mocked_subscriber = mock

      sub = pubsub.subscribe topic_name, new_sub_name

      mock.verify

      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::pubsub.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "raises NotFoundError when calling subscribe" do
      stub = Object.new
      def stub.create_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      pubsub.service.mocked_subscriber = stub

      expect do
        pubsub.subscribe topic_name, new_sub_name
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
