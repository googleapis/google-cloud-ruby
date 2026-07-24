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

  it "sends protocol_version = 1 in initial streaming pull request" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    stub = StreamingPullStub.new [[pull_res1]]
    subscriber.service.mocked_subscription_admin = stub

    called = false
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end
    listener.start

    wait_until(max: 100, msg: "callback was not called") { called }

    listener.stop
    listener.wait!

    initial_req = stub.requests.first.to_a.first
    _(initial_req.protocol_version).must_equal 1
  end

  it "restarts stream when keep-alive pong deadline is exceeded" do
    pull_res2 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc]
    stub = StreamingPullStub.new [[], [pull_res2]]
    subscriber.service.mocked_subscription_admin = stub

    called = false
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end
    stream = listener.instance_variable_get(:@stream_pool).first
    stream.keepalive_monitor.instance_variable_set :@interval, 0.05
    stream.keepalive_monitor.instance_variable_set :@deadline, 0.05
    listener.start

    wait_until(max: 500, msg: "stream did not restart and deliver message") { called }

    listener.stop
    listener.wait!

    _(stub.requests.count).must_equal 2
  end

  it "sends keep-alive ping synchronously when stream is open and queue exists" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first

    queue = Google::Cloud::PubSub::MessageListener::EnumeratorQueue.new stream
    stream.instance_variable_set :@request_queue, queue
    stream.instance_variable_set :@stream_open, true
    stream.instance_variable_set :@stopped, false
    stream.keepalive_monitor.instance_variable_set :@last_ping_at, 0.0
    stream.keepalive_monitor.instance_variable_set :@last_pong_at, 1.0

    stream.keepalive_monitor.send_ping!
    _(stream.keepalive_monitor.instance_variable_get(:@last_ping_at)).must_be :>, 0.0
  end

  it "does not restart stream when check_liveness! runs under active pongs" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first

    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stream.instance_variable_set :@stream_open, true
    stream.instance_variable_set :@stopped, false
    stream.instance_variable_set :@paused, false
    stream.keepalive_monitor.instance_variable_set :@last_ping_at, now - 5.0
    stream.keepalive_monitor.instance_variable_set :@last_pong_at, now - 1.0

    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open?).must_equal true
  end

  it "does not trigger false restarts on unpausing even if pause exceeded deadline" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first

    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stream.instance_variable_set :@stream_open, true
    stream.keepalive_monitor.instance_variable_set :@last_ping_at, now - 30.0
    stream.keepalive_monitor.instance_variable_set :@last_pong_at, now - 35.0
    stream.instance_variable_set :@paused, true
    stream.instance_variable_set :@stopped, false

    # 1. When paused, liveness checker should skip verification.
    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open?).must_equal true

    # 2. Unpausing must reset @last_pong_at to prevent immediate restart.
    stream.send(:unpause_streaming!)
    _(stream.keepalive_monitor.instance_variable_get(:@last_pong_at)).must_be :>=, now

    # 3. Direct liveness check immediately after unpausing (simulates the monitor thread racing the background thread).
    # It should NOT close the stream because our reset made @last_pong_at newer than @last_ping_at.
    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open?).must_equal true
  end

  it "re-creates and executes timer tasks if stopped and restarted" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start

    stream = listener.instance_variable_get(:@stream_pool).first

    # 1. Timers should be active on a started stream
    refute_nil stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@ping_task)
    refute_nil stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@monitor_task)

    first_keepalive = stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@ping_task)
    first_monitor = stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@monitor_task)

    # 2. Stopping the stream must shutdown and nilify the timers
    listener.stop
    listener.wait!
    assert_nil stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@ping_task)
    assert_nil stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@monitor_task)
    assert first_keepalive.shutdown?
    assert first_monitor.shutdown?

    # 3. Simulating a restart should create completely new timer instances
    stream.instance_variable_set :@background_thread, nil
    stream.instance_variable_set :@stopped, false
    stream.start

    new_keepalive = stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@ping_task)
    new_monitor = stream.instance_variable_get(:@keepalive_monitor)&.instance_variable_get(:@monitor_task)

    refute_nil new_keepalive
    refute_nil new_monitor
    refute_equal first_keepalive, new_keepalive
    refute_equal first_monitor, new_monitor

    stream.stop
  end

  it "sets stream_open to false during backoff to prevent monitor interruption" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first
    stream.instance_variable_set :@stream_open, true
    stream.instance_variable_set :@stopped, false

    wait_called = false
    backoff_cond = stream.instance_variable_get(:@backoff_cond)

    backoff_cond.stub :wait, ->(_timeout) {
      wait_called = true
      _(stream.stream_open?).must_equal false
    } do
      stream.send :backoff_and_wait!
    end

    assert wait_called
  end

  it "does not bleed self sentinel into the new request queue after restart_stream_for_timeout!" do
    stub = StreamingPullStub.new [[], []]
    subscriber.service.mocked_subscription_admin = stub

    called = false
    listener = subscriber.listen streams: 1 do |msg|
      called = true
    end
    stream = listener.instance_variable_get(:@stream_pool).first
    listener.start
    
    # Wait for the first connection
    wait_until(max: 100, msg: "stream did not connect") { stub.requests.count == 1 }
    
    # Trigger production-path timeout logically via the liveness monitor simulation
    # Back-date variables and invoke the monitor exactly as it runs in the background
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stream.keepalive_monitor.instance_variable_set :@last_ping_at, now - 60.0
    stream.keepalive_monitor.instance_variable_set :@last_pong_at, now - 65.0
    stream.keepalive_monitor.check_liveness!
    
    # Ensure stream correctly recreates the request_queue without sending the stream sentinel object
    # to the gRPC client (which would cause a fatal crash rather than a graceful restart and a new request).
    # Since backoff_and_wait! pauses for 1+ seconds, give it enough time to reconnect.
    wait_until(delay: 0.1, max: 100, msg: "stream did not restart") { stub.requests.count >= 2 }
    
    listener.stop
    listener.wait!
  end
end
