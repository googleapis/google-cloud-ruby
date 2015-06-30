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
  let(:event1) { Gcloud::Pubsub::Event.from_gapi \
                  JSON.parse(event_json("event1-msg-goes-here")), subscription }
  let(:event2) { Gcloud::Pubsub::Event.from_gapi \
                  JSON.parse(event_json("event2-msg-goes-here")), subscription }
  let(:event3) { Gcloud::Pubsub::Event.from_gapi \
                  JSON.parse(event_json("event3-msg-goes-here")), subscription }

  it "can acknowledge an ack id" do
    ack_id = event1.ack_id

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].must_equal [ack_id]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge ack_id
  end

  it "can acknowledge many ack ids" do
    ack_ids = [event1.ack_id, event3.ack_id, event3.ack_id]

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].must_equal ack_ids
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge *ack_ids
  end

  it "can acknowledge a message" do
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].must_equal [event1.ack_id]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge event1
  end

  it "can acknowledge many messages" do
    events  = [event1, event3, event3]
    ack_ids = events.map &:ack_id

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
      JSON.parse(env.body)["ackIds"].must_equal ack_ids
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.acknowledge *events
  end

  describe "lazy subscription object of a subscription that does exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "can acknowledge an ack id" do
      ack_id = event1.ack_id

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal [ack_id]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.acknowledge ack_id
    end

    it "can acknowledge many ack ids" do
      ack_ids = [event1.ack_id, event3.ack_id, event3.ack_id]

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal ack_ids
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.acknowledge *ack_ids
    end

    it "can acknowledge a message" do
      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal [event1.ack_id]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.acknowledge event1
    end

    it "can acknowledge many messages" do
      events  = [event1, event3, event3]
      ack_ids = events.map &:ack_id

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal ack_ids
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.acknowledge *events
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "raises NotFoundError when acknowledging an ack id" do
      ack_id = event1.ack_id

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal [ack_id]
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.acknowledge ack_id
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when acknowledging many ack ids" do
      ack_ids = [event1.ack_id, event3.ack_id, event3.ack_id]

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal ack_ids
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.acknowledge *ack_ids
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when acknowledging a message" do
      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal [event1.ack_id]
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.acknowledge event1
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when acknowledging many messages" do
      events  = [event1, event3, event3]
      ack_ids = events.map &:ack_id

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:acknowledge" do |env|
        JSON.parse(env.body)["ackIds"].must_equal ack_ids
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.acknowledge *events
      end.must_raise Gcloud::Pubsub::NotFoundError
    end
  end
end
