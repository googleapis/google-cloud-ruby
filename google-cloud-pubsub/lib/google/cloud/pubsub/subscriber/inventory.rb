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

module Google
  module Cloud
    module Pubsub
      class Subscriber
        ##
        # @private
        class Inventory
          include MonitorMixin

          attr_reader :stream, :limit

          def initialize stream, limit
            @stream = stream
            @limit = limit
            @_ack_ids = []
            @wait_cond = new_cond

            super()
          end

          def ack_ids
            @_ack_ids
          end

          def add *ack_ids
            ack_ids.flatten!.compact!
            return if ack_ids.empty?

            synchronize do
              @_ack_ids += ack_ids
              @wait_cond.broadcast
            end
          end

          def remove *ack_ids
            ack_ids.flatten!.compact!
            return if ack_ids.empty?

            synchronize do
              @_ack_ids -= ack_ids
              @wait_cond.broadcast
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

          def start
            @background_thread ||= Thread.new { background_run }

            self
          end

          def stop
            synchronize do
              @stopped = true
              @wait_cond.broadcast
            end

            self
          end

          def stopped?
            synchronize { @stopped }
          end

          def full?
            count >= limit
          end

          protected

          def background_run
            delay_target = nil

            synchronize do
              until @stopped
                if @_ack_ids.empty?
                  delay_target = nil

                  @wait_cond.wait # wait until broadcast
                  next
                end

                delay_target ||= calc_target
                delay_gap = delay_target - Time.now

                unless delay_gap.positive?
                  delay_target = nil
                  delay_gap = nil # wait until broadcast
                  stream.renew_lease!
                end

                @wait_cond.wait delay_gap
              end
            end
          end

          def calc_target
            Time.now + calc_delay
          end

          def calc_delay
            (stream.subscriber.deadline - 3) * rand(0.8..0.9)
          end
        end
      end
    end
  end
end
