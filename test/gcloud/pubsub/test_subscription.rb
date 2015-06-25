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

describe Gcloud::Pubsub::Subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:subscription_name) { "subscription-name-goes-here" }
  let :subscription do
    json = JSON.parse(subscription_json(topic_name, subscription_name))
    Gcloud::Pubsub::Subscription.from_gapi json, pubsub.connection
  end

  it "knows its name" do
    subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its topic" do
    subscription.topic.must_be_kind_of Gcloud::Pubsub::Topic
    subscription.topic.must_be :lazy?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "has an ack deadline" do
    subscription.must_respond_to :deadline
  end

  it "has an endpoint" do
    subscription.must_respond_to :endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"

    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:modifyPushConfig" do |env|
      JSON.parse(env.body)["pushConfig"]["pushEndpoint"].must_equal new_push_endpoint
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.endpoint = new_push_endpoint
  end

  it "can delete itself" do
    mock_connection.delete "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.delete
  end

  it "can pull a message" do
    event_msg = "pulled-message"
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       events_json(event_msg)]
    end

    events = subscription.pull
    events.wont_be :empty?
    events.first.message.data.must_equal event_msg
  end

  it "can acknowledge one message" do
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal "ack-id-1"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge "ack-id-1"
  end

  it "can acknowledge many messages" do
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 3
      JSON.parse(env.body)["ackIds"].must_include "ack-id-1"
      JSON.parse(env.body)["ackIds"].must_include "ack-id-2"
      JSON.parse(env.body)["ackIds"].must_include "ack-id-3"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"
  end

  it "can acknowledge with ack" do
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal "ack-id-1"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.ack "ack-id-1"
  end
end
