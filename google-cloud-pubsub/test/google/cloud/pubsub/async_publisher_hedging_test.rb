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
require "base64"
require "stringio"

Thread.abort_on_exception = true

class ScriptedHedgingTopicAdminStub
  attr_reader :calls

  def initialize &handler
    @mutex = Mutex.new
    @calls = []
    @handler = handler
  end

  def call_count
    @mutex.synchronize { @calls.size }
  end

  def publish_internal request, options = nil
    handle = Thread.current[Google::Cloud::PubSub::TopicAdmin::Client::THREAD_ATTEMPT_HANDLE_KEY]
    call_index = @mutex.synchronize do
      idx = @calls.size
      @calls << { request: request, options: options, handle: handle }
      idx
    end
    @handler.call call_index, request, options, handle
  end
end

describe Google::Cloud::PubSub::AsyncPublisher, :hedging, :mock_pubsub do
  let(:topic_name) { "hedged-topic" }

  describe "default and custom configuration" do
    it "disables hedging by default when hedging option is omitted" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
      begin
        _(publisher.hedging_options).must_be_nil
        _(publisher.token_bucket).must_be_nil
        _(publisher.hedging_scheduler).must_be_nil
      ensure
        publisher.stop!
      end
    end

    it "enables hedging with library defaults when hedging: {} or hedging: true is passed" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, hedging: {}
      begin
        _(publisher.hedging_options).wont_be_nil
        _(publisher.hedging_options).must_be :enabled?
        _(publisher.hedging_options.hedge_delay).must_equal 1.0
        _(publisher.hedging_options.max_tokens).must_equal 50
        _(publisher.hedging_options.refill_ratio).must_equal 0.1
        _(publisher.token_bucket).wont_be_nil
        _(publisher.token_bucket.tokens).must_equal 0.0
        _(publisher.hedging_scheduler).wont_be_nil
      ensure
        publisher.stop!
      end
    end

    it "disables hedging when enabled: false is specified" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        hedging: { enabled: false, hedge_delay: 0.2, max_tokens: 10, refill_ratio: 0.2 }
      )
      begin
        _(publisher.hedging_options).must_be_nil
        _(publisher.token_bucket).must_be_nil
        _(publisher.hedging_scheduler).must_be_nil
      ensure
        publisher.stop!
      end
    end

    it "validates hedging options on both AsyncPublisher.new and pubsub.publisher" do
      assert_raises ArgumentError do
        Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, hedging: { hedge_delay: 0.05 }
      end

      assert_raises ArgumentError do
        Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, hedging: { max_tokens: 0 }
      end

      assert_raises ArgumentError do
        Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, hedging: { refill_ratio: 0.5 }
      end

      assert_raises ArgumentError do
        pubsub.publisher topic_name, skip_lookup: true, async: { hedging: { max_tokens: 300 } }
      end
    end

    it "rejects hedge_delay >= publish_timeout" do
      pubsub.service.timeout = 2.0
      assert_raises ArgumentError do
        Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, hedging: { hedge_delay: 2.0 }
      end

      assert_raises ArgumentError do
        pubsub.publisher topic_name, skip_lookup: true, async: { hedging: { hedge_delay: 2.5 } }
      end
    end

    it "rejects enabling both hedging and message ordering" do
      assert_raises ArgumentError do
        Google::Cloud::PubSub::AsyncPublisher.new(
          topic_name,
          pubsub.service,
          hedging: { hedge_delay: 0.2 },
          message_ordering: true
        )
      end

      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        hedging: { hedge_delay: 0.2 }
      )
      begin
        err = assert_raises ArgumentError do
          publisher.enable_message_ordering!
        end
        _(err.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."
      ensure
        publisher.stop!
      end
    end

    it "rejects ordered messages and ordered batches when hedging is enabled, while preserving OrderedMessagesDisabled when hedging is disabled" do
      unhedged = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
      begin
        assert_raises Google::Cloud::PubSub::OrderedMessagesDisabled do
          unhedged.publish "a", ordering_key: "k1"
        end
      ensure
        unhedged.stop!
      end

      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        hedging: { hedge_delay: 0.1, refill_ratio: 0.2 }
      )
      begin
        stub = ScriptedHedgingTopicAdminStub.new do |_idx, req, _opts, _handle|
          Google::Cloud::PubSub::V1::PublishResponse.new message_ids: Array.new(req[:messages].size, "ord-1")
        end
        publisher.service.mocked_topic_admin = stub

        err = assert_raises ArgumentError do
          publisher.publish "a", ordering_key: "k1"
        end
        _(err.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."

        cb_results = Queue.new
        ordered_item = OpenStruct.new msg: Google::Cloud::PubSub::V1::PubsubMessage.new(data: "a", ordering_key: "k1"),
                                      bytesize: 5,
                                      callback: ->(res) { cb_results.push res }
        ordered_batch = OpenStruct.new "rebalance!" => [ordered_item],
                                       "reset!" => false,
                                       "total_message_bytes" => 5,
                                       "ordering_key" => "k1",
                                       "items" => [ordered_item]

        publisher.send :publish_batch_sync, topic_name, ordered_batch
        res = cb_results.pop
        _(res).must_be :failed?
        _(res.error).must_be_kind_of ArgumentError
        _(res.error.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."
        _(stub.call_count).must_equal 0
        _(publisher.token_bucket.tokens).must_equal 0.0
      ensure
        publisher.stop!
      end
    end
  end

  describe "token bucket warming, depletion, and rate limiting" do
    it "does not hedge on cold start, hedges once after warming to 1.0 token, and rate limits when depleted" do
      log_io = StringIO.new
      raw_logger = Logger.new log_io
      raw_logger.progname = "pubsub"
      raw_logger.level = Logger::DEBUG
      service = Google::Cloud::PubSub::Service.new project, credentials, logger: raw_logger

      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        stub = ScriptedHedgingTopicAdminStub.new do |idx, req, _opts, handle|
          case idx
          when 0
            # Cold-start slow batch: bucket is 0.0, so no hedge should fire even though it sleeps > hedge_delay
            sleep 0.16
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["cold-0"]
          when 1..4
            # 4 fast batches to bring token bucket from 0.2 -> 1.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["warm-#{idx}"]
          when 5
            # Slow batch #1 (attempt 0) when bucket has 1.0 token -> stalls until cancelled by hedged attempt 1 (idx 6)
            begin
              handle.sleep_interruptibly 2.0
            rescue Google::Cloud::PubSub::AsyncPublisher::AttemptCancelledError
              raise GRPC::Cancelled, "cancelled by winner"
            end
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["slow1-primary"]
          when 6
            # Hedged attempt 1 for slow batch #1 -> succeeds immediately!
            # Bucket went 1.0 -> 0.0 (acquired) -> 0.2 (refilled on win)
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["slow1-hedge-win"]
          else
            # Slow batch #2 when bucket only has 0.2 tokens -> rate limited, no hedge fires
            sleep 0.16
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: Array.new(req[:messages].size, "slow2-primary")
          end
        end
        service.mocked_topic_admin = stub

        publish_single = lambda do |payload|
          q = Queue.new
          publisher.publish payload do |res|
            q.push res
          end
          publisher.flush
          q.pop
        end

        # 1. Cold-start slow batch (bucket: 0.0 -> 0.2)
        res0 = publish_single.call "msg-0"
        _(res0).must_be :succeeded?
        _(res0.message_id).must_equal "cold-0"
        _(stub.call_count).must_equal 1
        _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6

        # 2. Warmup 4 fast batches (bucket: 0.2 -> 1.0)
        4.times do |i|
          res = publish_single.call "warm-#{i}"
          _(res).must_be :succeeded?
        end
        _(stub.call_count).must_equal 5
        _(publisher.token_bucket.tokens).must_be_close_to 1.0, 1e-6

        # 3. Slow batch with 1.0 token -> hedges and hedged attempt wins! (bucket: 1.0 - 1.0 + 0.2 = 0.2)
        res_hedged = publish_single.call "slow-1"
        _(res_hedged).must_be :succeeded?
        _(res_hedged.message_id).must_equal "slow1-hedge-win"
        _(stub.call_count).must_equal 7
        _(stub.calls[5][:handle]).must_be :cancelled?
        _(stub.calls[6][:options].retry_policy.retry_codes).must_equal []
        _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6

        # 4. Next slow batch with 0.2 tokens -> rate limited, no hedge dispatched! (bucket: 0.2 + 0.2 = 0.4)
        res_limited = publish_single.call "slow-2"
        _(res_limited).must_be :succeeded?
        _(res_limited.message_id).must_equal "slow2-primary"
        _(stub.call_count).must_equal 8
        _(publisher.token_bucket.tokens).must_be_close_to 0.4, 1e-6

        logs = log_io.string
        _(logs).must_include "Publishing hedged attempt 1"
        _(logs).must_include "Hedging rate limited due to lack of tokens."
      ensure
        publisher.stop!
      end
    end
  end

  describe "race outcomes and cancellation" do
    it "hedged attempt wins, cancels attempt 0, and resolves callbacks with attempt 1 message IDs" do
      pubsub.service.timeout = 5.0
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 2,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        5.times { publisher.token_bucket.refill }
        _(publisher.token_bucket.tokens).must_equal 1.0

        stub = ScriptedHedgingTopicAdminStub.new do |idx, _req, _opts, handle|
          if idx.zero?
            handle.sleep_interruptibly 3.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["orig-1", "orig-2"]
          else
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["hedge-1", "hedge-2"]
          end
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("m1") { |r| results.push r }
        publisher.publish("m2") { |r| results.push r }
        publisher.flush

        r1 = results.pop
        r2 = results.pop
        _(r1).must_be :succeeded?
        _(r2).must_be :succeeded?
        _([r1.message_id, r2.message_id].sort).must_equal ["hedge-1", "hedge-2"]

        _(stub.call_count).must_equal 2
        _(stub.calls[0][:handle]).must_be :cancelled?
        _(stub.calls[1][:options].timeout).must_be :<=, 5.0
        _(stub.calls[1][:options].retry_policy.retry_codes).must_equal []
        _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6
      ensure
        publisher.stop!
      end
    end

    it "original attempt wins before hedge_delay without consuming tokens" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.2, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        5.times { publisher.token_bucket.refill }
        _(publisher.token_bucket.tokens).must_equal 1.0

        stub = ScriptedHedgingTopicAdminStub.new do |_idx, _req, _opts, _handle|
          Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["fast-orig"]
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("fast") { |r| results.push r }
        publisher.flush

        res = results.pop
        _(res).must_be :succeeded?
        _(res.message_id).must_equal "fast-orig"
        _(stub.call_count).must_equal 1
        _(publisher.token_bucket.tokens).must_be_close_to 1.2, 1e-6
      ensure
        publisher.stop!
      end
    end

    it "original attempt wins after hedge is sent and cancels hedged attempt 1" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        5.times { publisher.token_bucket.refill }
        hedge_started = Concurrent::Event.new

        stub = ScriptedHedgingTopicAdminStub.new do |idx, _req, _opts, handle|
          if idx.zero?
            hedge_started.wait 1.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["orig-after-hedge"]
          else
            hedge_started.set
            handle.sleep_interruptibly 3.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["slow-hedge"]
          end
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("race") { |r| results.push r }
        publisher.flush

        res = results.pop
        _(res).must_be :succeeded?
        _(res.message_id).must_equal "orig-after-hedge"
        _(stub.call_count).must_equal 2
        _(stub.calls[0][:handle]).wont_be :cancelled?
        _(stub.calls[1][:handle]).must_be :cancelled?
        _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6
      ensure
        publisher.stop!
      end
    end

    it "supports multiple hedging (attempt 2 wins and cancels both attempt 0 and attempt 1)" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        10.times { publisher.token_bucket.refill }
        _(publisher.token_bucket.tokens).must_equal 2.0

        stub = ScriptedHedgingTopicAdminStub.new do |idx, _req, _opts, handle|
          if idx < 2
            handle.sleep_interruptibly 3.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["stalled-#{idx}"]
          else
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["hedge-2-winner"]
          end
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("multi-hedge") { |r| results.push r }
        publisher.flush

        res = results.pop
        _(res).must_be :succeeded?
        _(res.message_id).must_equal "hedge-2-winner"
        _(stub.call_count).must_equal 3
        _(stub.calls[0][:handle]).must_be :cancelled?
        _(stub.calls[1][:handle]).must_be :cancelled?
        _(stub.calls[2][:handle]).wont_be :cancelled?
        # Started at 2.0, consumed 2 tokens, refilled 0.2 on win -> 0.2
        _(publisher.token_bucket.tokens).must_be_close_to 0.2, 1e-6

        # Verify x-goog-pubsub-client-telemetry header on attempts 0, 1, and 2
        telemetries = (0..2).map do |attempt_idx|
          raw_b64 = stub.calls[attempt_idx][:options].metadata["x-goog-pubsub-client-telemetry"]
          _(raw_b64).wont_be_nil
          decoded = Google::Cloud::PubSub::V1::PubsubClientTelemetry.decode Base64.strict_decode64(raw_b64)
          _(decoded.publish_operation.hedged_attempt_count).must_equal attempt_idx
          _(decoded.publish_operation.publish_start_time.seconds).must_be :>, 0
          decoded
        end
        _(telemetries[1].publish_operation.publish_start_time).must_equal telemetries[0].publish_operation.publish_start_time
        _(telemetries[2].publish_operation.publish_start_time).must_equal telemetries[0].publish_operation.publish_start_time
      ensure
        publisher.stop!
      end
    end
  end

  describe "asymmetric error handling" do
    it "ignores hedged attempt failure while attempt 0 is still in flight and resolves when attempt 0 succeeds" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        5.times { publisher.token_bucket.refill }
        hedge_failed = Concurrent::Event.new

        stub = ScriptedHedgingTopicAdminStub.new do |idx, _req, _opts, _handle|
          if idx.zero?
            hedge_failed.wait 1.0
            sleep 0.02
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["orig-recovered"]
          else
            hedge_failed.set
            raise Google::Cloud::PermissionDeniedError, "hedged attempt failed"
          end
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("msg") { |r| results.push r }
        publisher.flush

        res = results.pop
        _(res).must_be :succeeded?
        _(res.message_id).must_equal "orig-recovered"
        _(stub.call_count).must_equal 2
      ensure
        publisher.stop!
      end
    end

    it "immediately cancels in-flight hedged attempt and fails batch when attempt 0 fails terminally" do
      publisher = Google::Cloud::PubSub::AsyncPublisher.new(
        topic_name,
        pubsub.service,
        max_messages: 1,
        interval: 0.005,
        hedging: { hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 }
      )

      begin
        5.times { publisher.token_bucket.refill }
        hedge_started = Concurrent::Event.new

        stub = ScriptedHedgingTopicAdminStub.new do |idx, _req, _opts, handle|
          if idx.zero?
            hedge_started.wait 1.0
            raise Google::Cloud::InvalidArgumentError, "permanent failure on attempt 0"
          else
            hedge_started.set
            handle.sleep_interruptibly 3.0
            Google::Cloud::PubSub::V1::PublishResponse.new message_ids: ["unreachable"]
          end
        end
        publisher.service.mocked_topic_admin = stub

        results = Queue.new
        publisher.publish("bad-msg") { |r| results.push r }
        publisher.flush

        res = results.pop
        _(res).must_be :failed?
        _(res.error).must_be_kind_of Google::Cloud::InvalidArgumentError
        _(stub.call_count).must_equal 2
        _(stub.calls[1][:handle]).must_be :cancelled?
      ensure
        publisher.stop!
      end
    end
  end
end
