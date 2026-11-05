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
require "stringio"
require "google/cloud/pubsub/internal_logger"
require "google/cloud/pubsub/async_publisher/hedging_token_bucket"
require "google/cloud/pubsub/async_publisher/cancellation_sharer"
require "google/cloud/pubsub/async_publisher/hedging_scheduler"

describe Google::Cloud::PubSub::AsyncPublisher, :hedging_scheduler do
  let(:bucket_class) { Google::Cloud::PubSub::AsyncPublisher.const_get :HedgingTokenBucket }
  let(:sharer_class) { Google::Cloud::PubSub::AsyncPublisher.const_get :CancellationSharer }
  let(:scheduler_class) { Google::Cloud::PubSub::AsyncPublisher.const_get :HedgingScheduler }
  let(:log_io) { StringIO.new }
  let(:ruby_logger) do
    Logger.new(log_io).tap do |l|
      l.level = Logger::DEBUG
      l.progname = "pubsub"
    end
  end
  let(:internal_logger) { Google::Cloud::PubSub::InternalLogger.new ruby_logger }

  it "hides HedgedRequest and HedgingScheduler as private constants" do
    assert_raises NameError do
      Google::Cloud::PubSub::AsyncPublisher::HedgedRequest
    end
    assert_raises NameError do
      Google::Cloud::PubSub::AsyncPublisher::HedgingScheduler
    end
  end

  it "dispatches hedged attempts in FIFO order, caps timeout at 10s, and re-enqueues for multiple hedging" do
    now_time = 100.0
    fake_clock = -> { now_time }
    bucket = bucket_class.new({ hedge_delay: 1.0, max_tokens: 10, refill_ratio: 0.2 })
    # Warm up 10 refills -> 2.0 tokens
    10.times { bucket.refill }
    _(bucket.tokens).must_equal 2.0

    dispatched = []
    scheduler = scheduler_class.new(
      hedge_delay: 1.0,
      token_bucket: bucket,
      logger: internal_logger,
      clock: fake_clock,
      auto_start: false
    ) do |coordinator, batch, attempt_number, attempt_timeout|
      dispatched << {
        coordinator: coordinator,
        batch: batch,
        attempt: attempt_number,
        timeout: attempt_timeout
      }
    end

    sharer = sharer_class.new batch: ["msg-a"], token_bucket: bucket, deadline: 160.0
    sharer.add_attempt 0
    scheduler.schedule sharer

    # Before hedge_delay (t = 100.5s): nothing due
    now_time = 100.5
    _(scheduler.process_queue).must_equal 0
    _(dispatched).must_be_empty

    # At t = 101.0s: attempt 1 fires with timeout capped at 10.0s (remaining is 59.0s)
    now_time = 101.0
    _(scheduler.process_queue).must_equal 1
    _(dispatched.size).must_equal 1
    _(dispatched[0][:attempt]).must_equal 1
    _(dispatched[0][:timeout]).must_equal 10.0
    _(dispatched[0][:batch]).must_equal ["msg-a"]
    _(bucket.tokens).must_equal 1.0
    _(log_io.string).must_include "Publishing hedged attempt 1"

    # Attempt 2 was automatically scheduled for t = 102.0s
    _(scheduler.size).must_equal 1
    now_time = 102.0
    _(scheduler.process_queue).must_equal 1
    _(dispatched.size).must_equal 2
    _(dispatched[1][:attempt]).must_equal 2
    _(bucket.tokens).must_equal 0.0
    _(log_io.string).must_include "Publishing hedged attempt 2"

    # At t = 103.0s: bucket is now empty (0.0 tokens), so attempt 3 is rate-limited and NOT re-enqueued
    _(scheduler.size).must_equal 1
    now_time = 103.0
    _(scheduler.process_queue).must_equal 0
    _(dispatched.size).must_equal 2
    _(scheduler.size).must_equal 0
    _(log_io.string).must_include "Hedging rate limited due to lack of tokens."
  end

  it "uses remaining deadline when less than 10s remains and skips expired deadlines" do
    now_time = 50.0
    fake_clock = -> { now_time }
    bucket = bucket_class.new({ hedge_delay: 1.0, max_tokens: 10, refill_ratio: 0.2 })
    5.times { bucket.refill } # 1.0 token

    dispatched = []
    scheduler = scheduler_class.new(
      hedge_delay: 1.0,
      token_bucket: bucket,
      clock: fake_clock,
      auto_start: false
    ) do |_coordinator, _batch, attempt_number, attempt_timeout|
      dispatched << { attempt: attempt_number, timeout: attempt_timeout }
    end

    # Deadline is at t = 54.5s
    sharer = sharer_class.new batch: ["msg-short"], token_bucket: bucket, deadline: 54.5
    sharer.add_attempt 0
    scheduler.schedule sharer

    now_time = 51.0
    _(scheduler.process_queue).must_equal 1
    _(dispatched.first[:timeout]).must_be_close_to 3.5, 0.001

    # Next check at t = 55.0s (past deadline 54.5s) is skipped without touching the bucket
    5.times { bucket.refill } # 1.0 token
    now_time = 55.0
    _(scheduler.process_queue).must_equal 0
    _(bucket.tokens).must_equal 1.0
  end

  it "skips completed coordinators and does not retain batch payload references in HedgedRequest" do
    now_time = 10.0
    fake_clock = -> { now_time }
    bucket = bucket_class.new({ hedge_delay: 1.0, max_tokens: 10, refill_ratio: 0.2 })
    5.times { bucket.refill } # 1.0 token

    dispatched = []
    scheduler = scheduler_class.new(
      hedge_delay: 1.0,
      token_bucket: bucket,
      clock: fake_clock,
      auto_start: false
    ) do |_coordinator, _batch, attempt_number, _timeout|
      dispatched << attempt_number
    end

    sharer = sharer_class.new batch: ["payload"], token_bucket: bucket, deadline: 30.0
    sharer.add_attempt 0
    req = scheduler.schedule sharer

    # HedgedRequest struct does not have a batch field
    _(req.members).must_equal [:coordinator, :attempt_number, :send_after]

    # Attempt 0 succeeds before hedge_delay
    sharer.handle_attempt_success 0, "ok"
    _(sharer.batch).must_be_nil
    _(scheduler.size).must_equal 1

    # When hedge_delay arrives, scheduler skips the completed sharer and does not consume a token
    now_time = 11.0
    _(scheduler.process_queue).must_equal 0
    _(dispatched).must_be_empty
    _(bucket.tokens).must_equal 1.2
  end

  it "runs with background timer thread when auto_start: true and stops cleanly" do
    bucket = bucket_class.new({ hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 })
    5.times { bucket.refill }

    dispatched_event = Concurrent::Event.new
    dispatched_attempts = []

    scheduler = scheduler_class.new(
      hedge_delay: 0.1,
      token_bucket: bucket,
      auto_start: true
    ) do |coordinator, _batch, attempt_number, _timeout|
      dispatched_attempts << attempt_number
      coordinator.handle_attempt_success attempt_number, "hedged-ok"
      dispatched_event.set
    end

    now = scheduler.now
    sharer = sharer_class.new batch: ["live-timer-msg"], token_bucket: bucket, deadline: now + 5.0
    sharer.add_attempt 0
    scheduler.schedule sharer

    _(dispatched_event.wait(1.0)).must_equal true
    _(dispatched_attempts).must_equal [1]
    _(sharer.wait(0.5)).must_equal "hedged-ok"

    scheduler.stop!
    _(scheduler.stopped?).must_equal true
  end

  it "refunds token when dispatch returns false or raises and keeps background timer thread alive" do
    bucket = bucket_class.new({ hedge_delay: 0.1, max_tokens: 10, refill_ratio: 0.2 })
    5.times { bucket.refill }
    _(bucket.tokens).must_equal 1.0

    second_event = Concurrent::Event.new
    call_num = 0

    scheduler = scheduler_class.new(
      hedge_delay: 0.1,
      token_bucket: bucket,
      auto_start: true
    ) do |coordinator, _batch, attempt_number, _timeout|
      call_num += 1
      raise "unexpected dispatch error" if call_num == 1

      coordinator.handle_attempt_success attempt_number, "recovered-hedge"
      second_event.set
      true
    end

    now = scheduler.now
    sharer1 = sharer_class.new batch: ["msg-1"], token_bucket: bucket, deadline: now + 5.0
    sharer1.add_attempt 0
    scheduler.schedule sharer1

    sharer2 = sharer_class.new batch: ["msg-2"], token_bucket: bucket, deadline: now + 5.0
    sharer2.add_attempt 0
    scheduler.schedule sharer2, send_after: now + 0.15

    _(second_event.wait(1.0)).must_equal true
    _(sharer2.wait(0.5)).must_equal "recovered-hedge"
    # First dispatch raised -> refunded 1.0 token, so second dispatch was able to acquire that token and win (+0.2 refill)
    _(bucket.tokens).must_be_close_to 0.2, 1e-6

    scheduler.stop!
  end
end
