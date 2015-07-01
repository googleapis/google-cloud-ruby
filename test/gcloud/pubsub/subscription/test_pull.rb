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

describe Gcloud::Pubsub::Subscription, :pull, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let :subscription do
    Gcloud::Pubsub::Subscription.from_gapi sub_hash, pubsub.connection
  end

  it "can pull messages" do
    rec_message_msg = "pulled-message"
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       rec_messages_json(rec_message_msg)]
    end

    rec_messages = subscription.pull
    rec_messages.wont_be :empty?
    rec_messages.first.message.data.must_equal rec_message_msg
  end

  describe "lazy subscription object of a subscription that does exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "can pull messages" do
      rec_message_msg = "pulled-message"
      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
        [200, {"Content-Type"=>"application/json"},
         rec_messages_json(rec_message_msg)]
      end

      rec_messages = subscription.pull
      rec_messages.wont_be :empty?
      rec_messages.first.message.data.must_equal rec_message_msg
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "raises NotFoundError when pulling messages" do
      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.pull
      end.must_raise Gcloud::Pubsub::NotFoundError
    end
  end
end
