# Copyright 2017 Google LLC
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
    module Debugger
      ##
      # @private Helps keep tracking of backoff on calling APIs in loop
      class Backoff
        ##
        # Small interval to start with
        DEFAULT_START_INTERVAL = 1

        ##
        # Maximum interval value to use
        DEFAULT_MAX_INTERVAL = 600

        ##
        # Interval incremental multiplier
        DEFAULT_MULTIPLIER = 2

        ##
        # The current time interval should wait until next iteration
        attr_reader :interval

        def initialize start_interval = DEFAULT_START_INTERVAL,
                       max_interval = DEFAULT_MAX_INTERVAL,
                       multiplier = DEFAULT_MULTIPLIER
          @start_interval = start_interval
          @max_interval = max_interval
          @multiplier = multiplier
        end

        ##
        # Resets backoff
        def succeeded
          @interval = nil
        end

        ##
        # Initialize backoff or increase backoff interval
        def failed
          @interval = if @interval
                        [@max_interval, @interval * @multiplier].min
                      else
                        @start_interval
                      end
        end

        ##
        # Check if a backoff delay should be applied
        def backing_off?
          !@interval.nil?
        end
      end
    end
  end
end
