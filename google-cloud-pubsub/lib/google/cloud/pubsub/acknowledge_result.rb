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
      # The result of a ack/nack/modack on messages.
      #
      # When the operation was successful the result will be marked
      # {#succeeded?}. Otherwise, the result will be marked {#failed?} and the
      # error raised will be availabe on {#error}.
      #
      class AcknowledgeResult
        ##
        # The constants below represents the status of ack/modack operations.
        # Indicates successful ack/modack
        SUCCESS = 1

        ##
        # Indicates occurence of permenant permission denied error
        PERMISSION_DENIED = 2

        ##
        # Indicates occurence of permenant failed precondition error
        FAILED_PRECONDITION = 3

        ##
        # Indicates occurence of permenant permission denied error
        INVALID_ACK_ID = 4

        ##
        # Indicates occurence of permenant uncatogorised error
        OTHER = 5

        ##
        # @return [Google::Cloud::Error] Error object of ack/modack operation
        attr_reader :error

        ##
        # @return [Numeric] Status of the ack/modack operation.
        attr_reader :status

        ##
        # @private Create an PublishResult object.
        def initialize status, error = nil
          @error = error
          @status = status
        end

        ##
        # @return [Boolean] Whether the operation was successful.
        def succeeded?
          @status == SUCCESS
        end

        ##
        # @return [Boolean] Whether the operation failed.
        def failed?
          !succeeded?
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
