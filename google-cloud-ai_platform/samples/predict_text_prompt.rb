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

# [START aiplatform_sdk_ideation]
require "google/cloud/ai_platform/v1"

##
# Vertex AI Predict Text Prompt
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Processor Location (e.g. "us-central1")
# @param publisher [String] The Model Publisher (e.g. "google")
# @param model [String] The Model Identifier (e.g. "text-bison@001")
#
def predict_text_prompt project_id:, location_id:, publisher:, model:
  # Create the Vertex AI client.
  client = ::Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
    config.endpoint = "#{location_id}-aiplatform.googleapis.com"
  end

  # Build the resource name from the project.
  endpoint = client.endpoint_path(
    project: project_id,
    location: location_id,
    publisher: publisher,
    model: model
  )

  prompt = "Give me ten interview questions for the role of program manager."

  # Initialize the request arguments
  instance = Google::Protobuf::Value.new(
    struct_value: Google::Protobuf::Struct.new(
      fields: {
        "prompt" => Google::Protobuf::Value.new(
          string_value: prompt
        )
      }
    )
  )

  instances = [instance]

  parameters = Google::Protobuf::Value.new(
    struct_value: Google::Protobuf::Struct.new(
      fields: {
        "temperature" => Google::Protobuf::Value.new(number_value: 0.2),
        "maxOutputTokens" => Google::Protobuf::Value.new(number_value: 256),
        "topP" => Google::Protobuf::Value.new(number_value: 0.95),
        "topK" => Google::Protobuf::Value.new(number_value: 40)
      }
    )
  )

  # Make the prediction request
  response = client.predict endpoint: endpoint, instances: instances, parameters: parameters

  # Handle the prediction response
  puts "Predict Response"
  puts response
end
# [END aiplatform_sdk_ideation]
