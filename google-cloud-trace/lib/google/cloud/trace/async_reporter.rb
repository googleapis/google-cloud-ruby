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


require "monitor"
require "concurrent"
require "google/cloud/trace/errors"

module Google
  module Cloud
    module Trace
      ##
      # # AsyncReporter
      #
      # @private Used by the {Google::Cloud::Trace::Middleware} to
      # asynchronously buffer traces and push batches to Stackdriver Trace
      # service when used in a Rack-based application.
      class AsyncReporter
        include MonitorMixin

        ##
        # @private Implementation accessors
        attr_reader :service, :max_bytes, :max_count, :max_queue, :interval,
                    :threads

        ##
        # @private Creates a new AsyncReporter instance.
        def initialize service, max_count: 1000, max_bytes: 4000000,
                       max_queue: 100, interval: 5, threads: 10
          @service = service

          @max_count = max_count
          @max_bytes = max_bytes
          @max_queue = max_queue
          @interval  = interval
          @threads   = threads

          @error_callbacks = []

          @cond = new_cond

          # Make sure all buffered messages are sent when process exits.
          at_exit { stop! }

          # init MonitorMixin
          super()
        end

        ##
        # Add the traces to the queue to be reported to Stackdriver Trace
        # asynchronously. Signal the child thread to start processing the queue.
        #
        # @param [Google::Cloud::Trace::TraceRecord,
        #     Array{Google::Cloud::Trace::TraceRecord}] traces Either a single
        #     trace object or an array of trace objects.
        def patch_traces traces
          if synchronize { @stopped }
            raise_stopped_error traces
            return
          end

          synchronize do
            Array(traces).each do |trace|
              # Add the trace to the batch
              @batch ||= Batch.new self
              next if @batch.try_add trace

              # If we can't add to the batch, publish and create a new batch
              patch_batch!
              @batch = Batch.new self
              @batch.add trace
            end

            init_resources!

            patch_batch! if @batch.ready?

            @cond.broadcast
          end
          self
        end

        ##
        # Get the project id from underlying service object.
        def project
          service.project
        end

        ##
        # Begins the process of stopping the reporter. Traces already in the
        # queue will be published, but no new traces can be added. Use {#wait!}
        # to block until the reporter is fully stopped and all pending traces
        # have been pushed to the API.
        #
        # @return [AsyncReporter] returns self so calls can be chained.
        def stop
          synchronize do
            break if @stopped

            @stopped = true
            patch_batch!
            @cond.broadcast
            @thread_pool.shutdown if @thread_pool
          end

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
        # Blocks until the reporter is fully stopped, all pending traces have
        # been published, and all callbacks have completed. Does not stop the
        # reporter. To stop the reporter, first call {#stop} and then call
        # {#wait!} to block until the reporter is stopped.
        #
        # @return [AsyncReporter] returns self so calls can be chained.
        def wait! timeout = nil
          synchronize do
            if @thread_pool
              @thread_pool.shutdown
              @thread_pool.wait_for_termination timeout
            end
          end

          self
        end

        ##
        # Forces all traces in the current batch to be patched to the API
        # immediately.
        #
        # @return [AsyncReporter] returns self so calls can be chained.
        #
        def flush!
          synchronize do
            patch_batch!
            @cond.broadcast
          end

          self
        end

        ##
        # Whether the reporter has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        #
        def started?
          !stopped?
        end

        ##
        # Whether the reporter has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        #
        def stopped?
          synchronize { @stopped }
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the reporter will attempt to
        # recover from the error and resume buffering, batching, and patching
        # traces.
        #
        # Multiple error handlers can be added.
        #
        # @yield [callback] The block to be called when an error is raised.
        # @yieldparam [Exception] error The error raised.
        #
        def on_error &block
          synchronize do
            @error_callbacks << block
          end
        end

        protected

        def init_resources!
          @thread_pool ||= \
            Concurrent::CachedThreadPool.new max_threads: @threads,
                                             max_queue: @max_queue
          @thread ||= Thread.new { run_background }
          nil # returning nil because of rubocop...
        end

        def run_background
          synchronize do
            until @stopped
              if @batch.nil?
                @cond.wait
                next
              end

              if @batch.ready?
                # interval met, publish the batch...
                patch_batch!
                @cond.wait
              else
                # still waiting for the interval to publish the batch...
                @cond.wait(@batch.publish_wait)
              end
            end
          end
        end

        def patch_batch!
          return unless @batch

          batch_to_be_patched = @batch
          @batch = nil
          patch_traces_async batch_to_be_patched
        end

        def patch_traces_async batch
          Concurrent::Promises.future_on(
            @thread_pool, batch.traces
          ) do |traces|
            patch_traces_with traces
          end
        rescue Concurrent::RejectedExecutionError => e
          async_error = AsyncReporterError.new(
            "Error writing traces: #{e.message}",
            batch.traces
          )
          # Manually set backtrace so we don't have to raise
          async_error.set_backtrace caller
          error! async_error
        end

        def patch_traces_with traces
          service.patch_traces traces
        rescue StandardError => e
          patch_error = AsyncPatchTracesError.new(
            "Error writing traces: #{e.message}",
            traces
          )
          # Manually set backtrace so we don't have to raise
          patch_error.set_backtrace caller
          error! patch_error
        end

        def raise_stopped_error traces
          stopped_error = AsyncReporterError.new(
            "AsyncReporter is stopped. Cannot patch traces.",
            traces
          )
          # Manually set backtrace so we don't have to raise
          stopped_error.set_backtrace caller
          error! stopped_error
        end

        # Calls all error callbacks.
        def error! error
          # We shouldn't need to synchronize getting the callbacks.
          error_callbacks = @error_callbacks
          error_callbacks = default_error_callbacks if error_callbacks.empty?
          error_callbacks.each { |error_callback| error_callback.call error }
        end

        def default_error_callbacks
          # This is memoized to reduce calls to the configuration.
          @default_error_callbacks ||= begin
            error_callback = Google::Cloud::Pubsub.configuration.on_error
            error_callback ||= Google::Cloud.configure.on_error
            if error_callback
              [error_callback]
            else
              []
            end
          end
        end

        ##
        # @private
        class Batch
          attr_reader :created_at, :traces

          def initialize reporter
            @reporter = reporter
            @traces = []
            @traces_bytes = reporter.project.bytesize + 4 # initial size
            @created_at = nil
          end

          def add trace, addl_bytes: nil
            addl_bytes ||= addl_bytes_for trace
            @traces << trace
            @traces_bytes += addl_bytes
            @created_at ||= Time.now
            nil
          end

          def try_add trace
            addl_bytes = addl_bytes_for trace
            new_message_count = @traces.count + 1
            new_message_bytes = @traces_bytes + addl_bytes
            if new_message_count > @reporter.max_count ||
               new_message_bytes >= @reporter.max_bytes
              return false
            end
            add trace, addl_bytes: addl_bytes
            true
          end

          def ready?
            @traces.count >= @reporter.max_count ||
              @traces_bytes >= @reporter.max_bytes ||
              (@created_at.nil? || (publish_at < Time.now))
          end

          def publish_at
            return nil if @created_at.nil?
            @created_at + @reporter.interval
          end

          def publish_wait
            publish_wait = publish_at - Time.now
            return 0 if publish_wait < 0
            publish_wait
          end

          def addl_bytes_for trace
            trace.to_grpc.to_proto.bytesize + 2
          end
        end
      end
    end
  end
end
