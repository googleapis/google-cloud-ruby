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

describe Google::Cloud::PubSub::MessageListener, :bug_regression, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }

  it "b/528401453: waits for exponential backoff before retrying on GRPC::Unavailable" do
    attempts = []
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: []
    response_groups = [[GRPC::Unavailable.new("simulated disconnect")], [pull_res]]
    stub = StreamingPullStub.new response_groups
    def stub.streaming_pull_internal request, options = nil
      @attempts ||= []
      @attempts << Process.clock_gettime(Process::CLOCK_MONOTONIC)
      super
    end
    stub.instance_variable_set(:@attempts, attempts)
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start

    retries = 0
    until attempts.count >= 2
      fail "stream did not retry" if retries > 200
      retries += 1
      sleep 0.05
    end

    listener.stop
    listener.wait!

    elapsed = attempts[1] - attempts[0]
    puts "\n[b/528401453 Test] Elapsed delay between attempts: #{elapsed.round(3)}s"
    _(elapsed).must_be :>=, 1.0
  end

  it "b/528404815: shuts down keepalive TimerTask when stream is stopped" do
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: []
    stub = StreamingPullStub.new [[pull_res]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start
    sleep 0.1
    listener.stop
    listener.wait!

    stream = listener.instance_variable_get(:@stream_pool).first
    keepalive_task = stream.instance_variable_get(:@stream_keepalive_task)
    puts "\n[b/528404815 Test] Keepalive task running state after stop: #{keepalive_task.running?}"
    _(keepalive_task.running?).must_equal false
  end
end
