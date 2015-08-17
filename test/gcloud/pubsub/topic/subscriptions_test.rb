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

describe Gcloud::Pubsub::Topic, :subscriptions, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  it "lists subscriptions" do
    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
      [200, {"Content-Type"=>"application/json"},
       subscriptions_json(topic_name, 3)]
    end

    subs = topic.subscriptions
    subs.count.must_equal 3
    subs.each do |sub|
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
    end
  end

  describe "lazy topic that exists" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "lists subscriptions" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
          [200, {"Content-Type"=>"application/json"},
           subscriptions_json(topic_name, 3)]
        end

        subs = topic.subscriptions
        subs.count.must_equal 3
        subs.each do |sub|
          sub.must_be_kind_of Gcloud::Pubsub::Subscription
        end
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "lists subscriptions" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
          [200, {"Content-Type"=>"application/json"},
           subscriptions_json(topic_name, 3)]
        end

        subs = topic.subscriptions
        subs.count.must_equal 3
        subs.each do |sub|
          sub.must_be_kind_of Gcloud::Pubsub::Subscription
        end
      end
    end
  end

  describe "lazy topic that does not exist" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "lists subscriptions" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.subscriptions
        end.must_raise Gcloud::Pubsub::NotFoundError
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "lists subscriptions" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}/subscriptions" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.subscriptions
        end.must_raise Gcloud::Pubsub::NotFoundError
      end
    end
  end
end
