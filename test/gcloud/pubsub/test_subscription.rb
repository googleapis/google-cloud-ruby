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
    subscription.topic.must_equal topic_path(topic_name)
  end

  it "has an ack deadline" do
    subscription.must_respond_to :deadline
  end

  it "has an endpoint" do
    subscription.must_respond_to :endpoint
  end

  it "can delete itself" do
    mock_connection.delete "/pubsub/v1beta1#{subscription_path subscription_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.delete
  end

  it "can pull a message" do
    event_msg = "pulled-message"
    mock_connection.post "/pubsub/v1beta1/subscriptions/pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       event_json(subscription_name, event_msg)]
    end

    event = subscription.pull
    event.wont_be :nil?
    event.message.must_equal event_msg
  end

  it "can acknowledge one message" do
    mock_connection.post "/pubsub/v1beta1/subscriptions/acknowledge" do |env|
      JSON.parse(env.body)["subscription"].must_equal subscription_path(subscription_name)
      JSON.parse(env.body)["ackId"].count.must_equal 1
      JSON.parse(env.body)["ackId"].first.must_equal "ack-id-1"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge "ack-id-1"
  end

  it "can acknowledge many messages" do
    mock_connection.post "/pubsub/v1beta1/subscriptions/acknowledge" do |env|
      JSON.parse(env.body)["subscription"].must_equal subscription_path(subscription_name)
      JSON.parse(env.body)["ackId"].count.must_equal 3
      JSON.parse(env.body)["ackId"].must_include "ack-id-1"
      JSON.parse(env.body)["ackId"].must_include "ack-id-2"
      JSON.parse(env.body)["ackId"].must_include "ack-id-3"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge "ack-id-1", "ack-id-2", "ack-id-3"
  end

  it "can acknowledge with ack" do
    mock_connection.post "/pubsub/v1beta1/subscriptions/acknowledge" do |env|
      JSON.parse(env.body)["subscription"].must_equal subscription_path(subscription_name)
      JSON.parse(env.body)["ackId"].count.must_equal 1
      JSON.parse(env.body)["ackId"].first.must_equal "ack-id-1"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.ack "ack-id-1"
  end
end
