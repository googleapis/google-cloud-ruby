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

# @private
# This file is a patch that removes data plane operations from the
# admin plane clients. This is to prevent confusion and misuse
# of the admin clients for data plane operations.
module Google
  module Cloud
    module PubSub
      module V1
        module TopicAdmin
          class Client
            # @private
            alias publish_internal publish

            # The `publish` method is a data plane operation.
            # Use Google::Cloud::PubSub::Publisher instead.
            # @raise [NotImplementedError]
            def publish *args, **kwargs
              raise NotImplementedError,
                    "The `publish` method is a data plane operation. " \
                    "Use Google::Cloud::PubSub::Publisher instead."
            end
          end
        end

        module SubscriptionAdmin
          class Client
            # @private
            alias modify_ack_deadline_internal modify_ack_deadline
            # @private
            alias acknowledge_internal acknowledge
            # @private
            alias pull_internal pull
            # @private
            alias streaming_pull_internal streaming_pull

            # The `modify_ack_deadline` method is a data plane operation.
            # Use Google::Cloud::PubSub::Subscriber instead.
            # @raise [NotImplementedError]
            def modify_ack_deadline *args, **kwargs
              raise NotImplementedError,
                    "The `modify_ack_deadline` method is a data plane operation. " \
                    "Use Google::Cloud::PubSub::Subscriber instead."
            end

            # The `acknowledge` method is a data plane operation.
            # Use Google::Cloud::PubSub::Subscriber instead.
            # @raise [NotImplementedError]
            def acknowledge *args, **kwargs
              raise NotImplementedError,
                    "The `acknowledge` method is a data plane operation. " \
                    "Use Google::Cloud::PubSub::Subscriber instead."
            end

            # The `pull` method is a data plane operation.
            # Use Google::Cloud::PubSub::Subscriber instead.
            # @raise [NotImplementedError]
            def pull *args, **kwargs
              raise NotImplementedError,
                    "The `pull` method is a data plane operation. " \
                    "Use Google::Cloud::PubSub::Subscriber instead."
            end

            # The `streaming_pull` method is a data plane operation.
            # Use Google::Cloud::PubSub::Subscriber instead.
            # @raise [NotImplementedError]
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
end
