# Copyright 2020 Google LLC
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
    module Securitycenter
      module V1
        # Cloud Security Command Center's (Cloud SCC) representation of a Google Cloud
        # Platform (GCP) resource.
        #
        # The Asset is a Cloud SCC resource that captures information about a single
        # GCP resource. All modifications to an Asset are only within the context of
        # Cloud SCC and don't affect the referenced GCP resource.
        # @!attribute [rw] name
        #   @return [String]
        #     The relative resource name of this asset. See:
        #     https://cloud.google.com/apis/design/resource_names#relative_resource_name
        #     Example:
        #     "organizations/{organization_id}/assets/{asset_id}".
        # @!attribute [rw] security_center_properties
        #   @return [Google::Cloud::SecurityCenter::V1::Asset::SecurityCenterProperties]
        #     Cloud SCC managed properties. These properties are managed by
        #     Cloud SCC and cannot be modified by the user.
        # @!attribute [rw] resource_properties
        #   @return [Hash{String => Google::Protobuf::Value}]
        #     Resource managed properties. These properties are managed and defined by
        #     the GCP resource and cannot be modified by the user.
        # @!attribute [rw] security_marks
        #   @return [Google::Cloud::SecurityCenter::V1::SecurityMarks]
        #     User specified security marks. These marks are entirely managed by the user
        #     and come from the SecurityMarks resource that belongs to the asset.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the asset was created in Cloud SCC.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the asset was last updated, added, or deleted in Cloud
        #     SCC.
        # @!attribute [rw] iam_policy
        #   @return [Google::Cloud::SecurityCenter::V1::Asset::IamPolicy]
        #     IAM Policy information associated with the GCP resource described by the
        #     Cloud SCC asset. This information is managed and defined by the GCP
        #     resource and cannot be modified by the user.
        class Asset
          # Cloud SCC managed properties. These properties are managed by Cloud SCC and
          # cannot be modified by the user.
          # @!attribute [rw] resource_name
          #   @return [String]
          #     The full resource name of the GCP resource this asset
          #     represents. This field is immutable after create time. See:
          #     https://cloud.google.com/apis/design/resource_names#full_resource_name
          # @!attribute [rw] resource_type
          #   @return [String]
          #     The type of the GCP resource. Examples include: APPLICATION,
          #     PROJECT, and ORGANIZATION. This is a case insensitive field defined by
          #     Cloud SCC and/or the producer of the resource and is immutable
          #     after create time.
          # @!attribute [rw] resource_parent
          #   @return [String]
          #     The full resource name of the immediate parent of the resource. See:
          #     https://cloud.google.com/apis/design/resource_names#full_resource_name
          # @!attribute [rw] resource_project
          #   @return [String]
          #     The full resource name of the project the resource belongs to. See:
          #     https://cloud.google.com/apis/design/resource_names#full_resource_name
          # @!attribute [rw] resource_owners
          #   @return [Array<String>]
          #     Owners of the Google Cloud resource.
          # @!attribute [rw] resource_display_name
          #   @return [String]
          #     The user defined display name for this resource.
          # @!attribute [rw] resource_parent_display_name
          #   @return [String]
          #     The user defined display name for the parent of this resource.
          # @!attribute [rw] resource_project_display_name
          #   @return [String]
          #     The user defined display name for the project of this resource.
          class SecurityCenterProperties; end

          # IAM Policy information associated with the GCP resource described by the
          # Cloud SCC asset. This information is managed and defined by the GCP
          # resource and cannot be modified by the user.
          # @!attribute [rw] policy_blob
          #   @return [String]
          #     The JSON representation of the Policy associated with the asset.
          #     See https://cloud.google.com/iam/reference/rest/v1/Policy for format
          #     details.
          class IamPolicy; end
        end
      end
    end
  end
end