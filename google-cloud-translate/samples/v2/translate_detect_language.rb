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

def translate_detect_language project_id:, text:
  # [START translate_detect_language]
  # project_id = "Your Google Cloud project ID"
  # text       = "The text you would like to detect the language of"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.translation_v2_service project_id: project_id
  detection = translate.detect text

  puts "'#{text}' detected as language: #{detection.language}"
  puts "Confidence: #{detection.confidence}"
  # [END translate_detect_language]
end
