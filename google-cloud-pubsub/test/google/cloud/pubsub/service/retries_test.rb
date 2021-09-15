# Copyright 2021 Google LLC
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

describe Google::Cloud::PubSub::Service::Retries, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name) }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc topic_grpc, pubsub.service }

  it "handles a single UnavailableError (retriable) and retries publish with backoff" do
    stub = Object.new # Stub the V1::Publisher::Client
    def stub.publish *args
      @tries ||= 0
      @tries += 1
      raise Google::Cloud::UnavailableError.new "unavailable" if @tries == 1

      Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    end
    topic.service.mocked_publisher = stub

    mock = Minitest::Mock.new
    mock.expect :sleep, nil, [0.13]
    mocked_sleep_for = lambda { |i| mock.sleep i }
    Google::Cloud::PubSub::Service::Retries.stub :sleep_for, -> { mocked_sleep_for } do
      msg = topic.publish message

      _(msg).must_be_kind_of Google::Cloud::PubSub::Message
      _(msg.message_id).must_equal "msg1"
    end

    mock.verify
  end
end
