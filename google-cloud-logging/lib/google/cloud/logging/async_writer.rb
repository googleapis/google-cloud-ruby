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


require "monitor"
require "concurrent"
require "google/cloud/logging/errors"

module Google
  module Cloud
    module Logging
      ##
      # # AsyncWriter
      #
      # AsyncWriter buffers, batches, and transmits log entries efficiently.
      # Writing log entries is asynchronous and will not block.
      #
      # Batches that cannot be delivered immediately are queued. When the queue
      # is full new batch requests will raise errors that can be consumed using
      # the {#on_error} callback. This provides back pressure in case the writer
      # cannot keep up with requests.
      #
      # This object is thread-safe; it may accept write requests from
      # multiple threads simultaneously, and will serialize them when
      # executing in the background thread.
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   async = logging.async_writer
      #
      #   entry1 = logging.entry payload: "Job started."
      #   entry2 = logging.entry payload: "Job completed."
      #
      #   labels = { job_size: "large", job_code: "red" }
      #   resource = logging.resource "gae_app",
      #                               "module_id" => "1",
      #                               "version_id" => "20150925t173233"
      #
      #   async.write_entries [entry1, entry2],
      #                       log_name: "my_app_log",
      #                       resource: resource,
      #                       labels: labels
      #
      class AsyncWriter
        include MonitorMixin

        ##
        # @private Implementation accessors
        attr_reader :logging, :max_bytes, :max_count, :interval,
                    :threads, :max_queue, :partial_success

        ##
        # @private Creates a new AsyncWriter instance.
        def initialize logging, max_count: 10000, max_bytes: 10000000,
                       max_queue: 100, interval: 5, threads: 10,
                       partial_success: false
          @logging = logging

          @max_count = max_count
          @max_bytes = max_bytes
          @max_queue = max_queue
          @interval  = interval
          @threads   = threads

          @partial_success = partial_success

          @error_callbacks = []

          @cond = new_cond

          # Make sure all buffered messages are sent when process exits.
          at_exit { stop }

          # init MonitorMixin
          super()
        end

        ##
        # Asynchronously write one or more log entries to the Stackdriver
        # Logging service.
        #
        # Unlike the main write_entries method, this method usually does not
        # block. The actual write RPCs will happen in the background, and may
        # be batched with related calls. However, if the queue is full, this
        # method will block until enough space has cleared out.
        #
        # @param [Google::Cloud::Logging::Entry,
        #   Array<Google::Cloud::Logging::Entry>] entries One or more entry
        #   objects to write. The log entries must have values for all required
        #   fields.
        # @param [String] log_name A default log ID for those log entries in
        #   `entries` that do not specify their own `log_name`. See also
        #   {Entry#log_name=}.
        # @param [Resource] resource A default monitored resource for those log
        #   entries in entries that do not specify their own resource. See also
        #   {Entry#resource}.
        # @param [Hash{Symbol,String => String}] labels User-defined `key:value`
        #   items that are added to the `labels` field of each log entry in
        #   `entries`, except when a log entry specifies its own `key:value`
        #   item with the same key. See also {Entry#labels=}.
        #
        # @return [Google::Cloud::Logging::AsyncWriter] Returns self.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   async = logging.async_writer
        #
        #   entry = logging.entry payload: "Job started.",
        #                         log_name: "my_app_log"
        #   entry.resource.type = "gae_app"
        #   entry.resource.labels[:module_id] = "1"
        #   entry.resource.labels[:version_id] = "20150925t173233"
        #
        #   async.write_entries entry
        #
        def write_entries entries, log_name: nil, resource: nil, labels: nil
          synchronize do
            raise "AsyncWriter has been stopped" if @stopped

            Array(entries).each do |entry|
              # Update the entry to have all the data directly on it
              entry.log_name ||= log_name
              if entry.resource.nil? || entry.resource.empty?
                entry.resource = resource
              end
              entry.labels = labels if entry.labels.nil? || entry.labels.empty?

              # Add the entry to the batch
              @batch ||= Batch.new self
              next if @batch.try_add entry

              # If we can't add to the batch, publish and create a new batch
              publish_batch!
              @batch = Batch.new self
              @batch.add entry
            end

            init_resources!

            publish_batch! if @batch.ready?

            @cond.broadcast
          end
          self
        end

        def noop
          # do nothing
        end
        alias state noop
        alias async_state noop
        alias suspend noop
        alias resume noop
        alias async_suspend noop
        alias async_resume noop
        alias async_suspended? noop

        ##
        # Creates a logger instance that is API-compatible with Ruby's standard
        # library [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc).
        #
        # The logger will use AsyncWriter to transmit log entries on a
        # background thread.
        #
        # @param [String] log_name A log resource name to be associated with the
        #   written log entries.
        # @param [Google::Cloud::Logging::Resource] resource The monitored
        #   resource to be associated with written log entries.
        # @param [Hash] labels A set of user-defined data to be associated with
        #   written log entries.
        #
        # @return [Google::Cloud::Logging::Logger] a Logger object that can be
        #   used in place of a ruby standard library logger object.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   resource = logging.resource "gae_app",
        #                               module_id: "1",
        #                               version_id: "20150925t173233"
        #
        #   async = logging.async_writer
        #   logger = async.logger "my_app_log", resource, env: :production
        #   logger.info "Job started."
        #
        def logger log_name, resource, labels = {}
          Logger.new self, log_name, resource, labels
        end

        ##
        # Begins the process of stopping the writer. Entries already in the
        # queue will be published, but no new entries can be added. Use {#wait!}
        # to block until the writer is fully stopped and all pending entries
        # have been published.
        #
        # @return [AsyncWriter] returns self so calls can be chained.
        def stop
          synchronize do
            break if @stopped

            @stopped = true
            publish_batch!
            @cond.broadcast
            @thread_pool.shutdown if @thread_pool
          end

          self
        end
        alias async_stop stop

        ##
        # Blocks until the writer is fully stopped, all pending entries have
        # been published, and all callbacks have completed. Does not stop the
        # writer. To stop the writer, first call {#stop} and then call {#wait!}
        # to block until the writer is stopped.
        #
        # @return [AsyncWriter] returns self so calls can be chained.
        def wait! timeout = nil
          synchronize do
            if @thread_pool
              @thread_pool.shutdown
              @thread_pool.wait_for_termination timeout
            end
          end

          self
        end
        alias wait_until_async_stopped wait!
        alias wait_until_stopped wait!

        ##
        # Stop this asynchronous writer and block until it has been stopped.
        #
        # @param [Number] timeout Timeout in seconds.
        # @param [Boolean] force If set to true, and the writer hasn't stopped
        #     within the given timeout, kill it forcibly by terminating the
        #     thread. This should be used with extreme caution, as it can
        #     leave RPCs unfinished. Default is false.
        #
        # @return [Symbol] Returns `:stopped` if the AsyncWriter was already
        #     stopped at the time of invocation, `:waited` if it stopped
        #     during the timeout period, `:timeout` if it is still running
        #     after the timeout, or `:forced` if it was forcibly killed.
        #
        def stop! timeout = nil, force: nil
          return :stopped if stopped?

          stop
          wait! timeout

          if synchronize { @thread_pool.shutdown? }
            return :waited if timeout
          elsif force
            @thread_pool.kill
            return :forced
          end
          :timeout
        end
        alias async_stop! stop!

        ##
        # Forces all entries in the current batch to be published
        # immediately.
        #
        # @return [AsyncWriter] returns self so calls can be chained.
        def flush
          synchronize do
            publish_batch!
            @cond.broadcast
          end

          self
        end

        ##
        # Whether the writer has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        def started?
          !stopped?
        end
        alias running? started?
        alias writable? started?
        alias async_running? started?
        alias async_working? started?

        ##
        # Whether the writer has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        def stopped?
          synchronize { @stopped }
        end
        alias async_stopped? stopped?

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the writer will attempt to
        # recover from the error and resume buffering, batching, and
        # transmitting log entries
        #
        # Multiple error handlers can be added.
        #
        # @yield [callback] The block to be called when an error is raised.
        # @yieldparam [Exception] error The error raised.
        #
        # @example
        #   require "google/cloud/logging"
        #   require "google/cloud/error_reporting"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   resource = logging.resource "gae_app",
        #                               module_id: "1",
        #                               version_id: "20150925t173233"
        #
        #   async = logging.async_writer
        #
        #   # Register to be notified when unhandled errors occur.
        #   async.on_error do |error|
        #     # error can be a AsyncWriterError or AsyncWriteEntriesError
        #     Google::Cloud::ErrorReporting.report error
        #   end
        #
        #   logger = async.logger "my_app_log", resource, env: :production
        #   logger.info "Job started."
        #
        def on_error &block
          synchronize do
            @error_callbacks << block
          end
        end

        ##
        # The most recent unhandled error to occur while transmitting log
        # entries.
        #
        # If an unhandled error has occurred the subscriber will attempt to
        # recover from the error and resume buffering, batching, and
        # transmitting log entries.
        #
        # @return [Exception, nil] error The most recent error raised.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   resource = logging.resource "gae_app",
        #                               module_id: "1",
        #                               version_id: "20150925t173233"
        #
        #   async = logging.async_writer
        #
        #   logger = async.logger "my_app_log", resource, env: :production
        #   logger.info "Job started."
        #
        #   # If an error was raised, it can be retrieved here:
        #   async.last_error #=> nil
        #
        def last_error
          synchronize { @last_error }
        end
        alias last_exception last_error

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
                publish_batch!
                @cond.wait
              else
                # still waiting for the interval to publish the batch...
                @cond.wait(@batch.publish_wait)
              end
            end
          end
        end

        def publish_batch!
          return unless @batch

          batch_to_be_published = @batch
          @batch = nil
          publish_batch_async batch_to_be_published
        end

        # Sets the last_error and calls all error callbacks.
        def error! error
          error_callbacks = synchronize do
            @last_error = error
            @error_callbacks
          end
          error_callbacks.each { |error_callback| error_callback.call error }
        end

        def publish_batch_async batch
          Concurrent::Promises.future_on(
            @thread_pool, batch.entries
          ) do |entries|
            write_entries_with entries
          end
        rescue Concurrent::RejectedExecutionError => e
          async_error = AsyncWriterError.new(
            "Error writing entries: #{e.message}",
            batch.entries
          )
          # Manually set backtrace so we don't have to raise
          async_error.set_backtrace backtrace
          error! async_error
        end

        def write_entries_with entries
          logging.write_entries entries, partial_success: partial_success
        rescue StandardError => e
          write_error = AsyncWriteEntriesError.new(
            "Error writing entries: #{e.message}",
            entries
          )
          # Manually set backtrace so we don't have to raise
          write_error.set_backtrace backtrace
          error! write_error
        end

        ##
        # @private
        class Batch
          attr_reader :created_at, :entries

          def initialize writer
            @writer = writer
            @entries = []
            @entries_bytes = 2 # initial size w/ partial_success
            @created_at = nil
          end

          def add entry, addl_bytes: nil
            addl_bytes ||= addl_bytes_for entry
            @entries << entry
            @entries_bytes += addl_bytes
            @created_at ||= Time.now
            nil
          end

          def try_add entry
            addl_bytes = addl_bytes_for entry
            new_message_count = @entries.count + 1
            new_message_bytes = @entries_bytes + addl_bytes
            if new_message_count > @writer.max_count ||
               new_message_bytes >= @writer.max_bytes
              return false
            end
            add entry, addl_bytes: addl_bytes
            true
          end

          def ready?
            @entries.count >= @writer.max_count ||
              @entries_bytes >= @writer.max_bytes ||
              (@created_at.nil? || (publish_at < Time.now))
          end

          def publish_at
            return nil if @created_at.nil?
            @created_at + @writer.interval
          end

          def publish_wait
            publish_wait = publish_at - Time.now
            return 0 if publish_wait < 0
            publish_wait
          end

          def addl_bytes_for entry
            entry.to_grpc.to_proto.bytesize + 2
          end
        end
      end
    end
  end
end
