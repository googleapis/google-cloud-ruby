# frozen_string_literal: true

# Copyright 2024 Google LLC
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
  module Ads
    module AdManager
      module V1
        # Represents the dimensions of an AdUnit, LineItem, or Creative.
        # @!attribute [rw] width
        #   @return [::Integer]
        #     Required. The width of the Creative,
        #     {::Google::Ads::AdManager::V1::AdUnit AdUnit}, or LineItem.
        # @!attribute [rw] height
        #   @return [::Integer]
        #     Required. The height of the Creative,
        #     {::Google::Ads::AdManager::V1::AdUnit AdUnit}, or LineItem.
        # @!attribute [rw] size_type
        #   @return [::Google::Ads::AdManager::V1::SizeTypeEnum::SizeType]
        #     Required. The SizeType of the Creative,
        #     {::Google::Ads::AdManager::V1::AdUnit AdUnit}, or LineItem.
        class Size
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
