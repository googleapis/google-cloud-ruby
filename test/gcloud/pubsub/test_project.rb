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
    mock_connection.put "/v1beta2/projects/#{project}/topics/#{new_topic_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       topic_json(new_topic_name)]
    end

    pubsub.create_topic new_topic_name
  end

  it "gets a topic" do
    topic_name = "found-topic"
    mock_connection.get "/v1beta2/projects/#{project}/topics/#{topic_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       topic_json(topic_name)]
    end

    topic = pubsub.topic topic_name
    topic.name.must_equal topic_path(topic_name)
  end

  it "lists topics" do
    num_topics = 3
    mock_connection.get "/v1beta2/projects/#{project}/topics" do |env|
      [200, {"Content-Type"=>"application/json"},
       topics_json(num_topics)]
    end

    topics = pubsub.topics
    topics.size.must_equal num_topics
  end

  it "paginates topics" do
    mock_connection.get "/v1beta2/projects/#{project}/topics" do |env|
      [200, {"Content-Type"=>"application/json"},
       topics_json(3, "next_page_token")]
    end
    mock_connection.get "/v1beta2/projects/#{project}/topics" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       topics_json(2)]
    end

    first_topics = pubsub.topics
    first_topics.size.must_equal 3
    first_topics.token.wont_be :nil?
    first_topics.token.must_equal "next_page_token"

    second_topics = pubsub.topics token: first_topics.token
    second_topics.size.must_equal 2
    second_topics.token.must_be :nil?
  end

  it "paginates topics with max set" do
    mock_connection.get "/v1beta2/projects/#{project}/topics" do |env|
      env.params.must_include "pageSize"
      env.params["pageSize"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       topics_json(3, "next_page_token")]
    end

    topics = pubsub.topics max: 3
    topics.size.must_equal 3
    topics.token.wont_be :nil?
    topics.token.must_equal "next_page_token"
  end

  it "paginates topics without max set" do
    mock_connection.get "/v1beta2/projects/#{project}/topics" do |env|
      env.params.wont_include "pageSize"
      [200, {"Content-Type"=>"application/json"},
       topics_json(3, "next_page_token")]
    end

    topics = pubsub.topics
    topics.size.must_equal 3
    topics.token.wont_be :nil?
    topics.token.must_equal "next_page_token"
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions/#{sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json("random-topic", sub_name)]
    end

    sub = pubsub.subscription sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "lists subscriptions" do
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3)]
    end

    subs = pubsub.subscriptions
    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "paginates subscriptions" do
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 2)]
    end

    first_subs = pubsub.subscriptions
    first_subs.count.must_equal 3
    first_subs.token.wont_be :nil?
    first_subs.token.must_equal "next_page_token"

    second_subs = pubsub.subscriptions token: first_subs.token
    second_subs.count.must_equal 2
    second_subs.token.must_be :nil?
  end

  it "paginates subscriptions with max set" do
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions" do |env|
      env.params.must_include "pageSize"
      env.params["pageSize"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end

    subs = pubsub.subscriptions max: 3
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

  it "paginates subscriptions without max set" do
    mock_connection.get "/v1beta2/projects/#{project}/subscriptions" do |env|
      env.params.wont_include "pageSize"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end

    subs = pubsub.subscriptions
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
  end

end
