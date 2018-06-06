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

describe Google::Cloud::Pubsub::Topic, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:subscriptions_with_token) do
    response = Google::Pubsub::V1::ListTopicSubscriptionsResponse.decode_json topic_subscriptions_json(3, "next_page_token")
    paged_enum_struct response
  end
  let(:subscriptions_without_token) do
    response = Google::Pubsub::V1::ListTopicSubscriptionsResponse.decode_json topic_subscriptions_json(2)
    paged_enum_struct response
  end
  let(:subscriptions_with_token_2) do
    response = Google::Pubsub::V1::ListTopicSubscriptionsResponse.decode_json topic_subscriptions_json(3, "next_page_token")
    paged_enum_struct response
  end

  it "knows its name" do
    topic.name.must_equal topic_path(topic_name)
  end

  it "can delete itself" do
    get_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_topic, get_res, [topic_path(topic_name), options: default_options]
    pubsub.service.mocked_publisher = mock

    topic.delete

    mock.verify
  end

  it "creates a subscription" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "creates a subscription with create_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.create_subscription new_sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "creates a subscription with new_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.new_subscription new_sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "creates a subscription with a deadline" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    deadline = 42
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: 42, retain_acked_messages: false, message_retention_duration: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, deadline: deadline

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "creates a subscription with retain_acked and retention" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)

    duration = Google::Protobuf::Duration.new seconds: 600, nanos: 0
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: nil, ack_deadline_seconds: nil, retain_acked_messages: true, message_retention_duration: duration, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, retain_acked: true, retention: 600

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "creates a subscription with a push endpoint" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    endpoint = "http://foo.bar/baz"
    push_config = Google::Pubsub::V1::PushConfig.new(push_endpoint: endpoint)
    create_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, new_sub_name)
    mock = Minitest::Mock.new
    mock.expect :create_subscription, create_res, [subscription_path(new_sub_name), topic_path(topic_name), push_config: push_config, ack_deadline_seconds: nil, retain_acked_messages: false, message_retention_duration: nil, options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscribe new_sub_name, endpoint: endpoint

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
  end

  it "raises when creating a subscription that already exists" do
    existing_sub_name = "existing-sub"

    stub = Object.new
    def stub.create_subscription *args
      gax_error = Google::Gax::GaxError.new "already exists"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(6, "already exists")
      raise gax_error
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
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    topic.service.mocked_subscriber = stub

    assert_raises Google::Cloud::NotFoundError do
      # Let's assume the topic has been deleted before calling create.
      topic.subscribe new_sub_name
    end
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.get_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
    topic.service.mocked_subscriber = mock

    sub = topic.find_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "lists subscriptions with find_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    topic.service.mocked_publisher = mock

    subs = topic.find_subscriptions

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "lists subscriptions with list_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    topic.service.mocked_publisher = mock

    subs = topic.list_subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    opts = {page_size: nil, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions
    second_subs = topic.subscriptions token: first_subs.token

    mock.verify

    first_subs.count.must_equal 3
    token = first_subs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"
    first_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.token.must_be :nil?
    second_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: 3, options: default_options]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions max: 3

    mock.verify

    subs.count.must_equal 3
    token = subs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    opts = {page_size: nil, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions
    second_subs = first_subs.next

    mock.verify

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions with with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: 3, options: default_options]
    opts = {page_size: 3, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    first_subs = topic.subscriptions max: 3
    second_subs = first_subs.next

    mock.verify

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions with all" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    opts = {page_size: nil, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all.to_a

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "paginates subscriptions with with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: 3, options: default_options]
    opts = {page_size: 3, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_without_token, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions(max: 3).all.to_a

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "iterates subscriptions with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    opts = {page_size: nil, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_with_token_2, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all.take(5)

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "iterates subscriptions with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_topic_subscriptions, subscriptions_with_token, [topic_path(topic_name), page_size: nil, options: default_options]
    opts = {page_size: nil, options: token_options("next_page_token")}
    mock.expect :list_topic_subscriptions, subscriptions_with_token_2, [topic_path(topic_name), opts]
    topic.service.mocked_publisher = mock

    subs = topic.subscriptions.all(request_limit: 1).to_a

    mock.verify

    subs.count.must_equal 6
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.must_be :lazy?
    end
  end

  it "can publish a message" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: encoded_msg)
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = topic.publish message

    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "can publish a message with attributes" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: encoded_msg, attributes: { "format" => "text" })
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msg = topic.publish message, format: :text

    mock.verify

    msg.must_be_kind_of Google::Cloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
    msg.attributes["format"].must_equal "text"
  end

  it "can publish multiple messages with a block" do
    message1 = "first-new-message"
    message2 = "second-new-message"
    encoded_msg1 = message1.encode(Encoding::ASCII_8BIT)
    encoded_msg2 = message2.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: encoded_msg1),
      Google::Pubsub::V1::PubsubMessage.new(data: encoded_msg2, attributes: { "format" => "none" })
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    topic.service.mocked_publisher = mock

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2, format: :none
    end

    mock.verify

    msgs.count.must_equal 2
    msgs.first.must_be_kind_of Google::Cloud::Pubsub::Message
    msgs.first.message_id.must_equal "msg1"
    msgs.last.must_be_kind_of Google::Cloud::Pubsub::Message
    msgs.last.message_id.must_equal "msg2"
    msgs.last.attributes["format"].must_equal "none"
  end
end
