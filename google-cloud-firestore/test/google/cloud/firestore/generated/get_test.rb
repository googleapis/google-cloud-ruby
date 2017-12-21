# Copyright 2017 Google LLC
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

require "helper"

describe "Cross-Language Get Tests", :mock_firestore do
  let(:document_path) { "C/d" }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }

  it "get a document" do
    get_doc_resp = [
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
        ))
    ]

    firestore_mock.expect :batch_get_documents, get_doc_resp.to_enum, [database_path, ["projects/projectID/databases/(default)/documents/C/d"], mask: nil, options: default_options]

    firestore.doc(document_path).get
  end
end
