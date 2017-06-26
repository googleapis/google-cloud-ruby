# Copyright 2017 Google Inc. All rights reserved.
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


require "google/cloud/pubsub/service"
require "google/cloud/errors"
require "monitor"
require "forwardable"
require "concurrent"

module Google
  module Cloud
    module Pubsub
      ##
      # # Subscriber
      #
      class Subscriber
        include MonitorMixin

        ##
        # @private Implementation attributes.
        attr_reader :request_queue, :output_enum, :thread_pool, :service

        ##
        # Subscriber attributes.
        attr_reader :callback, :subscription_name, :deadline, :inventory,
                    :threads

        ##
        # @private Create an empty {Subscriber} object.
        def initialize callback, subscription_name, deadline, inventory,
                       threads, service
          @request_queue = nil
          @output_enum = nil
          @callback = callback
          @subscription_name = subscription_name
          @deadline = deadline || 60
          @inventory = Inventory.new self, (inventory || 100)
          @threads = threads || [2, Concurrent.processor_count * 2].max
          @service = service

          super() # to init MonitorMixin
        end

        def start
          synchronize do
            return if @request_queue

            @request_queue = EnumeratorQueue.new self
            @thread_pool = Concurrent::FixedThreadPool.new threads
            start_streaming!
          end

          true
        end

        def stop
          synchronize do
            return if @request_queue.nil?
            @request_queue.push self
            @inventory.stop
            @stopped = true
          end

          true
        end

        def stopped?
          synchronize { @stopped }
        end

        def paused?
          synchronize { @paused }
        end

        def wait!
          synchronize do
            @background_thread.join if @background_thread

            @thread_pool.shutdown
            @thread_pool.wait_for_termination
          end

          true
        end

        ##
        # @private
        def acknowledge *messages
          ack_ids = coerce_ack_ids messages
          return true if ack_ids.empty?

          ack_request = Google::Pubsub::V1::StreamingPullRequest.new
          ack_request.ack_ids += ack_ids

          synchronize do
            @request_queue.push ack_request
            @inventory.remove ack_ids
            unpause_streaming!
          end

          true
        end

        ##
        # @private
        def delay new_deadline, *messages
          deadline_ack_ids = coerce_ack_ids messages
          return true if deadline_ack_ids.empty?

          deadline_seconds = deadline_ack_ids.count.times.map { new_deadline }
          deadline_ack_request = Google::Pubsub::V1::StreamingPullRequest.new
          deadline_ack_request.modify_deadline_ack_ids += deadline_ack_ids
          deadline_ack_request.modify_deadline_seconds += deadline_seconds

          synchronize do
            @request_queue.push deadline_ack_request
            @inventory.remove deadline_ack_ids
            unpause_streaming!
          end

          true
        end

        def inventory
          synchronize { @inventory.count }
        end

        ##
        # @private
        def delay_inventory!
          synchronize do
            return true if @inventory.empty?

            inv_mod_ack_deadline = @inventory.ack_ids.map { deadline }
            inv_mod_ack_request = Google::Pubsub::V1::StreamingPullRequest.new
            inv_mod_ack_request.modify_deadline_ack_ids += @inventory.ack_ids
            inv_mod_ack_request.modify_deadline_seconds += inv_mod_ack_deadline

            @request_queue.push inv_mod_ack_request
          end

          true
        end

        ##
        # @private
        def clear_inventory!
          synchronize do
            @inventory.clear
            unpause_streaming!
          end
        end

        # @private
        def to_s
          format "(subscription: %s, inventory: %i)", subscription_name,
                 inventory
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        protected

        # rubocop:disable all

        def background_run
          until synchronize { @stopped }
            Thread.current.kill if synchronize { @paused }

            begin
              # Cannot syncronize the enumerator, causes deadlock
              response = @output_enum.next
              response.received_messages.each do |rec_msg_grpc|
                rec_msg = ReceivedMessage.from_grpc(rec_msg_grpc, self)
                synchronize do
                  @inventory.add rec_msg.ack_id

                  perform_callback_async rec_msg
                end
              end
              synchronize { pause_streaming! }
            rescue StopIteration
              break
            end
          end
        rescue GRPC::DeadlineExceeded
          # The GRPC client will raise when stream is opened longer than the
          # timeout value it is configured for. When this happends, restart the
          # stream stealthly.
        rescue => e
          synchronize do
            @request_queue.unshift Google::Cloud::Error.from_error(e)
          end
        ensure
          Thread.pass
        end

        # rubocop:enable all

        def perform_callback_async rec_msg
          Concurrent::Future.new(executor: @thread_pool) do
            @callback.call rec_msg
          end.execute
        end

        def start_streaming!
          @request_queue.unshift initial_input_request
          @output_enum = service.streaming_pull @request_queue.each_item

          @background_thread.kill if @background_thread
          @background_thread = Thread.new { background_run }
          @stopped = nil
        end

        def pause_streaming!
          return if @paused

          @paused = true if inventory_full?
        end

        def unpause_streaming!
          return if @paused.nil? || inventory_full?

          @paused = nil
          # Need to recreate the enums otherwise we get the error:
          # "fiber called across threads"
          start_streaming!
        end

        def inventory_full?
          @inventory.full?
        end

        def initial_input_request
          Google::Pubsub::V1::StreamingPullRequest.new.tap do |req|
            req.subscription = subscription_name
            req.stream_ack_deadline_seconds = deadline
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

        # @private
        class Inventory
          include MonitorMixin

          attr_reader :subscriber, :limit

          def initialize subscriber, limit
            @subscriber = subscriber
            @limit = limit
            @_ack_ids = []
            @wait_cond = new_cond

            super()
          end

          def ack_ids
            @_ack_ids
          end

          def add *ack_ids
            ack_ids = Array(ack_ids).flatten
            synchronize do
              @_ack_ids += ack_ids
              @start_time ||= Time.now
              @background_thread ||= Thread.new { background_run }
            end
          end

          def remove *ack_ids
            ack_ids = Array(ack_ids).flatten
            synchronize do
              @_ack_ids -= ack_ids
              clear if @_ack_ids.empty?
            end
          end

          def clear
            synchronize do
              @_ack_ids = []
              if @background_thread
                @background_thread.kill
                @background_thread = nil
              end
              @start_time = nil
            end
          end

          def count
            synchronize do
              @_ack_ids.count
            end
          end

          def empty?
            synchronize do
              @_ack_ids.empty?
            end
          end

          def stop
            synchronize do
              @stopped = true
            end
          end

          def full?
            count >= limit
          end

          protected

          def background_run
            synchronize do
              until @stopped
                @wait_cond.wait calc_delay

                @subscriber.delay_inventory!
              end
            end
          end

          def calc_delay
            (@subscriber.deadline - 3) * rand(0.8..0.9)
          end
        end

        # @private
        class EnumeratorQueue
          extend Forwardable
          def_delegators :@q, :push

          # @private
          def initialize sentinel
            @q = Queue.new
            @sentinel = sentinel
          end

          def unshift request
            new_queue = Queue.new
            new_queue.push request
            while @q.size > 0
              r = @q.pop
              new_queue.push r unless r.equal? @sentinel
            end
            @q = new_queue
          end

          # @private
          def each_item
            return enum_for(:each_item) unless block_given?
            loop do
              r = @q.pop
              break if r.equal? @sentinel
              fail r if r.is_a? Exception
              yield r
            end
          end
        end
      end
    end
  end
end
