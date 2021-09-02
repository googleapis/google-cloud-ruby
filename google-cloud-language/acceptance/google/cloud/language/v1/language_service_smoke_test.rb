# Copyright 2019 Google LLC
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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/cloud/language"

describe "LanguageServiceSmokeTest v1" do
  it "runs one smoke test with analyze_sentiment" do
    language_service_client = Google::Cloud::Language.language_service version: :v1
    document = { content: "Hello, world!", type: :PLAIN_TEXT }
    response = language_service_client.analyze_sentiment document: document
    response.document_sentiment.score.must_be_kind_of Numeric
    response.language.must_equal "en"
  end

  it "surfaces error code, message, and status details" do
    language_service_client = Google::Cloud::Language.language_service version: :v1  
    document = { content: "This is a test", type: :PLAIN_TEXT, language: "zz" }
    err = ->{ language_service_client.analyze_sentiment(document: document) }.must_raise ::Google::Cloud::Error
    err.code.must_equal 3
    err.details.must_match /document.language is not valid/
    err.status_details[0].field_violations[0].field.must_equal "document.language"
    err.status_details[0].field_violations[0].description.must_match /document language is not valid/
  end
end
