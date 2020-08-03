# Copyright 2014 Google LLC
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

describe Google::Cloud::PubSub::Project, :mock_pubsub do
  let(:topics_with_token) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(3, "next_page_token")
    paged_enum_struct response
  end
  let(:topics_without_token) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(2)
    paged_enum_struct response
  end
  let(:topics_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(3, "second_page_token")
    paged_enum_struct response
  end
  let(:subscriptions_with_token) do
    response = Google::Cloud::PubSub::V1::ListSubscriptionsResponse.new subscriptions_hash("fake-topic", 3, "next_page_token")
    paged_enum_struct response
  end
  let(:subscriptions_without_token) do
    response = Google::Cloud::PubSub::V1::ListSubscriptionsResponse.new subscriptions_hash("fake-topic", 2)
    paged_enum_struct response
  end
  let(:subscriptions_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListSubscriptionsResponse.new subscriptions_hash("fake-topic", 3, "second_page_token")
    paged_enum_struct response
  end
  let(:snapshots_with_token) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 3, "next_page_token")
    paged_enum_struct response
  end
  let(:snapshots_without_token) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 2)
    paged_enum_struct response
  end
  let(:snapshots_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 3, "second_page_token")
    paged_enum_struct response
  end
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key) { "projects/a/locations/b/keyRings/c/cryptoKeys/d" }
  let(:persistence_regions) { ["us-west1", "us-west2"] }

  it "knows the project identifier" do
    _(pubsub.project).must_equal project
  end

  it "creates a topic" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
  end

  it "creates a topic with new_topic_alias" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.new_topic new_topic_name

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
  end

  it "creates a topic with labels" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: labels, kms_key_name: nil, message_storage_policy: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, labels: labels

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_equal labels
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
  end

  it "creates a topic with kms_key" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, kms_key_name: kms_key)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: kms_key, message_storage_policy: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, kms_key: kms_key

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_equal kms_key
    _(topic.persistence_regions).must_be :empty?
  end

  it "creates a topic with persistence_regions" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, persistence_regions: persistence_regions)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: { allowed_persistence_regions: persistence_regions }]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, persistence_regions: persistence_regions

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_equal persistence_regions
  end

  it "gets a topic" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "gets a topic with get_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.get_topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "gets a topic with find_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.find_topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "returns nil when getting an non-existent topic" do
    not_found_topic_name = "not-found-topic"

    stub = Object.new
    def stub.get_topic *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    pubsub.service.mocked_publisher = stub

    topic = pubsub.find_topic not_found_topic_name
    _(topic).must_be :nil?
  end

  it "gets a topic with skip_lookup option" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true
    _(topic.name).must_equal topic_path(topic_name)
    _(topic).must_be :reference?
    _(topic).wont_be :resource?
  end

  it "gets a topic with skip_lookup and project options" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true, project: "custom"
    _(topic.name).must_equal "projects/custom/topics/found-topic"
    _(topic).must_be :reference?
    _(topic).wont_be :resource?
  end

  it "lists topics" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "lists topics with find_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.find_topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "lists topics with list_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.list_topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "paginates topics" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = pubsub.topics token: first_topics.token

    mock.verify

    _(first_topics.size).must_equal 3
    token = first_topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_topics.size).must_equal 2
    _(second_topics.token).must_be :nil?
  end

  it "paginates topics with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics max: 3

    mock.verify

    _(topics.size).must_equal 3
    token = topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates topics with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = first_topics.next

    mock.verify

    _(first_topics.size).must_equal 3
    _(first_topics.next?).must_equal true

    _(second_topics.size).must_equal 2
    _(second_topics.next?).must_equal false
  end

  it "paginates topics with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics max: 3
    second_topics = first_topics.next

    mock.verify

    _(first_topics.size).must_equal 3
    _(first_topics.next?).must_equal true

    _(second_topics.size).must_equal 2
    _(second_topics.next?).must_equal false
  end

  it "paginates topics with all" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.to_a

    mock.verify

    _(topics.size).must_equal 5
  end

  it "paginates topics with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics(max: 3).all.to_a

    mock.verify

    _(topics.size).must_equal 5
  end

  it "iterates topics with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.take(5)

    mock.verify

    _(topics.size).must_equal 5
  end

  it "iterates topics with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all(request_limit: 1).to_a

    mock.verify

    _(topics.size).must_equal 6
  end

  it "paginates topics without max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    _(topics.size).must_equal 3
    token = topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal subscription_path(sub_name)
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.get_subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal subscription_path(sub_name)
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.find_subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal subscription_path(sub_name)
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "returns nil when getting an non-existent subscription" do
    not_found_sub_name = "does-not-exist"

    stub = Object.new
    def stub.get_subscription *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    pubsub.service.mocked_subscriber = stub

    sub = pubsub.subscription not_found_sub_name
    _(sub).must_be :nil?
  end

  it "gets a subscription with skip_lookup option" do
    sub_name = "found-sub-#{Time.now.to_i}"
    # No HTTP mock needed, since the lookup is not made

    sub = pubsub.subscription sub_name, skip_lookup: true
    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal subscription_path(sub_name)
    _(sub).must_be :reference?
    _(sub).wont_be :resource?
  end

  it "gets a subscription with skip_lookup and project options" do
    sub_name = "found-sub-#{Time.now.to_i}"
    # No HTTP mock needed, since the lookup is not made

    sub = pubsub.subscription sub_name, skip_lookup: true, project: "custom"
    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal "projects/custom/subscriptions/#{sub_name}"
    _(sub).must_be :reference?
    _(sub).wont_be :resource?
  end

  it "lists subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    end
  end

  it "lists subscriptions with find_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.find_subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    end
  end

  it "lists subscriptions with list_subscriptions alias" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.list_subscriptions

    mock.verify

    _(subs.count).must_equal 3
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    end
  end

  it "paginates subscriptions" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = pubsub.subscriptions token: first_subs.token

    mock.verify

    _(first_subs.count).must_equal 3
    token = first_subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_subs.count).must_equal 2
    _(second_subs.token).must_be :nil?
  end

  it "paginates subscriptions with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions max: 3

    mock.verify

    _(subs.count).must_equal 3
    token = subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates subscriptions with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  it "paginates subscriptions with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.subscriptions max: 3
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  it "paginates subscriptions with all" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.to_a

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  it "paginates subscriptions with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions(max: 3).all.to_a

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  it "iterates subscriptions with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all.take(5)

    mock.verify

    _(subs.count).must_equal 5
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  it "iterates subscriptions with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_subscriptions, subscriptions_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_subscriptions, subscriptions_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    subs = pubsub.subscriptions.all(request_limit: 1).to_a

    mock.verify

    _(subs.count).must_equal 6
    subs.each do |sub|
      _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
      _(sub).wont_be :reference?
      _(sub).must_be :resource?
    end
  end

  ##
  # List Snapshots

  it "lists snapshots" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "lists snapshots with find_snapshots alias" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.find_snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "lists snapshots with list_snapshots alias" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.list_snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_snapshots, snapshots_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots
    second_subs = pubsub.snapshots token: first_subs.token

    mock.verify

    _(first_subs.count).must_equal 3
    token = first_subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_subs.count).must_equal 2
    _(second_subs.token).must_be :nil?
  end

  it "paginates snapshots with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots max: 3

    mock.verify

    _(snapshots.count).must_equal 3
    token = snapshots.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates snapshots with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_snapshots, snapshots_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_snapshots, snapshots_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots max: 3
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with all" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_snapshots, snapshots_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all.to_a

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_snapshots, snapshots_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots(max: 3).all.to_a

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "iterates snapshots with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_snapshots, snapshots_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all.take(5)

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "iterates snapshots with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_snapshots, snapshots_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all(request_limit: 1).to_a

    mock.verify

    _(snapshots.count).must_equal 6
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end
end
