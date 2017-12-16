# Copyright 2016 Google LLC
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


module Stackdriver
  module Core
    ##
    # A Stackdriver trace context links the current request into a performance
    # trace, and communicates tracing options between related requests. This
    # functionality is used by the Stackdriver diagnostics libraries
    # (including google-cloud-trace, google-cloud-logging, and other rubygems)
    # that integrate with the tracing service.
    #
    # Most applications will not need to use the TraceContext class directly.
    # The Stackdriver libraries use it internally to store and propagate
    # context information.
    #
    class TraceContext
      ##
      # @private
      HEADER_RACK_KEY = "HTTP_X_CLOUD_TRACE_CONTEXT"

      ##
      # @private
      MEMO_RACK_KEY = "google.cloud.trace_context"

      ##
      # @private
      THREAD_KEY = :__stackdriver_trace_context__

      ##
      # @private
      UNCHANGED = ::Object.new

      ##
      # Create a new TraceContext instance.
      #
      # @param [String] trace_id The trace ID as a hex string. If nil or
      #     omitted, a new random Trace ID will be generated, and this
      #     TraceContext will be marked as new.
      # @param [Boolean] is_new Whether this trace context should be flagged
      #     as newly created. Optional: if unset, will reflect whether a new
      #     trace_id was generated when this object was created.
      # @param [Integer] span_id The context parent span ID as a 64-bit int.
      #     If nil or omitted, the context will specify no parent span.
      # @param [Boolean] sampled Whether the context has decided to sample
      #     this trace or not, or nil if the context does not specify a
      #     sampling decision.
      # @param [Boolean] capture_stack Whether the the context has decided to
      #     capture stack traces. Ignored if sampled is not true.
      #
      # @example
      #   require "stackdriver/core"
      #
      #   trace_id = "0123456789abcdef0123456789abcdef"
      #   ctx = Stackdriver::Core::TraceContext.new trace_id: trace_id,
      #                                             sampled: true
      #
      def initialize trace_id: nil, is_new: nil, span_id: nil, sampled: nil,
                     capture_stack: false
        @trace_id = trace_id || new_random_trace_id
        if is_new.nil?
          @is_new = !trace_id
        else
          @is_new = is_new ? true : false
        end
        @span_id = span_id ? span_id.to_i : nil
        @sampled = sampled
        if @sampled.nil?
          @capture_stack = nil
        else
          @sampled = @sampled ? true : false
          @capture_stack = capture_stack && @sampled
        end
      end

      ##
      # The trace ID, as a hex string.
      #
      # @return [String]
      #
      attr_reader :trace_id

      ##
      # The span ID, as a 64-bit integer, or `nil` if no span ID is present
      # in the context.
      #
      # @return [Integer, nil]
      #
      attr_reader :span_id

      ##
      # Returns `true` if the context wants to sample, `false` if the context
      # wants explicitly to disable sampling, or `nil` if the context does
      # not specify.
      #
      # @return [Boolean, nil]
      #
      def sampled?
        @sampled
      end

      ##
      # Returns `true` if the context wants to capture stack traces, `false` if
      # the context does not, or `nil` if the context does not specify a
      # sampling decision.
      #
      # @return [Boolean, nil]
      #
      def capture_stack?
        @capture_stack
      end

      ##
      # Returns `true` if this trace includes a newly generated trace_id.
      #
      # @return [Boolean]
      #
      def new?
        @is_new
      end

      ##
      # Standard value equality check for this object.
      #
      # @param [Object] other An object to compare with.
      # @return [Boolean]
      #
      def eql? other
        other.is_a?(TraceContext) &&
          trace_id == other.trace_id &&
          new? == other.new? &&
          span_id == other.span_id &&
          sampled? == other.sampled? &&
          capture_stack? == other.capture_stack?
      end
      alias_method :==, :eql?

      ##
      # Generate standard hash code for this object.
      #
      # @return [Integer]
      #
      def hash
        @hash ||= @trace_id.hash ^ @is_new.hash ^ @span_id.hash ^
                  @sampled.hash ^ @capture_stack.hash
      end

      ##
      # Returns a new TraceContext instance that is identical to this instance
      # except for the given changes. All parameters are optional. See
      # {TraceContext#initialize} for more details on each parameter.
      #
      # @param [String] trace_id New trace ID.
      # @param [Boolean] is_new New setting for newness indicator.
      # @param [Integer] span_id New parent span ID.
      # @param [Boolean] sampled New sampling decision.
      # @param [Boolean] capture_stack New stack capture decision.
      # @return [TraceContext]
      #
      # @example
      #   require "stackdriver/core"
      #
      #   trace_id = "0123456789abcdef0123456789abcdef"
      #   orig_ctx = Stackdriver::Core::TraceContext.new trace_id: trace_id,
      #
      #   sampled_ctx = orig_ctx.with sampled: true
      #
      def with trace_id: UNCHANGED, is_new: UNCHANGED, span_id: UNCHANGED,
               sampled: UNCHANGED, capture_stack: UNCHANGED
        trace_id = @trace_id if trace_id == UNCHANGED
        is_new = @is_new if is_new == UNCHANGED
        span_id = @span_id if span_id == UNCHANGED
        sampled = @sampled if sampled == UNCHANGED
        capture_stack = @capture_stack if capture_stack == UNCHANGED
        TraceContext.new trace_id: trace_id, is_new: is_new, span_id: span_id,
                         sampled: sampled, capture_stack: capture_stack
      end

      ##
      # Returns a string representation of this trace context, in the form
      # `<traceid>[/<spanid>][;o=<options>]`. This form is suitable for
      # setting the trace context header.
      #
      # @return [String]
      #
      def to_string
        str = trace_id
        str += "/#{span_id}" if span_id
        unless sampled?.nil?
          options = 0
          options |= 1 if sampled?
          options |= 2 if capture_stack?
          str += ";o=#{options}"
        end
        str
      end
      alias_method :to_s, :to_string

      ##
      # Attempts to parse the given string as a trace context representation.
      # Expects the form `<traceid>[/<spanid>][;o=<options>]`, which is the
      # form used in the trace context header. Returns either the parsed
      # trace context, or `nil` if the string was malformed.
      #
      # @param [String] str The string to parse.
      #
      # @return [TraceContext, nil]
      #
      # @example
      #   require "stackdriver/core"
      #
      #   str = "0123456789abcdef0123456789abcdef/12345;o=1"
      #   ctx = Stackdriver::Core::TraceContext.parse_string str
      #
      def self.parse_string str
        match = %r|^(\w{32})(/(\d+))?(;o=(\d+))?|.match str
        if match
          trace_id = match[1]
          span_id = match[3] ? match[3].to_i : nil
          options = match[5] ? match[5].to_i : nil
          if options.nil?
            sampled = capture_stack = nil
          else
            sampled = options & 1 != 0
            capture_stack = options & 2 != 0
          end
          new trace_id: trace_id, span_id: span_id, sampled: sampled,
              capture_stack: capture_stack
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
      #
      # @example
      #   require "stackdriver/core"
      #
      #   class MyMiddleware
      #     def initialize app
      #       @app = app
      #     end
      #
      #     def call env
      #       ctx = Stackdriver::Core::TraceContext.parse_rack_env env
      #       do_something_with ctx
      #       @app.call env
      #     end
      #   end
      #
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
      # @param [TraceContext, nil] trace_context The trace context to
      #     set for the current thread. May be `nil`.
      #
      # @return [TraceContext, nil] The context set.
      #
      # @example
      #   require "stackdriver/core"
      #
      #   ctx = Stackdriver::Core::TraceContext.new
      #   Stackdriver::Core::TraceContext.set ctx
      #   same_ctx = Stackdriver::Core::TraceContext.get
      #
      def self.set trace_context
        Thread.current[THREAD_KEY] = trace_context
        trace_context
      end

      ##
      # Returns the current thread's trace context, or `nil` if no trace
      # context has been set.
      #
      # @return [TraceContext, nil]
      #
      # @example
      #   require "stackdriver/core"
      #
      #   ctx = Stackdriver::Core::TraceContext.new
      #   Stackdriver::Core::TraceContext.set ctx
      #   same_ctx = Stackdriver::Core::TraceContext.get
      #
      def self.get
        Thread.current[THREAD_KEY]
      end

      protected

      ##
      # Returns a random trace ID (as a random type 4 UUID).
      #
      # @private
      # @return [String]
      #
      def new_random_trace_id
        val = rand 0x100000000000000000000000000000000
        val &= 0xffffffffffff0fffcfffffffffffffff
        val |= 0x00000000000040008000000000000000
        format("%032x", val)
      end
    end
  end
end
