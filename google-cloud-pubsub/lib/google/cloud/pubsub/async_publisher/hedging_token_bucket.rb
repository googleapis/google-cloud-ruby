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


require "google/cloud/pubsub/async_publisher/hedging_options"

module Google
  module Cloud
    module PubSub
      class AsyncPublisher
        ##
        # @private
        #
        # Thread-safe client-side token bucket rate limiter for Publish Hedging.
        # Uses fixed-point integer arithmetic scaled by 1,000 to avoid floating-point
        # rounding drift on fractional refill ratios down to 0.001.
        #
        class HedgingTokenBucket
          HEDGE_TOKEN_SCALE = 1000

          attr_reader :options
          attr_reader :hedge_delay
          attr_reader :max_tokens
          attr_reader :refill_ratio

          def initialize options = {}
            @options = options.is_a?(HedgingOptions) ? options : HedgingOptions.from(options)
            raise ArgumentError, "HedgingOptions must be enabled" if @options.nil?

            @hedge_delay = @options.hedge_delay
            @max_tokens = @options.max_tokens
            @refill_ratio = @options.refill_ratio

            @scaled_tokens = 0
            @scaled_max_tokens = @max_tokens * HEDGE_TOKEN_SCALE
            @scaled_refill_amount = (@refill_ratio * HEDGE_TOKEN_SCALE).round
            @mutex = Mutex.new
          end

          ##
          # Attempts to deduct 1.0 full token (1,000 scaled units) from the bucket.
          #
          # @return [Boolean] true if a token was acquired, false otherwise.
          #
          def try_acquire_hedge_token
            @mutex.synchronize do
              return false if @scaled_tokens < HEDGE_TOKEN_SCALE

              @scaled_tokens -= HEDGE_TOKEN_SCALE
              true
            end
          end

          ##
          # Credits refill_ratio tokens to the bucket, capped at max_tokens.
          #
          # @return [Float] Updated logical token count.
          #
          def refill
            @mutex.synchronize do
              @scaled_tokens = [@scaled_tokens + @scaled_refill_amount, @scaled_max_tokens].min
              @scaled_tokens.to_f / HEDGE_TOKEN_SCALE
            end
          end

          ##
          # Returns the current logical token balance.
          #
          # @return [Float]
          #
          def tokens
            @mutex.synchronize do
              @scaled_tokens.to_f / HEDGE_TOKEN_SCALE
            end
          end

          ##
          # Returns the raw fixed-point scaled token balance (1,000 = 1.0 token).
          #
          # @return [Integer]
          #
          def scaled_tokens
            @mutex.synchronize { @scaled_tokens }
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
