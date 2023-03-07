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
require "minitest/focus"

require "google/cloud/language"

class Google::Cloud::Language::LanguageServiceSmokeTestBase < Minitest::Test
  ##
  # A basic smoke test for a simple non-error operation (GRPC)
  def test_language_sentiment_grpc
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :grpc
    verify_language_sentiment language_service_client
  end

  ##
  # A basic smoke test for a simple non-error operation (REST)
  def test_language_sentiment_rest
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :rest
    verify_language_sentiment language_service_client
  end

  def verify_language_sentiment language_service_client
    document = { content: "Hello, world!", type: :PLAIN_TEXT }
    response = language_service_client.analyze_sentiment document: document

    assert_kind_of ::Numeric, response.document_sentiment.score
    assert_equal "en", response.language
  end

  ##
  # Test that the error code and details are surfaced (GRPC)
  def test_error_code_details_grpc
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :grpc
    verify_error_code_details language_service_client
  end

  ##
  # Test that the error code and details are surfaced (REST)
  def test_error_code_details_rest
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :rest
    verify_error_code_details language_service_client
  end

  def verify_error_code_details language_service_client
    document = { content: "This is a test", type: :PLAIN_TEXT, language: "zz" }

    err = assert_raises(::Google::Cloud::Error) do
      language_service_client.analyze_sentiment(document: document)
    end

    assert_equal 3, err.code
    assert_match /document.language is not valid/, err.message

    # Decoding BadRequest.FieldViolation from RPC error metadata
    assert_equal "document.language", err.status_details[0].field_violations[0].field
    assert_match /document.language is not valid/, err.status_details[0].field_violations[0].description

    # Since ErrorInfo is not present, the fields surfaced from it should be nil
    assert_nil err.reason
    assert_nil err.domain
    assert_nil err.error_metadata
  end

  ##
  # Test that ErrorInfo fields get surfaced (GRPC)
  def test_error_code_errorinfo_grpc
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :grpc do |config|
      config.quota_project = "this_project_does_not_exist"
    end
    verify_error_code_errorinfo language_service_client
  end

  ##
  # Test that ErrorInfo fields get surfaced (REST)
  def test_error_code_errorinfo_rest
    language_service_client = Google::Cloud::Language.language_service version: :v1, transport: :rest do |config|
      config.quota_project = "this_project_does_not_exist"
    end
    verify_error_code_errorinfo language_service_client
  end

  def verify_error_code_errorinfo language_service_client
    document = { content: "This is a test", type: :PLAIN_TEXT, language: "zz" }

    err = assert_raises(::Google::Cloud::Error) do
      language_service_client.analyze_sentiment(document: document)
    end

    refute_nil err.status_details

    err_infos = err.status_details.find_all { |status| status.is_a? ::Google::Rpc::ErrorInfo }
    assert err_infos.one?

    # Since ErrorInfo is present, its fields should be surfaced to the wrapper
    err_info = err_infos[0]
    assert_match /PROJECT_DENIED/, err_info.reason
    
    assert_match err_info.reason, err.reason
    assert_match err_info.domain, err.domain
    assert_kind_of ::Hash, err.error_metadata

    err_info.metadata.each do |key, value|
      assert err.error_metadata.key? key
      assert_equal value, err.error_metadata[key]
    end
  end
end
