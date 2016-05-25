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

describe Gcloud::Pubsub::Topic, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }

  it "knows its name" do
    topic.name.must_equal topic_path(topic_name)
  end

  it "can delete itself" do
    mock_connection.delete "/v1/projects/#{project}/topics/#{topic_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    topic.delete
  end

  it "creates a subscription" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription with create_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.create_subscription new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription with new_subscription alias" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.new_subscription new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription with a deadline" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    deadline = 42
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal              topic_path(topic_name)
      JSON.parse(env.body)["ackDeadlineSeconds"].must_equal deadline
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name, deadline: deadline
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription with a push endpoint" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    endpoint = "http://foo.bar/baz"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal                      topic_path(topic_name)
      JSON.parse(env.body)["pushConfig"]["pushEndpoint"].must_equal endpoint
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name, endpoint: endpoint
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription when calling subscribe" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "raises when creating a subscription that already exists" do
    existing_sub_name = "existing-sub"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{existing_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [409, {"Content-Type"=>"application/json"},
       already_exists_error_json(existing_sub_name)]
    end

    assert_raises Gcloud::Pubsub::AlreadyExistsError do
      topic.subscribe existing_sub_name
    end
  end

  it "raises when creating a subscription on a deleted topic" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [404, {"Content-Type"=>"application/json"},
       not_found_error_json(topic_name)]
    end

    assert_raises Gcloud::Pubsub::NotFoundError do
      # Let's assume the topic has been deleted before calling create.
      topic.subscribe new_sub_name
    end
  end

  it "gets a subscription" do
    sub_name = "found-sub-#{Time.now.to_i}"
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, sub_name)]
    end

    sub = topic.subscription sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets a subscription with get_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, sub_name)]
    end

    sub = topic.get_subscription sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets a subscription with find_subscription alias" do
    sub_name = "found-sub-#{Time.now.to_i}"
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, sub_name)]
    end

    sub = topic.find_subscription sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "lists subscriptions" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json(topic_name, 3)]
    end

    subs = topic.subscriptions
    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "lists subscriptions with find_subscriptions alias" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json(topic_name, 3)]
    end

    subs = topic.find_subscriptions
    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "lists subscriptions with list_subscriptions alias" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json(topic_name, 3)]
    end

    subs = topic.list_subscriptions
    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "paginates subscriptions" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 2)]
    end

    first_subs = topic.subscriptions
    first_subs.count.must_equal 3
    first_subs.token.wont_be :nil?
    first_subs.token.must_equal "next_page_token"
    first_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end

    second_subs = topic.subscriptions token: first_subs.token
    second_subs.count.must_equal 2
    second_subs.token.must_be :nil?
    second_subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "paginates subscriptions with max set" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      env.params.must_include "pageSize"
      env.params["pageSize"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end

    subs = topic.subscriptions max: 3
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "paginates subscriptions without max set" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      env.params.wont_include "pageSize"
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json("fake-topic", 3, "next_page_token")]
    end

    subs = topic.subscriptions
    subs.count.must_equal 3
    subs.token.wont_be :nil?
    subs.token.must_equal "next_page_token"
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  it "can publish a message" do
    message = "new-message-here"
    base_64_msg = [message].pack("m0")
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal base_64_msg
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = topic.publish message
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "can publish a message with attributes" do
    message = "new-message-here"
    base_64_msg = [message].pack("m0")
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal base_64_msg
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = topic.publish message, format: :text
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
    msg.attributes["format"].must_equal "text"
  end

  it "can publish multiple messages with a block" do
    message1 = "first-new-message"
    message2 = "second-new-message"
    base_64_msg1 = [message1].pack("m0")
    base_64_msg2 = [message2].pack("m0")

    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal base_64_msg1
      JSON.parse(env.body)["messages"].last["data"].must_equal  base_64_msg2
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1", "msg2"] }.to_json]
    end

    msgs = topic.publish do |batch|
      batch.publish message1
      batch.publish message2, format: :none
    end
    msgs.count.must_equal 2
    msgs.first.must_be_kind_of Gcloud::Pubsub::Message
    msgs.first.message_id.must_equal "msg1"
    msgs.last.must_be_kind_of Gcloud::Pubsub::Message
    msgs.last.message_id.must_equal "msg2"
    msgs.last.attributes["format"].must_equal "none"
  end
end
