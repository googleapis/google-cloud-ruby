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

describe Gcloud::Pubsub::Subscription, :pull, :autoack, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let :subscription do
    Gcloud::Pubsub::Subscription.from_gapi sub_hash, pubsub.connection
  end
  let(:rec_msg1_json) { rec_message_json "rec_msg1-msg-goes-here" }
  let(:rec_msg2_json) { rec_message_json "rec_msg2-msg-goes-here" }
  let(:rec_msg3_json) { rec_message_json "rec_msg3-msg-goes-here" }
  let(:rec_msgs_json) do
    {
      "receivedMessages" => [
        JSON.parse(rec_msg1_json),
        JSON.parse(rec_msg2_json),
        JSON.parse(rec_msg3_json),
      ]
    }.to_json
  end
  let(:rec_msg1) { Gcloud::Pubsub::ReceivedMessage.from_gapi \
                  JSON.parse(rec_msg1_json), subscription }
  let(:rec_msg2) { Gcloud::Pubsub::ReceivedMessage.from_gapi \
                  JSON.parse(rec_msg2_json), subscription }
  let(:rec_msg3) { Gcloud::Pubsub::ReceivedMessage.from_gapi \
                  JSON.parse(rec_msg3_json), subscription }

  it "can auto acknowledge when pulling messages" do
    ack_ids = [rec_msg1.ack_id, rec_msg2.ack_id, rec_msg3.ack_id]

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       rec_msgs_json]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].must_equal ack_ids
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    rec_messages = subscription.pull autoack: true
    rec_messages.count.must_equal 3
  end
end
