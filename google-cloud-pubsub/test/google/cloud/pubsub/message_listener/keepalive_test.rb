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

    listener_retries = 0
    until called
      fail "stream did not restart and deliver message" if listener_retries > 500
      listener_retries += 1
      sleep 0.01
    end

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
    stream.keepalive_monitor.last_ping_at = 0.0
    stream.keepalive_monitor.last_pong_at = 1.0

    stream.keepalive_monitor.send_ping!
    _(stream.keepalive_monitor.last_ping_at).must_be :>, 0.0
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
    stream.keepalive_monitor.last_ping_at = now - 5.0
    stream.keepalive_monitor.last_pong_at = now - 1.0

    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open).must_equal true
  end

  it "does not trigger false restarts on unpausing even if pause exceeded deadline" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first

    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stream.instance_variable_set :@stream_open, true
    stream.keepalive_monitor.last_ping_at = now - 30.0
    stream.keepalive_monitor.last_pong_at = now - 35.0
    stream.instance_variable_set :@paused, true
    stream.instance_variable_set :@stopped, false

    # 1. When paused, liveness checker should skip verification.
    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open).must_equal true

    # 2. Unpausing must reset @last_pong_at to prevent immediate restart.
    stream.send(:unpause_streaming!)
    _(stream.keepalive_monitor.last_pong_at).must_be :>=, now

    # 3. Direct liveness check immediately after unpausing (simulates the monitor thread racing the background thread).
    # It should NOT close the stream because our reset made @last_pong_at newer than @last_ping_at.
    stream.keepalive_monitor.check_liveness!
    _(stream.stream_open).must_equal true
  end

  it "re-creates and executes timer tasks if stopped and restarted" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    listener.start

    stream = listener.instance_variable_get(:@stream_pool).first

    # 1. Timers should be active on a started stream
    refute_nil stream.instance_variable_get(:@keepalive_monitor)&.ping_task
    refute_nil stream.instance_variable_get(:@keepalive_monitor)&.monitor_task

    first_keepalive = stream.instance_variable_get(:@keepalive_monitor)&.ping_task
    first_monitor = stream.instance_variable_get(:@keepalive_monitor)&.monitor_task

    # 2. Stopping the stream must shutdown and nilify the timers
    listener.stop
    listener.wait!
    assert_nil stream.instance_variable_get(:@keepalive_monitor)&.ping_task
    assert_nil stream.instance_variable_get(:@keepalive_monitor)&.monitor_task
    assert first_keepalive.shutdown?
    assert first_monitor.shutdown?

    # 3. Simulating a restart should create completely new timer instances
    stream.instance_variable_set :@background_thread, nil
    stream.instance_variable_set :@stopped, false
    stream.start

    new_keepalive = stream.instance_variable_get(:@keepalive_monitor)&.ping_task
    new_monitor = stream.instance_variable_get(:@keepalive_monitor)&.monitor_task

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
    pause_cond = stream.instance_variable_get(:@backoff_cond)

    pause_cond.stub :wait, ->(_timeout) {
      wait_called = true
      _(stream.instance_variable_get(:@stream_open)).must_equal false
    } do
      stream.send :backoff_and_wait!
    end

    assert wait_called
  end

  it "does not bleed self sentinel into the new request queue after restart_stream_for_timeout!" do
    stub = StreamingPullStub.new [[]]
    subscriber.service.mocked_subscription_admin = stub

    listener = subscriber.listen streams: 1 do |msg|
    end
    stream = listener.instance_variable_get(:@stream_pool).first

    queue = Google::Cloud::PubSub::MessageListener::EnumeratorQueue.new stream
    queue.push stream

    stream.instance_variable_set :@request_queue, queue
    stream.instance_variable_set :@stopped, false

    passed_enum = nil
    mock_pull = ->(req_enum, _options) {
      passed_enum = req_enum
      stream.instance_variable_set :@stopped, true
      raise Google::Cloud::InvalidArgumentError.new("stop test execution")
    }

    subscriber.service.stub :streaming_pull, mock_pull do
      begin
        stream.send :background_run
      rescue Google::Cloud::InvalidArgumentError
      end
    end

    # Inspect items yielded by the request enumerator passed to streaming_pull
    items_yielded = stream.instance_variable_get(:@request_queue).quit_and_dump_queue


    refute_includes items_yielded, stream
  end
end
