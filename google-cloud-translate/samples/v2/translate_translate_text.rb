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

def translate_translate_text project_id:, text:, language_code:
  # [START translate_translate_text]
  # project_id    = "Your Google Cloud project ID"
  # text          = "The text you would like to translate"
  # language_code = "The ISO 639-1 code of language to translate to, eg. 'en'"

  require "google/cloud/translate"

  translate   = Google::Cloud::Translate.translation_v2_service project_id: project_id
  translation = translate.translate text, to: language_code

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_translate_text]
end
