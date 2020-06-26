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

# rubocop:disable Metrics/MethodLength

def translate_v3_batch_translate_text_with_model \
  input_uri:, output_uri:, project_id:, location_id:, model_id:

  # [START translate_v3_batch_translate_text_with_model]
  require "google/cloud/translate"

  # input_uri = "gs://cloud-samples-data/text.txt"
  # output_uri = "gs://YOUR_BUCKET_ID/path_to_store_results/"
  # project_id = "[Google Cloud Project ID]"
  # location_id = "[LOCATION ID]"
  # model_id = "[MODEL ID]"

  source_lang = "en"
  target_lang = "ja"
  # Optional. Can be "text/plain" or "text/html".
  mime_type = "text/plain"

  client = Google::Cloud::Translate.translation_service

  parent = client.location_path project: project_id, location: location_id
  model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
  models = { target_lang => model }
  input_config = {
    mime_type:  mime_type,
    gcs_source: { input_uri: input_uri }
  }
  output_config = {
    gcs_destination: { output_uri_prefix: output_uri }
  }

  operation = client.batch_translate_text(
    parent:                parent,
    source_language_code:  source_lang,
    target_language_codes: [target_lang],
    input_configs:         [input_config],
    output_config:         output_config,
    models:                models
  )

  # Wait until the long running operation is done
  operation.wait_until_done!

  response = operation.response

  puts "Total Characters: #{response.total_characters}"
  puts "Translated Characters: #{response.translated_characters}"
  # [END translate_v3_batch_translate_text_with_model]
end

# rubocop:enable Metrics/MethodLength
