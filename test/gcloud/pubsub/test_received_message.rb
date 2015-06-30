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

describe Gcloud::Pubsub::ReceivedMesssage, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  let(:subscription_name) { "subscription-name-goes-here" }
  let :subscription do
    json = JSON.parse(subscription_json(topic_name, subscription_name))
    Gcloud::Pubsub::Subscription.from_gapi json, pubsub.connection
  end
  let(:rec_message_name) { "rec_message-name-goes-here" }
  let(:rec_message_msg)  { "rec_message-msg-goes-here" }
  let(:rec_message_data)  { JSON.parse(rec_message_json(rec_message_msg)) }
  let(:rec_message) { Gcloud::Pubsub::ReceivedMesssage.from_gapi rec_message_data,
                                                subscription }

  it "knows its subscription" do
    rec_message.subscription.wont_be :nil?
    rec_message.subscription.name.must_equal subscription_path(subscription_name)
  end

  it "knows its ack_id" do
    rec_message.ack_id.must_equal rec_message_data["ackId"]
  end

  it "has a message" do
    rec_message.message.wont_be :nil?
    rec_message.message.data.must_equal rec_message_data["message"]["data"]
    rec_message.message.attributes.must_equal rec_message_data["message"]["attributes"]
    rec_message.message.msg_id.must_equal rec_message_data["message"]["messageId"]
    rec_message.message.message_id.must_equal rec_message_data["message"]["messageId"]
  end

  it "can acknowledge" do
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal rec_message.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    rec_message.acknowledge!
  end

  it "can ack" do
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{subscription_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].count.must_equal 1
      JSON.parse(env.body)["ackIds"].first.must_equal rec_message.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    rec_message.ack!
  end

  it "can delay" do
    new_deadline = 42

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{subscription_name}:modifyAckDeadline" do |env|
      JSON.parse(env.body)["ackIds"].must_equal             [rec_message.ack_id]
      JSON.parse(env.body)["ackDeadlineSeconds"].must_equal new_deadline
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    rec_message.delay! new_deadline
  end
end
