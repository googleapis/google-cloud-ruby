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


require "concurrent"
require "google/cloud/errors"

module Google
  module Cloud
    module Debugger
      ##
      # # TransmitterError
      #
      # Used to indicate a problem submitting breakpoints. This can occur when
      # there are not enough resources allocated for the amount of usage, or
      # when the calling the API returns an error.
      #
      class TransmitterError < Google::Cloud::Error
        # @!attribute [r] breakpoint
        #   @return [Array<Google::Cloud::Debugger::Breakpoint>] The
        #   individual error event that was not submitted to Stackdriver
        #   Debugger service.
        attr_reader :breakpoint

        def initialize message, breakpoint = nil
          super message
          @breakpoint = breakpoint
        end
      end

      ##
      # # Transmitter
      #
      # Responsible for submit evaluated breakpoints back to Stackdriver
      # Debugger service asynchronously. It maintains a thread pool.
      #
      # The transmitter is controlled by the debugger agent it belongs to.
      # Debugger agent submits evaluated breakpoint asynchronously, and the
      # transmitter submits the breakpoints to Stackdriver Debugger service.
      #
      class Transmitter
        ##
        # @private The gRPC Service object and thread pool.
        attr_reader :service, :thread_pool

        ##
        # The debugger agent this transmiter belongs to
        # @return [Google::Cloud::Debugger::Agent]
        attr_accessor :agent

        ##
        # Maximum backlog size for this transmitter's queue
        attr_accessor :max_queue
        alias max_queue_size  max_queue
        alias max_queue_size= max_queue=

        ##
        # Maximum threads used in the thread pool
        attr_accessor :threads

        ##
        # @private Creates a new Transmitter instance.
        def initialize agent, service, max_queue: 1000, threads: 10
          @agent   = agent
          @service = service

          @max_queue = max_queue
          @threads   = threads

          @thread_pool = Concurrent::ThreadPoolExecutor.new \
            max_threads: @threads, max_queue: @max_queue

          @error_callbacks = []

          # Make sure all queued calls are completed when process exits.
          at_exit { stop }
        end

        ##
        # Enqueue an evaluated breakpoint to be submitted by the transmitter.
        #
        # @raise [TransmitterError] if there are no resources available to make
        #   queue the API call on the thread pool.
        def submit breakpoint
          Concurrent::Promises.future_on @thread_pool, breakpoint do |bp|
            submit_sync bp
          end
        rescue Concurrent::RejectedExecutionError => e
          raise TransmitterError.new(
            "Error asynchronously submitting breakpoint: #{e.message}",
            breakpoint
          )
        end

        ##
        # Starts the transmitter and its thread pool.
        #
        # @return [Transmitter] returns self so calls can be chained.
        def start
          # no-op
          self
        end

        ##
        # Stops the transmitter and its thread pool. Once stopped, cannot be
        # started again.
        #
        # @return [Transmitter] returns self so calls can be chained.
        def stop timeout = nil
          if @thread_pool
            @thread_pool.shutdown
            @thread_pool.wait_for_termination timeout
          end

          self
        end

        ##
        # Whether the transmitter has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        #
        def started?
          @thread_pool&.running?
        end

        ##
        # Whether the transmitter has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        #
        def stopped?
          !started?
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the transmitter will attempt to
        # recover from the error and resume submitting breakpoints.
        #
        # Multiple error handlers can be added.
        #
        # @yield [callback] The block to be called when an error is raised.
        # @yieldparam [Exception] error The error raised.
        #
        def on_error &block
          @error_callbacks << block
        end

        protected

        # Calls all error callbacks.
        def error! error
          error_callbacks = @error_callbacks
          error_callbacks = default_error_callbacks if error_callbacks.empty?
          error_callbacks.each { |error_callback| error_callback.call error }
        end

        def default_error_callbacks
          # This is memoized to reduce calls to the configuration.
          @default_error_callbacks ||= begin
            error_cb = Google::Cloud::Debugger.configure.on_error
            error_cb ||= Google::Cloud.configure.on_error
            if error_cb
              [error_cb]
            else
              []
            end
          end
        end

        def submit_sync breakpoint
          service.update_active_breakpoint agent.debuggee.id, breakpoint
        rescue StandardError => e
          sync_error = TransmitterError.new(
            "Error asynchronously transmitting breakpoint: #{e.message}",
            breakpoint
          )
          # Manually set backtrace so we don't have to raise
          sync_error.set_backtrace caller

          error! sync_error
        end
      end
    end
  end
end
