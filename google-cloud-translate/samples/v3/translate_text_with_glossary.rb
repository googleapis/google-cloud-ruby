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

def translate_v3_translate_text_with_glossary project_id:, location_id:, glossary_id:
  # [START translate_v3_translate_text_with_glossary]
  require "google/cloud/translate"

  # project_id = "[Google Cloud Project ID]"
  # location_id = "[LOCATION ID]"
  # glossary_id = "[YOUR_GLOSSARY_ID]"

  # The content to translate in string format
  contents = ["Hello, world!"]
  # Required. The BCP-47 language code to use for translation.
  target_language = "fr"
  # Optional. The BCP-47 language code of the input text.
  source_language = "en"
  # Optional. Can be "text/plain" or "text/html".
  mime_type = "text/plain"

  client = Google::Cloud::Translate.translation_service

  parent = client.location_path project: project_id, location: location_id
  glossary_path = client.glossary_path project:  project_id,
                                       location: location_id,
                                       glossary: glossary_id
  glossary_config = { glossary: glossary_path }

  response = client.translate_text parent:               parent,
                                   contents:             contents,
                                   target_language_code: target_language,
                                   source_language_code: source_language,
                                   glossary_config:      glossary_config,
                                   mime_type:            mime_type

  # Display the translation for each input text provided
  response.translations.each do |translation|
    puts "Translated text: #{translation.translated_text}"
  end
  # [END translate_v3_translate_text_with_glossary]
end
