# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Debugger
      ##
      # # RequestQuotaManager
      #
      # Tracking object used by debugger agent to manage quota in
      # request-based applications. This class tracks the amount of time
      # and number of breakpoints to evaluation in a single session.
      #
      # The debugger agent doesn't have use a quota manager by default, which
      # means it will evaluate all breakpoints encountered and takes as much
      # time as needed. This class is utilized by
      # {Google::Cloud::Debugger::Middleware} class to limit latency overhead
      # when used in Rack-based applications.
      #
      class RequestQuotaManager
        # Default Total time allowed to consume, in seconds
        DEFAULT_TIME_QUOTA = 0.05

        # Default max number of breakpoints to evaluate
        DEFAULT_COUNT_QUOTA = 10

        ##
        # The time quota for this manager
        attr_accessor :time_quota

        ##
        # The count quota for this manager
        attr_accessor :count_quota

        ##
        # The time quota used
        attr_accessor :time_used

        ##
        # The count quota used
        attr_accessor :count_used

        ##
        # Construct a new RequestQuotaManager instance
        #
        # @param [Float] time_quota The max quota for time consumed.
        # @param [Integer] count_quota The max quota for count usage.
        def initialize time_quota: DEFAULT_TIME_QUOTA,
                       count_quota: DEFAULT_COUNT_QUOTA
          @time_quota = time_quota
          @time_used = 0
          @count_quota = count_quota
          @count_used = 0
        end

        ##
        # Check if there's more quota left.
        #
        # @return [Boolean] True if there's more quota; false otherwise.
        def more?
          (time_used < time_quota) && (count_used < count_quota)
        end

        ##
        # Reset all the quota usage.
        def reset
          @time_used = 0
          @count_used = 0
        end

        ##
        # Notify the quota manager some resource has been consumed. Each time
        # called increases the count quota usage.
        #
        # @param [Float] time Amount of time to deduct from the time quota.
        def consume time: 0
          @time_used += time
          @count_used += 1
        end
      end
    end
  end
end
