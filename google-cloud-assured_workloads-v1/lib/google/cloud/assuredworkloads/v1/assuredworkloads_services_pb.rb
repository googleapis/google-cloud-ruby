# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/assuredworkloads/v1/assuredworkloads.proto for package 'Google.Cloud.AssuredWorkloads.V1'
# Original file comments:
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'grpc'
require 'google/cloud/assuredworkloads/v1/assuredworkloads_pb'

module Google
  module Cloud
    module AssuredWorkloads
      module V1
        module AssuredWorkloadsService
          # Service to manage AssuredWorkloads.
          class Service

            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.assuredworkloads.v1.AssuredWorkloadsService'

            # Creates Assured Workload.
            rpc :CreateWorkload, ::Google::Cloud::AssuredWorkloads::V1::CreateWorkloadRequest, ::Google::Longrunning::Operation
            # Updates an existing workload.
            # Currently allows updating of workload display_name and labels.
            # For force updates don't set etag field in the Workload.
            # Only one update operation per workload can be in progress.
            rpc :UpdateWorkload, ::Google::Cloud::AssuredWorkloads::V1::UpdateWorkloadRequest, ::Google::Cloud::AssuredWorkloads::V1::Workload
            # Restrict the list of resources allowed in the Workload environment.
            # The current list of allowed products can be found at
            # https://cloud.google.com/assured-workloads/docs/supported-products
            # In addition to assuredworkloads.workload.update permission, the user should
            # also have orgpolicy.policy.set permission on the folder resource
            # to use this functionality.
            rpc :RestrictAllowedResources, ::Google::Cloud::AssuredWorkloads::V1::RestrictAllowedResourcesRequest, ::Google::Cloud::AssuredWorkloads::V1::RestrictAllowedResourcesResponse
            # Deletes the workload. Make sure that workload's direct children are already
            # in a deleted state, otherwise the request will fail with a
            # FAILED_PRECONDITION error.
            rpc :DeleteWorkload, ::Google::Cloud::AssuredWorkloads::V1::DeleteWorkloadRequest, ::Google::Protobuf::Empty
            # Gets Assured Workload associated with a CRM Node
            rpc :GetWorkload, ::Google::Cloud::AssuredWorkloads::V1::GetWorkloadRequest, ::Google::Cloud::AssuredWorkloads::V1::Workload
            # Lists Assured Workloads under a CRM Node.
            rpc :ListWorkloads, ::Google::Cloud::AssuredWorkloads::V1::ListWorkloadsRequest, ::Google::Cloud::AssuredWorkloads::V1::ListWorkloadsResponse
            # Lists the Violations in the AssuredWorkload Environment.
            # Callers may also choose to read across multiple Workloads as per
            # [AIP-159](https://google.aip.dev/159) by using '-' (the hyphen or dash
            # character) as a wildcard character instead of workload-id in the parent.
            # Format `organizations/{org_id}/locations/{location}/workloads/-`
            rpc :ListViolations, ::Google::Cloud::AssuredWorkloads::V1::ListViolationsRequest, ::Google::Cloud::AssuredWorkloads::V1::ListViolationsResponse
            # Retrieves Assured Workload Violation based on ID.
            rpc :GetViolation, ::Google::Cloud::AssuredWorkloads::V1::GetViolationRequest, ::Google::Cloud::AssuredWorkloads::V1::Violation
            # Acknowledges an existing violation. By acknowledging a violation, users
            # acknowledge the existence of a compliance violation in their workload and
            # decide to ignore it due to a valid business justification. Acknowledgement
            # is a permanent operation and it cannot be reverted.
            rpc :AcknowledgeViolation, ::Google::Cloud::AssuredWorkloads::V1::AcknowledgeViolationRequest, ::Google::Cloud::AssuredWorkloads::V1::AcknowledgeViolationResponse
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
