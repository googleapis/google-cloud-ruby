# Copyright 2014 Google Inc. All rights reserved.
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

describe Gcloud::Pubsub::Project, :mock_pubsub do
  it "knows the project identifier" do
    pubsub.project.must_equal project
  end

  it "creates a topic" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_req = Google::Pubsub::V1::Topic.new(
      name: topic_path(new_topic_name)
    )
    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [create_req]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name

    mock.verify

    topic.name.must_equal topic_path(new_topic_name)
  end

  it "creates a topic with new_topic_alias" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_req = Google::Pubsub::V1::Topic.new(
      name: topic_path(new_topic_name)
    )
    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [create_req]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.new_topic new_topic_name

    mock.verify

    topic.name.must_equal topic_path(new_topic_name)
  end

  it "gets a topic" do
    topic_name = "found-topic"

    get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "gets a topic with get_topic alias" do
    topic_name = "found-topic"

    get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.get_topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "gets a topic with find_topic alias" do
    topic_name = "found-topic"

    get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.find_topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "returns nil when getting an non-existant topic" do
    not_found_topic_name = "not-found-topic"

    stub = Object.new
    def stub.get_topic *args
      raise GRPC::BadStatus.new 5, "not found"
    end
    pubsub.service.mocked_publisher = stub

    topic = pubsub.find_topic not_found_topic_name
    topic.must_be :nil?
  end

  it "gets a topic with skip_lookup option" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true
    topic.name.must_equal topic_path(topic_name)
    topic.must_be :lazy?
  end

  it "gets a topic with skip_lookup and project options" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true, project: "custom"
    topic.name.must_equal "projects/custom/topics/found-topic"
    topic.must_be :lazy?
  end

  it "lists topics" do
    num_topics = 3

    get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(num_topics)
    mock = Minitest::Mock.new
    mock.expect :list_topics, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    topics.size.must_equal num_topics
  end

  it "lists topics with find_topics alias" do
    num_topics = 3

    get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(num_topics)
    mock = Minitest::Mock.new
    mock.expect :list_topics, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.find_topics

    mock.verify

    topics.size.must_equal num_topics
  end

  it "lists topics with list_topics alias" do
    num_topics = 3

    get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(num_topics)
    mock = Minitest::Mock.new
    mock.expect :list_topics, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.list_topics

    mock.verify

    topics.size.must_equal num_topics
  end

  it "paginates topics" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = pubsub.topics token: first_topics.token

    mock.verify

    first_topics.size.must_equal 3
    first_topics.token.wont_be :nil?
    first_topics.token.must_equal "next_page_token"

    second_topics.size.must_equal 2
    second_topics.token.must_be :nil?
  end

  it "paginates topics with max set" do
    get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_size: 3
    get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_topics, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics max: 3

    mock.verify

    topics.size.must_equal 3
    topics.token.wont_be :nil?
    topics.token.must_equal "next_page_token"
  end

  it "paginates topics with next? and next" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = first_topics.next

    mock.verify

    first_topics.size.must_equal 3
    first_topics.next?.must_equal true

    second_topics.size.must_equal 2
    second_topics.next?.must_equal false
  end

  it "paginates topics with next? and next and max set" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_size: 3
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_size: 3, page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics max: 3
    second_topics = first_topics.next

    mock.verify

    first_topics.size.must_equal 3
    first_topics.next?.must_equal true

    second_topics.size.must_equal 2
    second_topics.next?.must_equal false
  end

  it "paginates topics with all" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.to_a

    mock.verify

    topics.size.must_equal 5
  end

  it "paginates topics with all and max set" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_size: 3
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_size: 3, page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics(max: 3).all.to_a

    mock.verify

    topics.size.must_equal 5
  end

  it "iterates topics with all using Enumerator" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "second_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.take(5)

    mock.verify

    topics.size.must_equal 5
  end

  it "iterates topics with all and request_limit set" do
    first_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "second_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_topics, first_get_res, [first_get_req]
    mock.expect :list_topics, second_get_res, [second_get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all(request_limit: 1).to_a

    mock.verify

    topics.size.must_equal 6
  end

  it "paginates topics without max set" do
    get_req = Google::Pubsub::V1::ListTopicsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_topics, get_res, [get_req]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    topics.size.must_equal 3
    topics.token.wont_be :nil?
    topics.token.must_equal "next_page_token"
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_req = Google::Pubsub::V1::GetSubscriptionRequest.new subscription: "projects/#{project}/subscriptions/#{sub_name}"
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_req = Google::Pubsub::V1::GetSubscriptionRequest.new subscription: "projects/#{project}/subscriptions/#{sub_name}"
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.get_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_req = Google::Pubsub::V1::GetSubscriptionRequest.new subscription: "projects/#{project}/subscriptions/#{sub_name}"
    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.find_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "returns nil when getting an non-existant subscription" do
    not_found_sub_name = "does-not-exist"

    stub = Object.new
    def stub.get_subscription *args
      raise GRPC::BadStatus.new 5, "not found"
    end
    pubsub.service.mocked_subscriber = stub

    sub = pubsub.subscription not_found_sub_name
    sub.must_be :nil?
  end

  it "gets a subscription with skip_lookup option" do
    sub_name = "found-sub-#{Time.now.to_i}"
    # No HTTP mock needed, since the lookup is not made

    sub = pubsub.subscription sub_name, skip_lookup: true
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.must_be :lazy?
  end

  it "gets a subscription with skip_lookup and project options" do
    sub_name = "found-sub-#{Time.now.to_i}"
    # No HTTP mock needed, since the lookup is not made

    sub = pubsub.subscription sub_name, skip_lookup: true, project: "custom"
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal "projects/custom/subscriptions/#{sub_name}"
    sub.must_be :lazy?
  end

  it "lists subscriptions" do
    get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "lists subscriptions with find_subscriptions alias" do
    get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.find_subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "lists subscriptions with list_subscriptions alias" do
    get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.list_subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "paginates subscriptions" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = pubsub.subscriptions token: first_subs.token

    mock.verify

    first_subs.count.must_equal 3
    first_subs.token.wont_be :nil?
    first_subs.token.must_equal "next_page_token"

    second_subs.count.must_equal 2
    second_subs.token.must_be :nil?
  end

  it "paginates subscriptions with max set" do
    get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_size: 3
    get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions max: 3

    mock.verify

    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

  it "paginates subscriptions without max set" do
    get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, get_res, [get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions

    mock.verify

    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

  it "paginates subscriptions with next? and next" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = first_subs.next

    mock.verify

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end

  it "paginates subscriptions with next? and next and max set" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_size: 3
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_size: 3, page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions max: 3
    second_subs = first_subs.next

    mock.verify

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end

  it "paginates subscriptions with all" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.to_a

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end

  it "paginates subscriptions with all and max set" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_size: 3
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_size: 3, page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions(max: 3).all.to_a

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end

  it "iterates subscriptions with all using Enumerator" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "second_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.take(5)

    mock.verify

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end

  it "iterates subscriptions with all and request_limit set" do
    first_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}"
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    second_get_req = Google::Pubsub::V1::ListSubscriptionsRequest.new project: "projects/#{project}", page_token: "next_page_token"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "second_page_token")
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, first_get_res, [first_get_req]
    mock.expect :list_subscriptions, second_get_res, [second_get_req]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all(request_limit: 1).to_a

    mock.verify

    subs.count.must_equal 6
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end
  end
end
