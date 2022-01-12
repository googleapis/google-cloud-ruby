# Copyright 2019 Google LLC
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

module Gapic
  class CallOptions
    ##
    # The policy for retrying failed RPC calls using an incremental backoff. A new object instance should be used for
    # every RpcCall invocation.
    #
    # Only errors orginating from GRPC will be retried.
    #
    class RetryPolicy
      ##
      # Create new API Call RetryPolicy.
      #
      # @param initial_delay [Numeric] client-side timeout
      # @param multiplier [Numeric] client-side timeout
      # @param max_delay [Numeric] client-side timeout
      #
      def initialize retry_codes: nil, initial_delay: nil, multiplier: nil, max_delay: nil
        @retry_codes   = convert_codes retry_codes
        @initial_delay = initial_delay
        @multiplier    = multiplier
        @max_delay     = max_delay
        @delay         = nil
      end

      def retry_codes
        @retry_codes || []
      end

      def initial_delay
        @initial_delay || 1
      end

      def multiplier
        @multiplier || 1.3
      end

      def max_delay
        @max_delay || 15
      end

      ##
      # The current delay value.
      def delay
        @delay || initial_delay
      end

      def call error
        return false unless retry? error

        delay!
        increment_delay!

        true
      end

      ##
      # @private
      # Apply default values to the policy object. This does not replace user-provided values, it only overrides empty
      # values.
      #
      # @param retry_policy [Hash] The policy for error retry. keys must match the arguments for
      #   {RpcCall::RetryPolicy.new}.
      def apply_defaults retry_policy
        return unless retry_policy.is_a? Hash

        @retry_codes   ||= convert_codes retry_policy[:retry_codes]
        @initial_delay ||= retry_policy[:initial_delay]
        @multiplier    ||= retry_policy[:multiplier]
        @max_delay     ||= retry_policy[:max_delay]

        self
      end

      # @private
      # See https://grpc.github.io/grpc/core/md_doc_statuscodes.html for a
      # list of error codes.
      ERROR_CODE_MAPPING = [
        "OK",
        "CANCELLED",
        "UNKNOWN",
        "INVALID_ARGUMENT",
        "DEADLINE_EXCEEDED",
        "NOT_FOUND",
        "ALREADY_EXISTS",
        "PERMISSION_DENIED",
        "RESOURCE_EXHAUSTED",
        "FAILED_PRECONDITION",
        "ABORTED",
        "OUT_OF_RANGE",
        "UNIMPLEMENTED",
        "INTERNAL",
        "UNAVAILABLE",
        "DATA_LOSS",
        "UNAUTHENTICATED"
      ].freeze

      # @private
      ERROR_STRING_MAPPING = ERROR_CODE_MAPPING.each_with_index.each_with_object({}) do |(str, num), hash|
        hash[str] = num
      end.freeze

      private

      def retry? error
        error.is_a?(GRPC::BadStatus) && retry_codes.include?(error.code)
      end

      def delay!
        # Call Kernel.sleep so we can stub it.
        Kernel.sleep delay
      end

      def convert_codes input_codes
        return nil if input_codes.nil?
        Array(input_codes).map do |obj|
          case obj
          when String
            ERROR_STRING_MAPPING[obj]
          when Integer
            obj
          end
        end.compact
      end

      ##
      # Calculate and set the next delay value.
      def increment_delay!
        @delay = [delay * multiplier, max_delay].min
      end
    end
  end
end
