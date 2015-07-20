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

describe Gcloud::Pubsub::Topic, :subscribe, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  let(:new_sub_name) { "new-sub-#{Time.now.to_i}" }

  it "creates a subscription when calling subscribe" do
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  describe "lazy topic that exists" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "creates a subscription when calling subscribe" do
        mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
          JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
          [200, {"Content-Type"=>"application/json"},
           subscription_json(topic_name, new_sub_name)]
        end

        sub = topic.subscribe new_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "creates a subscription when calling subscribe" do
        mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
          JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
          [200, {"Content-Type"=>"application/json"},
           subscription_json(topic_name, new_sub_name)]
        end

        sub = topic.subscribe new_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
      end
    end
  end

  describe "lazy topic that does not exist" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "creates a subscription when calling subscribe" do
        #first, failed attempt to subscribe
        mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end
        # second, successful attempt to create topic
        mock_connection.put "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end
        # third, successful attempt to subscribe
        mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
          JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
          [200, {"Content-Type"=>"application/json"},
           subscription_json(topic_name, new_sub_name)]
        end

        sub = topic.subscribe new_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "raises NotFoundError when calling subscribe" do
        mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.subscribe new_sub_name
        end.must_raise Gcloud::Pubsub::NotFoundError
      end
    end
  end
end
