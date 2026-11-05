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

require "google/cloud/pubsub/v1/topic_admin/client"
require "google/cloud/pubsub/v1/subscription_admin/client"

module Google
  module Cloud
    module PubSub
      module TopicAdmin
        ##
        # The TopicAdmin client is used to manage topics.
        #
        # This client is a subclass of the auto-generated TopicAdmin client, and provides
        # the same methods. However, it raises errors on data plane operations
        # to prevent misuse.
        #
        class Client < Google::Cloud::PubSub::V1::TopicAdmin::Client
          THREAD_ATTEMPT_HANDLE_KEY = :pubsub_attempt_handle
          private_constant :THREAD_ATTEMPT_HANDLE_KEY

          # @private
          alias publish_internal publish

          # @private
          def self.current_attempt_handle
            Thread.current[THREAD_ATTEMPT_HANDLE_KEY]
          end

          # @private
          def self.with_attempt_handle attempt_handle
            prev_handle = Thread.current[THREAD_ATTEMPT_HANDLE_KEY]
            Thread.current[THREAD_ATTEMPT_HANDLE_KEY] = attempt_handle
            begin
              yield
            ensure
              attempt_handle&.clear_operation
              Thread.current[THREAD_ATTEMPT_HANDLE_KEY] = prev_handle
            end
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

          # @private
          def ensure_publish_operation_hook!
            return if @publish_operation_hook_installed

            @publish_operation_hook_mutex ||= Mutex.new
            @publish_operation_hook_mutex.synchronize do
              return if @publish_operation_hook_installed

              if @topic_admin_stub.respond_to?(:grpc_stub) && @topic_admin_stub.grpc_stub
                grpc_stub = @topic_admin_stub.grpc_stub
                if grpc_stub.respond_to? :publish
                  grpc_stub.define_singleton_method :publish do |*args, **kwargs, &blk|
                    op = super(*args, **kwargs, &blk)
                    handle = Client.current_attempt_handle
                    handle.register_operation op if handle && kwargs[:return_op]
                    op
                  end
                end
              end

              @publish_operation_hook_installed = true
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
