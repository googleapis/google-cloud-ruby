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

def translate_v3_delete_glossary project_id:, location_id:, glossary_id:
  # [START translate_v3_delete_glossary]
  require "google/cloud/translate"

  # project_id = "[Google Cloud Project ID]"
  # location_id = "[LOCATION ID]"
  # glossary_id = "[YOUR_GLOSSARY_ID]"

  client = Google::Cloud::Translate.translation_service

  name = client.glossary_path project:  project_id,
                              location: location_id,
                              glossary: glossary_id

  operation = client.delete_glossary name: name

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Deleted Glossary."
  # [END translate_v3_delete_glossary]
end
