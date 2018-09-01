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
        # Export asset request.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The relative name of the root asset. Can only be an organization
        #     number (such as "organizations/123"), or a project id (such as
        #     "projects/my-project-id") or a project number (such as "projects/12345").
        # @!attribute [rw] read_time
        #   @return [Google::Protobuf::Timestamp]
        #     Timestamp to take an asset snapshot. This can only be set to a timestamp in
        #     the past or of the current time. If not specified, the current time will be
        #     used. Due to delays in resource data collection and indexing, there is a
        #     volatile window during which running the same query may get different
        #     results.
        # @!attribute [rw] asset_types
        #   @return [Array<String>]
        #     A list of asset types of which to take a snapshot for. Example:
        #     "google.compute.disk". If specified, only matching assets will be returned.
        # @!attribute [rw] content_type
        #   @return [Google::Cloud::Asset::V1beta1::ContentType]
        #     Asset content type. If not specified, no content but the asset name will be
        #     returned.
        # @!attribute [rw] output_config
        #   @return [Google::Cloud::Asset::V1beta1::OutputConfig]
        #     Required. Output configuration indicating where the results will be output
        #     to. All results will be in newline delimited JSON format.
        class ExportAssetsRequest; end

        # The export asset response. This message is returned by the
        # {Google::Longrunning::Operations::GetOperation} method in the returned
        # {Google::Longrunning::Operation#response} field.
        # @!attribute [rw] read_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time the snapshot was taken.
        # @!attribute [rw] output_config
        #   @return [Google::Cloud::Asset::V1beta1::OutputConfig]
        #     Output configuration indicating where the results were output to.
        #     All results are in JSON format.
        class ExportAssetsResponse; end

        # Batch get assets history request.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The relative name of the root asset. It can only be an
        #     organization number (such as "organizations/123"), or a project id (such as
        #     "projects/my-project-id")"or a project number (such as "projects/12345").
        # @!attribute [rw] asset_names
        #   @return [Array<String>]
        #     A list of the full names of the assets. See:
        #     https://cloud.google.com/apis/design/resource_names#full_resource_name
        #     Example:
        #     "//compute.googleapis.com/projects/my_project_123/zones/zone1/instances/instance1".
        #
        #     The request becomes a no-op if the asset name list is empty, and the max
        #     size of the asset name list is 100 in one request.
        # @!attribute [rw] content_type
        #   @return [Google::Cloud::Asset::V1beta1::ContentType]
        #     Required. The content type.
        # @!attribute [rw] read_time_window
        #   @return [Google::Cloud::Asset::V1beta1::TimeWindow]
        #     Required. The time window for the asset history. The start time is
        #     required. The returned results contain all temporal assets whose time
        #     window overlap with read_time_window.
        class BatchGetAssetsHistoryRequest; end

        # Batch get assets history response.
        # @!attribute [rw] assets
        #   @return [Array<Google::Cloud::Asset::V1beta1::TemporalAsset>]
        #     A list of assets with valid time windows.
        class BatchGetAssetsHistoryResponse; end

        # Output configuration for export assets destination.
        # @!attribute [rw] gcs_destination
        #   @return [Google::Cloud::Asset::V1beta1::GcsDestination]
        #     Destination on Google Cloud Storage (GCS).
        class OutputConfig; end

        # A Google Cloud Storage (GCS) location.
        # @!attribute [rw] uri
        #   @return [String]
        #     The path of the GCS objects. It's the same path that is used by gsutil, for
        #     example: "gs://bucket_name/object_path". See:
        #     https://cloud.google.com/storage/docs/viewing-editing-metadata for more
        #     information.
        class GcsDestination; end

        # Asset content type.
        module ContentType
          # Unspecified content type.
          CONTENT_TYPE_UNSPECIFIED = 0

          # Resource metadata.
          RESOURCE = 1

          # The actual IAM policy set on a resource.
          IAM_POLICY = 2
        end
      end
    end
  end
end