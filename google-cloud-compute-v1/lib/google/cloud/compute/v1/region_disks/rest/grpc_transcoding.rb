# frozen_string_literal: true

# Copyright 2021 Google LLC
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
    module Compute
      module V1
        module RegionDisks
          module Rest
            # GRPC transcoding helper methods for the RegionDisks REST API.
            module GrpcTranscoding
              # @param request_pb [::Google::Cloud::Compute::V1::AddResourcePoliciesRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_add_resource_policies request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}/addResourcePolicies"
                body = request_pb.region_disks_add_resource_policies_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::CreateSnapshotRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_create_snapshot request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}/createSnapshot"
                body = request_pb.snapshot_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::DeleteRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_delete request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}"
                body = nil
                query_string_params = {}
                query_string_params["requestId"] = request_pb.request_id.to_s if request_pb.request_id && request_pb.request_id != ""

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::GetRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_get request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}"
                body = nil
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::GetIamPolicyRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_get_iam_policy request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.resource}/getIamPolicy"
                body = nil
                query_string_params = {}
                query_string_params["optionsRequestedPolicyVersion"] = request_pb.options_requested_policy_version.to_s if request_pb.options_requested_policy_version && request_pb.options_requested_policy_version != 0

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::InsertRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_insert request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks"
                body = request_pb.disk_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::ListRegionDisksRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_list request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks"
                body = nil
                query_string_params = {}
                query_string_params["filter"] = request_pb.filter.to_s if request_pb.filter && request_pb.filter != ""
                query_string_params["maxResults"] = request_pb.max_results.to_s if request_pb.max_results && request_pb.max_results != 0
                query_string_params["orderBy"] = request_pb.order_by.to_s if request_pb.order_by && request_pb.order_by != ""
                query_string_params["pageToken"] = request_pb.page_token.to_s if request_pb.page_token && request_pb.page_token != ""
                query_string_params["returnPartialSuccess"] = request_pb.return_partial_success.to_s if request_pb.return_partial_success && request_pb.return_partial_success != false

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::RemoveResourcePoliciesRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_remove_resource_policies request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}/removeResourcePolicies"
                body = request_pb.region_disks_remove_resource_policies_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::ResizeRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_resize request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.disk}/resize"
                body = request_pb.region_disks_resize_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::SetIamPolicyRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_set_iam_policy request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.resource}/setIamPolicy"
                body = request_pb.region_set_policy_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::SetLabelsRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_set_labels request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.resource}/setLabels"
                body = request_pb.region_set_labels_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end

              # @param request_pb [::Google::Cloud::Compute::V1::TestIamPermissionsRegionDiskRequest]
              #   A request object representing the call parameters. Required.
              # @return [Array(String, [String, nil], Hash{String => String})]
              #   Uri, Body, Query string parameters
              def transcode_test_iam_permissions request_pb
                uri = "/compute/v1/projects/#{request_pb.project}/regions/#{request_pb.region}/disks/#{request_pb.resource}/testIamPermissions"
                body = request_pb.test_permissions_request_resource.to_json
                query_string_params = {}

                [uri, body, query_string_params]
              end
              extend self
            end
          end
        end
      end
    end
  end
end
