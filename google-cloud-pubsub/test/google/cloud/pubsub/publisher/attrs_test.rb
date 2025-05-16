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

describe Google::Cloud::PubSub::Publisher, :attributes, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key_name) { "projects/a/locations/b/keyRings/c/cryptoKeys/d" }
  let(:persistence_regions) { ["us-central1", "us-central2"] }
  let(:schema_name) { schema_path "my-schema" }
  let(:message_encoding) { :JSON }
  let :topic_hsh do
    topic_hash topic_name,
               labels: labels,
               kms_key_name: kms_key_name,
               persistence_regions: persistence_regions,
               schema_settings: { schema: schema_name, encoding: message_encoding }
  end
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hsh }
  let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc topic_grpc, pubsub.service }

  it "is not reference when created with an HTTP method" do
    _(publisher).wont_be :reference?
    _(publisher).must_be :resource?
  end

  it "accesses name without making an API call" do
    _(publisher.name).must_equal topic_path(topic_name)
  end

  describe "reference topic" do
    let :publisher do
      Google::Cloud::PubSub::Publisher.from_name topic_name, pubsub.service
    end

    it "is reference" do
      _(publisher).must_be :reference?
      _(publisher).wont_be :resource?
    end

    it "accesses name without making an API call" do
      _(publisher).must_be :reference?
      _(publisher).wont_be :resource?

      _(publisher.name).must_equal topic_path(topic_name)

      _(publisher).must_be :reference?
      _(publisher).wont_be :resource?
    end
  end
end
