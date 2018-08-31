# Copyright 2018 Google LLC
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
    module Asset
      module V1beta1
        # Temporal asset. In addition to the asset, the temporal asset includes the
        # status of the asset and valid from and to time of it.
        # @!attribute [rw] window
        #   @return [Google::Cloud::Asset::V1beta1::TimeWindow]
        #     The time window when the asset data and state was observed.
        # @!attribute [rw] deleted
        #   @return [true, false]
        #     If the asset is deleted or not.
        # @!attribute [rw] asset
        #   @return [Google::Cloud::Asset::V1beta1::Asset]
        #     Asset.
        class TemporalAsset; end

        # A time window of [start_time, end_time).
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Start time of the time window (inclusive).
        #     Infinite past if not specified.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     End time of the time window (exclusive).
        #     Infinite future if not specified.
        class TimeWindow; end

        # Cloud asset. This include all Google Cloud Platform resources, as well as
        # IAM policies and other non-GCP assets.
        # @!attribute [rw] name
        #   @return [String]
        #     The full name of the asset. See:
        #     https://cloud.google.com/apis/design/resource_names#full_resource_name
        #     Example:
        #     "//compute.googleapis.com/projects/my_project_123/zones/zone1/instances/instance1".
        # @!attribute [rw] asset_type
        #   @return [String]
        #     Type of the asset. Example: "google.compute.disk".
        # @!attribute [rw] resource
        #   @return [Google::Cloud::Asset::V1beta1::Resource]
        #     Representation of the resource.
        # @!attribute [rw] iam_policy
        #   @return [Google::Iam::V1::Policy]
        #     Representation of the actual IAM policy set on a cloud resource. For each
        #     resource, there must be at most one IAM policy set on it.
        class Asset; end

        # Representation of a cloud resource.
        # @!attribute [rw] version
        #   @return [String]
        #     The API version. Example: "v1".
        # @!attribute [rw] discovery_document_uri
        #   @return [String]
        #     The URL of the discovery document containing the resource's JSON schema.
        #     Example:
        #     "https://www.googleapis.com/discovery/v1/apis/compute/v1/rest".
        #     It will be left unspecified for resources without a discovery-based API,
        #     such as Cloud Bigtable.
        # @!attribute [rw] discovery_name
        #   @return [String]
        #     The JSON schema name listed in the discovery document.
        #     Example: "Project". It will be left unspecified for resources (such as
        #     Cloud Bigtable) without a discovery-based API.
        # @!attribute [rw] resource_url
        #   @return [String]
        #     The REST URL for accessing the resource. An HTTP GET operation using this
        #     URL returns the resource itself.
        #     Example:
        #     +https://cloudresourcemanager.googleapis.com/v1/projects/my-project-123+.
        #     It will be left unspecified for resources without a REST API.
        # @!attribute [rw] parent
        #   @return [String]
        #     The full name of the immediate parent of this resource. See:
        #     https://cloud.google.com/apis/design/resource_names#full_resource_name
        #
        #     For GCP assets, it is the parent resource defined in the IAM policy
        #     hierarchy: https://cloud.google.com/iam/docs/overview#policy_hierarchy.
        #     Example: "//cloudresourcemanager.googleapis.com/projects/my_project_123".
        #
        #     For third-party assets, it is up to the users to define.
        # @!attribute [rw] data
        #   @return [Google::Protobuf::Struct]
        #     The content of the resource, in which some sensitive fields are scrubbed
        #     away and may not be present.
        class Resource; end
      end
    end
  end
end