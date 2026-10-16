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
require "google/cloud/pubsub/async_publisher/hedging_options"
require "google/cloud/pubsub/async_publisher/hedging_token_bucket"

describe Google::Cloud::PubSub::AsyncPublisher::HedgingTokenBucket do
  let(:options_class) { Google::Cloud::PubSub::AsyncPublisher::HedgingOptions }
  let(:bucket_class) { Google::Cloud::PubSub::AsyncPublisher::HedgingTokenBucket }

  describe "HedgingOptions validation and defaults" do
    it "returns nil when options are nil, false, or enabled: false" do
      _(options_class.from(nil)).must_be_nil
      _(options_class.from(false)).must_be_nil
      _(options_class.from({ enabled: false })).must_be_nil
      _(options_class.from({ "enabled" => false, "hedge_delay" => 0.001 })).must_be_nil
    end

    it "applies spec defaults when an empty Hash or true is passed" do
      opts = options_class.from({})
      _(opts).wont_be_nil
      _(opts.enabled?).must_equal true
      _(opts.hedge_delay).must_equal 1.0
      _(opts.delay).must_equal 1.0
      _(opts.max_tokens).must_equal 50
      _(opts.refill_ratio).must_equal 0.1

      opts_true = options_class.from true
      _(opts_true.hedge_delay).must_equal 1.0
      _(opts_true.max_tokens).must_equal 50
      _(opts_true.refill_ratio).must_equal 0.1
    end

    it "supports delay alias and string keys" do
      opts = options_class.from({ "delay" => 0.25, "max_tokens" => 10, "refill_ratio" => 0.05 })
      _(opts.hedge_delay).must_equal 0.25
      _(opts.max_tokens).must_equal 10
      _(opts.refill_ratio).must_equal 0.05
    end

    it "validates hedge_delay bounds (0.1s..10.0s)" do
      _(options_class.from({ hedge_delay: 0.1 }).hedge_delay).must_equal 0.1
      _(options_class.from({ hedge_delay: 10.0 }).hedge_delay).must_equal 10.0

      [0.099, 0, -1.0, 10.001, Float::NAN, Float::INFINITY, "1.0"].each do |invalid_delay|
        assert_raises ArgumentError do
          options_class.from({ hedge_delay: invalid_delay })
        end
      end
    end

    it "validates max_tokens bounds (Integer in 1..250)" do
      _(options_class.from({ max_tokens: 1 }).max_tokens).must_equal 1
      _(options_class.from({ max_tokens: 250 }).max_tokens).must_equal 250

      [0, -10, 251, 10.5, "50", Float::NAN].each do |invalid_max|
        assert_raises ArgumentError do
          options_class.from({ max_tokens: invalid_max })
        end
      end
    end

    it "validates refill_ratio bounds (0.001..0.2)" do
      _(options_class.from({ refill_ratio: 0.001 }).refill_ratio).must_equal 0.001
      _(options_class.from({ refill_ratio: 0.2 }).refill_ratio).must_equal 0.2

      [0.0009, 0.0, -0.1, 0.2001, Float::NAN, Float::INFINITY, "0.1"].each do |invalid_ratio|
        assert_raises ArgumentError do
          options_class.from({ refill_ratio: invalid_ratio })
        end
      end
    end

    it "rejects enabling hedging and message ordering simultaneously" do
      err = assert_raises ArgumentError do
        options_class.from({}, message_ordering: true)
      end
      _(err.message).must_include "Publish hedging and message ordering cannot be enabled at the same time."

      # Allowed when hedging is explicitly disabled
      _(options_class.from({ enabled: false }, message_ordering: true)).must_be_nil
    end

    it "validates hedge_delay is strictly less than publish timeout" do
      _(options_class.from({ hedge_delay: 1.0 }, timeout: 60.0).hedge_delay).must_equal 1.0

      assert_raises ArgumentError do
        options_class.from({ hedge_delay: 5.0 }, timeout: 5.0)
      end

      assert_raises ArgumentError do
        options_class.from({ hedge_delay: 5.0 }, timeout: 2.0)
      end
    end
  end

  describe "HedgingTokenBucket fixed-point arithmetic and concurrency" do
    it "starts at 0 tokens and refuses acquisition until 1.0 token is accumulated" do
      bucket = bucket_class.new({ refill_ratio: 0.2, max_tokens: 10 })
      _(bucket.tokens).must_equal 0.0
      _(bucket.scaled_tokens).must_equal 0
      _(bucket.try_acquire_hedge_token).must_equal false

      4.times { bucket.refill }
      _(bucket.tokens).must_equal 0.8
      _(bucket.try_acquire_hedge_token).must_equal false

      bucket.refill
      _(bucket.tokens).must_equal 1.0
      _(bucket.try_acquire_hedge_token).must_equal true
      _(bucket.tokens).must_equal 0.0
      _(bucket.try_acquire_hedge_token).must_equal false
    end

    it "avoids floating-point drift on 0.001 refill_ratio across 1,000 refills" do
      bucket = bucket_class.new({ refill_ratio: 0.001, max_tokens: 5 })
      999.times { bucket.refill }
      _(bucket.scaled_tokens).must_equal 999
      _(bucket.try_acquire_hedge_token).must_equal false

      bucket.refill
      _(bucket.scaled_tokens).must_equal 1000
      _(bucket.tokens).must_equal 1.0
      _(bucket.try_acquire_hedge_token).must_equal true
      _(bucket.scaled_tokens).must_equal 0
    end

    it "caps accumulated tokens at max_tokens" do
      bucket = bucket_class.new({ refill_ratio: 0.2, max_tokens: 2 })
      20.times { bucket.refill }
      _(bucket.tokens).must_equal 2.0
      _(bucket.scaled_tokens).must_equal 2000

      _(bucket.try_acquire_hedge_token).must_equal true
      _(bucket.try_acquire_hedge_token).must_equal true
      _(bucket.try_acquire_hedge_token).must_equal false
      _(bucket.tokens).must_equal 0.0
    end

    it "is thread-safe under concurrent refill and token acquisition" do
      bucket = bucket_class.new({ refill_ratio: 0.1, max_tokens: 250 })
      # 10 threads each refilling 200 times = 2,000 refills of 0.1 = 200.0 tokens total
      acquired_count = Concurrent::AtomicFixnum.new 0

      refillers = Array.new(10) do
        Thread.new do
          200.times { bucket.refill }
        end
      end

      acquirers = Array.new(5) do
        Thread.new do
          400.times do
            acquired_count.increment if bucket.try_acquire_hedge_token
          end
        end
      end

      (refillers + acquirers).each(&:join)

      # Drain any remaining full tokens after refillers finish
      acquired_count.increment while bucket.try_acquire_hedge_token

      _(acquired_count.value).must_equal 200
      _(bucket.scaled_tokens).must_equal 0
    end
  end
end
