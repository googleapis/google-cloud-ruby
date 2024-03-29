# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/bigquery/datapolicies/v1/datapolicy.proto for package 'Google.Cloud.Bigquery.DataPolicies.V1'
# Original file comments:
# Copyright 2022 Google LLC
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
require 'google/cloud/bigquery/datapolicies/v1/datapolicy_pb'

module Google
  module Cloud
    module Bigquery
      module DataPolicies
        module V1
          module DataPolicyService
            # Data Policy Service provides APIs for managing the label-policy bindings.
            class Service

              include ::GRPC::GenericService

              self.marshal_class_method = :encode
              self.unmarshal_class_method = :decode
              self.service_name = 'google.cloud.bigquery.datapolicies.v1.DataPolicyService'

              # Creates a new data policy under a project with the given `dataPolicyId`
              # (used as the display name), policy tag, and data policy type.
              rpc :CreateDataPolicy, ::Google::Cloud::Bigquery::DataPolicies::V1::CreateDataPolicyRequest, ::Google::Cloud::Bigquery::DataPolicies::V1::DataPolicy
              # Updates the metadata for an existing data policy. The target data policy
              # can be specified by the resource name.
              rpc :UpdateDataPolicy, ::Google::Cloud::Bigquery::DataPolicies::V1::UpdateDataPolicyRequest, ::Google::Cloud::Bigquery::DataPolicies::V1::DataPolicy
              # Renames the id (display name) of the specified data policy.
              rpc :RenameDataPolicy, ::Google::Cloud::Bigquery::DataPolicies::V1::RenameDataPolicyRequest, ::Google::Cloud::Bigquery::DataPolicies::V1::DataPolicy
              # Deletes the data policy specified by its resource name.
              rpc :DeleteDataPolicy, ::Google::Cloud::Bigquery::DataPolicies::V1::DeleteDataPolicyRequest, ::Google::Protobuf::Empty
              # Gets the data policy specified by its resource name.
              rpc :GetDataPolicy, ::Google::Cloud::Bigquery::DataPolicies::V1::GetDataPolicyRequest, ::Google::Cloud::Bigquery::DataPolicies::V1::DataPolicy
              # List all of the data policies in the specified parent project.
              rpc :ListDataPolicies, ::Google::Cloud::Bigquery::DataPolicies::V1::ListDataPoliciesRequest, ::Google::Cloud::Bigquery::DataPolicies::V1::ListDataPoliciesResponse
              # Gets the IAM policy for the specified data policy.
              rpc :GetIamPolicy, ::Google::Iam::V1::GetIamPolicyRequest, ::Google::Iam::V1::Policy
              # Sets the IAM policy for the specified data policy.
              rpc :SetIamPolicy, ::Google::Iam::V1::SetIamPolicyRequest, ::Google::Iam::V1::Policy
              # Returns the caller's permission on the specified data policy resource.
              rpc :TestIamPermissions, ::Google::Iam::V1::TestIamPermissionsRequest, ::Google::Iam::V1::TestIamPermissionsResponse
            end

            Stub = Service.rpc_stub_class
          end
        end
      end
    end
  end
end
