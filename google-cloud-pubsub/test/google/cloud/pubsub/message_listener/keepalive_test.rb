# Copyright 2026 Google LLC
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

describe Google::Cloud::PubSub::MessageListener, :keepalive, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }

  before do
    ENV["PUBSUB_TEST_KEEPALIVE_INTERVAL"] = "0.05"
    ENV["PUBSUB_TEST_PONG_DEADLINE"] = "0.05"
  end

  after do
    ENV.delete "PUBSUB_TEST_KEEPALIVE_INTERVAL"
    ENV.delete "PUBSUB_TEST_PONG_DEADLINE"
  end

  it "sends protocol_version = 1 in initial streaming pull request" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    stub = StreamingPullStub.new [[pull_res1]]
    subscriber.service.mocked_subscription_admin = stub

    called = false
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end
    listener.start

    listener_retries = 0
    until called
      fail "callback was not called" if listener_retries > 100
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!

    initial_req = stub.requests.first.to_a.first
    _(initial_req.protocol_version).must_equal 1
  end

  it "sends keep-alive pings periodically even when inventory is empty" do
    q = StreamingPullStub::RaisableEnumeratorQueue.new
    stub = StreamingPullStub.new [[]]
    def stub.streaming_pull_internal req, opt = nil
      @requests << req
      @my_q.each
    end
    stub.instance_variable_set(:@my_q, q)
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start

    pong_thread = Thread.new do
      10.times do
        sleep 0.02
        q.push Google::Cloud::PubSub::V1::StreamingPullResponse.new(received_messages: [])
      end
    end

    sleep 0.18
    pong_thread.join

    listener.stop
    listener.wait!

    reqs = stub.requests.first.to_a
    _(reqs.count).must_be :>=, 2
  end

  it "restarts stream when keep-alive pong deadline is exceeded" do
    pull_res2 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    stub = StreamingPullStub.new [[], [pull_res2]]
    subscriber.service.mocked_subscription_admin = stub

    called = false
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end
    listener.start

    listener_retries = 0
    until called
      fail "stream did not restart and deliver message" if listener_retries > 200
      listener_retries += 1
      sleep 0.01
    end

    listener.stop
    listener.wait!

    _(stub.requests.count).must_equal 2
  end

  it "does not restart stream when actively receiving keep-alive pongs" do
    q = StreamingPullStub::RaisableEnumeratorQueue.new
    stub = StreamingPullStub.new [[]]
    def stub.streaming_pull_internal req, opt = nil
      @requests << req
      @my_q.each
    end
    stub.instance_variable_set(:@my_q, q)
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start

    pong_sender = Thread.new do
      8.times do
        sleep 0.02
        empty_pong = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: []
        q.push empty_pong
      end
    end

    sleep 0.15
    pong_sender.join

    listener.stop
    listener.wait!

    _(stub.requests.count).must_equal 1
  end
end
