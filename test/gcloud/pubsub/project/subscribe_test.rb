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

describe Gcloud::Pubsub::Project, :subscribe, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:new_sub_name) { "new-sub-#{Time.now.to_i}" }

  it "creates a subscription when calling subscribe" do
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = pubsub.subscribe topic_name, new_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription and topic when called with autocreate" do
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [404, {"Content-Type"=>"application/json"},
       not_found_error_json(topic_name)]
    end
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    create_req = Google::Pubsub::V1::Topic.new(
      name: topic_path(topic_name)
    )
    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [create_req]
    pubsub.service.mocked_publisher = mock

    sub = pubsub.subscribe topic_name, new_sub_name, autocreate: true

    mock.verify

    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  it "creates a subscription but not topic even when called with autocreate" do
    mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
      JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
      [200, {"Content-Type"=>"application/json"},
       subscription_json(topic_name, new_sub_name)]
    end

    sub = pubsub.subscribe topic_name, new_sub_name, autocreate: true
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
  end

  describe "lazy topic that exists" do
    let(:topic) { Gcloud::Pubsub::pubsub.new_lazy topic_name,
                                                 pubsub.connection, pubsub.service,
                                                 autocreate: false }

    it "creates a subscription when calling subscribe" do
      mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
        JSON.parse(env.body)["topic"].must_equal topic_path(topic_name)
        [200, {"Content-Type"=>"application/json"},
         subscription_json(topic_name, new_sub_name)]
      end

      sub = pubsub.subscribe topic_name, new_sub_name
      sub.must_be_kind_of Gcloud::Pubsub::Subscription
      sub.name.must_equal "projects/#{project}/subscriptions/#{new_sub_name}"
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Gcloud::Pubsub::pubsub.new_lazy topic_name,
                                                 pubsub.connection, pubsub.service,
                                                 autocreate: false }

    it "raises NotFoundError when calling subscribe" do
      mock_connection.put "/v1/projects/#{project}/subscriptions/#{new_sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(topic_name)]
      end

      expect do
        pubsub.subscribe topic_name, new_sub_name
      end.must_raise Gcloud::Pubsub::NotFoundError
    end
  end
end
