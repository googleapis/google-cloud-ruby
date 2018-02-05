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

require "google/cloud/vision"
require "google/cloud/vision/v1/helpers"
require "google/cloud/vision/v1/image_annotator_client"
require "google/cloud/vision/v1/image_annotator_services_pb"

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

class MockImageAnnotatorCredentials < Google::Cloud::Vision::Credentials
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


describe Google::Cloud::Vision::V1::ImageAnnotatorClient do
  describe 'feature methods' do
    it 'has feature methods' do
      mock_stub = MockGrpcClientStub.new(:feature_method, Proc.new { nil })
      mock_credentials = MockImageAnnotatorCredentials.new("nil")

      Google::Cloud::Vision::V1::ImageAnnotator::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision.new(version: :v1)

          # Some examples of feature methods that should have been dynamically
          # attached to the client object
          assert(client.respond_to?(:logo_detection))
          assert(client.respond_to?(:face_detection))
        end
      end
    end

    it 'modifies request for URL' do
      expected_request =
        Google::Cloud::Vision::V1::BatchAnnotateImagesRequest.new(
          requests: [
            {
              image: {source: {image_uri: "https://www.google.com/to/an/image"}},
              features: [{type: :FACE_DETECTION}]
            }
          ]
        )


      # Mock Grpc layer to check that request has been put into expected format
      check_expected_request = Proc.new do |request|
        assert_equal(request, expected_request)        
        Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new
      end

      mock_stub = MockGrpcClientStub.new(:batch_annotate_images, check_expected_request)
      mock_credentials = MockImageAnnotatorCredentials.new("face_detection")

      Google::Cloud::Vision::V1::ImageAnnotator::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision.new(version: :v1)

          # Call method
          request = client.face_detection("https://www.google.com/to/an/image")
        end
      end
    end

    it 'modifies request for file path' do
      expected_request =
        Google::Cloud::Vision::V1::BatchAnnotateImagesRequest.new(
          requests: [
            {
              image: {content: "expected content\n"},
              features: [{type: :FACE_DETECTION}]
            }
          ]
        )


      # Mock Grpc layer to check that request has been put into expected format
      check_expected_request = Proc.new do |request|
        assert_equal(request, expected_request)        
        Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new
      end

      mock_stub = MockGrpcClientStub.new(:batch_annotate_images, check_expected_request)
      mock_credentials = MockImageAnnotatorCredentials.new("face_detection")

      Google::Cloud::Vision::V1::ImageAnnotator::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision.new(version: :v1)

          # Call method
          request = client.face_detection("test/testdata/file.txt")
        end
      end
    end

    it 'modifies request for IO' do
      expected_request =
        Google::Cloud::Vision::V1::BatchAnnotateImagesRequest.new(
          requests: [
            {
              image: {content: "expected content\n"},
              features: [{type: :FACE_DETECTION}]
            }
          ]
        )


      # Mock Grpc layer to check that request has been put into expected format
      check_expected_request = Proc.new do |request|
        assert_equal(request, expected_request)
        Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new
      end

      mock_stub = MockGrpcClientStub.new(:batch_annotate_images, check_expected_request)
      mock_credentials = MockImageAnnotatorCredentials.new("face_detection")

      Google::Cloud::Vision::V1::ImageAnnotator::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision.new(version: :v1)

          # Call method
          f = File.new("test/testdata/file.txt")
          request = client.face_detection(f)
        end
      end
    end
    
    it 'validates request' do
      expected_request =
        Google::Cloud::Vision::V1::BatchAnnotateImagesRequest.new(
          requests: [
            {
              image: {content: "expected content\n"},
              features: [{type: :FACE_DETECTION}]
            }
          ]
        )


      # Mock Grpc layer to check that request has been put into expected format
      mock_annotate = Proc.new { |r| p r ; raise "This should never be reached." }

      mock_stub = MockGrpcClientStub.new(:batch_annotate_images, mock_annotate)
      mock_credentials = MockImageAnnotatorCredentials.new("face_detection")

      Google::Cloud::Vision::V1::ImageAnnotator::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision.new(version: :v1)

          # Method should fail because FACE_DETECTION label is asked for in a
          # LABEL_DECTION call.
          assert_raises ArgumentError do
            client.label_detection(
              {
                image: {content: "expected content\n"},
                features: [{type: :FACE_DETECTION}]
              }
            )
          end
        end
      end
    end
  end
end
