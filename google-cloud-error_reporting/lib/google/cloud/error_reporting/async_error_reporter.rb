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


require "concurrent"
require "google/cloud/errors"

module Google
  module Cloud
    module ErrorReporting
      ##
      # # AsyncErrorReporterError
      #
      # @private Used to indicate a problem reporting errors asynchronously.
      # This can occur when there are not enough resources allocated for the
      # amount of usage.
      #
      class AsyncErrorReporterError < Google::Cloud::Error
        # @!attribute [r] error_event
        #   @return [Array<Google::Cloud::ErrorReporting::ErrorEvent>] The
        #   individual error event that was not reported to Error
        #   Reporting service.
        attr_reader :error_event

        def initialize message, error_event = nil
          super message
          @error_event = error_event
        end
      end

      ##
      # # ErrorReporterError
      #
      # @private Used to indicate a problem reporting errors. This can occur
      # when the calling the API returns an error.
      #
      class ErrorReporterError < Google::Cloud::Error
        # @!attribute [r] error_event
        #   @return [Array<Google::Cloud::ErrorReporting::ErrorEvent>] The
        #   individual error event that was not reported to Error
        #   Reporting service.
        attr_reader :error_event

        def initialize message, error_event = nil
          super message
          @error_event = error_event
        end
      end

      ##
      # # AsyncErrorReporter
      #
      # @private Used by {Google::Cloud::ErrorReporting} and
      # {Google::Cloud::ErrorReporting::Middleware} to asynchronously submit
      # error events to Error Reporting service when used in
      # Ruby applications.
      class AsyncErrorReporter
        ##
        # @private Implementation accessors
        attr_reader :error_reporting, :max_queue, :threads, :thread_pool

        ##
        # @private Creates a new AsyncErrorReporter instance.
        def initialize error_reporting, max_queue: 1000, threads: 10
          @error_reporting = error_reporting

          @max_queue = max_queue
          @threads   = threads

          @thread_pool = Concurrent::ThreadPoolExecutor.new \
            max_threads: @threads, max_queue: @max_queue

          @error_callbacks = []

          # Make sure all queued calls are completed when process exits.
          at_exit { stop! }
        end

        ##
        # Add the error event to the queue. This will raise if there are no
        # resources available to make the API call.
        def report error_event
          Concurrent::Promises.future_on @thread_pool, error_event do |error|
            report_sync error
          end
        rescue Concurrent::RejectedExecutionError => e
          raise AsyncErrorReporterError,
                "Error reporting error_event asynchronously: #{e.message}",
                error_event
        end

        ##
        # Begins the process of stopping the reporter. ErrorEvents already
        # in the queue will be published, but no new ErrorEvent can be added.
        # Use {#wait!} to block until the reporter is fully stopped and all
        # pending error_events have been pushed to the API.
        #
        # @return [AsyncErrorReporter] returns self so calls can be chained.
        def stop
          @thread_pool&.shutdown

          self
        end

        ##
        # Stop this asynchronous reporter and block until it has been stopped.
        #
        # @param [Number] timeout Timeout in seconds.
        #
        def stop! timeout = nil
          stop
          wait! timeout
        end

        ##
        # Blocks until the reporter is fully stopped, all pending error_events
        # have been published, and all callbacks have completed. Does not stop
        # the reporter. To stop the reporter, first call {#stop} and then call
        # {#wait!} to block until the reporter is stopped.
        #
        # @return [AsyncErrorReporter] returns self so calls can be chained.
        def wait! timeout = nil
          if @thread_pool
            @thread_pool.shutdown
            @thread_pool.wait_for_termination timeout
          end

          self
        end

        ##
        # Whether the reporter has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        #
        def started?
          @thread_pool&.running?
        end

        ##
        # Whether the reporter has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        #
        def stopped?
          !started?
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the reporter will attempt to
        # recover from the error and resume reporting error_events.
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
            error_cb = Google::Cloud::ErrorReporting.configure.on_error
            error_cb ||= Google::Cloud.configure.on_error
            if error_cb
              [error_cb]
            else
              []
            end
          end
        end

        def report_sync error_event
          error_reporting.report error_event
        rescue StandardError => e
          sync_error = ErrorReporterError.new(
            "Error reporting error_event: #{e.message}",
            error_event
          )
          # Manually set backtrace so we don't have to raise
          sync_error.set_backtrace caller
          error! sync_error
        end
      end
    end
  end
end
