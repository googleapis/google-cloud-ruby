# Copyright 2018 Google LLC
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

require "google/cloud/text_to_speech"
require "google/cloud/text_to_speech/v1/text_to_speech_client"
require "google/cloud/texttospeech/v1/cloud_tts_services_pb"

class CustomTestError_v1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1

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

class MockTextToSpeechCredentials_v1 < Google::Cloud::TextToSpeech::V1::Credentials
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

describe Google::Cloud::TextToSpeech::V1::TextToSpeechClient do

  describe 'list_voices' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::TextToSpeech::V1::TextToSpeechClient#list_voices."

    it 'invokes list_voices without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Texttospeech::V1::ListVoicesResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_voices, mock_method)

      # Mock auth layer
      mock_credentials = MockTextToSpeechCredentials_v1.new("list_voices")

      Google::Cloud::Texttospeech::V1::TextToSpeech::Stub.stub(:new, mock_stub) do
        Google::Cloud::TextToSpeech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::TextToSpeech.new(version: :v1)

          # Call method
          response = client.list_voices

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_voices do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_voices with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_voices, mock_method)

      # Mock auth layer
      mock_credentials = MockTextToSpeechCredentials_v1.new("list_voices")

      Google::Cloud::Texttospeech::V1::TextToSpeech::Stub.stub(:new, mock_stub) do
        Google::Cloud::TextToSpeech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::TextToSpeech.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_voices
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'synthesize_speech' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::TextToSpeech::V1::TextToSpeechClient#synthesize_speech."

    it 'invokes synthesize_speech without error' do
      # Create request parameters
      input = {}
      voice = {}
      audio_config = {}

      # Create expected grpc response
      audio_content = "16"
      expected_response = { audio_content: audio_content }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Texttospeech::V1::SynthesizeSpeechResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Texttospeech::V1::SynthesizeSpeechRequest, request)
        assert_equal(Google::Gax::to_proto(input, Google::Cloud::Texttospeech::V1::SynthesisInput), request.input)
        assert_equal(Google::Gax::to_proto(voice, Google::Cloud::Texttospeech::V1::VoiceSelectionParams), request.voice)
        assert_equal(Google::Gax::to_proto(audio_config, Google::Cloud::Texttospeech::V1::AudioConfig), request.audio_config)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:synthesize_speech, mock_method)

      # Mock auth layer
      mock_credentials = MockTextToSpeechCredentials_v1.new("synthesize_speech")

      Google::Cloud::Texttospeech::V1::TextToSpeech::Stub.stub(:new, mock_stub) do
        Google::Cloud::TextToSpeech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::TextToSpeech.new(version: :v1)

          # Call method
          response = client.synthesize_speech(
            input,
            voice,
            audio_config
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.synthesize_speech(
            input,
            voice,
            audio_config
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes synthesize_speech with error' do
      # Create request parameters
      input = {}
      voice = {}
      audio_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Texttospeech::V1::SynthesizeSpeechRequest, request)
        assert_equal(Google::Gax::to_proto(input, Google::Cloud::Texttospeech::V1::SynthesisInput), request.input)
        assert_equal(Google::Gax::to_proto(voice, Google::Cloud::Texttospeech::V1::VoiceSelectionParams), request.voice)
        assert_equal(Google::Gax::to_proto(audio_config, Google::Cloud::Texttospeech::V1::AudioConfig), request.audio_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:synthesize_speech, mock_method)

      # Mock auth layer
      mock_credentials = MockTextToSpeechCredentials_v1.new("synthesize_speech")

      Google::Cloud::Texttospeech::V1::TextToSpeech::Stub.stub(:new, mock_stub) do
        Google::Cloud::TextToSpeech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::TextToSpeech.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.synthesize_speech(
              input,
              voice,
              audio_config
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end