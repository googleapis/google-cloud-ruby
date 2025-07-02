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
require "google/cloud/errors"
require "google/cloud/pubsub/acknowledge_result"
require "monitor"
require "retriable"

module Google
  module Cloud
    module PubSub
      class MessageListener
        ##
        # @private
        class TimedUnaryBuffer
          include MonitorMixin

          attr_reader :max_bytes
          attr_reader :interval
          attr_reader :retry_thread_pool
          attr_reader :callback_thread_pool

          PERMANENT_FAILURE = "PERMANENT_FAILURE".freeze
          # Google::Cloud::Unavailable error is already retried at gapic level
          EXACTLY_ONCE_DELIVERY_POSSIBLE_RETRIABLE_ERRORS = [Google::Cloud::CanceledError,
                                                             Google::Cloud::DeadlineExceededError,
                                                             Google::Cloud::InternalError,
                                                             Google::Cloud::ResourceExhaustedError,
                                                             Google::Cloud::InvalidArgumentError].freeze
          MAX_RETRY_DURATION = 600 # 600s since the server allows ack/modacks for 10 mins max
          MAX_TRIES = 15
          BASE_INTERVAL = 1
          MAX_INTERVAL = 64
          MULTIPLIER = 2

          def initialize subscriber, max_bytes: 500_000, interval: 1.0
            super() # to init MonitorMixin

            @subscriber = subscriber
            @max_bytes = max_bytes
            @interval = interval

            # Using a Hash ensures there is only one entry for each ack_id in
            # the buffer. Adding an entry again will overwrite the previous
            # entry.
            @register = {}

            @ack_callback_register = {}
            @modack_callback_register = {}

            @retry_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @subscriber.callback_threads
            @callback_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @subscriber.callback_threads
            @task = Concurrent::TimerTask.new execution_interval: interval do
              flush!
            end
          end

          def acknowledge ack_ids, callback = nil
            return if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                # ack has no deadline set, use :ack indicate it is an ack
                @register[ack_id] = :ack
                @ack_callback_register[ack_id] = callback unless callback.nil?
              end
            end

            true
          end

          def modify_ack_deadline deadline, ack_ids, callback = nil
            return if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                @register[ack_id] = deadline
                @modack_callback_register[ack_id] = callback unless callback.nil?
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
              make_acknowledge_request requests, pool
              make_modack_request requests, pool
            end

            true
          end

          def make_acknowledge_request requests, pool
            requests[:acknowledge].each do |ack_req|
              add_future pool do
                begin
                  @subscriber.service.acknowledge ack_req.subscription, *ack_req.ack_ids
                  handle_callback AcknowledgeResult.new(AcknowledgeResult::SUCCESS), ack_req.ack_ids
                rescue *EXACTLY_ONCE_DELIVERY_POSSIBLE_RETRIABLE_ERRORS => e
                  handle_failure e, ack_req.ack_ids if @subscriber.exactly_once_delivery_enabled
                rescue StandardError => e
                  handle_callback construct_result(e), ack_req.ack_ids
                end
              end
            end
          end

          def make_modack_request requests, pool
            requests[:modify_ack_deadline].each do |mod_ack_req|
              add_future pool do
                begin
                  @subscriber.service.modify_ack_deadline mod_ack_req.subscription, mod_ack_req.ack_ids,
                                                          mod_ack_req.ack_deadline_seconds
                  handle_callback AcknowledgeResult.new(AcknowledgeResult::SUCCESS),
                                  mod_ack_req.ack_ids,
                                  modack: true
                rescue *EXACTLY_ONCE_DELIVERY_POSSIBLE_RETRIABLE_ERRORS => e
                  if @subscriber.exactly_once_delivery_enabled
                    handle_failure e, mod_ack_req.ack_ids, mod_ack_req.ack_deadline_seconds
                  end
                rescue StandardError => e
                  handle_callback construct_result(e), mod_ack_req.ack_ids, modack: true
                end
              end
            end
          end

          def start
            @task.execute

            self
          end

          def stop
            @task.shutdown
            @retry_thread_pool.shutdown
            @callback_thread_pool.shutdown
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

          def handle_failure error, ack_ids, ack_deadline_seconds = nil
            error_ack_ids = parse_error error, modack: ack_deadline_seconds.nil?
            unless error_ack_ids.nil?
              handle_callback AcknowledgeResult.new(AcknowledgeResult::SUCCESS),
                              ack_ids - error_ack_ids,
                              modack: ack_deadline_seconds.nil?
              ack_ids = error_ack_ids
            end
            perform_retry_async ack_ids, ack_deadline_seconds
          end

          def parse_error error, modack: false
            metadata = error.error_metadata
            return if metadata.nil?
            permanent_failures, temporary_failures = metadata.partition do |_, v|
              v.include? PERMANENT_FAILURE
            end.map(&:to_h)
            unless permanent_failures.empty?
              handle_callback construct_result(error),
                              permanent_failures.keys.map(&:to_s),
                              modack: modack
            end
            temporary_failures.keys.map(&:to_s) unless temporary_failures.empty?
          end

          def construct_result error
            case error
            when Google::Cloud::PermissionDeniedError
              AcknowledgeResult.new AcknowledgeResult::PERMISSION_DENIED, error
            when Google::Cloud::FailedPreconditionError
              AcknowledgeResult.new AcknowledgeResult::FAILED_PRECONDITION, error
            when Google::Cloud::InvalidArgumentError
              AcknowledgeResult.new AcknowledgeResult::INVALID_ACK_ID, error
            else
              AcknowledgeResult.new AcknowledgeResult::OTHER, error
            end
          end

          def handle_callback result, ack_ids, modack: false
            ack_ids.each do |ack_id|
              callback = modack ? @modack_callback_register[ack_id] : @ack_callback_register[ack_id]
              perform_callback_async result, callback unless callback.nil?
            end
            synchronize do
              if modack
                @modack_callback_register.delete_if { |ack_id, _| ack_ids.include? ack_id }
              else
                @ack_callback_register.delete_if { |ack_id, _| ack_ids.include? ack_id }
              end
            end
          end

          def perform_callback_async result, callback
            return unless retry_thread_pool.running?
            Concurrent::Promises.future_on(
              callback_thread_pool, result, callback, &method(:perform_callback_sync)
            )
          end

          def perform_callback_sync result, callback
            begin
              callback.call result unless stopped?
            rescue StandardError => e
              @subscriber.error! e
            end
          end

          def perform_retry_async ack_ids, ack_deadline_seconds = nil
            return unless retry_thread_pool.running?
            Concurrent::Promises.future_on(
              retry_thread_pool, ack_ids, ack_deadline_seconds, &method(:retry_transient_error)
            )
          end

          def retry_transient_error ack_ids, ack_deadline_seconds
            if ack_deadline_seconds.nil?
              retry_request ack_ids, ack_deadline_seconds.nil? do |retry_ack_ids|
                @subscriber.service.acknowledge subscription_name, *retry_ack_ids
                handle_callback AcknowledgeResult.new AcknowledgeResult::SUCCESS, retry_ack_ids
              end
            else
              retry_request ack_ids, ack_deadline_seconds.nil? do |retry_ack_ids|
                @subscriber.service.modify_ack_deadline subscription_name, retry_ack_ids, ack_deadline_seconds
                handle_callback AcknowledgeResult.new AcknowledgeResult::SUCCESS, retry_ack_ids, modack: true
              end
            end
          end

          def retry_request ack_ids, modack
            begin
              Retriable.retriable tries: MAX_TRIES,
                                  base_interval: BASE_INTERVAL,
                                  max_interval: MAX_INTERVAL,
                                  multiplier: MULTIPLIER,
                                  max_elapsed_time: MAX_RETRY_DURATION,
                                  on: EXACTLY_ONCE_DELIVERY_POSSIBLE_RETRIABLE_ERRORS do
                return if ack_ids.nil?
                begin
                  yield ack_ids
                rescue Google::Cloud::InvalidArgumentError => e
                  error_ack_ids = parse_error e.error_metadata, modack: modack
                  unless error_ack_ids.nil?
                    handle_callback AcknowledgeResult.new(AcknowledgeResult::SUCCESS),
                                    ack_ids - error_ack_ids,
                                    modack: modack
                  end
                  ack_ids = error_ack_ids
                  raise e
                end
              end
            rescue StandardError => e
              handle_callback e, ack_ids, modack: modack
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
