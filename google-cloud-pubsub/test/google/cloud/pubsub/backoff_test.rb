# Copyright 2016 Google Inc. All rights reserved.
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

describe "Google Cloud Pub/Sub Backoff", :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }
  let(:sub_name) { "session-timed-out-sub" }

  it "retries when the session times out" do
    stub = Object.new
    def stub.get_subscription *args
      @tries ||= 0
      @tries += 1
      raise GRPC::BadStatus.new 14, "goaway" if @tries < 3
      return Google::Pubsub::V1::Subscription.decode_json(
        "{\"name\":\"projects/test/subscriptions/session-timed-out-sub\",\"topic\":\"projects/test/topics/topic-name-goes-here\",\"push_config\":{\"push_endpoint\":\"http://example.com/callback\"},\"ack_deadline_seconds\":60}"
      )
    end
    topic.service.mocked_subscriber = stub

    sub = nil
    assert_backoff_sleep 1, 2 do
      sub = topic.subscription sub_name
    end

    sub.must_be_kind_of Google::Cloud::Pubsub::Subscription
    sub.wont_be :lazy?
  end

  it "raises after enough retries" do
    stub = Object.new
    def stub.get_subscription *args
      raise GRPC::BadStatus.new 14, "goaway"
    end
    topic.service.mocked_subscriber = stub

    assert_backoff_sleep 1, 2, 3, 4, 5 do
      expect { topic.subscription sub_name }.must_raise Google::Cloud::UnavailableError
    end
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Google::Cloud::Core::Backoff.new retries: 5, backoff: callback

    Google::Cloud::Core::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
