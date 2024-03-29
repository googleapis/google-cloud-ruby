# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/discoveryengine/v1beta/schema_service.proto for package 'Google.Cloud.DiscoveryEngine.V1beta'
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
require 'google/cloud/discoveryengine/v1beta/schema_service_pb'

module Google
  module Cloud
    module DiscoveryEngine
      module V1beta
        module SchemaService
          # Service for managing [Schema][google.cloud.discoveryengine.v1beta.Schema]s.
          class Service

            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.discoveryengine.v1beta.SchemaService'

            # Gets a [Schema][google.cloud.discoveryengine.v1beta.Schema].
            rpc :GetSchema, ::Google::Cloud::DiscoveryEngine::V1beta::GetSchemaRequest, ::Google::Cloud::DiscoveryEngine::V1beta::Schema
            # Gets a list of [Schema][google.cloud.discoveryengine.v1beta.Schema]s.
            rpc :ListSchemas, ::Google::Cloud::DiscoveryEngine::V1beta::ListSchemasRequest, ::Google::Cloud::DiscoveryEngine::V1beta::ListSchemasResponse
            # Creates a [Schema][google.cloud.discoveryengine.v1beta.Schema].
            rpc :CreateSchema, ::Google::Cloud::DiscoveryEngine::V1beta::CreateSchemaRequest, ::Google::Longrunning::Operation
            # Updates a [Schema][google.cloud.discoveryengine.v1beta.Schema].
            rpc :UpdateSchema, ::Google::Cloud::DiscoveryEngine::V1beta::UpdateSchemaRequest, ::Google::Longrunning::Operation
            # Deletes a [Schema][google.cloud.discoveryengine.v1beta.Schema].
            rpc :DeleteSchema, ::Google::Cloud::DiscoveryEngine::V1beta::DeleteSchemaRequest, ::Google::Longrunning::Operation
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
