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

def translate_list_language_names project_id:, language_code: "en"
  # [START translate_list_language_names]
  # project_id = "Your Google Cloud project ID"

  # To receive the names of the supported languages, provide the code
  # for the language in which you wish to receive the names
  # language_code = "en"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.translation_v2_service project_id: project_id
  languages = translate.languages language_code

  puts "Supported languages:"
  languages.each do |language|
    puts "#{language.code} #{language.name}"
  end
  # [END translate_list_language_names]
end
