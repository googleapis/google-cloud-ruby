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

describe Gcloud::Pubsub::Message, :mock_pubsub do
  let(:data)       { "event-msg-goes-here" }
  let(:attributes) { { "foo" => "FOO", "bar" => "BAR" } }
  let(:msg)    { Gcloud::Pubsub::Message.new data, attributes }

  it "knows its data" do
    msg.data.must_equal data
  end

  it "knows its attributes" do
    msg.attributes.must_equal attributes
  end

  describe "from gapi" do
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
    let(:msg)     { Gcloud::Pubsub::Message.from_gapi event_data["message"] }

    it "knows its data" do
      msg.data.must_equal event_data["message"]["data"]
    end

    it "knows its attributes" do
      msg.attributes.must_equal event_data["message"]["attributes"]
    end

    it "knows its message_id" do
      msg.msg_id.must_equal     event_data["message"]["messageId"]
      msg.message_id.must_equal event_data["message"]["messageId"]
    end
  end
end
