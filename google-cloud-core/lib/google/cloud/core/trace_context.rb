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
    module Core
      ##
      # Represents a Stackdriver trace context, which links the current request
      # into a performance trace and communicates tracing options between
      # requests. This functionality is shared among Stackdriver libraries
      # (google-cloud-trace, google-cloud-logging, and others) that integrate
      # with the tracing service.
      class TraceContext
        HEADER_RACK_KEY = "HTTP_X_CLOUD_TRACE_CONTEXT"
        MEMO_RACK_KEY = "google.cloud.trace_context"
        THREAD_KEY = :__stackdriver_trace_context__

        ##
        # Create a new TraceContext instance.
        #
        # @param [String,NilClass] trace_id The trace ID as a hex string. If
        #     nil or omitted, a new random Trace ID will be created, and this
        #     TraceContext will be marked as new.
        # @param [Integer,NilClass] span_id The context parent span ID as a
        #     64-bit Integer. If nil or omitted, the context will specify no
        #     parent span.
        # @param [Boolean,NilClass] sampled Whether the the context has decided
        #     to sample this trace or not, or nil if the context does not
        #     specify a sampling decision.
        def initialize trace_id: nil, span_id: nil, sampled: nil
          @trace_id = trace_id || new_random_trace_id
          @span_id = span_id ? span_id.to_i : nil
          @sampled = sampled
          @is_new = !trace_id
        end

        ##
        # The trace ID, as a hex string.
        attr_reader :trace_id

        ##
        # The span ID, as a 64-bit integer, or nil if no span ID is present
        # in the context.
        attr_reader :span_id

        ##
        # Returns `true` if the context wants to sample, `false` if the context
        # wants explicitly to disable sampling, or `nil` if the context does
        # not specify.
        # @return [Boolean,NilClass]
        def sampled?
          @sampled
        end

        ##
        # Returns `true` if this trace includes a newly generated trace_id.
        # @return [Boolean]
        def new?
          @is_new
        end

        ##
        # Returns a string representation of this trace context, in the form
        # "<traceid>[/<spanid>][;o=<options>]". This form is suitable for
        # setting the trace context header.
        #
        # @return [String]
        def to_string
          str = trace_id
          str += "/#{span_id}" if span_id
          if @sampled == true
            str += ";o=1"
          elsif @sampled == false
            str += ";o=0"
          end
          str
        end
        alias_method :to_s, :to_string

        ##
        # Attempts to parse the given string as a trace context representation.
        # Expects the form "<traceid>[/<spanid>][;o=<options>]", which is the
        # form used in the trace context header. Returns either the parsed
        # trace context, or nil if the string was malformed.
        #
        # @param [String] str The string to parse.
        #
        # @return [TraceContext,NilClass]
        def self.parse_string str
          match = %r|^(\w{32})(/(\d+))?(;o=(\d+))?|.match str
          if match
            trace_id = match[1]
            span_id = match[3] ? match[3].to_i : nil
            sampled = match[5] ? match[5].to_i & 1 == 1 : nil
            new trace_id: trace_id, span_id: span_id, sampled: sampled
          else
            nil
          end
        end

        ##
        # Obtains a TraceContext from the given Rack environment. This should
        # be used by any service that wants to obtain the TraceContext for a
        # Rack request. If a new trace context is generated in the process, it
        # is memoized into the Rack environment so subsequent services will get
        # the same context.
        #
        # Specifically, the following steps are attempted in order:
        #  1. Attempts to use any memoized context previously obtained.
        #  2. Attempts to parse the trace context header.
        #  3. Creates a new trace context with a random trace ID.
        #
        # Furthermore, if a block is given, it is provided with an opportunity
        # to modify the trace context. The current trace context and the Rack
        # environment is passed to the block, and its result is used as the
        # final trace context. The final context is memoized back into the
        # Rack environment.
        #
        # @param [Hash] env The Rack environment hash
        #
        # @return [TraceContext]
        def self.parse_rack_env env
          trace_context = env[MEMO_RACK_KEY] ||
                          parse_string(env[HEADER_RACK_KEY].to_s) ||
                          new
          trace_context = yield trace_context, env if block_given?
          env[MEMO_RACK_KEY] = trace_context
        end

        ##
        # Set the current thread's trace context, and returns the context.
        #
        # @param [TraceContext,NilClass] trace_context The trace context to
        #     set for the current thread. May be nil.
        #
        # @return [TraceContext]
        def self.set trace_context
          Thread.current[THREAD_KEY] = trace_context
          trace_context
        end

        ##
        # Get the current thread's trace context, or nil if none has been set.
        #
        # @return [TraceContext,NilClass]
        def self.get
          Thread.current[THREAD_KEY]
        end

        protected

        ##
        # Returns a random trace ID (as a random type 4 UUID).
        #
        # @private
        # @return [String]
        def new_random_trace_id
          val = rand 0x100000000000000000000000000000000
          val &= 0xffffffffffff0fffcfffffffffffffff
          val |= 0x00000000000040008000000000000000
          format("%032x", val)
        end
      end
    end
  end
end
