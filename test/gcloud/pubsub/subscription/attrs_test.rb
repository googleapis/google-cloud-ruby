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

describe Gcloud::Pubsub::Subscription, :attributes, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_deadline) { sub_hash["ackDeadlineSeconds"] }
  let(:sub_endpoint) { sub_hash["pushConfig"]["pushEndpoint"] }
  let :subscription do
    Gcloud::Pubsub::Subscription.from_gapi sub_hash, pubsub.connection, pubsub.service
  end

  it "gets endpoint from the Google API object" do
    # No mocked connection means no connections are happening.
    subscription.topic.must_be_kind_of Gcloud::Pubsub::Topic
    subscription.topic.must_be :lazy?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "gets endpoint from the Google API object" do
    subscription.deadline.must_equal sub_deadline
  end

  it "gets endpoint from the Google API object" do
    subscription.endpoint.must_equal sub_endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"

    mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:modifyPushConfig" do |env|
      JSON.parse(env.body)["pushConfig"]["pushEndpoint"].must_equal new_push_endpoint
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.endpoint = new_push_endpoint
  end

  describe "lazy subscription object of a subscription that does exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection, pubsub.service
    end

    it "makes an HTTP API call to retrieve topic" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"},
         sub_json]
      end

      subscription.topic.must_be_kind_of Gcloud::Pubsub::Topic
      subscription.topic.must_be :lazy?
      subscription.topic.name.must_equal topic_path(topic_name)
    end

    it "makes an HTTP API call to retrieve deadline" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"},
         sub_json]
      end

      subscription.deadline.must_equal sub_deadline
    end

    it "makes an HTTP API call to retrieve endpoint" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"},
         sub_json]
      end

      subscription.endpoint.must_equal sub_endpoint
    end

    it "makes an HTTP API call to update endpoint" do
      new_push_endpoint = "https://foo.bar/baz"

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:modifyPushConfig" do |env|
        JSON.parse(env.body)["pushConfig"]["pushEndpoint"].must_equal new_push_endpoint
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.endpoint = new_push_endpoint
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection, pubsub.service
    end

    it "raises NotFoundError when retrieving topic" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.topic
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when retrieving deadline" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.deadline
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when retrieving endpoint" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.endpoint
      end.must_raise Gcloud::Pubsub::NotFoundError
    end

    it "raises NotFoundError when updating endpoint" do
      new_push_endpoint = "https://foo.bar/baz"

      mock_connection.post "/v1/projects/#{project}/subscriptions/#{sub_name}:modifyPushConfig" do |env|
        JSON.parse(env.body)["pushConfig"]["pushEndpoint"].must_equal new_push_endpoint
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.endpoint = new_push_endpoint
      end.must_raise Gcloud::Pubsub::NotFoundError
    end
  end
end
