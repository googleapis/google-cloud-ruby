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

require "google/cloud/trace/time_sampler"

module Google
  module Cloud
    module Trace
      ##
      # A sampler determines whether a given request's latency trace should
      # actually be reported. It is usually not necessary to trace every
      # request, especially for an application serving heavy traffic. You may
      # use a sampler to decide, for a given request, whether to report its
      # trace. A sampler is simply a Proc that takes an optional context
      # argument and returns a boolean indicating whether or not to sample the
      # current request. The context argument must be a Hash, but otherwise
      # its format is not defined at this time.
      #
      # See {Google::Cloud::Trace::TimeSampler} for an example.
      #
      module Sampling
        @sampler = TimeSampler.new

        class << self
          ##
          # This attribute is a global sampler to use by default. For example,
          # the {Google::Cloud::Trace::Middleware} calls this sampler to decide
          # whether to report traces collected by the Rack integration.
          #
          attr_accessor :sampler
        end
      end
    end
  end
end
