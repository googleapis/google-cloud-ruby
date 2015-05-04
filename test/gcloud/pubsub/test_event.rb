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

describe Gcloud::Pubsub::Event, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  let(:subscription_name) { "subscription-name-goes-here" }
  let :subscription do
    json = JSON.parse(subscription_json(topic_name, subscription_name))
    Gcloud::Pubsub::Subscription.from_gapi json, pubsub.connection
  end
  let(:event_name) { "event-name-goes-here" }
  let(:event_msg)  { "event-msg-goes-here" }
  let(:event_data)  { JSON.parse(event_json(event_msg)) }
  let(:event) { Gcloud::Pubsub::Event.from_gapi event_data,
                                                subscription }

  it "knows its subscription" do
    event.subscription.wont_be :nil?
    event.subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its ack_id" do
    event.ack_id.must_equal event_data["ackId"]
  end

  it "has a message" do
    event.message.wont_be :nil?
    event.message.data.must_equal event_data["message"]["data"]
    event.message.attributes.must_equal event_data["message"]["attributes"]
    event.message.msg_id.must_equal event_data["message"]["messageId"]
    event.message.message_id.must_equal event_data["message"]["messageId"]
  end

  it "can acknowledge" do
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal event.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    event.acknowledge!
  end

  it "can ack" do
    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal event.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    event.ack!
  end

  it "can delay" do
    new_deadline = 42

    mock_connection.post "/v1beta2/projects/#{project}/subscriptions/#{subscription_name}:modifyAckDeadline" do |env|
      JSON.parse(env.body)["ackId"].must_equal              event.ack_id
      JSON.parse(env.body)["ackDeadlineSeconds"].must_equal new_deadline
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    event.delay! new_deadline
  end
end
