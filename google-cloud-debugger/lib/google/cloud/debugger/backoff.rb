# Copyright 2016 Google Inc. All rights reserved.
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
      class Backoff
        def initialize min_interval=10, max_interval=600, multiplier=2
          @min_interval = min_interval
          @max_interval = max_interval
          @multiplier = multiplier
          @cur_interval = min_interval
        end

        def succeeded
          @cur_interval = @min_interval
        end

        def failed
          interval = @cur_interval
          @cur_interval *= @multiplier
          @cur_interval = @max_interval if @cur_interval > @max_interval
          interval
        end
      end
    end
  end
end
