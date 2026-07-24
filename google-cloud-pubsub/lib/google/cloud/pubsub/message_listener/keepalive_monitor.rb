# Copyright 2026 Google LLC
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

module Google
  module Cloud
    module PubSub
      class MessageListener
        ##
        # @private
        # Monitors gRPC streaming connection health via periodic bi-directional keep-alive pings and pongs.
        #
        # Tracks ping and pong timestamps over the active gRPC stream to detect silent connection drops or freezes,
        # and triggers a stream restart when server responses exceed the configured pong deadline.
        # This prevents firewalls and load balancers from dropping idle connections during periods of low
        # message publisher volume, which minimizes message delivery latency by maintaining a healthy lease.
        class KeepaliveMonitor
          # Default interval in seconds between keep-alive ping requests.
          DEFAULT_INTERVAL = 30.0
          # Default deadline in seconds to receive a keep-alive pong response.
          DEFAULT_DEADLINE = 15.0
          # Divisor applied to keep-alive interval to calculate monitor polling interval (1/5th of interval).
          MONITOR_DIVISOR = 5.0
          # Minimum floor in seconds (10ms) for the monitor polling interval to prevent CPU spinning.
          MIN_MONITOR_INTERVAL = 0.01

          # Initializes the KeepaliveMonitor.
          #
          # @param [Stream] stream The parent streaming pull connection to monitor.
          # @param [Float] interval The interval in seconds between keep-alive pings.
          # @param [Float] deadline The deadline in seconds for receiving a pong.
          def initialize stream, interval: DEFAULT_INTERVAL, deadline: DEFAULT_DEADLINE
            @stream       = stream
            @interval     = interval
            @deadline     = deadline
            @last_ping_at = nil
            @last_pong_at = nil
            @ping_task    = nil
            @monitor_task = nil
          end

          # Starts the background keep-alive ping and liveness monitor timer tasks.
          #
          # @return [KeepaliveMonitor] self for chaining.
          def start
            @stream.synchronize do
              return self if @ping_task

              @ping_task = Concurrent::TimerTask.new(execution_interval: [@interval, MIN_MONITOR_INTERVAL].max) do
                send_ping!
              end
              @ping_task.execute

              @monitor_task = Concurrent::TimerTask.new(
                execution_interval: [@interval / MONITOR_DIVISOR, MIN_MONITOR_INTERVAL].max
              ) do
                check_liveness!
              end
              @monitor_task.execute
            end
            self
          end

          # Shuts down and cleans up the background keep-alive and monitor timer tasks.
          #
          # @return [KeepaliveMonitor] self for chaining.
          def stop
            @stream.synchronize do
              @ping_task&.shutdown
              @ping_task = nil
              @monitor_task&.shutdown
              @monitor_task = nil
            end
            self
          end

          # Records the initial stream handshake by setting ping and pong timestamps to the current monotonic time.
          #
          # @return [void]
          def record_handshake!
            @stream.synchronize do
              now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
              @last_ping_at = now
              @last_pong_at = now
            end
          end

          # Records a received pong by updating the last pong timestamp to the current monotonic time.
          #
          # @return [void]
          def record_pong!
            @stream.synchronize do
              @stream.log_info "received keepAlive pong from stream for subscription #{@stream.subscriber.subscription_name}"
              @last_pong_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            end
          end

          # Evaluates stream state and sends a bi-directional keep-alive ping if appropriate.
          #
          # @return [void]
          def send_ping!
            @stream.synchronize do
              # Push unconditional keep-alive pings only when the stream is actively open and request queue is active.
              # Note: ACKs are sent via unary RPCs (TimedUnaryBuffer), not over this stream.
              return unless @stream.stream_open? && !@stream.stopped? && @stream.request_queue_active?

              @stream.log_info "sending keepAlive to stream for subscription #{@stream.subscriber.subscription_name}"
              # Only advance @last_ping_at if the previous ping was successfully ponged.
              # If a pong is outstanding (@last_pong_at < @last_ping_at), freezing @last_ping_at preserves the start time
              # of the un-ponged cycle so check_liveness! can accurately evaluate the elapsed deadline.
              @last_ping_at = Process.clock_gettime(Process::CLOCK_MONOTONIC) if @last_pong_at >= @last_ping_at
              @stream.send_ping_request!
            end
          end

          # Checks whether a pong response has been received within the configured deadline,
          # and triggers a stream restart if the deadline has been exceeded.
          #
          # @return [void]
          def check_liveness!
            @stream.synchronize do
              # Do not check pong deadline if paused (client flow control inventory full).
              # When paused, background_run waits on condition variable and stops calling enum.next,
              # so incoming server pongs sit buffered in gRPC and last_pong_at stays un-updated.
              return unless @stream.stream_open? && @last_ping_at && @last_pong_at && !@stream.stopped? && !@stream.paused?

              now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
              if now - @last_ping_at >= @deadline && @last_pong_at < @last_ping_at
                elapsed_pong = (now - @last_pong_at).round(2)
                @stream.log_error "Keep-alive pong not received within #{@deadline}s (last pong #{elapsed_pong}s ago); restarting stream."
                @stream.restart_stream_for_timeout!
              end
            end
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
