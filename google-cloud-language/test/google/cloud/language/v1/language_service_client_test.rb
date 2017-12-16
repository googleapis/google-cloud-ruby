# Copyright 2017 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/language"
require "google/cloud/language/v1/language_service_client"
require "google/cloud/language/v1/language_service_services_pb"

class CustomTestError < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub

  # @param expected_symbol [Symbol] the symbol of the grpc method to be mocked.
  # @param mock_method [Proc] The method that is being mocked.
  def initialize(expected_symbol, mock_method)
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end

  # This overrides the Object#method method to return the mocked method when the mocked method
  # is being requested. For methods that aren't being tested, this method returns a proc that
  # will raise an error when called. This is to assure that only the mocked grpc method is being
  # called.
  #
  # @param symbol [Symbol] The symbol of the method being requested.
  # @return [Proc] The proc of the requested method. If the requested method is not being mocked
  #   the proc returned will raise when called.
  def method(symbol)
    return @mock_method if symbol == @expected_symbol

    # The requested method is not being tested, raise if it called.
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class MockLanguageServiceCredentials < Google::Cloud::Language::Credentials
  def initialize(method_name)
    @method_name = method_name
  end

  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Language::V1::LanguageServiceClient do

  describe 'analyze_sentiment' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#analyze_sentiment."

    it 'invokes analyze_sentiment without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      language = "language-1613589672"
      expected_response = { language: language }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::AnalyzeSentimentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeSentimentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:analyze_sentiment, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_sentiment")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.analyze_sentiment(document)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes analyze_sentiment with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeSentimentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:analyze_sentiment, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_sentiment")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.analyze_sentiment(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'analyze_entities' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#analyze_entities."

    it 'invokes analyze_entities without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      language = "language-1613589672"
      expected_response = { language: language }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::AnalyzeEntitiesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeEntitiesRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:analyze_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_entities")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.analyze_entities(document)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes analyze_entities with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeEntitiesRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:analyze_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_entities")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.analyze_entities(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'analyze_entity_sentiment' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#analyze_entity_sentiment."

    it 'invokes analyze_entity_sentiment without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      language = "language-1613589672"
      expected_response = { language: language }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::AnalyzeEntitySentimentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeEntitySentimentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:analyze_entity_sentiment, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_entity_sentiment")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.analyze_entity_sentiment(document)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes analyze_entity_sentiment with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeEntitySentimentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:analyze_entity_sentiment, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_entity_sentiment")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.analyze_entity_sentiment(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'analyze_syntax' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#analyze_syntax."

    it 'invokes analyze_syntax without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      language = "language-1613589672"
      expected_response = { language: language }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::AnalyzeSyntaxResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeSyntaxRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:analyze_syntax, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_syntax")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.analyze_syntax(document)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes analyze_syntax with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnalyzeSyntaxRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:analyze_syntax, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("analyze_syntax")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.analyze_syntax(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'classify_text' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#classify_text."

    it 'invokes classify_text without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::ClassifyTextResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::ClassifyTextRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:classify_text, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("classify_text")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.classify_text(document)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes classify_text with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::ClassifyTextRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:classify_text, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("classify_text")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.classify_text(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'annotate_text' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Language::V1::LanguageServiceClient#annotate_text."

    it 'invokes annotate_text without error' do
      # Create request parameters
      document = {}
      features = {}

      # Create expected grpc response
      language = "language-1613589672"
      expected_response = { language: language }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Language::V1::AnnotateTextResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnnotateTextRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        assert_equal(Google::Gax::to_proto(features, Google::Cloud::Language::V1::AnnotateTextRequest::Features), request.features)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:annotate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("annotate_text")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          response = client.annotate_text(document, features)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes annotate_text with error' do
      # Create request parameters
      document = {}
      features = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Language::V1::AnnotateTextRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Cloud::Language::V1::Document), request.document)
        assert_equal(Google::Gax::to_proto(features, Google::Cloud::Language::V1::AnnotateTextRequest::Features), request.features)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:annotate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockLanguageServiceCredentials.new("annotate_text")

      Google::Cloud::Language::V1::LanguageService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Language::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Language.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.annotate_text(document, features)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end