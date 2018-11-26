# Copyright 2018 Google LLC
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
    module Pubsub
      class Subscriber
        ##
        # @private
        class TimedUnaryBuffer
          attr_reader :max_bytes, :interval

          def initialize subscriber, max_bytes: 10000000, interval: 1.0
            @subscriber = subscriber
            @max_bytes = max_bytes
            @interval = interval

            # Using a Map ensures there is only one entry for each ack_id in the
            # buffer. Adding an entry again will overwrite the previous entry.
            @register = Concurrent::Map.new

            @task = Concurrent::TimerTask.new(execution_interval: interval) do
              flush!
            end
          end

          def acknowledge ack_ids
            return if ack_ids.empty?

            ack_ids.each do |ack_id|
              # ack has no deadline set
              @register[ack_id] = nil
            end

            true
          end

          def modify_ack_deadline deadline, ack_ids
            return if ack_ids.empty?

            ack_ids.each do |ack_id|
              @register[ack_id] = deadline
            end

            true
          end
          alias delay modify_ack_deadline

          def flush!
            # Grab requests from the buffer and release synchronize ASAP
            requests = flush_requests!
            return if requests.empty?

            # Perform the RCP calls in order
            requests[:acknowledge].each do |ack_req|
              begin
                @subscriber.service.acknowledge \
                  ack_req.subscription, *ack_req.ack_ids
              rescue StandardError => error
                @subscriber.error! error
              end
            end
            requests[:modify_ack_deadline].each do |mod_ack_req|
              begin
                @subscriber.service.modify_ack_deadline \
                  mod_ack_req.subscription, mod_ack_req.ack_ids,
                  mod_ack_req.ack_deadline_seconds
              rescue StandardError => error
                @subscriber.error! error
              end
            end

            true
          end

          def start
            @task.execute

            self
          end

          def stop
            @task.shutdown
            flush!

            self
          end

          def started?
            @task.running?
          end

          def stopped?
            !started?
          end

          private

          def flush_requests!
            return {} if @register.empty?

            prev_reg = @register
            @register = Concurrent::Map.new

            groups = prev_reg.each_pair.group_by { |_ack_id, delay| delay }
            req_hash = Hash[groups.map { |k, v| [k, v.map(&:first)] }]

            requests = { acknowledge: [] }
            ack_ids = Array(req_hash.delete(nil)) # ack has no deadline set
            if ack_ids.any?
              requests[:acknowledge] = create_acknowledge_requests ack_ids
            end
            requests[:modify_ack_deadline] = \
              req_hash.map do |mod_deadline, mod_ack_ids|
                create_modify_ack_deadline_requests mod_deadline, mod_ack_ids
              end.flatten
            requests
          end

          def create_acknowledge_requests ack_ids
            req = Google::Pubsub::V1::AcknowledgeRequest.new(
              subscription: subscription_name,
              ack_ids: ack_ids
            )
            addl_to_create = req.to_proto.bytesize / max_bytes
            return [req] if addl_to_create.zero?

            ack_ids.each_slice(addl_to_create + 1).map do |sliced_ack_ids|
              Google::Pubsub::V1::AcknowledgeRequest.new(
                subscription: subscription_name,
                ack_ids: sliced_ack_ids
              )
            end
          end

          def create_modify_ack_deadline_requests deadline, ack_ids
            req = Google::Pubsub::V1::ModifyAckDeadlineRequest.new(
              subscription: subscription_name,
              ack_ids: ack_ids,
              ack_deadline_seconds: deadline
            )
            addl_to_create = req.to_proto.bytesize / max_bytes
            return [req] if addl_to_create.zero?

            ack_ids.each_slice(addl_to_create + 1).map do |sliced_ack_ids|
              Google::Pubsub::V1::ModifyAckDeadlineRequest.new(
                subscription: subscription_name,
                ack_ids: sliced_ack_ids,
                ack_deadline_seconds: deadline
              )
            end
          end

          def subscription_name
            @subscriber.subscription_name
          end
        end
      end
    end
  end
end
