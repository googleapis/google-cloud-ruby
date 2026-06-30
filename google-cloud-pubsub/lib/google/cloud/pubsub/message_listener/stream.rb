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

require "google/cloud/pubsub/message_listener/sequencer"
require "google/cloud/pubsub/message_listener/enumerator_queue"
require "google/cloud/pubsub/message_listener/inventory"
require "google/cloud/pubsub/service"
require "google/cloud/errors"
require "monitor"
require "concurrent"

module Google
  module Cloud
    module PubSub
      class MessageListener
        ##
        # @private
        class Stream
          include MonitorMixin

          ##
          # @private Implementation attributes.
          attr_reader :callback_thread_pool

          ##
          # @private Subscriber attributes.
          attr_reader :subscriber

          ##
          # @private Inventory.
          attr_reader :inventory

          ##
          # @private Sequencer.
          attr_reader :sequencer

          ##
          # @private exactly_once_delivery_enabled.
          attr_reader :exactly_once_delivery_enabled
          attr_accessor :keepalive_interval, :pong_deadline

          ##
          # @private Create an empty Subscriber::Stream object.
          def initialize subscriber
            super() # to init MonitorMixin

            @subscriber = subscriber

            @request_queue = nil
            @stopped = nil
            @paused  = nil
            @pause_cond = new_cond
            @exactly_once_delivery_enabled = false

            @inventory = Inventory.new self, **@subscriber.stream_inventory

            @sequencer = Sequencer.new(&method(:perform_callback_async)) if subscriber.message_ordering

            @callback_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @subscriber.callback_threads

            @keepalive_interval = Float(ENV["PUBSUB_TEST_KEEPALIVE_INTERVAL"] || 30)
            @pong_deadline = Float(ENV["PUBSUB_TEST_PONG_DEADLINE"] || 15)
            @last_ping_at = nil
            @last_pong_at = nil
            @stream_opened = false
            @reconnect_delay = nil

            @stream_keepalive_task = nil
            @pong_monitor_task = nil
          end

          def start
            synchronize do
              break if @background_thread

              @inventory.start
              @stream_keepalive_task = Concurrent::TimerTask.new(
                execution_interval: @keepalive_interval
              ) { send_keepalive_ping! }
              @stream_keepalive_task.execute

              @pong_monitor_task = Concurrent::TimerTask.new(
                execution_interval: [@keepalive_interval / 5.0, 0.01].max
              ) { check_liveness! }
              @pong_monitor_task.execute

              start_streaming!
            end

            self
          end

          def stop
            synchronize do
              break if @stopped

              subscriber.service.logger.log :info, "subscriber-streams" do
                "stopping stream for subscription #{@subscriber.subscription_name}"
              end
              # Close the stream by pushing the sentinel value.
              # The unary pusher does not use the stream, so it can close here.
              @request_queue&.push self

              # Signal to the background thread that we are stopped.
              @stopped = true
              @pause_cond.broadcast

              @stream_keepalive_task&.shutdown
              @stream_keepalive_task = nil
              @pong_monitor_task&.shutdown
              @pong_monitor_task = nil

              # Now that the reception thread is stopped, immediately stop the
              # callback thread pool. All queued callbacks will see the stream
              # is stopped and perform a noop.
              @callback_thread_pool.shutdown

              # Once all the callbacks are stopped, we can stop the inventory.
              @inventory.stop
            end

            self
          end

          def stopped?
            synchronize { @stopped }
          end

          def paused?
            synchronize { @paused }
          end

          def running?
            !stopped?
          end

          def wait! timeout = nil
            # Wait for all queued callbacks to be processed.
            @callback_thread_pool.wait_for_termination timeout

            self
          end

          ##
          # @private
          def acknowledge *messages, &callback
            ack_ids = coerce_ack_ids messages
            return true if ack_ids.empty?

            synchronize do
              @inventory.remove ack_ids
              @subscriber.buffer.acknowledge ack_ids, callback
            end

            true
          end

          ##
          # @private
          def modify_ack_deadline deadline, *messages, &callback
            mod_ack_ids = coerce_ack_ids messages
            return true if mod_ack_ids.empty?

            synchronize do
              @inventory.remove mod_ack_ids
              @subscriber.buffer.modify_ack_deadline deadline, mod_ack_ids, callback
            end

            true
          end

          ##
          # @private
          def release *messages
            ack_ids = coerce_ack_ids messages
            return if ack_ids.empty?

            synchronize do
              # Remove from inventory if the message was not explicitly acked or
              # nacked in the callback
              @inventory.remove ack_ids
              # Check whether to unpause the stream only after the callback is
              # completed and the thread is being reclaimed.
              unpause_streaming!
            end
          end

          def push request
            synchronize { @request_queue.push request }
          end

          ##
          # @private
          def renew_lease!
            synchronize do
              return true if @inventory.empty?

              @inventory.remove_expired!
              @subscriber.buffer.renew_lease @subscriber.deadline, @inventory.ack_ids
              unpause_streaming!
            end

            true
          end

          # @private
          def to_s
            seq_str = "sequenced: #{sequencer}, " if sequencer
            "(inventory: #{@inventory.count}, #{seq_str}status: #{status}, thread: #{thread_status})"
          end

          # @private
          def inspect
            "#<#{self.class.name} #{self}>"
          end

          protected

          # @private
          class RestartStream < StandardError; end

          # rubocop:disable all

          def backoff_and_wait!
            @reconnect_delay = @reconnect_delay ? [@reconnect_delay * 1.5, 60.0].min : 1.0
            synchronize do
              @pause_cond.wait(@reconnect_delay + rand(0.0..0.5)) unless @stopped
            end
          end

          def background_run
            synchronize do
              # Don't allow a stream to restart if already stopped
              if @stopped
                subscriber.service.logger.log :debug, "subscriber-streams" do
                  "not filling stream for subscription #{@subscriber.subscription_name} because stream is already" \
                  " stopped"
                end
                return
              end

              @stopped = false
              @paused  = false

              # signal to the previous queue to shut down
              old_queue = []
              old_queue = @request_queue.quit_and_dump_queue if @request_queue

              # Always create a new request queue
              @request_queue = EnumeratorQueue.new self
              @request_queue.push initial_input_request
              old_queue.each { |obj| @request_queue.push obj }
            end

            # Call the StreamingPull API to get the response enumerator
            options = { :"metadata" => { :"x-goog-request-params" =>  @subscriber.subscription_name } }
            synchronize do
              @stream_opened = false
            end
            enum = @subscriber.service.streaming_pull @request_queue.each, options
            subscriber.service.logger.log :info, "subscriber-streams" do
              "rpc: streamingPull, subscription: #{@subscriber.subscription_name}, stream opened"
            end

            synchronize do
              now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
              @last_ping_at = now
              @last_pong_at = now
              @stream_opened = true
            end

            loop do
              synchronize do
                if @paused && !@stopped
                  @pause_cond.wait
                  next
                end
              end

              # Break loop, close thread if stopped
              break if synchronize { @stopped }

              begin
                # Cannot synchronize the enumerator, causes deadlock
                response = enum.next
                synchronize do
                  @last_pong_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                  # Reset backoff delay only after successfully reading a frame from enum.next.
                  # If the connection drops immediately upon reading, @reconnect_delay is preserved.
                  @reconnect_delay = nil
                end
                received_messages = response.received_messages
                # Skip processing properties and inventory on Pong frames (empty received_messages).
                # Subscription properties on keep-alive Pongs are not valid.
                next if received_messages.empty?
                new_exactly_once_delivery_enabled = response&.subscription_properties&.exactly_once_delivery_enabled

                # Use synchronize so changes happen atomically
                synchronize do
                  update_min_duration_per_lease_extension new_exactly_once_delivery_enabled
                  @exactly_once_delivery_enabled = new_exactly_once_delivery_enabled unless new_exactly_once_delivery_enabled.nil?
                  @subscriber.exactly_once_delivery_enabled = @exactly_once_delivery_enabled

                  # Create receipt of received messages reception
                  if @exactly_once_delivery_enabled
                    create_receipt_modack_for_eos received_messages
                  else
                    @subscriber.buffer.modify_ack_deadline @subscriber.deadline, received_messages.map(&:ack_id)
                    # Add received messages to inventory
                    @inventory.add received_messages
                  end
                end

                received_messages.each do |rec_msg_grpc|
                  rec_msg = ReceivedMessage.from_grpc(rec_msg_grpc, self)
                  # No need to synchronize the callback future
                  register_callback rec_msg
                end if !@exactly_once_delivery_enabled # Exactly once delivery scenario is handled by callback

                synchronize { pause_streaming! }
              rescue StopIteration
                break
              end
            end

            # Has the loop broken but we aren't stopped?
            # Could be GRPC has thrown an internal error, so restart.
            raise RestartStream unless synchronize { @stopped }

            # We must be stopped, tell the stream to quit.
            stop
          rescue GRPC::Cancelled, GRPC::DeadlineExceeded, GRPC::Internal,
                 GRPC::ResourceExhausted, GRPC::Unauthenticated,
                 GRPC::Unavailable => e
            status_code = e.respond_to?(:code) ? e.code : e.class.name
            subscriber.service.logger.log :error, "subscriber-streams" do
              "Subscriber stream for subscription #{@subscriber.subscription_name} has ended with status " \
              "#{status_code}; will be retried."
            end
            # Restart the stream with an incremental back for a retriable error.
            backoff_and_wait!
            retry
          rescue RestartStream
            subscriber.service.logger.log :info, "subscriber-streams" do
              "Subscriber stream for subscription #{@subscriber.subscription_name} has ended; will be retried."
            end
            backoff_and_wait!
            retry
          rescue StandardError => e
            subscriber.service.logger.log :error, "subscriber-streams" do
              "error on stream for subscription #{@subscriber.subscription_name}: #{e.inspect}"
            end
            @subscriber.error! e

            backoff_and_wait!
            retry
          end

          # rubocop:enable all

          def create_receipt_modack_for_eos received_messages
            received_messages.each do |rec_msg_grpc|
              callback = proc do |result|
                if result.succeeded?
                  synchronize { @inventory.add rec_msg_grpc }
                  rec_msg = ReceivedMessage.from_grpc rec_msg_grpc, self
                  register_callback rec_msg
                end
              end
              @subscriber.buffer.modify_ack_deadline @subscriber.deadline, [rec_msg_grpc.ack_id], callback
            end
          end

          # Updates min_duration_per_lease_extension to 60 when exactly_once_delivery_enabled
          # and reverts back to default 0 when disabled.
          # Skips if exactly_once_enabled is not modified.
          def update_min_duration_per_lease_extension new_exactly_once_delivery_enabled
            return if new_exactly_once_delivery_enabled == @exactly_once_delivery_enabled
            @inventory.min_duration_per_lease_extension = new_exactly_once_delivery_enabled ? 60 : 0
          end

          def register_callback rec_msg
            if @sequencer
              # Add the message to the sequencer to invoke the callback.
              @sequencer.add rec_msg
            else
              # Call user provided code for received message
              perform_callback_async rec_msg
            end
          end

          def perform_callback_async rec_msg
            return unless callback_thread_pool.running?

            Concurrent::Promises.future_on(
              callback_thread_pool,
              rec_msg,
              &method(:perform_callback_sync)
            )
          end

          def perform_callback_sync rec_msg
            subscriber.service.logger.log :info, "callback-delivery" do
              "message (ID #{rec_msg.message_id}, ackID #{rec_msg.ack_id}) delivery to user callbacks"
            end
            @subscriber.callback.call rec_msg unless stopped?
          rescue StandardError => e
            subscriber.service.logger.log :info, "callback-exceptions" do
              "message (ID #{rec_msg.message_id}, ackID #{rec_msg.ack_id}) caused a user callback exception: " \
                "#{e.inspect}"
            end
            @subscriber.error! e
          ensure
            release rec_msg
            if @sequencer && running?
              begin
                @sequencer.next rec_msg
              rescue OrderedMessageDeliveryError => e
                @subscriber.error! e
              end
            end
          end

          def start_streaming!
            # A Stream will only ever have one background thread. If the thread
            # dies because it was stopped, or because of an unhandled error that
            # could not be recovered from, so be it.
            return if @background_thread

            # create new background thread to handle new enumerator
            @background_thread = Thread.new { background_run }
          end

          def pause_streaming!
            return unless pause_streaming?

            @paused = true
            subscriber.service.logger.log :info, "subscriber-flow-control" do
              "subscriber for #{@subscriber.subscription_name} is client-side flow control blocked"
            end
          end

          def pause_streaming?
            return false if @stopped
            return false if @paused

            @inventory.full?
          end

          def send_keepalive_ping!
            synchronize do
              if @stream_opened && !@stopped && @request_queue
                subscriber.service.logger.log :info, "subscriber-streams" do
                  "sending keepAlive to stream for subscription #{@subscriber.subscription_name}"
                end
                @last_ping_at = Process.clock_gettime(Process::CLOCK_MONOTONIC) if @last_pong_at >= @last_ping_at
                push Google::Cloud::PubSub::V1::StreamingPullRequest.new
              end
            end
          end

          def check_liveness!
            synchronize do
              if @stream_opened && @last_ping_at && @last_pong_at && !@stopped && !@paused
                now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                if now - @last_ping_at >= @pong_deadline && @last_pong_at < @last_ping_at
                  subscriber.service.logger.log :error, "subscriber-streams" do
                    "Keep-alive pong not received within #{@pong_deadline}s; restarting stream."
                  end
                  @stream_opened = false
                  @background_thread&.raise RestartStream
                end
              end
            end
          end

          def unpause_streaming!
            synchronize do
              return unless unpause_streaming?

              @paused = nil
              @last_pong_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
              subscriber.service.logger.log :info, "subscriber-flow-control" do
                "subscriber for #{@subscriber.subscription_name} is unblocking client-side flow control"
              end
              # signal to the background thread that we are unpaused
              @pause_cond.broadcast
            end
          end

          def unpause_streaming?
            return false if @stopped
            return false if @paused.nil?

            @inventory.count < @inventory.limit * 0.8
          end

          def initial_input_request
            Google::Cloud::PubSub::V1::StreamingPullRequest.new.tap do |req|
              req.subscription = @subscriber.subscription_name
              req.stream_ack_deadline_seconds = @subscriber.deadline
              req.modify_deadline_ack_ids += @inventory.ack_ids
              req.modify_deadline_seconds += @inventory.ack_ids.map { @subscriber.deadline }
              req.client_id = @subscriber.service.client_id
              req.max_outstanding_messages = @inventory.limit
              req.max_outstanding_bytes = @inventory.bytesize
              req.protocol_version = 1
            end
          end

          ##
          # Makes sure the values are the `ack_id`. If given several
          # {ReceivedMessage} objects extract the `ack_id` values.
          def coerce_ack_ids messages
            Array(messages).flatten.map do |msg|
              msg.respond_to?(:ack_id) ? msg.ack_id : msg.to_s
            end
          end

          def status
            return "stopped" if stopped?
            return "paused" if paused?
            "running"
          end

          def thread_status
            return "not started" if @background_thread.nil?

            status = @background_thread.status
            return "error" if status.nil?
            return "stopped" if status == false
            status
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
