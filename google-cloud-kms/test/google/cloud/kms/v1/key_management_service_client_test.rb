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

require "google/cloud/kms"
require "google/cloud/kms/v1/key_management_service_client"
require "google/cloud/kms/v1/service_services_pb"
require "google/iam/v1/iam_policy_services_pb"

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

class MockKeyManagementServiceCredentials_v1 < Google::Cloud::Kms::V1::Credentials
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

describe Google::Cloud::Kms::V1::KeyManagementServiceClient do

  describe 'list_key_rings' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#list_key_rings."

    it 'invokes list_key_rings without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      key_rings_element = {}
      key_rings = [key_rings_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        key_rings: key_rings
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::ListKeyRingsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListKeyRingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_key_rings, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_key_rings")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.list_key_rings(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.key_rings.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_key_rings with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListKeyRingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_key_rings, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_key_rings")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_key_rings(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_crypto_keys' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#list_crypto_keys."

    it 'invokes list_crypto_keys without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      crypto_keys_element = {}
      crypto_keys = [crypto_keys_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        crypto_keys: crypto_keys
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::ListCryptoKeysResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListCryptoKeysRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_crypto_keys, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_crypto_keys")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.list_crypto_keys(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.crypto_keys.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_crypto_keys with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListCryptoKeysRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_crypto_keys, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_crypto_keys")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_crypto_keys(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_crypto_key_versions' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#list_crypto_key_versions."

    it 'invokes list_crypto_key_versions without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      crypto_key_versions_element = {}
      crypto_key_versions = [crypto_key_versions_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        crypto_key_versions: crypto_key_versions
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::ListCryptoKeyVersionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListCryptoKeyVersionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_crypto_key_versions, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_crypto_key_versions")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.list_crypto_key_versions(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.crypto_key_versions.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_crypto_key_versions with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::ListCryptoKeyVersionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_crypto_key_versions, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("list_crypto_key_versions")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_crypto_key_versions(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_key_ring' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#get_key_ring."

    it 'invokes get_key_ring without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::KeyRing)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetKeyRingRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_key_ring, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_key_ring")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.get_key_ring(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_key_ring(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_key_ring with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetKeyRingRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_key_ring, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_key_ring")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_key_ring(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_crypto_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#get_crypto_key."

    it 'invokes get_crypto_key without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetCryptoKeyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.get_crypto_key(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_crypto_key(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_crypto_key with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetCryptoKeyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_crypto_key(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_crypto_key_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#get_crypto_key_version."

    it 'invokes get_crypto_key_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKeyVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.get_crypto_key_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_crypto_key_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_crypto_key_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_crypto_key_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_key_ring' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#create_key_ring."

    it 'invokes create_key_ring without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")
      key_ring_id = ''
      key_ring = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::KeyRing)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateKeyRingRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(key_ring_id, request.key_ring_id)
        assert_equal(Google::Gax::to_proto(key_ring, Google::Cloud::Kms::V1::KeyRing), request.key_ring)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_key_ring, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_key_ring")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.create_key_ring(
            formatted_parent,
            key_ring_id,
            key_ring
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_key_ring(
            formatted_parent,
            key_ring_id,
            key_ring
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_key_ring with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")
      key_ring_id = ''
      key_ring = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateKeyRingRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(key_ring_id, request.key_ring_id)
        assert_equal(Google::Gax::to_proto(key_ring, Google::Cloud::Kms::V1::KeyRing), request.key_ring)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_key_ring, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_key_ring")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_key_ring(
              formatted_parent,
              key_ring_id,
              key_ring
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_crypto_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#create_crypto_key."

    it 'invokes create_crypto_key without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      crypto_key_id = "my-app-key"
      purpose = :ENCRYPT_DECRYPT
      seconds = 2147483647
      next_rotation_time = { seconds: seconds }
      seconds_2 = 604800
      rotation_period = { seconds: seconds_2 }
      crypto_key = {
        purpose: purpose,
        next_rotation_time: next_rotation_time,
        rotation_period: rotation_period
      }

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateCryptoKeyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(crypto_key_id, request.crypto_key_id)
        assert_equal(Google::Gax::to_proto(crypto_key, Google::Cloud::Kms::V1::CryptoKey), request.crypto_key)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.create_crypto_key(
            formatted_parent,
            crypto_key_id,
            crypto_key
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_crypto_key(
            formatted_parent,
            crypto_key_id,
            crypto_key
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_crypto_key with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      crypto_key_id = "my-app-key"
      purpose = :ENCRYPT_DECRYPT
      seconds = 2147483647
      next_rotation_time = { seconds: seconds }
      seconds_2 = 604800
      rotation_period = { seconds: seconds_2 }
      crypto_key = {
        purpose: purpose,
        next_rotation_time: next_rotation_time,
        rotation_period: rotation_period
      }

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateCryptoKeyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(crypto_key_id, request.crypto_key_id)
        assert_equal(Google::Gax::to_proto(crypto_key, Google::Cloud::Kms::V1::CryptoKey), request.crypto_key)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_crypto_key(
              formatted_parent,
              crypto_key_id,
              crypto_key
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_crypto_key_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#create_crypto_key_version."

    it 'invokes create_crypto_key_version without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      crypto_key_version = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKeyVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateCryptoKeyVersionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(crypto_key_version, Google::Cloud::Kms::V1::CryptoKeyVersion), request.crypto_key_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.create_crypto_key_version(formatted_parent, crypto_key_version)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_crypto_key_version(formatted_parent, crypto_key_version) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_crypto_key_version with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      crypto_key_version = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::CreateCryptoKeyVersionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(crypto_key_version, Google::Cloud::Kms::V1::CryptoKeyVersion), request.crypto_key_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("create_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_crypto_key_version(formatted_parent, crypto_key_version)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_crypto_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#update_crypto_key."

    it 'invokes update_crypto_key without error' do
      # Create request parameters
      crypto_key = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyRequest, request)
        assert_equal(Google::Gax::to_proto(crypto_key, Google::Cloud::Kms::V1::CryptoKey), request.crypto_key)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.update_crypto_key(crypto_key, update_mask)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_crypto_key(crypto_key, update_mask) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_crypto_key with error' do
      # Create request parameters
      crypto_key = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyRequest, request)
        assert_equal(Google::Gax::to_proto(crypto_key, Google::Cloud::Kms::V1::CryptoKey), request.crypto_key)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_crypto_key(crypto_key, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_crypto_key_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#update_crypto_key_version."

    it 'invokes update_crypto_key_version without error' do
      # Create request parameters
      crypto_key_version = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKeyVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyVersionRequest, request)
        assert_equal(Google::Gax::to_proto(crypto_key_version, Google::Cloud::Kms::V1::CryptoKeyVersion), request.crypto_key_version)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.update_crypto_key_version(crypto_key_version, update_mask)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_crypto_key_version(crypto_key_version, update_mask) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_crypto_key_version with error' do
      # Create request parameters
      crypto_key_version = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyVersionRequest, request)
        assert_equal(Google::Gax::to_proto(crypto_key_version, Google::Cloud::Kms::V1::CryptoKeyVersion), request.crypto_key_version)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_crypto_key_version(crypto_key_version, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'encrypt' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#encrypt."

    it 'invokes encrypt without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY_PATH]")
      plaintext = ''

      # Create expected grpc response
      name_2 = "name2-1052831874"
      ciphertext = "-72"
      expected_response = { name: name_2, ciphertext: ciphertext }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::EncryptResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::EncryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(plaintext, request.plaintext)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:encrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("encrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.encrypt(formatted_name, plaintext)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.encrypt(formatted_name, plaintext) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes encrypt with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY_PATH]")
      plaintext = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::EncryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(plaintext, request.plaintext)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:encrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("encrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.encrypt(formatted_name, plaintext)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'decrypt' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#decrypt."

    it 'invokes decrypt without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      ciphertext = ''

      # Create expected grpc response
      plaintext = "-9"
      expected_response = { plaintext: plaintext }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::DecryptResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::DecryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ciphertext, request.ciphertext)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:decrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("decrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.decrypt(formatted_name, ciphertext)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.decrypt(formatted_name, ciphertext) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes decrypt with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      ciphertext = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::DecryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ciphertext, request.ciphertext)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:decrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("decrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.decrypt(formatted_name, ciphertext)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_crypto_key_primary_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#update_crypto_key_primary_version."

    it 'invokes update_crypto_key_primary_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      crypto_key_version_id = ''

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyPrimaryVersionRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(crypto_key_version_id, request.crypto_key_version_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key_primary_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key_primary_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.update_crypto_key_primary_version(formatted_name, crypto_key_version_id)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_crypto_key_primary_version(formatted_name, crypto_key_version_id) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_crypto_key_primary_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
      crypto_key_version_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::UpdateCryptoKeyPrimaryVersionRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(crypto_key_version_id, request.crypto_key_version_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_crypto_key_primary_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("update_crypto_key_primary_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_crypto_key_primary_version(formatted_name, crypto_key_version_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'destroy_crypto_key_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#destroy_crypto_key_version."

    it 'invokes destroy_crypto_key_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKeyVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::DestroyCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:destroy_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("destroy_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.destroy_crypto_key_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.destroy_crypto_key_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes destroy_crypto_key_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::DestroyCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:destroy_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("destroy_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.destroy_crypto_key_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'restore_crypto_key_version' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#restore_crypto_key_version."

    it 'invokes restore_crypto_key_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::CryptoKeyVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::RestoreCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:restore_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("restore_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.restore_crypto_key_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.restore_crypto_key_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes restore_crypto_key_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::RestoreCryptoKeyVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:restore_crypto_key_version, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("restore_crypto_key_version")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.restore_crypto_key_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_public_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#get_public_key."

    it 'invokes get_public_key without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Create expected grpc response
      pem = "pem110872"
      expected_response = { pem: pem }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::PublicKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_public_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.get_public_key(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_public_key(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_public_key with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::GetPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_public_key")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_public_key(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'asymmetric_decrypt' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#asymmetric_decrypt."

    it 'invokes asymmetric_decrypt without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
      ciphertext = ''

      # Create expected grpc response
      plaintext = "-9"
      expected_response = { plaintext: plaintext }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::AsymmetricDecryptResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::AsymmetricDecryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ciphertext, request.ciphertext)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:asymmetric_decrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("asymmetric_decrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.asymmetric_decrypt(formatted_name, ciphertext)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.asymmetric_decrypt(formatted_name, ciphertext) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes asymmetric_decrypt with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
      ciphertext = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::AsymmetricDecryptRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ciphertext, request.ciphertext)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:asymmetric_decrypt, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("asymmetric_decrypt")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.asymmetric_decrypt(formatted_name, ciphertext)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'asymmetric_sign' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#asymmetric_sign."

    it 'invokes asymmetric_sign without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
      digest = {}

      # Create expected grpc response
      signature = "-72"
      expected_response = { signature: signature }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Kms::V1::AsymmetricSignResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::AsymmetricSignRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(digest, Google::Cloud::Kms::V1::Digest), request.digest)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:asymmetric_sign, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("asymmetric_sign")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.asymmetric_sign(formatted_name, digest)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.asymmetric_sign(formatted_name, digest) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes asymmetric_sign with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
      digest = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Kms::V1::AsymmetricSignRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(digest, Google::Cloud::Kms::V1::Digest), request.digest)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:asymmetric_sign, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("asymmetric_sign")

      Google::Cloud::Kms::V1::KeyManagementService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.asymmetric_sign(formatted_name, digest)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      policy = {}

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("set_iam_policy")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.set_iam_policy(formatted_resource, policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_iam_policy(formatted_resource, policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("set_iam_policy")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.set_iam_policy(formatted_resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_iam_policy")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.get_iam_policy(formatted_resource)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_iam_policy(formatted_resource) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("get_iam_policy")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_iam_policy(formatted_resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Kms::V1::KeyManagementServiceClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("test_iam_permissions")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          response = client.test_iam_permissions(formatted_resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.test_iam_permissions(formatted_resource, permissions) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockKeyManagementServiceCredentials_v1.new("test_iam_permissions")

      Google::Iam::V1::IAMPolicy::Stub.stub(:new, mock_stub) do
        Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Kms.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.test_iam_permissions(formatted_resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end