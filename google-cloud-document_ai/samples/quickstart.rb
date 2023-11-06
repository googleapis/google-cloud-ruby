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

# [START documentai_quickstart]
require "google/cloud/document_ai/v1"

##
# Document AI quickstart
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Processor Location (e.g. "us")
# @param processor_id [String] Your Processor ID (e.g. "a14dae8f043b60bd")
# @param file_path [String] Path to Local File (e.g. "invoice.pdf")
# @param mime_type [String] Refer to https://cloud.google.com/document-ai/docs/file-types (e.g. "application/pdf")
#
def quickstart project_id:, location_id:, processor_id:, file_path:, mime_type:
  # Create the Document AI client.
  client = ::Google::Cloud::DocumentAI::V1::DocumentProcessorService::Client.new do |config|
    config.endpoint = "#{location_id}-documentai.googleapis.com"
  end

  # Build the resource name from the project.
  name = client.processor_path(
    project: project_id,
    location: location_id,
    processor: processor_id
  )

  # Read the bytes into memory
  content = File.binread file_path

  # Create request
  request = Google::Cloud::DocumentAI::V1::ProcessRequest.new(
    skip_human_review: true,
    name: name,
    raw_document: {
      content: content,
      mime_type: mime_type
    }
  )

  # Process document
  response = client.process_document request

  # Handle response
  puts response.document.text
end
# [END documentai_quickstart]
