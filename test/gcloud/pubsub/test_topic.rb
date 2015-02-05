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

describe Gcloud::Pubsub::Topic, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }

  it "knows its name" do
    topic.name.must_equal topic_path(topic_name)
  end

  it "can delete itself" do
    mock_connection.delete "/pubsub/v1beta1#{topic_path topic_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    topic.delete
  end

  it "creates a subscription" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.post "/pubsub/v1beta1/subscriptions" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      JSON.parse(env.body)["name"].must_equal subscription_path(new_sub_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.create_subscription new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription without giving a name" do
    mock_connection.post "/pubsub/v1beta1/subscriptions" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      JSON.parse(env.body)["name"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, nil)]
    end

    sub = topic.create_subscription
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end

  it "creates a subscription when calling subscribe" do
    new_sub_name = "new-sub-#{Time.now.to_i}"
    mock_connection.post "/pubsub/v1beta1/subscriptions" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      JSON.parse(env.body)["name"].must_equal subscription_path(new_sub_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = topic.subscribe new_sub_name
    sub.wont_be :nil?
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
  end
end
