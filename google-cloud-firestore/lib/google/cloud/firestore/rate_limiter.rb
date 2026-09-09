# Copyright 2023 Google LLC
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
    module Firestore
      ##
      # @private Implements 5/5/5 ramp-up via Token Bucket algorithm.
      #
      # 5/5/5 is a ramp up strategy that starts with a budget of 500 operations per
      # second. Additionally, every 5 minutes, the maximum budget can increase by
      # 50%. Thus, at 5:01 into a long bulk-writing process, the maximum budget
      # becomes 750 operations per second. At 10:01, the budget becomes 1,125
      # operations per second.
      #
      class RateLimiter
        DEFAULT_STARTING_MAXIMUM_OPS_PER_SECOND = 500.0
        DEFAULT_PHASE_LENGTH = 300.0

        attr_reader :bandwidth

        ##
        # Initialize the object
        def initialize starting_ops: nil, phase_length: nil
          @start_time = time
          @last_fetched = time
          @bandwidth = (starting_ops || DEFAULT_STARTING_MAXIMUM_OPS_PER_SECOND).to_f
          @phase_length = phase_length || DEFAULT_PHASE_LENGTH
        end

        ##
        # Wait till the number of tokens is available
        # Assumes that the bandwidth is distributed evenly across the entire second.
        #
        # Example - If the limit is 500 qps, then it has been further broken down to 2e+6 nsec
        # per query
        #
        # @return [nil]
        def wait_for_tokens size
          available_time = @last_fetched + (size / @bandwidth)
          waiting_time = [0, available_time - time].max
          sleep waiting_time
          @last_fetched = time
          increase_bandwidth
        end

        private

        ##
        # Returns time elapsed since epoch.
        #
        # @return [Float] Float denoting time elapsed since epoch
        def time
          Time.now.to_f
        end

        ##
        # Increase the bandwidth as per 555 rule
        #
        # @return [nil]
        def increase_bandwidth
          intervals = (time - @start_time) / @phase_length
          @bandwidth = (DEFAULT_STARTING_MAXIMUM_OPS_PER_SECOND * (1.5**intervals.floor)).to_f
        end
      end
    end
  end
end
