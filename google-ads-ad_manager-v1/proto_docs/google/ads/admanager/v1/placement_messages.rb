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
        # The `Placement` resource.
        # @!attribute [rw] name
        #   @return [::String]
        #     Identifier. The resource name of the `Placement`.
        #     Format: `networks/{network_code}/placements/{placement_id}`
        # @!attribute [r] placement_id
        #   @return [::Integer]
        #     Output only. `Placement` ID.
        # @!attribute [rw] display_name
        #   @return [::String]
        #     Required. The display name of the placement. This attribute has a maximum
        #     length of 255 characters.
        # @!attribute [rw] description
        #   @return [::String]
        #     Optional. A description of the Placement. This attribute has a maximum
        #     length of 65,535 characters.
        # @!attribute [r] placement_code
        #   @return [::String]
        #     Output only. A string used to uniquely identify the Placement for purposes
        #     of serving the ad. This attribute is assigned by Google.
        # @!attribute [r] status
        #   @return [::Google::Ads::AdManager::V1::PlacementStatusEnum::PlacementStatus]
        #     Output only. The status of the Placement.
        # @!attribute [rw] targeted_ad_units
        #   @return [::Array<::String>]
        #     Optional. The resource names of AdUnits that constitute the Placement.
        #     Format: "networks/\\{network_code}/adUnits/\\{ad_unit}"
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The instant this Placement was last modified.
        class Placement
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
