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
        attr_reader :callback, :subscription_name, :deadline, :threads

        ##
        # @private Create an empty {Subscriber} object.
        def initialize callback, subscription_name, deadline, threads, service
          @request_queue = nil
          @output_enum = nil
          @callback = callback
          @subscription_name = subscription_name
          @deadline = deadline
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
          end

          true
        end

        def wait!
          synchronize do
            return if @background_thread.nil?
            @background_thread.join
          end

          return true if @thread_pool.shutdown?
          @thread_pool.shutdown
          @thread_pool.wait_for_termination

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
          end

          true
        end

        # @private
        def to_s
          format "(subscription: %s)", subscription_name
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        protected

        def background_run
          @output_enum.each do |response|
            response.received_messages.each do |rec_msg_grpc|
              perform_callback_async @callback, rec_msg_grpc
            end
          end
        rescue GRPC::DeadlineExceeded
          # The GRPC client will raise when stream is opened longer than the
          # timeout value it is configured for. When this happends, restart the
          # stream stealthly.
          synchronize do
            start_streaming!
          end
        rescue => e
          @request_queue.unshift Google::Cloud::Error.from_error(e)
          Thread.current.kill
        ensure
          Thread.pass
        end

        def perform_callback_async callback, rec_msg_grpc
          Concurrent::Future.new(executor: @thread_pool) do
            callback.call ReceivedMessage.from_grpc(rec_msg_grpc, self)
          end.execute
        end

        def start_streaming!
          @request_queue.unshift initial_input_request
          @output_enum = service.streaming_pull @request_queue.each_item

          @background_thread = Thread.new { background_run }
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
            new_queue.push @q.pop while @q.size > 0
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
