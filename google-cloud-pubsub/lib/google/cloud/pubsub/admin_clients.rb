# Copyright 2025 Google LLC
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

require "gapic/call_options"
require "google/cloud/pubsub/v1/topic_admin/client"
require "google/cloud/pubsub/v1/subscription_admin/client"
require "google/cloud/pubsub/async_publisher/cancellation_sharer"

module Google
  module Cloud
    module PubSub
      module TopicAdmin
        ##
        # @private
        # Retry policy for publish RPC attempts that supports per-attempt
        # cancellation and interruptible backoff sleep without modifying gapic-common.
        #
        class CancellableRetryPolicy < ::Gapic::CallOptions::RetryPolicy
          attr_reader :attempt_handle

          def initialize attempt_handle: nil, **kwargs
            @attempt_handle = attempt_handle
            super(**kwargs)
          end

          def apply_defaults retry_policy
            super
            @delay = initial_delay if @perform_delay_count.zero?
            self
          end

          def retry_error? error
            return false if @attempt_handle&.cancelled?
            return false if error.is_a? AsyncPublisher::AttemptCancelledError

            super
          end

          def dup
            self.class.new attempt_handle: @attempt_handle,
                           initial_delay: @initial_delay,
                           max_delay: @max_delay,
                           multiplier: @multiplier,
                           retry_codes: @retry_codes,
                           jitter: @jitter
          end

          def eql? other
            super && other.is_a?(CancellableRetryPolicy) && other.attempt_handle == @attempt_handle
          end
          alias == eql?

          def hash
            [super, @attempt_handle].hash
          end

          private

          def delay!
            delay_to_perform = [delay + Kernel.rand(0.0..jitter), max_delay].min
            if @attempt_handle
              @attempt_handle.sleep_interruptibly delay_to_perform
            else
              super
            end
          end
        end

        ##
        # The TopicAdmin client is used to manage topics.
        #
        # This client is a subclass of the auto-generated TopicAdmin client, and provides
        # the same methods. However, it raises errors on data plane operations
        # to prevent misuse.
        #
        class Client < Google::Cloud::PubSub::V1::TopicAdmin::Client
          # @private
          THREAD_ATTEMPT_HANDLE_KEY = :pubsub_attempt_handle

          # @private
          alias publish_internal publish

          # @private
          def initialize
            super
            install_publish_operation_hook!
          end

          ##
          # The `publish` method is a data plane operation.
          #
          # @raise [NotImplementedError] This method is not implemented on the
          #   admin client. Use {Google::Cloud::PubSub::Publisher} instead.
          #
          def publish *args, **kwargs
            raise NotImplementedError,
                  "The `publish` method is a data plane operation. " \
                  "Use Google::Cloud::PubSub::Publisher instead."
          end

          private

          def install_publish_operation_hook!
            return unless @topic_admin_stub.respond_to?(:grpc_stub) && @topic_admin_stub.grpc_stub

            grpc_stub = @topic_admin_stub.grpc_stub
            return unless grpc_stub.respond_to? :publish

            grpc_stub.define_singleton_method :publish do |*args, **kwargs, &blk|
              op = super(*args, **kwargs, &blk)
              handle = Thread.current[THREAD_ATTEMPT_HANDLE_KEY]
              handle.register_operation op if handle && kwargs[:return_op]
              op
            end
          end
        end
      end

      module SubscriptionAdmin
        ##
        # The SubscriptionAdmin client is used to manage subscriptions.
        #
        # This client is a subclass of the auto-generated SubscriptionAdmin client, and
        # provides the same methods. However, it raises errors on data plane
        # operations to prevent misuse.
        #
        class Client < Google::Cloud::PubSub::V1::SubscriptionAdmin::Client
          # @private
          alias modify_ack_deadline_internal modify_ack_deadline
          # @private
          alias acknowledge_internal acknowledge
          # @private
          alias pull_internal pull
          # @private
          alias streaming_pull_internal streaming_pull

          ##
          # The `modify_ack_deadline` method is a data plane operation.
          #
          # @raise [NotImplementedError] This method is not implemented on the
          #   admin client. Use {Google::Cloud::PubSub::Subscriber} instead.
          #
          def modify_ack_deadline *args, **kwargs
            raise NotImplementedError,
                  "The `modify_ack_deadline` method is a data plane operation. " \
                  "Use Google::Cloud::PubSub::Subscriber instead."
          end

          ##
          # The `acknowledge` method is a data plane operation.
          #
          # @raise [NotImplementedError] This method is not implemented on the
          #   admin client. Use {Google::Cloud::PubSub::Subscriber} instead.
          #
          def acknowledge *args, **kwargs
            raise NotImplementedError,
                  "The `acknowledge` method is a data plane operation. " \
                  "Use Google::Cloud::PubSub::Subscriber instead."
          end

          ##
          # The `pull` method is a data plane operation.
          #
          # @raise [NotImplementedError] This method is not implemented on the
          #   admin client. Use {Google::Cloud::PubSub::Subscriber} instead.
          #
          def pull *args, **kwargs
            raise NotImplementedError,
                  "The `pull` method is a data plane operation. " \
                  "Use Google::Cloud::PubSub::Subscriber instead."
          end

          ##
          # The `streaming_pull` method is a data plane operation.
          #
          # @raise [NotImplementedError] This method is not implemented on the
          #   admin client. Use {Google::Cloud::PubSub::Subscriber} instead.
          #
          def streaming_pull *args, **kwargs
            raise NotImplementedError,
                  "The `streaming_pull` method is a data plane operation. " \
                  "Use Google::Cloud::PubSub::Subscriber instead."
          end
        end
      end
    end
  end
end
