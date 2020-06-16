# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../delete_glossary"

require "securerandom"

describe "translate_v3_delete_glossary", :translate do
  let(:glossary_id) { "glossary-#{SecureRandom.uuid}" }
  let(:location_id) { "us-central1" }
  let(:glossary_name) { client.glossary_path project: project_id, location: location_id, glossary: glossary_id }

  it "deletes a glossary" do
    input_uri = "gs://cloud-samples-data/translation/glossary_ja.csv"
    glossary = {
      name:               glossary_name,
      language_codes_set: { language_codes: ["en", "ja"] },
      input_config:       { gcs_source: { input_uri: input_uri } }
    }
    parent = client.location_path project: project_id, location: location_id
    operation = client.create_glossary parent: parent, glossary: glossary
    operation.wait_until_done!

    out, _err = capture_io do
      translate_v3_delete_glossary project_id: project_id, location_id: location_id, glossary_id: glossary_id
    end
    assert_match(/Deleted Glossary/, out)

    assert_raises Google::Cloud::NotFoundError do
      client.get_glossary name: glossary_name
    end
  end
end
