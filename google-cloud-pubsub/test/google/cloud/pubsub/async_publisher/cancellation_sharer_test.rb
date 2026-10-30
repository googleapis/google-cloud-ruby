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
require "google/cloud/pubsub/async_publisher/hedging_token_bucket"
require "google/cloud/pubsub/async_publisher/cancellation_sharer"

describe Google::Cloud::PubSub::AsyncPublisher::CancellationSharer do
  let(:bucket_class) { Google::Cloud::PubSub::AsyncPublisher::HedgingTokenBucket }
  let(:sharer_class) { Google::Cloud::PubSub::AsyncPublisher::CancellationSharer }
  let(:handle_class) { Google::Cloud::PubSub::AsyncPublisher::AttemptHandle }
  let(:cancelled_error_class) { Google::Cloud::PubSub::AsyncPublisher::AttemptCancelledError }
  let(:token_bucket) { bucket_class.new({ refill_ratio: 0.2, max_tokens: 10 }) }
  let(:batch_payload) { ["msg-1", "msg-2"] }

  describe "AttemptHandle" do
    it "cancels a registered gRPC operation when cancel! is called" do
      handle = handle_class.new
      cancelled_ops = []
      fake_op = Object.new
      fake_op.define_singleton_method(:cancel) { cancelled_ops << :cancelled }

      handle.register_operation fake_op
      _(handle.cancelled?).must_equal false

      _(handle.cancel!).must_equal true
      _(handle.cancelled?).must_equal true
      _(cancelled_ops).must_equal [:cancelled]

      # Idempotent on subsequent cancel! calls
      _(handle.cancel!).must_equal false
      _(cancelled_ops).must_equal [:cancelled]
    end

    it "immediately cancels an operation registered after cancel! was already called" do
      handle = handle_class.new
      handle.cancel!

      cancelled_ops = []
      fake_op = Object.new
      fake_op.define_singleton_method(:cancel) { cancelled_ops << :cancelled }

      assert_raises cancelled_error_class do
        handle.register_operation fake_op
      end
      _(cancelled_ops).must_equal [:cancelled]
    end

    it "wakes sleep_interruptibly immediately when cancel! is called" do
      handle = handle_class.new
      started = Concurrent::Event.new

      sleeper = Thread.new do
        started.set
        assert_raises cancelled_error_class do
          handle.sleep_interruptibly 10.0
        end
      end

      started.wait 1.0
      sleep 0.01
      handle.cancel!
      _(sleeper.join(1.0)).wont_be_nil
    end
  end

  describe "CancellationSharer attempt coordination" do
    it "cancels sibling attempts, refills token bucket, and nulls out batch when attempt 0 wins" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      h0 = sharer.add_attempt 0
      h1 = sharer.add_attempt 1

      _(sharer.batch).must_equal batch_payload
      _(sharer.running_attempt_count).must_equal 2

      _(sharer.handle_attempt_success(0, "resp-0")).must_equal true
      _(sharer.done?).must_equal true
      _(sharer.winning_attempt).must_equal 0
      _(sharer.batch).must_be_nil
      _(sharer.running_attempt_count).must_equal 0
      _(h0.cancelled?).must_equal false
      _(h1.cancelled?).must_equal true
      _(token_bucket.tokens).must_equal 0.2
      _(sharer.wait(0.1)).must_equal "resp-0"

      # Late completion from attempt 1 is ignored
      _(sharer.handle_attempt_success(1, "resp-1")).must_equal false
      _(token_bucket.tokens).must_equal 0.2
    end

    it "cancels attempt 0 and resolves with hedged response when attempt 1 wins" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      h0 = sharer.add_attempt 0
      h1 = sharer.add_attempt 1

      _(sharer.handle_attempt_success(1, "resp-1")).must_equal true
      _(sharer.done?).must_equal true
      _(sharer.winning_attempt).must_equal 1
      _(sharer.batch).must_be_nil
      _(h0.cancelled?).must_equal true
      _(h1.cancelled?).must_equal false
      _(token_bucket.tokens).must_equal 0.2
      _(sharer.wait(0.1)).must_equal "resp-1"
    end

    it "immediately cancels a late attempt registered via add_attempt after done is true" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      sharer.add_attempt 0
      sharer.handle_attempt_success 0, "resp-0"

      late_handle = handle_class.new
      _(sharer.add_attempt(1, late_handle)).must_be_nil
      _(late_handle.cancelled?).must_equal true
    end

    it "discards hedged attempt errors while attempt 0 is still in flight" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      h0 = sharer.add_attempt 0
      h1 = sharer.add_attempt 1

      hedged_err = StandardError.new "PERMISSION_DENIED on hedged attempt"
      _(sharer.handle_attempt_failure(1, hedged_err)).must_equal false
      _(sharer.done?).must_equal false
      _(sharer.batch).must_equal batch_payload
      _(h0.cancelled?).must_equal false
      _(sharer.running_attempt_count).must_equal 1

      # Subsequent success on attempt 0 resolves the batch normally
      _(sharer.handle_attempt_success(0, "resp-0")).must_equal true
      _(sharer.wait(0.1)).must_equal "resp-0"
    end

    it "terminates immediately and cancels in-flight hedged attempts when attempt 0 fails terminally" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      sharer.add_attempt 0
      h1 = sharer.add_attempt 1
      h2 = sharer.add_attempt 2

      primary_err = StandardError.new "Primary attempt exhausted retries"
      _(sharer.handle_attempt_failure(0, primary_err)).must_equal true
      _(sharer.done?).must_equal true
      _(sharer.batch).must_be_nil
      _(h1.cancelled?).must_equal true
      _(h2.cancelled?).must_equal true
      _(token_bucket.tokens).must_equal 0.0

      err = assert_raises StandardError do
        sharer.wait 0.1
      end
      _(err).must_be_same_as primary_err
    end

    it "invokes on_complete callbacks outside the coordinator mutex without deadlocking" do
      sharer = sharer_class.new batch: batch_payload, token_bucket: token_bucket, deadline: 100.0
      sharer.add_attempt 0

      reentered_done = nil
      reentered_batch = :not_checked
      sharer.on_complete do |_resp, _err, _winner|
        # Re-entering sharer methods inside on_complete would raise ThreadError
        # if on_complete were invoked while holding @mutex.
        reentered_done = sharer.done?
        reentered_batch = sharer.batch
      end

      sharer.handle_attempt_success 0, "resp-0"
      _(reentered_done).must_equal true
      _(reentered_batch).must_be_nil
    end
  end
end
