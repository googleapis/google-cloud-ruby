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
    module PubSub
      class Subscriber
        ##
        # @private
        class Inventory
          InventoryItem = Struct.new :bytesize, :pulled_at do
            def self.from rec_msg
              new rec_msg.to_proto.bytesize, Time.now
            end
          end

          include MonitorMixin

          attr_reader :stream, :limit, :bytesize, :extension, :max_duration_per_lease_extension,
                      :use_legacy_flow_control

          def initialize stream, limit:, bytesize:, extension:, max_duration_per_lease_extension:,
                         use_legacy_flow_control:
            super()
            @stream = stream
            @limit = limit
            @bytesize = bytesize
            @extension = extension
            @max_duration_per_lease_extension = max_duration_per_lease_extension
            @use_legacy_flow_control = use_legacy_flow_control
            @inventory = {}
            @wait_cond = new_cond
          end

          def ack_ids
            @inventory.keys
          end

          def add *rec_msgs
            rec_msgs.flatten!
            rec_msgs.compact!
            return if rec_msgs.empty?

            synchronize do
              rec_msgs.each do |rec_msg|
                @inventory[rec_msg.ack_id] = InventoryItem.from rec_msg
              end
              @wait_cond.broadcast
            end
          end

          def remove *ack_ids
            ack_ids.flatten!
            ack_ids.compact!
            return if ack_ids.empty?

            synchronize do
              @inventory.delete_if { |ack_id, _| ack_ids.include? ack_id }
              @wait_cond.broadcast
            end
          end

          def remove_expired!
            synchronize do
              extension_time = Time.new - extension
              @inventory.delete_if { |_ack_id, item| item.pulled_at < extension_time }
              @wait_cond.broadcast
            end
          end

          def count
            synchronize do
              @inventory.count
            end
          end

          def total_bytesize
            synchronize do
              @inventory.values.sum(&:bytesize)
            end
          end

          def empty?
            synchronize do
              @inventory.empty?
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
            synchronize do
              @inventory.count >= limit || @inventory.values.sum(&:bytesize) >= bytesize
            end
          end

          protected

          def background_run
            delay_target = nil

            until stopped?
              if empty?
                delay_target = nil

                synchronize { @wait_cond.wait } # wait until broadcast
                next
              end

              delay_target ||= calc_target
              delay_gap = delay_target - Time.now

              unless delay_gap.positive?
                delay_target = calc_target
                stream.renew_lease!
                next
              end

              synchronize { @wait_cond.wait delay_gap }
            end
          end

          def calc_target
            Time.now + calc_delay
          end

          def calc_delay
            delay = (stream.subscriber.deadline - 3) * rand(0.8..0.9)
            delay = [delay, max_duration_per_lease_extension].min if max_duration_per_lease_extension.positive?
            delay
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
