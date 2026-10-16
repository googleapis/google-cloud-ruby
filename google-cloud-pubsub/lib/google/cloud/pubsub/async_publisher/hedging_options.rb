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


module Google
  module Cloud
    module PubSub
      class AsyncPublisher
        ##
        # @private
        #
        # Configuration options and validation invariants for Publish Hedging.
        #
        class HedgingOptions
          DEFAULT_ENABLED = true
          DEFAULT_HEDGE_DELAY = 1.0
          DEFAULT_MAX_TOKENS = 50
          DEFAULT_REFILL_RATIO = 0.1

          MIN_HEDGE_DELAY = 0.1
          MAX_HEDGE_DELAY = 10.0

          MIN_MAX_TOKENS = 1
          MAX_MAX_TOKENS = 250

          MIN_REFILL_RATIO = 0.001
          MAX_REFILL_RATIO = 0.2

          attr_reader :enabled
          attr_reader :hedge_delay
          attr_reader :max_tokens
          attr_reader :refill_ratio

          alias enabled? enabled
          alias delay hedge_delay

          def initialize enabled: DEFAULT_ENABLED,
                         hedge_delay: nil,
                         delay: nil,
                         max_tokens: nil,
                         refill_ratio: nil
            @enabled = enabled.nil? ? DEFAULT_ENABLED : Boolean(enabled)
            raw_delay = hedge_delay.nil? ? delay : hedge_delay
            @hedge_delay = raw_delay.nil? ? DEFAULT_HEDGE_DELAY : raw_delay
            @max_tokens = max_tokens.nil? ? DEFAULT_MAX_TOKENS : max_tokens
            @refill_ratio = refill_ratio.nil? ? DEFAULT_REFILL_RATIO : refill_ratio

            validate_bounds! if @enabled
          end

          ##
          # Resolves and validates hedging options from a Hash, HedgingOptions, or nil.
          # Returns nil if hedging is not configured or explicitly disabled.
          #
          # @param [Hash, HedgingOptions, Boolean, nil] options
          # @param [Boolean] message_ordering Whether message ordering is enabled.
          # @param [Numeric, nil] timeout Effective publish RPC timeout in seconds.
          # @return [HedgingOptions, nil]
          #
          def self.from options, message_ordering: false, timeout: nil
            return nil if options.nil? || options == false

            resolved = case options
                       when HedgingOptions
                         options
                       when true
                         new
                       when Hash
                         from_hash options
                       else
                         raise ArgumentError, "hedging must be a Hash or HedgingOptions"
                       end

            return nil unless resolved.enabled?

            resolved.validate_message_ordering! message_ordering
            resolved.validate_timeout! timeout
            resolved
          end

          def validate_message_ordering! message_ordering
            return unless @enabled && message_ordering

            raise ArgumentError, "Publish hedging and message ordering cannot be enabled at the same time."
          end

          def validate_timeout! timeout
            return unless @enabled && timeout.is_a?(Numeric)
            return if @hedge_delay < timeout

            raise ArgumentError,
                  "hedge_delay (#{@hedge_delay}s) must be strictly less than publish timeout (#{timeout}s)"
          end

          def self.from_hash hash
            new(
              enabled: fetch_opt(hash, :enabled, DEFAULT_ENABLED),
              hedge_delay: fetch_opt(hash, :hedge_delay),
              delay: fetch_opt(hash, :delay),
              max_tokens: fetch_opt(hash, :max_tokens),
              refill_ratio: fetch_opt(hash, :refill_ratio)
            )
          end
          private_class_method :from_hash

          def self.fetch_opt hash, key, default = nil
            if hash.key? key
              hash[key]
            elsif hash.key? key.to_s
              hash[key.to_s]
            else
              default
            end
          end
          private_class_method :fetch_opt

          private

          def Boolean value # rubocop:disable Naming/MethodName
            return value if value == true || value == false

            raise ArgumentError, "enabled must be a boolean"
          end

          def validate_bounds!
            validate_hedge_delay!
            validate_max_tokens!
            validate_refill_ratio!
          end

          def validate_hedge_delay!
            unless @hedge_delay.is_a?(Numeric) && !nan_or_infinite?(@hedge_delay) &&
                   @hedge_delay >= MIN_HEDGE_DELAY && @hedge_delay <= MAX_HEDGE_DELAY
              raise ArgumentError,
                    "hedge_delay must be between #{MIN_HEDGE_DELAY} and #{MAX_HEDGE_DELAY} seconds"
            end
            @hedge_delay = @hedge_delay.to_f
          end

          def validate_max_tokens!
            unless @max_tokens.is_a?(Integer) &&
                   @max_tokens >= MIN_MAX_TOKENS && @max_tokens <= MAX_MAX_TOKENS
              raise ArgumentError,
                    "max_tokens must be an Integer between #{MIN_MAX_TOKENS} and #{MAX_MAX_TOKENS}"
            end
          end

          def validate_refill_ratio!
            unless @refill_ratio.is_a?(Numeric) && !nan_or_infinite?(@refill_ratio) &&
                   @refill_ratio >= MIN_REFILL_RATIO && @refill_ratio <= MAX_REFILL_RATIO
              raise ArgumentError,
                    "refill_ratio must be between #{MIN_REFILL_RATIO} and #{MAX_REFILL_RATIO}"
            end
            @refill_ratio = @refill_ratio.to_f
          end

          def nan_or_infinite? num
            num.respond_to?(:nan?) && (num.nan? || num.infinite?)
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
