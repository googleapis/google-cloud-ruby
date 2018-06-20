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

require "google/cloud/speech/v1"
require "google/cloud/speech/v1/cloud_speech_services_pb"

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub
  # @param expected_symbol [Symbol] the symbol of the grpc method to be mocked.
  # @param mock_method [Proc] The method that is being mocked.
  def initialize expected_symbol, mock_method
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end

  # This overrides the Object#method method to return the mocked method when the
  # mocked method is being requested. For methods that aren't being tested, this
  # method returns a proc that will raise an error when called. This is to
  # assure that only the mocked grpc method is being called.
  #
  # @param symbol [Symbol] The symbol of the method being requested.
  # @return [Proc] The proc of the requested method. If the requested method is
  #   not being mocked the proc returned will raise when called.
  def method symbol
    return @mock_method if symbol == @expected_symbol

    # The requested method is not being tested, raise if it called.
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class MockSpeechCredentials < Google::Cloud::Speech::V1::Credentials
  def initialize method_name
    @method_name = method_name
  end

  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. " \
            "This should not happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Speech::V1::Stream do
  # Tokens to control mock streaming_recognize behavior
  FINAL = "final".freeze
  INTERIM = "interim".freeze
  EXCEPTION = "exception".freeze
  WAIT = "wait".freeze
  UTTERANCE = "utterance".freeze

  # Mock Grpc layer. Send back an interim/final result or raise an exception
  # depending on the request.
  mock_method = proc do |requests|
    mock_enum = Enumerator.new do |y|
      requests.each do |request|
        unless request.is_a?(
          Google::Cloud::Speech::V1::StreamingRecognizeRequest
        )
          raise "Unexpected request type"
        end

        if request.audio_content == FINAL || request.audio_content == INTERIM
          y << Google::Cloud::Speech::V1::StreamingRecognizeResponse.new(
            results: [{ is_final: request.audio_content == FINAL }]
          )

        elsif request.audio_content == UTTERANCE
          y << Google::Cloud::Speech::V1::StreamingRecognizeResponse.new(
            speech_event_type: :END_OF_SINGLE_UTTERANCE
          )

        elsif request.audio_content == EXCEPTION
          raise StandardError

        # Else, wait
        else
          sleep(0.5)
          y << Google::Cloud::Speech::V1::StreamingRecognizeResponse.new
        end
      end
    end
    OpenStruct.new execute: mock_enum
  end
  mock_stub = MockGrpcClientStub.new(:streaming_recognize, mock_method)

  # Mock auth layer
  mock_credentials = MockSpeechCredentials.new("streaming_recognize")

  it "wraps basic streaming functionality" do
    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Speech.new(version: :v1)
        stream = client.streaming_recognize({})
        stream.on_error { |err| "Stream failed unexpectedly with error #{err}" }

        # Check that stream is not started or stopped
        assert_kind_of(Google::Cloud::Speech::V1::Stream, stream)
        refute(stream.started?)
        refute(stream.stopped?)

        # Send some data
        stream.send(INTERIM)
        stream.send(INTERIM)

        # Check that stream is started but not stopped
        assert(stream.started?)
        refute(stream.stopped?)

        # Send some data to produce a final result
        stream.send(FINAL)
        stream.send(WAIT)

        # Check that stream can be stopped
        stream.stop

        # Check that stream is stopped
        assert(stream.stopped?)

        # Check that stream is not complete
        refute(stream.complete?)

        # Wait until stream is complete
        stream.wait_until_complete!

        # Check that stream is complete
        assert(stream.complete?)

        # Check that we got the final result we were expecting
        assert(stream.results.size == 1)
      end
    end
  end

  it "runs on_error callback" do
    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Speech.new(version: :v1)
        stream = client.streaming_recognize({})
        counters = Hash.new { |h, k| h[k] = 0 }
        errors = []

        stream.on_error { |err| errors << err }
        stream.on_interim { counters[:interim] += 1 }
        stream.on_result { counters[:result] += 1 }
        stream.on_complete { counters[:complete] += 1 }
        stream.on_utterance { counters[:utterance] += 1 }

        stream.send(EXCEPTION)
        stream.stop
        stream.wait_until_complete!

        errors.size.must_equal 1
        counters[:interim].must_be :zero?
        counters[:result].must_be :zero?
        counters[:complete].must_equal 1
        counters[:utterance].must_be :zero?
      end
    end
  end

  it "runs on_interim callback" do
    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Speech.new(version: :v1)
        stream = client.streaming_recognize({})
        counters = Hash.new { |h, k| h[k] = 0 }
        errors = []

        stream.on_error { |err| errors << err }
        stream.on_interim { counters[:interim] += 1 }
        stream.on_result { counters[:result] += 1 }
        stream.on_complete { counters[:complete] += 1 }
        stream.on_utterance { counters[:utterance] += 1 }

        stream.send(INTERIM)
        stream.stop
        stream.wait_until_complete!

        errors.size.must_be :zero?
        counters[:interim].must_equal 1
        counters[:result].must_be :zero?
        counters[:complete].must_equal 1
        counters[:utterance].must_be :zero?
      end
    end
  end

  it "runs on_result callback" do
    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Speech.new(version: :v1)
        stream = client.streaming_recognize({})
        counters = Hash.new { |h, k| h[k] = 0 }
        errors = []

        stream.on_error { |err| errors << err }
        stream.on_interim { counters[:interim] += 1 }
        stream.on_result { counters[:result] += 1 }
        stream.on_complete { counters[:complete] += 1 }
        stream.on_utterance { counters[:utterance] += 1 }

        stream.send(FINAL)
        stream.stop
        stream.wait_until_complete!

        errors.size.must_be :zero?
        counters[:interim].must_be :zero?
        counters[:result].must_equal 1
        counters[:complete].must_equal 1
        counters[:utterance].must_be :zero?
      end
    end
  end

  it "runs on_utterance callback" do
    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Speech.new(version: :v1)
        stream = client.streaming_recognize({})
        counters = Hash.new { |h, k| h[k] = 0 }
        errors = []

        stream.on_error { |err| errors << err }
        stream.on_interim { counters[:interim] += 1 }
        stream.on_result { counters[:result] += 1 }
        stream.on_complete { counters[:complete] += 1 }
        stream.on_utterance { counters[:utterance] += 1 }

        stream.send(UTTERANCE)
        stream.stop
        stream.wait_until_complete!

        errors.size.must_be :zero?
        counters[:interim].must_be :zero?
        counters[:result].must_be :zero?
        counters[:complete].must_equal 1
        counters[:utterance].must_equal 1
      end
    end
  end
end
