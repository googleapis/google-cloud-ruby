# frozen_string_literal: true

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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module AIPlatform
      module V1
        # Generic Metadata shared by all operations.
        # @!attribute [r] partial_failures
        #   @return [::Array<::Google::Rpc::Status>]
        #     Output only. Partial failures encountered.
        #     E.g. single files that couldn't be read.
        #     This field should never exceed 20 entries.
        #     Status details field will contain standard Google Cloud error details.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Time when the operation was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Time when the operation was updated for the last time.
        #     If the operation has finished (successfully or not), this is the finish
        #     time.
        class GenericOperationMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Details of operations that perform deletes of any entities.
        # @!attribute [rw] generic_metadata
        #   @return [::Google::Cloud::AIPlatform::V1::GenericOperationMetadata]
        #     The common part of the operation metadata.
        class DeleteOperationMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
