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

describe Gcloud::Pubsub::Topic, :subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  let(:found_sub_name) { "found-sub-#{Time.now.to_i}" }
  let(:not_found_sub_name) { "found-sub-#{Time.now.to_i}" }

  it "gets an existing subscription" do
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{found_sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, found_sub_name)]
    end

    sub = topic.subscription found_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets an existing subscription with get_subscription alias" do
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{found_sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, found_sub_name)]
    end

    sub = topic.get_subscription found_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "gets an existing subscription with find_subscription alias" do
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{found_sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, found_sub_name)]
    end

    sub = topic.find_subscription found_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "returns nil when getting an non-existant subscription" do
    mock_connection.get "/v1/projects/#{project}/subscriptions/#{not_found_sub_name}" do |env|
      [404, {"Content-Type"=>"application/json"},
       not_found_error_json(not_found_sub_name)]
    end

    sub = topic.subscription found_sub_name
    sub.must_be :nil?
  end

  describe "lazy topic that exists" do
    let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.connection }

    it "gets an existing subscription" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{found_sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"},
         subscription_json(topic_name, found_sub_name)]
      end

      sub = topic.subscription found_sub_name
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.wont_be :lazy?
    end

    it "returns nil when getting an non-existant subscription" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{not_found_sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(not_found_sub_name)]
      end

      sub = topic.subscription found_sub_name
      sub.must_be :nil?
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.connection }

    it "returns nil when getting an non-existant subscription" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{not_found_sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(not_found_sub_name)]
      end

      sub = topic.subscription found_sub_name
      sub.must_be :nil?
    end
  end
end
