# Copyright 2021 Google LLC
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

require_relative "translate_v3_helper"

describe "smoke test" do
  it "translates hello world into french" do
    client = Google::Cloud::Translate.translation_service
    parent = client.location_path project: ENV["GOOGLE_CLOUD_PROJECT"], location: "global"
    response = client.translate_text parent: parent,
                                     contents: ["Hello, world!"],
                                     target_language_code: "fr"
    assert_equal "Bonjour le monde!", response.translations.first.translated_text
  end
end
