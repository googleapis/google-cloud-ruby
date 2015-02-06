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
  let(:event_data)  { JSON.parse(event_json(subscription_name, event_msg)) }
  let(:event) { Gcloud::Pubsub::Event.from_gapi event_data,
                                                pubsub.connection }

  it "knows its subscription" do
    event.subscription.must_equal subscription_path(subscription_name)
  end

  it "knows its ack_id" do
    event.ack_id.must_equal event_data["ackId"]
  end

  it "knows its message" do
    event.msg.must_equal event_data["pubsubEvent"]["message"]["data"]
    event.message.must_equal event_data["pubsubEvent"]["message"]["data"]
  end

  it "knows its message_id" do
    event.msg_id.must_equal event_data["pubsubEvent"]["message"]["messageId"]
    event.message_id.must_equal event_data["pubsubEvent"]["message"]["messageId"]
  end

  it "can acknowledge" do
    mock_connection.post "/pubsub/v1beta1/subscriptions/acknowledge" do |env|
      JSON.parse(env.body)["subscription"].must_equal subscription_path(subscription_name)
      JSON.parse(env.body)["ackId"].count.must_equal 1
      JSON.parse(env.body)["ackId"].first.must_equal event.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    event.acknowledge!
  end

  it "can ack" do
    mock_connection.post "/pubsub/v1beta1/subscriptions/acknowledge" do |env|
      JSON.parse(env.body)["subscription"].must_equal subscription_path(subscription_name)
      JSON.parse(env.body)["ackId"].count.must_equal 1
      JSON.parse(env.body)["ackId"].first.must_equal event.ack_id
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    event.ack!
  end
end
