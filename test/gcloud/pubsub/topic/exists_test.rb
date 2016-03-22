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
  let(:topic) { Gcloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    topic.must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    topic.must_be :exists?
  end

  describe "lazy topic object of a topic that exists" do
    describe "lazy topic with default autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service }

      it "checks if the topic exists by making an HTTP call" do
        get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
        get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
        mock = Minitest::Mock.new
        mock.expect :get_topic, get_res, [get_req]
        topic.service.mocked_publisher = mock

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?

        mock.verify
      end
    end

    describe "lazy topic with explicit autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service,
                                                   autocreate: true }

      it "checks if the topic exists by making an HTTP call" do
        get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
        get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
        mock = Minitest::Mock.new
        mock.expect :get_topic, get_res, [get_req]
        topic.service.mocked_publisher = mock

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?

        mock.verify
      end
    end

    describe "lazy topic without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service,
                                                   autocreate: false }

      it "checks if the topic exists by making an HTTP call" do
        get_req = Google::Pubsub::V1::GetTopicRequest.new topic: "projects/#{project}/topics/#{topic_name}"
        get_res = Google::Pubsub::V1::Topic.decode_json topic_json(topic_name)
        mock = Minitest::Mock.new
        mock.expect :get_topic, get_res, [get_req]
        topic.service.mocked_publisher = mock

        topic.must_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.must_be :exists?

        mock.verify
      end
    end
  end

  describe "lazy topic object of a topic that does not exist" do
    describe "lazy topic with default autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service }

      it "checks if the topic exists by making an HTTP call" do
        stub = Object.new
        def stub.get_topic *args
          raise GRPC::BadStatus.new 5, "not found"
        end
        topic.service.mocked_publisher = stub

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end

    describe "lazy topic with explicit autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service,
                                                   autocreate: true }

      it "checks if the topic exists by making an HTTP call" do
        stub = Object.new
        def stub.get_topic *args
          raise GRPC::BadStatus.new 5, "not found"
        end
        topic.service.mocked_publisher = stub

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end

    describe "lazy topic without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.service,
                                                   autocreate: false }

      it "checks if the topic exists by making an HTTP call" do
        stub = Object.new
        def stub.get_topic *args
          raise GRPC::BadStatus.new 5, "not found"
        end
        topic.service.mocked_publisher = stub

        topic.wont_be :exists?
        # Additional exists? calls do not make HTTP calls
        topic.wont_be :exists?
      end
    end
  end
end
