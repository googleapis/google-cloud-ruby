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

describe Google::Cloud::PubSub::Topic, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name, labels: labels)), pubsub.service }
  let(:subscriptions_with_token) do
    Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(3, "next_page_token")
  end
  let(:subscriptions_without_token) do
    Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(2)
  end
  let(:subscriptions_with_token_2) do
    Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(3, "next_page_token")
  end
  let(:filter) { "attributes.event_type = \"1\"" }
  let(:dead_letter_topic_name) { "topic-name-dead-letter" }
  let(:dead_letter_topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(dead_letter_topic_name)), pubsub.service }
  let(:retry_minimum_backoff) { 12.123 }
  let(:retry_maximum_backoff) { 123.321 }
  let(:retry_policy) do
    Google::Cloud::PubSub::RetryPolicy.new(
      minimum_backoff: retry_minimum_backoff,
      maximum_backoff: retry_maximum_backoff
    )
  end

  it "knows its name" do
    _(topic.name).must_equal topic_path(topic_name)
  end

  it "knows its labels" do
    _(topic.labels).must_equal labels
    _(topic.labels).must_be :frozen?
  end

  it "can delete itself" do
    get_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic.delete

    mock.verify
  end

  it "creates a subscription" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with create_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name)
    topic.service.mocked_subscriber = mock

    sub = topic.create_subscription new_sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with new_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name)
    topic.service.mocked_subscriber = mock

    sub = topic.new_subscription new_sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with a deadline" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    deadline = 42
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, ack_deadline_seconds: 42)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, deadline: deadline

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with retain_acked and retention" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)

    duration = Google::Protobuf::Duration.new seconds: 600, nanos: 0
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, retain_acked_messages: true, message_retention_duration: duration)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, retain_acked: true, retention: 600

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with a push endpoint" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    endpoint = "http://foo.bar/baz"
    push_config = Google::Cloud::PubSub::V1::PushConfig.new(push_endpoint: endpoint)
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, push_config: push_config)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, endpoint: endpoint

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "creates a subscription with an authenticated push endpoint via push config" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    endpoint = "http://foo.bar/baz"

    push_config = Google::Cloud::PubSub::Subscription::PushConfig.new
    push_config.endpoint = endpoint
    push_config.set_oidc_token(
        "service-account@example.net", "audience-header-value"
    )
    
    expected_oidc_token = {
        service_account_email: "service-account@example.net",
        audience: "audience-header-value"
    }
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, oidc_token: expected_oidc_token)

    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, push_config: push_config.to_grpc)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, push_config: push_config

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
  end

  it "raises if both push_config and endpoint are provided" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    endpoint = "http://foo.bar/baz" 
    push_config = Google::Cloud::PubSub::Subscription::PushConfig.new
    push_config.endpoint = endpoint
    assert_raises ArgumentError do
        topic.subscribe new_sub_name, push_config: push_config, endpoint: endpoint
    end
  end

  it "creates a subscription with labels" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, labels: labels)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, labels: labels

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.labels).must_equal labels
    _(sub.labels).must_be :frozen?
  end

  it "creates a subscription with filter" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, filter: filter)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, filter: filter)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, filter: filter

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.filter).must_equal filter
    _(sub.filter).must_be :frozen?
  end

  it "creates a subscription with dead_letter_topic and dead_letter_max_delivery_attempts" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, dead_letter_topic: dead_letter_topic_name, max_delivery_attempts: 7)
    dead_letter_policy = Google::Cloud::PubSub::V1::DeadLetterPolicy.new dead_letter_topic: topic_path(dead_letter_topic_name), max_delivery_attempts: 7
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, dead_letter_policy: dead_letter_policy)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, dead_letter_topic: dead_letter_topic, dead_letter_max_delivery_attempts: 7

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.dead_letter_topic.name).must_equal topic_path(dead_letter_topic_name)
    _(sub.dead_letter_max_delivery_attempts).must_equal 7
  end

  it "raises when creating a subscription with dead_letter_max_delivery_attempts but no dead_letter_topic" do
    assert_raises ArgumentError do
      topic.subscribe "my-new-sub", dead_letter_max_delivery_attempts: 7
    end
  end

  it "creates a subscription with retry_minimum_backoff and retry_maximum_backoff" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, new_sub_name, retry_minimum_backoff: retry_minimum_backoff, retry_maximum_backoff: retry_maximum_backoff)
    retry_policy_grpc = Google::Cloud::PubSub::V1::RetryPolicy.new minimum_backoff: retry_minimum_backoff, maximum_backoff: retry_maximum_backoff
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, create_subscription_args(new_sub_name, topic_name, retry_policy: retry_policy_grpc)
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, retry_policy: retry_policy

    mock.verify

    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.retry_policy.minimum_backoff).must_equal retry_minimum_backoff
    _(sub.retry_policy.maximum_backoff).must_equal retry_maximum_backoff
  end

  it "raises when creating a subscription that already exists" do
    existing_sub_name = "existing-sub"

    stub = Object.new
    def stub.create_subscription *args
      raise Google::Cloud::AlreadyExistsError.new("already exists")
    end
    topic.service.mocked_subscriber = stub

    assert_raises Google::Cloud::AlreadyExistsError do
      topic.subscribe existing_sub_name
    end
  end

  it "raises when creating a subscription on a deleted topic" do
    new_sub_name = "new-sub-#{Time.now.to_i}"

    stub = Object.new
    def stub.create_subscription *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    topic.service.mocked_subscriber = stub

    assert_raises Google::Cloud::NotFoundError do
      # Let's assume the topic has been deleted before calling create.
      topic.subscribe new_sub_name
    end
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.get_subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    topic.service.mocked_subscriber = mock

    sub = topic.find_subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "lists subscriptions with find_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    topic.service.mocked_publisher = mock

    subs = topic.find_subscriptions

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "lists subscriptions with list_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    topic.service.mocked_publisher = mock

    subs = topic.list_subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic: topic_path(topic_name), page_size: nil, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions
    second_subs = topic.subscriptions token: first_subs.token

    mock.verify

    _(first_subs.count).must_equal 3
    token = first_subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
    first_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end

    _(second_subs.count).must_equal 2
    _(second_subs.token).must_be :nil?
    second_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: 3, page_token: nil]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions max: 3

    mock.verify

    _(subs.count).must_equal 3
    token = subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic: topic_path(topic_name), page_size: nil, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions with with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: 3, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic: topic_path(topic_name), page_size: 3, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions max: 3
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions with all" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic: topic_path(topic_name), page_size: nil, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all.to_a

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "paginates subscriptions with with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: 3, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic: topic_path(topic_name), page_size: 3, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions(max: 3).all.to_a

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "iterates subscriptions with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_with_token_2, [topic: topic_path(topic_name), page_size: nil, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all.take(5)

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "iterates subscriptions with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic: topic_path(topic_name), page_size: nil, page_token: nil]
    mock.expect :list_topic_subscriptions, subscriptions_with_token_2, [topic: topic_path(topic_name), page_size: nil, page_token: "next_page_token"]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all(request_limit: 1).to_a

    mock.verify

    _(subs.count).must_equal 6
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).must_be :reference?
      _(sub).wont_be :resource?
    end
  end

  it "can publish a message" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = topic.publish message

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
  end

  it "can publish a message with attributes" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg, attributes: { "format" => "text" })
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msg = topic.publish message, format: :text

    mock.verify

    _(msg).must_be_kind_of Google::Cloud::PubSub::Message
    _(msg.message_id).must_equal "msg1"
    _(msg.attributes["format"]).must_equal "text"
  end

  it "can publish multiple messages with a block" do
    message1 = "first-new-message"
    message2 = "second-new-message"
    encoded_msg1 = message1.encode(Encoding::ASCII_8BIT)
    encoded_msg2 = message2.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg1),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg2, attributes: { "format" => "none" })
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1", "msg2"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic: topic_path(topic_name), messages: messages]
    topic.service.mocked_publisher = mock

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2, format: :none
    end

    mock.verify

    _(msgs.count).must_equal 2
    _(msgs.first).must_be_kind_of Google::Cloud::PubSub::Message
    _(msgs.first.message_id).must_equal "msg1"
    _(msgs.last).must_be_kind_of Google::Cloud::PubSub::Message
    _(msgs.last.message_id).must_equal "msg2"
    _(msgs.last.attributes["format"]).must_equal "none"
  end
end
