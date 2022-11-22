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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/webrisk"
require "google/cloud/webrisk/v1beta1/web_risk_service_v1_beta1_client"
require "google/cloud/webrisk/v1beta1/webrisk_services_pb"

class CustomTestError_v1beta1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1beta1

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

class MockWebRiskServiceV1Beta1Credentials_v1beta1 < Google::Cloud::Webrisk::V1beta1::Credentials
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

describe Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client do

  describe 'compute_threat_list_diff' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client#compute_threat_list_diff."

    it 'invokes compute_threat_list_diff without error' do
      # Create request parameters
      threat_type = :THREAT_TYPE_UNSPECIFIED
      constraints = {}

      # Create expected grpc response
      new_version_token = "115"
      expected_response = { new_version_token: new_version_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest, request)
        assert_equal(threat_type, request.threat_type)
        assert_equal(Google::Gax::to_proto(constraints, Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest::Constraints), request.constraints)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:compute_threat_list_diff, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("compute_threat_list_diff")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          response = client.compute_threat_list_diff(threat_type, constraints)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.compute_threat_list_diff(threat_type, constraints) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes compute_threat_list_diff with error' do
      # Create request parameters
      threat_type = :THREAT_TYPE_UNSPECIFIED
      constraints = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest, request)
        assert_equal(threat_type, request.threat_type)
        assert_equal(Google::Gax::to_proto(constraints, Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest::Constraints), request.constraints)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:compute_threat_list_diff, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("compute_threat_list_diff")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.compute_threat_list_diff(threat_type, constraints)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_uris' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client#search_uris."

    it 'invokes search_uris without error' do
      # Create request parameters
      uri = ''
      threat_types = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Webrisk::V1beta1::SearchUrisResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::SearchUrisRequest, request)
        assert_equal(uri, request.uri)
        assert_equal(threat_types, request.threat_types)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:search_uris, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("search_uris")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          response = client.search_uris(uri, threat_types)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.search_uris(uri, threat_types) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes search_uris with error' do
      # Create request parameters
      uri = ''
      threat_types = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::SearchUrisRequest, request)
        assert_equal(uri, request.uri)
        assert_equal(threat_types, request.threat_types)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:search_uris, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("search_uris")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.search_uris(uri, threat_types)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_hashes' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client#search_hashes."

    it 'invokes search_hashes without error' do
      # Create request parameters
      threat_types = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Webrisk::V1beta1::SearchHashesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::SearchHashesRequest, request)
        assert_equal(threat_types, request.threat_types)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:search_hashes, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("search_hashes")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          response = client.search_hashes(threat_types)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.search_hashes(threat_types) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes search_hashes with error' do
      # Create request parameters
      threat_types = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Webrisk::V1beta1::SearchHashesRequest, request)
        assert_equal(threat_types, request.threat_types)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:search_hashes, mock_method)

      # Mock auth layer
      mock_credentials = MockWebRiskServiceV1Beta1Credentials_v1beta1.new("search_hashes")

      Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.stub(:new, mock_stub) do
        Google::Cloud::Webrisk::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Webrisk.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.search_hashes(threat_types)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end