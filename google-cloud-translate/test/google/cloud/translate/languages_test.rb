# Copyright 2016 Google LLC
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

require "helper"

describe Google::Cloud::Translate::Api, :languages, :mock_translate do
  it "lists languages without a language" do
    mock = Minitest::Mock.new
    languages_resource = { language: "af", name: nil }
    list_languages_resource = JSON.parse({ languages: [languages_resource] }.to_json)
    mock.expect :languages, list_languages_resource, [nil]

    translate.service = mock
    languages = translate.languages
    mock.verify

    languages.count.must_be :>, 0
    languages.first.code.must_equal "af"
    languages.first.name.must_be :nil?
  end

  it "lists languages with a language" do
    mock = Minitest::Mock.new
    languages_resource = { language: "af", name: "Afrikaans" }
    list_languages_resource = JSON.parse({ languages: [languages_resource] }.to_json)
    mock.expect :languages, list_languages_resource, ["en"]

    translate.service = mock
    languages = translate.languages "en"
    mock.verify

    languages.count.must_be :>, 0
    languages.first.code.must_equal "af"
    languages.first.name.must_equal "Afrikaans"
  end
end
