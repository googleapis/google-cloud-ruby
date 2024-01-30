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


require "google/cloud/pubsub/subscriber/sequencer"
require "google/cloud/pubsub/subscriber/enumerator_queue"
require "google/cloud/pubsub/subscriber/inventory"
require "google/cloud/pubsub/service"
require "google/cloud/errors"
require "monitor"
require "concurrent"

module Google
  module Cloud
    module PubSub
      class Subscriber
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

            @stream_keepalive_task = Concurrent::TimerTask.new(
              execution_interval: 30
            ) do
              # push empty request every 30 seconds to keep stream alive
              push Google::Cloud::PubSub::V1::StreamingPullRequest.new unless inventory.empty?
            end.execute
          end

          def start
            synchronize do
              break if @background_thread

              @inventory.start

              start_streaming!
            end

            self
          end

          def stop
            synchronize do
              break if @stopped

              # Close the stream by pushing the sentinel value.
              # The unary pusher does not use the stream, so it can close here.
              @request_queue&.push self

              # Signal to the background thread that we are stopped.
              @stopped = true
              @pause_cond.broadcast

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

          def background_run
            synchronize do
              # Don't allow a stream to restart if already stopped
              return if @stopped

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
            enum = @subscriber.service.streaming_pull @request_queue.each, options

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
                # Cannot syncronize the enumerator, causes deadlock
                response = enum.next
                new_exactly_once_delivery_enabled = response&.subscription_properties&.exactly_once_delivery_enabled
                received_messages = response.received_messages

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
                 GRPC::Unavailable
            # Restart the stream with an incremental back for a retriable error.

            retry
          rescue RestartStream
            retry
          rescue StandardError => e
            @subscriber.error! e

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
              callback_thread_pool, rec_msg, &method(:perform_callback_sync)
            )
          end

          def perform_callback_sync rec_msg
            @subscriber.callback.call rec_msg unless stopped?
          rescue StandardError => e
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
          end

          def pause_streaming?
            return if @stopped
            return if @paused

            @inventory.full?
          end

          def unpause_streaming!
            return unless unpause_streaming?

            @paused = nil
            # signal to the background thread that we are unpaused
            @pause_cond.broadcast
          end

          def unpause_streaming?
            return if @stopped
            return if @paused.nil?

            @inventory.count < @inventory.limit * 0.8
          end

          def initial_input_request
            Google::Cloud::PubSub::V1::StreamingPullRequest.new.tap do |req|
              req.subscription = @subscriber.subscription_name
              req.stream_ack_deadline_seconds = @subscriber.deadline
              req.modify_deadline_ack_ids += @inventory.ack_ids
              req.modify_deadline_seconds += @inventory.ack_ids.map { @subscriber.deadline }
              req.client_id = @subscriber.service.client_id
              req.max_outstanding_messages = @inventory.use_legacy_flow_control ? 0 : @inventory.limit
              req.max_outstanding_bytes = @inventory.use_legacy_flow_control ? 0 : @inventory.bytesize
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
