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

  it "handles UnavailableError (retriable) and retries publish with incremental backoff" do
    message = "new-message-here"
    encoded_msg = message.encode(Encoding::ASCII_8BIT)
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: encoded_msg)
    ]
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [{topic: topic_path(topic_name), messages: messages}, nil]
    topic.service.mocked_publisher = PublisherClientStub.new mock

    sleep_mock = Minitest::Mock.new
    [0.13, 0.169, 0.21970000000000003].each do |delay|
      sleep_mock.expect :sleep, nil, [delay]
    end
    mocked_sleep_for = -> (delay) { sleep_mock.sleep delay }
    Kernel.stub :sleep, mocked_sleep_for do
      msg = topic.publish message

      _(msg).must_be_kind_of Google::Cloud::PubSub::Message
      _(msg.message_id).must_equal "msg1"
    end

    mock.verify
    sleep_mock.verify
  end

  class PublisherClientStub
    def initialize mock, errors: 3
      @mock = mock
      @errors = errors
      @tries = 0
    end

    def publish *args
      @tries += 1
      raise Google::Cloud::UnavailableError.new "unavailable: #{@tries}" if @tries < @errors + 1
      @mock.publish *args
    end
  end
end
