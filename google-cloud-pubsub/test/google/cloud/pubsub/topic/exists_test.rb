# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::PubSub::Topic, :exists, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    _(topic).must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    _(topic).must_be :exists?
  end

  describe "reference topic object of a topic that exists" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "checks if the topic exists by making an HTTP call" do
      get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
      mock = Minitest::Mock.new
      mock.expect :get_topic, get_res, topic: topic_path(topic_name)
      topic.service.mocked_publisher = mock

      _(topic).must_be :exists?
      # Additional exists? calls do not make HTTP calls
      _(topic).must_be :exists?

      mock.verify
    end
  end

  describe "reference topic object of a topic that does not exist" do
    let(:topic) { Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service }

    it "checks if the topic exists by making an HTTP call" do
      stub = Object.new
      def stub.get_topic *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      topic.service.mocked_publisher = stub

      _(topic).wont_be :exists?
      # Additional exists? calls do not make HTTP calls
      _(topic).wont_be :exists?
    end
  end
end
