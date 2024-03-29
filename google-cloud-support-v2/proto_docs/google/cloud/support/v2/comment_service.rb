# frozen_string_literal: true

# Copyright 2023 Google LLC
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
    module Support
      module V2
        # The request message for the ListComments endpoint.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The resource name of Case object for which comments should be
        #     listed.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     The maximum number of comments fetched with each request. Defaults to 10.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     A token identifying the page of results to return. If unspecified, the
        #     first page is retrieved.
        class ListCommentsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response message for the ListComments endpoint.
        # @!attribute [rw] comments
        #   @return [::Array<::Google::Cloud::Support::V2::Comment>]
        #     The list of Comments associated with the given Case.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token to retrieve the next page of results. This should be set in the
        #     `page_token` field of subsequent `ListCommentsRequest` message that is
        #     issued. If unspecified, there are no more results to retrieve.
        class ListCommentsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request message for CreateComment endpoint.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The resource name of Case to which this comment should be added.
        # @!attribute [rw] comment
        #   @return [::Google::Cloud::Support::V2::Comment]
        #     Required. The Comment object to be added to this Case.
        class CreateCommentRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
