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

def translate_v3_create_glossary project_id:, location_id:, glossary_id:
  # [START translate_v3_create_glossary]
  require "google/cloud/translate"

  # project_id = "[Google Cloud Project ID]"
  # location_id = "[LOCATION ID]"
  # glossary_id = "your-glossary-display-name"

  client = Google::Cloud::Translate.translation_service

  input_uri = "gs://cloud-samples-data/translation/glossary_ja.csv"

  parent = client.location_path project: project_id, location: location_id
  glossary_name = client.glossary_path project:  project_id,
                                       location: location_id,
                                       glossary: glossary_id
  language_codes_set = { language_codes: ["en", "ja"] }
  input_config = { gcs_source: { input_uri: input_uri } }
  glossary = {
    name:               glossary_name,
    language_codes_set: language_codes_set,
    input_config:       input_config
  }

  operation = client.create_glossary parent: parent, glossary: glossary
  # Wait until the long running operation is done
  operation.wait_until_done!
  response = operation.response

  puts "Created Glossary."
  puts "Glossary name: #{response.name}"
  puts "Entry count: #{response.entry_count}"
  puts "Input URI: #{response.input_config.gcs_source.input_uri}"
  # [END translate_v3_create_glossary]
end
