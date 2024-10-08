# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/discoveryengine/v1/search_tuning_service.proto for package 'Google.Cloud.DiscoveryEngine.V1'
# Original file comments:
# Copyright 2024 Google LLC
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
require 'google/cloud/discoveryengine/v1/search_tuning_service_pb'

module Google
  module Cloud
    module DiscoveryEngine
      module V1
        module SearchTuningService
          # Service for search tuning.
          class Service

            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.discoveryengine.v1.SearchTuningService'

            # Trains a custom model.
            rpc :TrainCustomModel, ::Google::Cloud::DiscoveryEngine::V1::TrainCustomModelRequest, ::Google::Longrunning::Operation
            # Gets a list of all the custom models.
            rpc :ListCustomModels, ::Google::Cloud::DiscoveryEngine::V1::ListCustomModelsRequest, ::Google::Cloud::DiscoveryEngine::V1::ListCustomModelsResponse
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
