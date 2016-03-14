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

class Gcloud::Pubsub::ListenMustStopInTests < StandardError; end

describe Gcloud::Pubsub::Subscription, :listen, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let :subscription do
    Gcloud::Pubsub::Subscription.from_gapi sub_hash, pubsub.connection, pubsub.service
  end
  let(:empty_json) { { "receivedMessages" => [] }.to_json }

  it "can listen for messages" do
    rec_message_msg = "pulled-message"
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       rec_messages_json(rec_message_msg)]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       rec_messages_json(rec_message_msg)]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      raise Gcloud::Pubsub::ListenMustStopInTests,
            "time to break the loop by raising an error"
    end

    expect do
      subscription.listen do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests
  end

  it "sleeps when there are no results returned" do
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       empty_json]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
        empty_json]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      raise Gcloud::Pubsub::ListenMustStopInTests,
            "time to break the loop by raising an error"
    end

    $listen_sleep_mock = Minitest::Mock.new
    $listen_sleep_mock.expect :mock_sleep, nil, [1]
    $listen_sleep_mock.expect :mock_sleep, nil, [1]
    def subscription.sleep delay
      $listen_sleep_mock.mock_sleep delay
    end

    expect do
      subscription.listen do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests

    $listen_sleep_mock.verify
    $listen_sleep_mock = nil
  end

  it "sleeps for the value passed in :delay" do
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
       empty_json]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      [200, {"Content-Type"=>"application/json"},
        empty_json]
    end
    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:pull" do |env|
      raise Gcloud::Pubsub::ListenMustStopInTests,
            "time to break the loop by raising an error"
    end

    $listen_sleep_mock = Minitest::Mock.new
    $listen_sleep_mock.expect :mock_sleep, nil, [999]
    $listen_sleep_mock.expect :mock_sleep, nil, [999]
    def subscription.sleep delay
      $listen_sleep_mock.mock_sleep delay
    end

    expect do
      subscription.listen(delay: 999) do |msg|
        msg.must_be_kind_of Gcloud::Pubsub::ReceivedMessage
      end
    end.must_raise Gcloud::Pubsub::ListenMustStopInTests

    $listen_sleep_mock.verify
    $listen_sleep_mock = nil
  end
end
