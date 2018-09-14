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

describe Google::Cloud::Pubsub::Topic, :subscribe, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:new_sub_name) { "new-sub-#{Time.now.to_i}" }
  let(:labels) { { "foo" => "bar" } }

  it "creates a subscription when calling subscribe" do
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, labels: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription with labels" do
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, labels: labels, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, labels: labels

    mock.verify

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    sub.labels.must_equal labels
    sub.labels.must_be :frozen?
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "creates a subscription when calling subscribe" do
      create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
      mock = Minitest::Mock.new
      mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, labels: nil, options: default_options]
      topic.service.mocked_subscriber = mock

      sub = topic.subscribe new_sub_name

      mock.verify

      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service }

    it "raises NotFoundError when calling subscribe" do
      stub = Object.new
      def stub.create_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      topic.service.mocked_subscriber = stub

      expect do
        topic.subscribe new_sub_name
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
