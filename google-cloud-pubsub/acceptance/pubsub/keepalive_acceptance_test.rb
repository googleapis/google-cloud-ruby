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

require "pubsub_helper"

describe Google::Cloud::PubSub, :keepalive_acceptance, :pubsub do
  def retrieve_topic topic_name
    topic_path = pubsub.topic_path topic_name
    $topic_admin.get_topic(topic: topic_path) rescue $topic_admin.create_topic(name: topic_path)
  end

  def retrieve_subscription topic, subscription_name
    subscription_path = pubsub.subscription_path subscription_name
    $subscription_admin.get_subscription(subscription: subscription_path) \
      rescue $subscription_admin.create_subscription(name: subscription_path, topic: topic.name)
  end

  let(:nonce) { rand 1000 }
  let(:topic) { retrieve_topic "#{$topic_prefix}-ka-topic#{nonce}" }
  let(:sub) { retrieve_subscription topic, "#{$topic_prefix}-ka-sub#{nonce}" }

  it "maintains real gRPC keep-alive heartbeat and delivers messages from live Google Cloud Pub/Sub servers" do
    subscriber = pubsub.subscriber sub.name

    messages_received = []
    listener = subscriber.listen streams: 1 do |msg|
      messages_received << msg
      msg.ack!
    end

    stream = listener.instance_variable_get(:@stream_pool).first
    # Set a short keep-alive interval (2.0s) so multiple ping/pong cycles occur against live GCP servers
    stream.keepalive_monitor.instance_variable_set :@interval, 2.0
    stream.keepalive_monitor.instance_variable_set :@deadline, 10.0

    listener.start

    # Publish a live message to the real topic on GCP
    publisher = pubsub.publisher topic.name
    publish_result = nil
    publisher.publish_async "keepalive-production-acceptance-test-#{nonce}" do |result|
      publish_result = result
    end

    pub_retries = 0
    until publish_result
      fail "Live publish failed against Google Cloud Pub/Sub" if pub_retries >= 30
      pub_retries += 1
      sleep 0.2
    end
    _(publish_result).must_be :succeeded?

    # Wait for the message to be received by our streaming listener from live GCP
    sub_retries = 0
    until messages_received.any?
      fail "Listener did not receive published message from live Google Cloud Pub/Sub" if sub_retries >= 50
      sub_retries += 1
      sleep 0.2
    end

    received = messages_received.first
    _(received.data).must_equal "keepalive-production-acceptance-test-#{nonce}"

    # Allow at least 2 full keep-alive intervals (4+ seconds) to run over live production wire
    sleep 4.5

    monitor = stream.keepalive_monitor
    _(stream.stream_open).must_equal true
    _(monitor.last_ping_at).wont_be_nil
    _(monitor.last_pong_at).wont_be_nil
    _(monitor.last_ping_at).must_be :>, 0.0
    _(monitor.last_pong_at).must_be :>, 0.0

    listener.stop
    listener.wait!
  end

  it "safely unpauses flow control under real network conditions against live Google Cloud Pub/Sub servers" do
    subscriber = pubsub.subscriber sub.name

    listener = subscriber.listen streams: 1 do |msg|
      msg.ack!
    end

    stream = listener.instance_variable_get(:@stream_pool).first
    monitor = stream.keepalive_monitor

    listener.start

    # Allow initial connection handshake against real GCP to establish
    sleep 1.0
    _(stream.stream_open).must_equal true

    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    # Validate unpause_streaming! atomically updates last_pong_at against real live listener thread
    stream.send(:unpause_streaming!)
    _(monitor.last_pong_at).must_be :>=, now
    _(stream.stream_open).must_equal true

    listener.stop
    listener.wait!
  end
end
