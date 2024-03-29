# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/dialogflow/cx/v3/generator.proto for package 'Google.Cloud.Dialogflow.CX.V3'
# Original file comments:
# Copyright 2023 Google LLC
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
require 'google/cloud/dialogflow/cx/v3/generator_pb'

module Google
  module Cloud
    module Dialogflow
      module CX
        module V3
          module Generators
            # Service for managing [Generators][google.cloud.dialogflow.cx.v3.Generator]
            class Service

              include ::GRPC::GenericService

              self.marshal_class_method = :encode
              self.unmarshal_class_method = :decode
              self.service_name = 'google.cloud.dialogflow.cx.v3.Generators'

              # Returns the list of all generators in the specified agent.
              rpc :ListGenerators, ::Google::Cloud::Dialogflow::CX::V3::ListGeneratorsRequest, ::Google::Cloud::Dialogflow::CX::V3::ListGeneratorsResponse
              # Retrieves the specified generator.
              rpc :GetGenerator, ::Google::Cloud::Dialogflow::CX::V3::GetGeneratorRequest, ::Google::Cloud::Dialogflow::CX::V3::Generator
              # Creates a generator in the specified agent.
              rpc :CreateGenerator, ::Google::Cloud::Dialogflow::CX::V3::CreateGeneratorRequest, ::Google::Cloud::Dialogflow::CX::V3::Generator
              # Update the specified generator.
              rpc :UpdateGenerator, ::Google::Cloud::Dialogflow::CX::V3::UpdateGeneratorRequest, ::Google::Cloud::Dialogflow::CX::V3::Generator
              # Deletes the specified generators.
              rpc :DeleteGenerator, ::Google::Cloud::Dialogflow::CX::V3::DeleteGeneratorRequest, ::Google::Protobuf::Empty
            end

            Stub = Service.rpc_stub_class
          end
        end
      end
    end
  end
end
