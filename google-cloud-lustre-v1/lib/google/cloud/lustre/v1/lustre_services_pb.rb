# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/lustre/v1/lustre.proto for package 'google.cloud.lustre.v1'
# Original file comments:
# Copyright 2025 Google LLC
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
require 'google/cloud/lustre/v1/lustre_pb'

module Google
  module Cloud
    module Lustre
      module V1
        module Lustre
          # Service describing handlers for resources
          class Service

            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.lustre.v1.Lustre'

            # Lists instances in a given project and location.
            rpc :ListInstances, ::Google::Cloud::Lustre::V1::ListInstancesRequest, ::Google::Cloud::Lustre::V1::ListInstancesResponse
            # Gets details of a single instance.
            rpc :GetInstance, ::Google::Cloud::Lustre::V1::GetInstanceRequest, ::Google::Cloud::Lustre::V1::Instance
            # Creates a new instance in a given project and location.
            rpc :CreateInstance, ::Google::Cloud::Lustre::V1::CreateInstanceRequest, ::Google::Longrunning::Operation
            # Updates the parameters of a single instance.
            rpc :UpdateInstance, ::Google::Cloud::Lustre::V1::UpdateInstanceRequest, ::Google::Longrunning::Operation
            # Deletes a single instance.
            rpc :DeleteInstance, ::Google::Cloud::Lustre::V1::DeleteInstanceRequest, ::Google::Longrunning::Operation
            # Imports data from Cloud Storage to a Managed Lustre instance.
            rpc :ImportData, ::Google::Cloud::Lustre::V1::ImportDataRequest, ::Google::Longrunning::Operation
            # Exports data from a Managed Lustre instance to Cloud Storage.
            rpc :ExportData, ::Google::Cloud::Lustre::V1::ExportDataRequest, ::Google::Longrunning::Operation
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
