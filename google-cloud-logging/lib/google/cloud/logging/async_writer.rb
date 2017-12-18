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


require "set"
require "stackdriver/core/async_actor"

module Google
  module Cloud
    module Logging
      ##
      # # AsyncWriter
      #
      # An object that batches and transmits log entries asynchronously.
      #
      # Use this object to transmit log entries efficiently. It keeps a queue
      # of log entries, and runs a background thread that transmits them to
      # the logging service in batches. Generally, adding to the queue will
      # not block.
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
        include Stackdriver::Core::AsyncActor

        DEFAULT_MAX_QUEUE_SIZE = 10000
        CLEANUP_TIMEOUT = Stackdriver::Core::AsyncActor::CLEANUP_TIMEOUT
        WAIT_INTERVAL = Stackdriver::Core::AsyncActor::WAIT_INTERVAL

        ##
        # @private Item in the log entries queue.
        QueueItem = Struct.new(:entries, :log_name, :resource, :labels) do
          def try_combine next_item
            if log_name == next_item.log_name &&
               resource == next_item.resource &&
               labels == next_item.labels
              entries.concat(next_item.entries)
              true
            else
              false
            end
          end
        end

        ##
        # @private The logging object.
        attr_accessor :logging

        ##
        # @private The maximum size of the entries queue, or nil if not set.
        attr_accessor :max_queue_size

        ##
        # The current state. Either :running, :suspended, :stopping, or :stopped
        #
        # DEPRECATED. Use #async_state instead.
        alias_method :state, :async_state

        ##
        # The last exception thrown by the background thread, or nil if nothing
        # has been thrown.
        attr_reader :last_exception

        ##
        # @private Creates a new AsyncWriter instance.
        def initialize logging, max_queue_size = DEFAULT_MAX_QUEUE_SIZE,
                       partial_success = false
          super()

          @logging = logging
          @max_queue_size = max_queue_size
          @partial_success = partial_success
          @queue_resource = new_cond
          @queue = []
          @queue_size = 0
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
          ensure_thread
          entries = Array(entries)
          synchronize do
            fail "AsyncWriter has been stopped" unless writable?
            queue_item = QueueItem.new entries, log_name, resource, labels
            if @queue.empty? || !@queue.last.try_combine(queue_item)
              @queue.push queue_item
            end
            @queue_size += entries.size
            @queue_resource.broadcast
            while @max_queue_size && @queue_size > @max_queue_size
              @queue_resource.wait
            end
          end
          self
        end

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
        # Stops this asynchronous writer.
        #
        # After this call succeeds, the state will change to :stopping, and
        # you may not issue any additional write_entries calls. Any previously
        # issued writes will complete. Once any existing backlog has been
        # cleared, the state will change to :stopped.
        #
        # DEPRECATED. Use #async_stop instead.
        #
        # @return [Boolean] Returns true if the writer was running, or false
        #   if the writer had already been stopped.
        #
        alias_method :stop, :async_stop

        ##
        # Suspends this asynchronous writer.
        #
        # After this call succeeds, the state will change to :suspended, and
        # the writer will stop sending RPCs until resumed.
        #
        # DEPRECATED. Use #async_suspend instead.
        #
        # @return [Boolean] Returns true if the writer had been running and was
        #   suspended, otherwise false.
        #
        alias_method :suspend, :async_suspend

        ##
        # Resumes this suspended asynchronous writer.
        #
        # After this call succeeds, the state will change to :running, and
        # the writer will resume sending RPCs.
        #
        # DEPRECATED. Use #async_resume instead.
        #
        # @return [Boolean] Returns true if the writer had been suspended and
        #   is now running, otherwise false.
        #
        alias_method :resume, :async_resume

        ##
        # Returns true if this writer is running.
        #
        # DEPRECATED. Use #async_running? instead.
        #
        # @return [Boolean] Returns true if the writer is currently running.
        #
        alias_method :running?, :async_running?

        ##
        # Returns true if this writer is suspended.
        #
        # DEPRECATED. Use #async_suspended? instead.
        #
        # @return [Boolean] Returns true if the writer is currently suspended.
        #
        alias_method :suspended?, :async_suspended?

        ##
        # Returns true if this writer is still accepting writes. This means
        # it is either running or suspended.
        #
        # DEPRECATED. Use #async_working? instead.
        #
        # @return [Boolean] Returns true if the writer is accepting writes.
        #
        alias_method :writable?, :async_working?

        ##
        # Returns true if this writer is fully stopped.
        #
        # DEPRECATED. Use #async_stopped? instead.
        #
        # @return [Boolean] Returns true if the writer is fully stopped.
        #
        alias_method :stopped?, :async_stopped?

        ##
        # Blocks until this asynchronous writer has been stopped, or the given
        # timeout (if present) has elapsed.
        #
        # DEPRECATED. Use #wait_until_async_stopped instead.
        #
        # @param [Number, nil] timeout Timeout in seconds, or `nil` for no
        #     timeout.
        #
        # @return [Boolean] Returns true if the writer is stopped, or false
        #   if the timeout expired.
        #
        alias_method :wait_until_stopped, :wait_until_async_stopped

        ##
        # Stop this asynchronous writer and block until it has been stopped.
        #
        # DEPRECATED. Use #async_stop! instead.
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
        def stop! timeout, force: false
          @cleanup_options[:timeout] = timeout unless timeout.nil?
          @cleanup_options[:force] = force unless force.nil?

          async_stop!
        end

        ##
        # @private Callback function when the async actor thread state changes
        def on_async_state_change
          synchronize do
            @queue_resource.broadcast
          end
        end

        protected

        ##
        # @private The background thread implementation, which continuously
        # waits for and performs work, and returns only when fully stopped.
        #
        def run_backgrounder
          queue_item = wait_next_item
          return unless queue_item
          begin
            logging.write_entries(
              queue_item.entries,
              log_name: queue_item.log_name,
              resource: queue_item.resource,
              labels: queue_item.labels,
              partial_success: @partial_success
            )
          rescue => e
            # Ignore any exceptions thrown from the background thread, but
            # keep running to ensure its state behavior remains consistent.
            @last_exception = e
          end
        end

        ##
        # @private Wait for and dequeue the next set of log entries to transmit.
        #
        # @return [QueueItem, nil] Returns the next set of entries. If
        #   the writer has been stopped and no more entries are left in the
        #   queue, returns `nil`.
        #
        def wait_next_item
          synchronize do
            while state == :suspended ||
                  (state == :running && @queue.empty?)
              @queue_resource.wait
            end
            queue_item = nil
            unless @queue.empty?
              queue_item = @queue.shift
              @queue_size -= queue_item.entries.size
            end
            @queue_resource.broadcast
            queue_item
          end
        end

        ##
        # @private Override the #backgrounder_stoppable? method from AsyncActor
        # module. The actor can be gracefully stopped when queue is
        # empty.
        def backgrounder_stoppable?
          synchronize do
            @queue.empty?
          end
        end
      end
    end
  end
end
