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
    
    # Decoding BadRequest.FieldViolation from RPC error metadata
    err.status_details[0].field_violations[0].field.must_equal "document.language"
    err.status_details[0].field_violations[0].description.must_match /document language is not valid/

    # Since ErrorInfo is not present, the fields surfaced from it should be nil
    err.reason.must_be_nil
    err.domain.must_be_nil
    err.error_metadata.must_be_nil
  end

  it "surfaces ErrorInfo fields if present" do
    language_service_client = Google::Cloud::Language.language_service version: :v1 do |config|
      config.quota_project = "this_project_does_not_exist"
    end
    document = { content: "This is a test", type: :PLAIN_TEXT, language: "zz" }
    err = ->{ language_service_client.analyze_sentiment(document: document) }.must_raise ::Google::Cloud::Error
    err.status_details.wont_be_nil
    
    err_infos = err.status_details.find_all { |status| status.is_a? ::Google::Rpc::ErrorInfo }
    err_infos.length.must_equal 1

    # Since ErrorInfo is present, its fields should be surfaced to the wrapper
    err_info = err_infos[0]
    err_info.reason.must_match /PROJECT_DENIED/
    
    err.reason.must_match err_info.reason
    err.domain.must_match err_info.domain
    err.error_metadata.must_be_kind_of Hash

    err_info.metadata.each do |key, value|
      err.error_metadata.key?(key).must_equal true
      err.error_metadata[key].must_equal value
    end
  end
end
