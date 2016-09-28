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

describe Google::Cloud::Pubsub::Project, :mock_pubsub do
  let(:mock_topics_with_token) do
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    page = Google::Gax::PagedEnumerable::Page.new first_get_res, "next_page_token", "topics"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock
  end
  let(:mock_topics_without_token) do
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    page = Google::Gax::PagedEnumerable::Page.new second_get_res, "next_page_token", "topics"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock.expect :page_token, nil, []
    mock
  end
  let(:mock_topics_both_pages) do
    first_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(3, "next_page_token")
    page = Google::Gax::PagedEnumerable::Page.new first_get_res, "next_page_token", "topics"
    second_get_res = Google::Pubsub::V1::ListTopicsResponse.decode_json topics_json(2)
    page_2 = Google::Gax::PagedEnumerable::Page.new second_get_res, "next_page_token", "topics"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock.expect :next_page?, true, []
    mock.expect :next_page, page_2, []
    mock.expect :page, page_2, []
    mock.expect :next_page?, true, []
    mock
  end
  let(:mock_subscriptions_with_token) do
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    page = Google::Gax::PagedEnumerable::Page.new first_get_res, "next_page_token", "subscriptions"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock
  end
  let(:mock_subscriptions_without_token) do
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    page = Google::Gax::PagedEnumerable::Page.new second_get_res, "next_page_token", "subscriptions"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock.expect :page_token, nil, []
    mock
  end
  let(:mock_subscriptions_both_pages) do
    first_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 3, "next_page_token")
    page = Google::Gax::PagedEnumerable::Page.new first_get_res, "next_page_token", "subscriptions"
    second_get_res = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("fake-topic", 2)
    page_2 = Google::Gax::PagedEnumerable::Page.new second_get_res, "next_page_token", "subscriptions"
    mock = Minitest::Mock.new
    mock.expect :page, page, []
    mock.expect :next_page?, true, []
    mock.expect :next_page, page_2, []
    mock.expect :page, page_2, []
    mock.expect :next_page?, true, []
    mock
  end

  it "knows the project identifier" do
    pubsub.project.must_equal project
  end

  it "creates a topic" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [topic_path(new_topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name

    mock.verify

    topic.name.must_equal topic_path(new_topic_name)
  end

  it "creates a topic with new_topic_alias" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [topic_path(new_topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.new_topic new_topic_name

    mock.verify

    topic.name.must_equal topic_path(new_topic_name)
  end

  it "gets a topic" do
    topic_name = "found-topic"

    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "gets a topic with get_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.get_topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "gets a topic with find_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.find_topic topic_name

    mock.verify

    topic.name.must_equal topic_path(topic_name)
    topic.wont_be :lazy?
  end

  it "returns nil when getting an non-existent topic" do
    not_found_topic_name = "not-found-topic"

    stub = Object.new
    def stub.get_topic *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
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
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    topics.size.must_equal 3

    mock.verify
    mock_topics_with_token.verify
  end

  it "lists topics with find_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.find_topics

    topics.size.must_equal 3

    mock.verify
    mock_topics_with_token.verify
  end

  it "lists topics with list_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.list_topics

    topics.size.must_equal 3

    mock.verify
    mock_topics_with_token.verify
  end

  it "paginates topics" do
    mock_topics_with_token.expect :page_token, "next_page_token", []
    mock_topics_with_token.expect :page_token, "next_page_token", []

    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: nil, options: nil]
    {page_size: nil, options: Google::Gax::CallOptions.new(page_token: "next_page_token")} # TODO: use this instead of Hash, below
    mock.expect :list_topics, mock_topics_without_token, ["projects/#{project}", Hash]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = pubsub.topics token: first_topics.token


    first_topics.size.must_equal 3
    token = first_topics.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_topics.size.must_equal 2
    second_topics.token.must_be :nil?

    mock.verify
    mock_topics_with_token.verify
    mock_topics_without_token.verify
  end

  it "paginates topics with max set" do
    mock_topics_with_token.expect :page_token, "next_page_token", []
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics max: 3

    topics.size.must_equal 3
    token = topics.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    mock.verify
    mock_topics_with_token.verify
  end

  it "paginates topics with next? and next" do
    mock_topics_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = first_topics.next

    first_topics.size.must_equal 3
    first_topics.next?.must_equal true

    second_topics.size.must_equal 2
    second_topics.next?.must_equal false

    mock.verify
    mock_topics_both_pages.verify
  end

  it "paginates topics with next? and next and max set" do
    mock_topics_both_pages.expect :next_page?, false, []
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics max: 3
    second_topics = first_topics.next

    first_topics.size.must_equal 3
    first_topics.next?.must_equal true

    second_topics.size.must_equal 2
    second_topics.next?.must_equal false

    mock.verify
    mock_topics_both_pages.verify
  end

  it "paginates topics with all" do
    mock_topics_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.to_a

    topics.size.must_equal 5

    mock.verify
    mock_topics_both_pages.verify
  end

  it "paginates topics with all and max set" do
    mock_topics_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics(max: 3).all.to_a

    topics.size.must_equal 5

    mock.verify
    mock_topics_both_pages.verify
  end

  it "iterates topics with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.take(5)

    topics.size.must_equal 5

    mock.verify
    mock_topics_both_pages.verify
  end

  it "iterates topics with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all(request_limit: 1).to_a

    topics.size.must_equal 5

    mock.verify
    mock_topics_both_pages.verify
  end

  it "paginates topics without max set" do
    mock_topics_with_token.expect :page_token, "next_page_token", []
    mock = Minitest::Mock.new
    mock.expect :list_topics, mock_topics_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    topics.size.must_equal 3
    token = topics.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    mock.verify
    mock_topics_with_token.verify
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.get_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.find_subscription sub_name

    mock.verify

    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.wont_be :lazy?
  end

  it "returns nil when getting an non-existent subscription" do
    not_found_sub_name = "does-not-exist"

    stub = Object.new
    def stub.get_subscription *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
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
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal subscription_path(sub_name)
    sub.must_be :lazy?
  end

  it "gets a subscription with skip_lookup and project options" do
    sub_name = "found-sub-#{Time.now.to_i}"
    # No HTTP mock needed, since the lookup is not made

    sub = pubsub.subscription sub_name, skip_lookup: true, project: "custom"
    sub.wont_be :nil?
    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.name.must_equal "projects/custom/subscriptions/#{sub_name}"
    sub.must_be :lazy?
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    end

    mock.verify
    mock_subscriptions_with_token.verify
  end

  it "lists subscriptions with find_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.find_subscriptions

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    end

    mock.verify
    mock_subscriptions_with_token.verify
  end

  it "lists subscriptions with list_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_with_token, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.list_subscriptions

    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    end

    mock.verify
    mock_subscriptions_with_token.verify
  end

  it "paginates subscriptions" do
    mock_subscriptions_with_token.expect :page_token, "next_page_token", []
    mock_subscriptions_with_token.expect :page_token, "next_page_token", []

    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_with_token, ["projects/#{project}", page_size: nil, options: nil]
    {page_size: nil, options: Google::Gax::CallOptions.new(page_token: "next_page_token")} # TODO: use this instead of Hash, below
    mock.expect :list_subscriptions, mock_subscriptions_without_token, ["projects/#{project}", Hash]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = pubsub.subscriptions token: first_subs.token

    first_subs.count.must_equal 3
    token = first_subs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_subs.count.must_equal 2
    second_subs.token.must_be :nil?

    mock.verify
    mock_subscriptions_with_token.verify
    mock_subscriptions_without_token.verify
  end

  it "paginates subscriptions with max set" do
    mock_subscriptions_with_token.expect :page_token, "next_page_token", []
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_with_token, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions max: 3

    subs.count.must_equal 3
    token = subs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    mock.verify
    mock_subscriptions_with_token.verify
  end

  it "paginates subscriptions with next? and next" do
    mock_subscriptions_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = first_subs.next

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end

  it "paginates subscriptions with next? and next and max set" do
    mock_subscriptions_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions max: 3
    second_subs = first_subs.next

    first_subs.count.must_equal 3
    first_subs.next?.must_equal true
    first_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    second_subs.count.must_equal 2
    second_subs.next?.must_equal false
    second_subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end

  it "paginates subscriptions with all" do
    mock_subscriptions_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.to_a

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end

  it "paginates subscriptions with all and max set" do
    mock_subscriptions_both_pages.expect :next_page?, false, []

    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: 3, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions(max: 3).all.to_a

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end

  it "iterates subscriptions with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.take(5)

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end

  it "iterates subscriptions with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, mock_subscriptions_both_pages, ["projects/#{project}", page_size: nil, options: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all(request_limit: 1).to_a

    subs.count.must_equal 5
    subs.each do |sub|
      sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    mock.verify
    mock_subscriptions_both_pages.verify
  end
end
