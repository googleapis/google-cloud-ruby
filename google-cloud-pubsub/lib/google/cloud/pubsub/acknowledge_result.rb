# Copyright 2022 Google LLC
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


module Google
  module Cloud
    module PubSub
      ##
      # The result of a ack/nack/modack on messages. The message object is available on
      # {#message} and will have {#message_id} assigned by the API.
      #
      # When the operation was successful the result will be marked
      # {#succeeded?}. Otherwise, the result will be marked {#failed?} and the
      # error raised will be availabe on {#error}.
      #
      class AcknowledgeResult
        SUCCESS = 1
        PERMISSION_DENIED = 2
        FAILED_PRECONDITION = 3
        INVALID_ACK_ID = 4
        OTHER = 5

        attr_reader :error
        attr_reader :status

        ##
        # @private Create an PublishResult object.
        def initialize status, error = nil
          @error = error
          @status = status
        end

        ##
        # Whether the operation was successful.
        def succeeded?
          @status == SUCCESS
        end

        # Whether the operation failed.
        def failed?
          !succeeded?
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
