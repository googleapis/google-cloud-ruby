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
require "monitor"

module Google
  module Cloud
    module PubSub
      class Subscriber
        ##
        # @private
        class TimedUnaryBuffer
          include MonitorMixin

          attr_reader :max_bytes
          attr_reader :interval

          PERMANENT_FAILURE = "PERMANENT_FAILURE"
          # Google::Cloud::Unavailable error is already retried at gapic level
          RETRIABLE_ERRORS = [Google::Cloud::Cancelled, 
                              Google::Cloud::DeadlineExceeded, 
                              Google::Cloud::Internal,
                              Google::Cloud::ResourceExhausted,
                              Google::Cloud::InvalidArgumentError]
          MAX_RETRY_DURATION = 600 # 600s since the server allows ack/modacks for 10 mins max       
          MAX_TRIES = 10                                 

          def initialize subscriber, max_bytes: 500_000, interval: 1.0
            super() # to init MonitorMixin

            @subscriber = subscriber
            @max_bytes = max_bytes
            @interval = interval

            # Using a Hash ensures there is only one entry for each ack_id in
            # the buffer. Adding an entry again will overwrite the previous
            # entry.
            @register = {}

            @retry_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @subscriber.push_threads
            @task = Concurrent::TimerTask.new execution_interval: interval do
              flush!
            end
          end

          def acknowledge ack_ids
            return if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                # ack has no deadline set, use :ack indicate it is an ack
                @register[ack_id] = :ack
              end
            end

            true
          end

          def modify_ack_deadline deadline, ack_ids
            return if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                @register[ack_id] = deadline
              end
            end

            true
          end

          def renew_lease deadline, ack_ids
            return if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                # Don't overwrite pending actions when renewing leased messages.
                @register[ack_id] ||= deadline
              end
            end

            true
          end

          def flush!
            # Grab requests from the buffer and release synchronize ASAP
            requests = flush_requests!
            return if requests.empty?

            # Perform the RCP calls concurrently
            with_threadpool do |pool|
              requests[:acknowledge].each do |ack_req|
                add_future pool do
                  begin
                    @subscriber.service.acknowledge ack_req.subscription, *ack_req.ack_ids
                  rescue Google::Cloud::Cancelled, Google::Cloud::DeadlineExceeded, Google::Cloud::Internal,
                         Google::Cloud::ResourceExhausted
                    retry if @subscriber.exactly_once_delivery_enabled
                  rescue Google::Cloud::InvalidArgumentError => e
                    handleAcknowledgeError e.error_metadata if @subscriber.exactly_once_delivery_enabled
                  end
                end
              end
              requests[:modify_ack_deadline].each do |mod_ack_req|
                add_future pool do
                  begin
                    @subscriber.service.modify_ack_deadline mod_ack_req.subscription, mod_ack_req.ack_ids,
                                                            mod_ack_req.ack_deadline_seconds
                  rescue Google::Cloud::Cancelled, Google::Cloud::DeadlineExceeded, Google::Cloud::Internal,
                         Google::Cloud::ResourceExhausted
                    retry if @subscriber.exactly_once_delivery_enabled
                  rescue Google::Cloud::InvalidArgumentError => e
                    handleModAckError e.error_metadata, mod_ack_req.ack_deadline_seconds if @subscriber.exactly_once_delivery_enabled
                  end                                                            
                end
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
            @retry_thread_pool.shutdown
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

          def handleAcknowledgeError error_metadata
            return if error_metadata.empty?
            permanent_failures, temporary_failures = parseError error_metadata
            log_permanent_failures permanent_failures
            perform_ack_retry_async temporary_failures.keys.map(&:to_s)
          end

          def handleModAckError error_metadata, ack_deadline_seconds
            return if error_metadata.empty?
            permanent_failures, temporary_failures = parseError error_metadata
            log_permanent_failures permanent_failures
            perform_mod_ack_retry_async temporary_failures.keys.map(&:to_s), ack_deadline_seconds
          end

          def parseError error_metadata
            error_metadata.partition { |_, v| v.include? PERMANENT_FAILURE }.map(&:to_h)
          end

          def log_permanent_failures permanent_failures
            permanent_failures.each do |ack_id, cause|
              p "The acknowledgement id #{ack_id} failed with cause #{cause}"
            end
          end

          def perform_ack_retry_async ack_ids
            return unless retry_thread_pool.running?

            Concurrent::Promises.future_on(
              retry_thread_pool, ack_ids, &method(:retry_temporary_ack)
            )
          end

          def retry_temporary_ack ack_ids
            Retriable.retriable tries: MAX_TRIES, max_elapsed_time: MAX_RETRY_DURATION, on: RETRIABLE_ERRORS do
              return if ack_ids.empty?
              requests = create_acknowledge_requests ack_ids
              requests.each do |ack_req|
                begin
                  @subscriber.service.acknowledge ack_req.subscription, *ack_req.ack_ids
                rescue Google::Cloud::InvalidArgumentError => e
                  permanent_failures, temporary_failures = parseError error_metadata
                  log_permanent_failures permanent_failures
                  ack_ids = temporary_failures.keys.map(&:to_s)
                  raise e
                end
              end
            end
          end

          def perform_mod_ack_retry_async ack_ids, ack_deadline_seconds
            return unless retry_thread_pool.running?

            Concurrent::Promises.future_on(
              retry_thread_pool, ack_ids, ack_deadline_seconds, &method(:retry_temporary_mod_ack)
            )
          end

          def retry_temporary_mod_ack ack_ids, ack_deadline_seconds
            Retriable.retriable tries: MAX_TRIES, max_elapsed_time: MAX_RETRY_DURATION, on: RETRIABLE_ERRORS do
              return if ack_ids.empty?
              requests = create_modify_ack_deadline_requests ack_deadline_seconds, ack_ids
              requests.each do |mod_ack_req|
                begin
                  @subscriber.service.modify_ack_deadline mod_ack_req.subscription, mod_ack_req.ack_ids,
                                                            mod_ack_req.ack_deadline_seconds
                rescue Google::Cloud::InvalidArgumentError => e
                  permanent_failures, temporary_failures = parseError error_metadata
                  log_permanent_failures permanent_failures
                  ack_ids = temporary_failures.keys.map(&:to_s)
                  raise e
                end
              end
            end
          end

          def flush_requests!
            prev_reg =
              synchronize do
                return {} if @register.empty?
                reg = @register
                @register = {}
                reg
              end

            groups = prev_reg.each_pair.group_by { |_ack_id, delay| delay }
            req_hash = groups.transform_values { |v| v.map(&:first) }

            requests = { acknowledge: [] }
            ack_ids = Array(req_hash.delete(:ack)) # ack has no deadline set
            requests[:acknowledge] = create_acknowledge_requests ack_ids if ack_ids.any?
            requests[:modify_ack_deadline] =
              req_hash.map do |mod_deadline, mod_ack_ids|
                create_modify_ack_deadline_requests mod_deadline, mod_ack_ids
              end.flatten
            requests
          end

          def create_acknowledge_requests ack_ids
            req = Google::Cloud::PubSub::V1::AcknowledgeRequest.new(
              subscription: subscription_name,
              ack_ids:      ack_ids
            )
            addl_to_create = req.to_proto.bytesize / max_bytes
            return [req] if addl_to_create.zero?

            ack_ids.each_slice(addl_to_create + 1).map do |sliced_ack_ids|
              Google::Cloud::PubSub::V1::AcknowledgeRequest.new(
                subscription: subscription_name,
                ack_ids:      sliced_ack_ids
              )
            end
          end

          def create_modify_ack_deadline_requests deadline, ack_ids
            req = Google::Cloud::PubSub::V1::ModifyAckDeadlineRequest.new(
              subscription:         subscription_name,
              ack_ids:              ack_ids,
              ack_deadline_seconds: deadline
            )
            addl_to_create = req.to_proto.bytesize / max_bytes
            return [req] if addl_to_create.zero?

            ack_ids.each_slice(addl_to_create + 1).map do |sliced_ack_ids|
              Google::Cloud::PubSub::V1::ModifyAckDeadlineRequest.new(
                subscription:         subscription_name,
                ack_ids:              sliced_ack_ids,
                ack_deadline_seconds: deadline
              )
            end
          end

          def subscription_name
            @subscriber.subscription_name
          end

          def push_threads
            @subscriber.push_threads
          end

          def error! error
            @subscriber.error! error
          end

          def with_threadpool
            pool = Concurrent::ThreadPoolExecutor.new max_threads: @subscriber.push_threads

            yield pool

            pool.shutdown
            pool.wait_for_termination 60
            return if pool.shutdown?

            pool.kill
            begin
              raise "Timeout making subscriber API calls"
            rescue StandardError => e
              error! e
            end
          end

          def add_future pool
            Concurrent::Promises.future_on pool do
              yield
            rescue StandardError => e
              error! e
            end
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
