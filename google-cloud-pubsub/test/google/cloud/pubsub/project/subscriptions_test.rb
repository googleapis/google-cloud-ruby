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

describe Google::Cloud::PubSub::Project, :subscriptions, :mock_pubsub do
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

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res,  subscription: subscription_path(sub_name) 
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_name

    mock.verify

    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal subscription_path(sub_name)
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
  end

  it "gets a subscription with fully-qualified subscription path" do
    sub_full_path = "projects/other-project/subscriptions/found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_full_path)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res,  subscription: sub_full_path 
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_full_path

    mock.verify

    _(sub.name).must_equal sub_full_path
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_name)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res,  subscription: subscription_path(sub_name) 
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
    mock.expect :get_subscription, get_res,  subscription: subscription_path(sub_name) 
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

  it "gets a subscription with project option" do
    sub_name = "found-sub-#{Time.now.to_i}"
    sub_full_path = "projects/custom/subscriptions/#{sub_name}"

    get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash("random-topic", sub_full_path)
    mock = Minitest::Mock.new
    mock.expect :get_subscription, get_res,  subscription: sub_full_path 
    pubsub.service.mocked_subscriber = mock

    sub = pubsub.subscription sub_name, project: "custom"
    _(sub).wont_be :nil?
    _(sub).must_be_kind_of Google::Cloud::PubSub::Subscription
    _(sub.name).must_equal sub_full_path
    _(sub).wont_be :reference?
    _(sub).must_be :resource?
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_without_token,  project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: 3, page_token: nil 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_without_token,  project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: 3, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_without_token,  project: "projects/#{project}", page_size: 3, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_without_token,  project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: 3, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_without_token,  project: "projects/#{project}", page_size: 3, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_with_token_2,  project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
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
    mock.expect :list_subscriptions, subscriptions_with_token,  project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_subscriptions, subscriptions_with_token_2,  project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
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
end
