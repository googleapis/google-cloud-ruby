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
require "google/cloud/pubsub/subscriber/stream"
require "google/cloud/pubsub/subscriber/enumerator_queue"
require "monitor"
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
        # Subscriber attributes.
        attr_reader :subscription_name, :callback, :deadline, :streams,
                    :inventory, :threads

        ##
        # @private Implementation attributes.
        attr_reader :stream_pool, :thread_pool, :service

        ##
        # @private Create an empty {Subscriber} object.
        def initialize subscription_name, callback, deadline: nil, streams: nil,
                       inventory: nil, threads: nil, service: nil
          @callback = callback
          @subscription_name = subscription_name
          @deadline = deadline || 60
          @streams = streams || 1
          @inventory = inventory || 100
          @threads = threads || [2, Concurrent.processor_count * 2].max
          @thread_pool = Concurrent::FixedThreadPool.new @threads
          @service = service

          @stream_pool = @streams.times.map do
            Thread.new do
              Thread.current[:stream] = Stream.new self
            end
          end
          @stream_pool.map!(&:join)
          @stream_pool.map! { |t| t[:stream] }

          super() # to init MonitorMixin
        end

        def start
          start_pool = synchronize do
            @stream_pool.map do |stream|
              Thread.new { stream.start }
            end
          end
          start_pool.join

          self
        end

        def stop
          stop_pool = synchronize do
            @stream_pool.map do |stream|
              Thread.new { stream.stop }
            end
          end
          stop_pool.join

          self
        end

        def wait!
          wait_pool = synchronize do
            @stream_pool.map do |stream|
              Thread.new { stream.wait! }
            end
          end
          wait_pool.join

          synchronize do
            @thread_pool.shutdown
            @thread_pool.wait_for_termination
          end

          self
        end

        # @private
        def to_s
          format "(subscription: %s, streams: %i)", subscription_name, streams
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end
      end
    end
  end
end
