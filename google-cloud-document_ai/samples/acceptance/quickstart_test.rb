# Copyright 2023 Google, Inc
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

require_relative "../../../.toys/.lib/sample_loader"

describe "Document AI Quickstart" do
  let(:client) { Google::Cloud::DocumentAI.document_processor_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us" }
  let(:processor_id) { "aaaaaaaa" }
  let(:file_path) { "acceptance/data/invoice.pdf" }
  let(:mime_type) { "application/pdf" }

  it "processes a document" do
    sample = SampleLoader.load "quickstart.rb"

    assert_output "Invoice" do
      sample.run project_id: project_id, location_id: location_id, processor_id: processor_id, file_path: file_path, mime_type: mime_type
    end

  end
end
