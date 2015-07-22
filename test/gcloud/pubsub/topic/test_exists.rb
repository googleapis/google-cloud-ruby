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

describe Gcloud::Pubsub::Topic, :exists, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock_connection config means this test will fail
    # if the method exists? makes an HTTP call.
    topic.must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    topic.must_be :exists?
  end

  describe "lazy topic object of a topic that exists" do
    describe "lazy topic with default autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?
      end
    end

    describe "lazy topic with explicit autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?
      end
    end

    describe "lazy topic without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?
      end
    end
  end

  describe "lazy topic object of a topic that does not exist" do
    describe "lazy topic with default autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end

    describe "lazy topic with explicit autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end

    describe "lazy topic without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "checks if the topic exists by making an HTTP call" do
        mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end
  end
end
