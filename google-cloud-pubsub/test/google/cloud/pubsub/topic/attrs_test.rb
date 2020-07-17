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

describe Google::Cloud::PubSub::Topic, :attributes, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key_name) { "projects/a/locations/b/keyRings/c/cryptoKeys/d" }
  let(:persistence_regions) { ["us-central1", "us-central2"] }
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: labels, kms_key_name: kms_key_name, persistence_regions: persistence_regions) }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc topic_grpc, pubsub.service }

  it "is not reference when created with an HTTP method" do
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "accesses name without making an API call" do
    _(topic.name).must_equal topic_path(topic_name)
  end

  it "accesses labels without making an API call" do
    _(topic.labels).must_equal labels
  end

  it "accesses kms_key without making an API call" do
    _(topic.kms_key).must_equal kms_key_name
  end

  it "accesses persistence_regions without making an API call" do
    _(topic.persistence_regions).must_equal persistence_regions
  end

  describe "reference topic" do
    let :topic do
      Google::Cloud::PubSub::Topic.from_name topic_name, pubsub.service
    end

    it "is reference" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?
    end

    it "accesses name without making an API call" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      _(topic.name).must_equal topic_path(topic_name)

      _(topic).must_be :reference?
      _(topic).wont_be :resource?
    end

    it "accesses labels by making an API call" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      mock = Minitest::Mock.new
      mock.expect :get_topic, topic_grpc, [topic: topic_path(topic_name)]
      topic.service.mocked_publisher = mock

      _(topic.labels).must_equal labels

      _(topic).wont_be :reference?
      _(topic).must_be :resource?

      mock.verify
    end

    it "accesses kms_key by making an API call" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      mock = Minitest::Mock.new
      mock.expect :get_topic, topic_grpc, [topic: topic_path(topic_name)]
      topic.service.mocked_publisher = mock

      _(topic.kms_key).must_equal kms_key_name

      _(topic).wont_be :reference?
      _(topic).must_be :resource?

      mock.verify
    end

    it "accesses persistence_regions by making an API call" do
      _(topic).must_be :reference?
      _(topic).wont_be :resource?

      mock = Minitest::Mock.new
      mock.expect :get_topic, topic_grpc, [topic: topic_path(topic_name)]
      topic.service.mocked_publisher = mock

      _(topic.persistence_regions).must_equal persistence_regions

      _(topic).wont_be :reference?
      _(topic).must_be :resource?

      mock.verify
    end

    describe "no MessageStoragePolicy" do
      let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name, labels: labels) }

      it "accesses persistence_regions by making an API call" do
        _(topic).must_be :reference?
        _(topic).wont_be :resource?

        mock = Minitest::Mock.new
        mock.expect :get_topic, topic_grpc, [topic: topic_path(topic_name)]
        topic.service.mocked_publisher = mock

        _(topic.persistence_regions).must_be :empty?

        _(topic).wont_be :reference?
        _(topic).must_be :resource?

        mock.verify
      end
    end
  end
end
