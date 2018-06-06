# Copyright 2016 Google LLC
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
    module Trace
      ##
      # A sampler determines whether a given request's latency trace should
      # actually be reported. It is usually not necessary to trace every
      # request, especially for an application serving heavy traffic. You may
      # use a sampler to decide, for a given request, whether to report its
      # trace. A sampler is simply a Proc that takes the Rack environment as an
      # argument and returns a boolean indicating whether or not to sample the
      # current request. Alternately, it could be an object that duck-types the
      # Proc interface by implementing the `call` method.
      #
      # TimeSampler is the default sampler. It bases its sampling decision on
      # two considerations:
      #
      # 1.  It allows you to blacklist certain URI paths that should never be
      #     traced. For example, the Google App Engine health check request
      #     path `/_ah/health` is blacklisted by default. Kubernetes default
      #     health check `/healthz` is also ignored.
      # 2.  It spaces samples out by delaying a minimum time between each
      #     sample. This enforces a maximum QPS for this Ruby process.
      #
      class TimeSampler
        ##
        # Default list of paths for which to disable traces. Currently includes
        # App Engine Flex health checks.
        DEFAULT_PATH_BLACKLIST = ["/_ah/health", "/healthz"].freeze

        ##
        # Create a TimeSampler for the given QPS.
        #
        # @param [Number] qps Samples per second. Default is 0.1.
        # @param [Array{String,Regex}] path_blacklist An array of paths or
        #     path patterns indicating URIs that should never be traced.
        #     Default is DEFAULT_PATH_BLACKLIST.
        #
        def initialize qps: 0.1, path_blacklist: DEFAULT_PATH_BLACKLIST
          @delay_secs = 1.0 / qps
          @last_time = ::Time.now.to_f - @delay_secs
          @path_blacklist = path_blacklist
        end

        @default = new

        ##
        # Get the default global TimeSampler.
        #
        # @return [TimeSampler]
        #
        def self.default
          @default
        end

        ##
        # Implements the sampler contract. Checks to see whether a sample
        # should be taken at this time.
        #
        # @param [Hash] env Rack environment.
        # @return [Boolean] Whether to sample at this time.
        #
        def call env
          return false if path_blacklisted? env
          time = ::Time.now.to_f
          delays = (time - @last_time) / @delay_secs
          if delays >= 2.0
            @last_time = time - @delay_secs
            true
          elsif delays >= 1.0
            @last_time += @delay_secs
            true
          else
            false
          end
        end

        ##
        # Determines if the URI path in the given Rack environment is
        # blacklisted in this sampler.
        #
        # @private
        #
        def path_blacklisted? env
          path = "#{env['SCRIPT_NAME']}#{env['PATH_INFO']}"
          path = "/#{path}" unless path.start_with? "/"
          @path_blacklist.find { |p| p === path }
        end
      end
    end
  end
end
