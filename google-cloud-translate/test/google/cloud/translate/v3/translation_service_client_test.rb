# Copyright 2020 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/translate"
require "google/cloud/translate/v3/translation_service_client"
require "google/cloud/translate/v3/translation_service_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError_v3 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v3

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

class MockTranslationServiceCredentials_v3 < Google::Cloud::Translate::V3::Credentials
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

describe Google::Cloud::Translate::V3::TranslationServiceClient do

  describe 'delete_glossary' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#delete_glossary."

    it 'invokes delete_glossary without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::DeleteGlossaryResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_glossary_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::DeleteGlossaryRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("delete_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.delete_glossary(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes delete_glossary and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Translate::V3::TranslationServiceClient#delete_glossary.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_glossary_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::DeleteGlossaryRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("delete_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.delete_glossary(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes delete_glossary with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::DeleteGlossaryRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("delete_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.delete_glossary(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'translate_text' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#translate_text."

    it 'invokes translate_text without error' do
      # Create request parameters
      contents = []
      target_language_code = ''
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::TranslateTextResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::TranslateTextRequest, request)
        assert_equal(contents, request.contents)
        assert_equal(target_language_code, request.target_language_code)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:translate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("translate_text")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.translate_text(
            contents,
            target_language_code,
            formatted_parent
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.translate_text(
            contents,
            target_language_code,
            formatted_parent
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes translate_text with error' do
      # Create request parameters
      contents = []
      target_language_code = ''
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::TranslateTextRequest, request)
        assert_equal(contents, request.contents)
        assert_equal(target_language_code, request.target_language_code)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:translate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("translate_text")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.translate_text(
              contents,
              target_language_code,
              formatted_parent
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'detect_language' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#detect_language."

    it 'invokes detect_language without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::DetectLanguageResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::DetectLanguageRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:detect_language, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("detect_language")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.detect_language(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.detect_language(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes detect_language with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::DetectLanguageRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:detect_language, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("detect_language")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.detect_language(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_supported_languages' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#get_supported_languages."

    it 'invokes get_supported_languages without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::SupportedLanguages)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::GetSupportedLanguagesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_supported_languages, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("get_supported_languages")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.get_supported_languages(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_supported_languages(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_supported_languages with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::GetSupportedLanguagesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_supported_languages, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("get_supported_languages")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.get_supported_languages(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_translate_text' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#batch_translate_text."

    it 'invokes batch_translate_text without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      source_language_code = ''
      target_language_codes = []
      input_configs = []
      output_config = {}

      # Create expected grpc response
      total_characters = 1368640955
      translated_characters = 1337326221
      failed_characters = 1723028396
      expected_response = {
        total_characters: total_characters,
        translated_characters: translated_characters,
        failed_characters: failed_characters
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::BatchTranslateResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_translate_text_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::BatchTranslateTextRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(source_language_code, request.source_language_code)
        assert_equal(target_language_codes, request.target_language_codes)
        input_configs = input_configs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Translate::V3::InputConfig)
        end
        assert_equal(input_configs, request.input_configs)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Translate::V3::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:batch_translate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("batch_translate_text")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.batch_translate_text(
            formatted_parent,
            source_language_code,
            target_language_codes,
            input_configs,
            output_config
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_translate_text and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      source_language_code = ''
      target_language_codes = []
      input_configs = []
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Translate::V3::TranslationServiceClient#batch_translate_text.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_translate_text_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::BatchTranslateTextRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(source_language_code, request.source_language_code)
        assert_equal(target_language_codes, request.target_language_codes)
        input_configs = input_configs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Translate::V3::InputConfig)
        end
        assert_equal(input_configs, request.input_configs)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Translate::V3::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:batch_translate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("batch_translate_text")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.batch_translate_text(
            formatted_parent,
            source_language_code,
            target_language_codes,
            input_configs,
            output_config
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_translate_text with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      source_language_code = ''
      target_language_codes = []
      input_configs = []
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::BatchTranslateTextRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(source_language_code, request.source_language_code)
        assert_equal(target_language_codes, request.target_language_codes)
        input_configs = input_configs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Translate::V3::InputConfig)
        end
        assert_equal(input_configs, request.input_configs)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Translate::V3::OutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:batch_translate_text, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("batch_translate_text")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.batch_translate_text(
              formatted_parent,
              source_language_code,
              target_language_codes,
              input_configs,
              output_config
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_glossary' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#create_glossary."

    it 'invokes create_glossary without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      glossary = {}

      # Create expected grpc response
      name = "name3373707"
      entry_count = 811131134
      expected_response = { name: name, entry_count: entry_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::Glossary)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_glossary_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::CreateGlossaryRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(glossary, Google::Cloud::Translate::V3::Glossary), request.glossary)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("create_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.create_glossary(formatted_parent, glossary)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_glossary and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      glossary = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Translate::V3::TranslationServiceClient#create_glossary.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_glossary_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::CreateGlossaryRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(glossary, Google::Cloud::Translate::V3::Glossary), request.glossary)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("create_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.create_glossary(formatted_parent, glossary)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_glossary with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
      glossary = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::CreateGlossaryRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(glossary, Google::Cloud::Translate::V3::Glossary), request.glossary)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("create_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.create_glossary(formatted_parent, glossary)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_glossaries' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#list_glossaries."

    it 'invokes list_glossaries without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      glossaries_element = {}
      glossaries = [glossaries_element]
      expected_response = { next_page_token: next_page_token, glossaries: glossaries }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::ListGlossariesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::ListGlossariesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_glossaries, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("list_glossaries")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.list_glossaries(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.glossaries.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_glossaries with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::ListGlossariesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_glossaries, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("list_glossaries")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.list_glossaries(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_glossary' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Translate::V3::TranslationServiceClient#get_glossary."

    it 'invokes get_glossary without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      entry_count = 811131134
      expected_response = { name: name_2, entry_count: entry_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Translate::V3::Glossary)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::GetGlossaryRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("get_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          response = client.get_glossary(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_glossary(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_glossary with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Translate::V3::GetGlossaryRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_glossary, mock_method)

      # Mock auth layer
      mock_credentials = MockTranslationServiceCredentials_v3.new("get_glossary")

      Google::Cloud::Translate::V3::TranslationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Translate::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Translate.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.get_glossary(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end