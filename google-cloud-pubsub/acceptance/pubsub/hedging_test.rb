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
require "concurrent/atomics"
require "stringio"

describe Google::Cloud::PubSub, :hedging, :pubsub do
  def retrieve_topic topic_name
    topic_path = pubsub.topic_path topic_name
    $topic_admin.get_topic(topic: topic_path)
  rescue Google::Cloud::NotFoundError
    $topic_admin.create_topic(name: topic_path)
  end

  def retrieve_subscription topic, subscription_name
    subscription_path = pubsub.subscription_path subscription_name
    $subscription_admin.get_subscription(subscription: subscription_path)
  rescue Google::Cloud::NotFoundError
    $subscription_admin.create_subscription(name: subscription_path, topic: topic.name)
  end

  def pull_messages subscriber, expected_count, timeout_seconds: 30
    collected = []
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout_seconds
    while collected.size < expected_count && Process.clock_gettime(Process::CLOCK_MONOTONIC) < deadline
      received = subscriber.pull immediate: false, max: expected_count
      unless received.empty?
        received.each(&:ack!)
        collected.concat received
      end
      sleep 0.5 if collected.size < expected_count
    end
    collected
  end

  def publish_single_sync publisher, payload
    result_queue = Queue.new
    publisher.publish_async payload do |result|
      result_queue.push result
    end
    publisher.async_publisher.flush
    result_queue.pop
  end

  it "publishes messages end-to-end with custom hedging settings and caps token bucket at max_tokens" do
    suffix = SecureRandom.hex 4
    topic = retrieve_topic "#{$topic_prefix}-hdg-e2e-#{suffix}"
    sub = retrieve_subscription topic, "#{$topic_prefix}-hdg-e2e-sub-#{suffix}"

    publisher = pubsub.publisher(
      topic.name,
      async: {
        max_messages: 1,
        interval: 0.005,
        hedging: {
          hedge_delay: 0.2,
          max_tokens: 1,
          refill_ratio: 0.2
        }
      }
    )
    subscriber = pubsub.subscriber sub.name

    begin
      10.times do |i|
        res = publish_single_sync publisher, "hedged-e2e-#{i}"
        _(res).must_be :succeeded?
        expected_tokens = [(i + 1) * 0.2, 1.0].min
        _(publisher.token_bucket.tokens).must_be_close_to expected_tokens, 1e-6
      end

      received = pull_messages subscriber, 10
      _(received.map(&:data).sort).must_equal(10.times.map { |i| "hedged-e2e-#{i}" }.sort)
    ensure
      publisher.async_publisher&.stop!
      $subscription_admin.delete_subscription subscription: sub.name
    end
  end

  it "hedged attempt 1 wins against live Pub/Sub and cancels stalled primary attempt 0" do
    suffix = SecureRandom.hex 4
    topic = retrieve_topic "#{$topic_prefix}-hdg-win-#{suffix}"
    sub = retrieve_subscription topic, "#{$topic_prefix}-hdg-win-sub-#{suffix}"

    publisher = pubsub.publisher(
      topic.name,
      async: {
        max_messages: 1,
        interval: 0.005,
        hedging: {
          hedge_delay: 0.15,
          max_tokens: 5,
          refill_ratio: 0.2
        }
      }
    )
    subscriber = pubsub.subscriber sub.name

    begin
      # Warm up the token bucket to 1.0 token with 5 real publish batches
      5.times do |i|
        res = publish_single_sync publisher, "warmup-#{i}"
        _(res).must_be :succeeded?
      end
      _(publisher.token_bucket.tokens).must_be_close_to 1.0, 1e-6

      # Intercept the 6th batch: stall attempt 0 (call_options[:retry_policy].nil?) on its AttemptHandle,
      # while allowing hedged attempt 1 (call_options[:retry_policy][:retry_codes] == [])
      # to pass straight through to the live Pub/Sub service.
      orig_publish = publisher.service.method :publish
      attempt0_handle = nil
      hedged_call_count = Concurrent::AtomicFixnum.new 0

      publisher.service.define_singleton_method :publish do |t_name, msgs, **kwargs|
        call_opts = kwargs[:call_options]
        handle = kwargs[:attempt_handle]
        if call_opts&.dig(:retry_policy).nil? && attempt0_handle.nil?
          attempt0_handle = handle
          handle.sleep_interruptibly 2.5
        elsif call_opts&.dig(:retry_policy)
          hedged_call_count.increment
        end
        orig_publish.call t_name, msgs, **kwargs
      end

      res = publish_single_sync publisher, "hedged-winner-payload"
      _(res).must_be :succeeded?
      _(res.message_id).wont_be :empty?
      _(hedged_call_count.value).must_equal 1
      _(attempt0_handle).wont_be_nil
      _(attempt0_handle).must_be :cancelled?
      # 1.0 - 1.0 (acquired) + 0.2 (refilled on win) = 0.2
      _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6

      received = pull_messages subscriber, 6
      _(received.map(&:data)).must_include "hedged-winner-payload"
    ensure
      publisher.async_publisher&.stop!
      $subscription_admin.delete_subscription subscription: sub.name
    end
  end

  it "primary attempt 0 wins after hedge dispatch and cancels in-flight hedged attempt 1" do
    suffix = SecureRandom.hex 4
    topic = retrieve_topic "#{$topic_prefix}-hdg-orig-#{suffix}"
    sub = retrieve_subscription topic, "#{$topic_prefix}-hdg-orig-sub-#{suffix}"

    publisher = pubsub.publisher(
      topic.name,
      async: {
        max_messages: 1,
        interval: 0.005,
        hedging: {
          hedge_delay: 0.15,
          max_tokens: 5,
          refill_ratio: 0.2
        }
      }
    )
    subscriber = pubsub.subscriber sub.name

    begin
      5.times do |i|
        res = publish_single_sync publisher, "warmup-orig-#{i}"
        _(res).must_be :succeeded?
      end
      _(publisher.token_bucket.tokens).must_be_close_to 1.0, 1e-6

      orig_publish = publisher.service.method :publish
      attempt1_handle = nil
      intercepted_primary = false

      publisher.service.define_singleton_method :publish do |t_name, msgs, **kwargs|
        call_opts = kwargs[:call_options]
        handle = kwargs[:attempt_handle]
        if call_opts&.dig(:retry_policy).nil? && !intercepted_primary
          intercepted_primary = true
          handle.sleep_interruptibly 0.25
        elsif call_opts&.dig(:retry_policy) && attempt1_handle.nil?
          attempt1_handle = handle
          handle.sleep_interruptibly 2.5
        end
        orig_publish.call t_name, msgs, **kwargs
      end

      res = publish_single_sync publisher, "primary-after-hedge-payload"
      _(res).must_be :succeeded?
      _(res.message_id).wont_be :empty?
      _(attempt1_handle).wont_be_nil
      _(attempt1_handle).must_be :cancelled?
      _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6

      received = pull_messages subscriber, 6
      _(received.map(&:data)).must_include "primary-after-hedge-payload"
    ensure
      publisher.async_publisher&.stop!
      $subscription_admin.delete_subscription subscription: sub.name
    end
  end

  it "rate limits hedging when token bucket has fewer than 1.0 token" do
    suffix = SecureRandom.hex 4
    topic = retrieve_topic "#{$topic_prefix}-hdg-rl-#{suffix}"
    sub = retrieve_subscription topic, "#{$topic_prefix}-hdg-rl-sub-#{suffix}"

    log_io = StringIO.new
    raw_logger = Logger.new log_io
    raw_logger.progname = "pubsub"
    raw_logger.level = Logger::DEBUG
    custom_service = Google::Cloud::PubSub::Service.new(
      pubsub.project,
      pubsub.service.credentials,
      host: pubsub.service.host,
      timeout: pubsub.service.timeout,
      universe_domain: pubsub.service.universe_domain,
      logger: raw_logger
    )
    custom_pubsub = Google::Cloud::PubSub::Project.new custom_service

    publisher = custom_pubsub.publisher(
      topic.name,
      skip_lookup: true,
      async: {
        max_messages: 1,
        interval: 0.005,
        hedging: {
          hedge_delay: 0.15,
          max_tokens: 5,
          refill_ratio: 0.2
        }
      }
    )
    subscriber = pubsub.subscriber sub.name

    begin
      # 2 warmup batches -> 0.4 tokens (< 1.0)
      2.times do |i|
        res = publish_single_sync publisher, "rl-warm-#{i}"
        _(res).must_be :succeeded?
      end
      _(publisher.token_bucket.tokens).must_be_close_to 0.4, 1e-6

      orig_publish = custom_service.method :publish
      rpc_calls = Concurrent::AtomicFixnum.new 0

      custom_service.define_singleton_method :publish do |t_name, msgs, **kwargs|
        rpc_calls.increment
        kwargs[:attempt_handle]&.sleep_interruptibly 0.3
        orig_publish.call t_name, msgs, **kwargs
      end

      res = publish_single_sync publisher, "rate-limited-payload"
      _(res).must_be :succeeded?
      _(rpc_calls.value).must_equal 1
      _(publisher.token_bucket.tokens).must_be_close_to 0.6, 1e-6
      _(log_io.string).must_include "Hedging rate limited due to lack of tokens."

      received = pull_messages subscriber, 3
      _(received.map(&:data)).must_include "rate-limited-payload"
    ensure
      publisher.async_publisher&.stop!
      $subscription_admin.delete_subscription subscription: sub.name
    end
  end

  it "rejects enabling message ordering or publishing with an ordering_key when hedging is enabled" do
    suffix = SecureRandom.hex 4
    topic = retrieve_topic "#{$topic_prefix}-hdg-ord-#{suffix}"
    publisher = pubsub.publisher(
      topic.name,
      skip_lookup: true,
      async: {
        hedging: { hedge_delay: 0.2 }
      }
    )

    begin
      err = assert_raises ArgumentError do
        publisher.enable_message_ordering!
      end
      _(err.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."

      err2 = assert_raises ArgumentError do
        publisher.publish_async "ordered-msg", ordering_key: "k1"
      end
      _(err2.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."
    ensure
      publisher.async_publisher&.stop!
    end
  end
end
