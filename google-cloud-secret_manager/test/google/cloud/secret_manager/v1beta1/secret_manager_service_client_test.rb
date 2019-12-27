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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/secret_manager"
require "google/cloud/secret_manager/v1beta1/secret_manager_service_client"
require "google/cloud/secret_manager/v1beta1/service_services_pb"

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

class MockSecretManagerServiceCredentials_v1beta1 < Google::Cloud::SecretManager::V1beta1::Credentials
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

describe Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient do

  describe 'list_secrets' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#list_secrets."

    it 'invokes list_secrets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      secrets_element = {}
      secrets = [secrets_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        secrets: secrets
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::ListSecretsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::ListSecretsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_secrets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("list_secrets")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.list_secrets(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.secrets.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_secrets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::ListSecretsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_secrets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("list_secrets")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_secrets(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_secret' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#create_secret."

    it 'invokes create_secret without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")
      secret_id = ''

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::Secret)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::CreateSecretRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(secret_id, request.secret_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("create_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.create_secret(formatted_parent, secret_id)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_secret(formatted_parent, secret_id) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_secret with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")
      secret_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::CreateSecretRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(secret_id, request.secret_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("create_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.create_secret(formatted_parent, secret_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'add_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#add_secret_version."

    it 'invokes add_secret_version without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
      payload = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::SecretVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::AddSecretVersionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(payload, Google::Cloud::SecretManager::V1beta1::SecretPayload), request.payload)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:add_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("add_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.add_secret_version(formatted_parent, payload)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.add_secret_version(formatted_parent, payload) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes add_secret_version with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
      payload = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::AddSecretVersionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(payload, Google::Cloud::SecretManager::V1beta1::SecretPayload), request.payload)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:add_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("add_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.add_secret_version(formatted_parent, payload)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_secret' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#get_secret."

    it 'invokes get_secret without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::Secret)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::GetSecretRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.get_secret(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_secret(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_secret with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::GetSecretRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_secret(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_secret' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#update_secret."

    it 'invokes update_secret without error' do
      # Create request parameters
      secret = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::Secret)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::UpdateSecretRequest, request)
        assert_equal(Google::Gax::to_proto(secret, Google::Cloud::SecretManager::V1beta1::Secret), request.secret)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("update_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.update_secret(secret, update_mask)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_secret(secret, update_mask) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_secret with error' do
      # Create request parameters
      secret = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::UpdateSecretRequest, request)
        assert_equal(Google::Gax::to_proto(secret, Google::Cloud::SecretManager::V1beta1::Secret), request.secret)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("update_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.update_secret(secret, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_secret' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#delete_secret."

    it 'invokes delete_secret without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DeleteSecretRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("delete_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.delete_secret(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_secret(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_secret with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DeleteSecretRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_secret, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("delete_secret")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.delete_secret(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_secret_versions' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#list_secret_versions."

    it 'invokes list_secret_versions without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      versions_element = {}
      versions = [versions_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        versions: versions
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::ListSecretVersionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::ListSecretVersionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_secret_versions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("list_secret_versions")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.list_secret_versions(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.versions.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_secret_versions with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::ListSecretVersionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_secret_versions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("list_secret_versions")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_secret_versions(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#get_secret_version."

    it 'invokes get_secret_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::SecretVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::GetSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.get_secret_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_secret_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_secret_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::GetSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_secret_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'access_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#access_secret_version."

    it 'invokes access_secret_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::AccessSecretVersionResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::AccessSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:access_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("access_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.access_secret_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.access_secret_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes access_secret_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::AccessSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:access_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("access_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.access_secret_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'disable_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#disable_secret_version."

    it 'invokes disable_secret_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::SecretVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DisableSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:disable_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("disable_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.disable_secret_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.disable_secret_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes disable_secret_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DisableSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:disable_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("disable_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.disable_secret_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'enable_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#enable_secret_version."

    it 'invokes enable_secret_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::SecretVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::EnableSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:enable_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("enable_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.enable_secret_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.enable_secret_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes enable_secret_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::EnableSecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:enable_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("enable_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.enable_secret_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'destroy_secret_version' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#destroy_secret_version."

    it 'invokes destroy_secret_version without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecretManager::V1beta1::SecretVersion)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DestroySecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:destroy_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("destroy_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.destroy_secret_version(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.destroy_secret_version(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes destroy_secret_version with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecretManager::V1beta1::DestroySecretVersionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:destroy_secret_version, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("destroy_secret_version")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.destroy_secret_version(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      resource = ''
      policy = {}

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("set_iam_policy")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.set_iam_policy(resource, policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_iam_policy(resource, policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      resource = ''
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("set_iam_policy")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.set_iam_policy(resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      resource = ''

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_iam_policy")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.get_iam_policy(resource)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_iam_policy(resource) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      resource = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("get_iam_policy")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_iam_policy(resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      resource = ''
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(permissions, request.permissions)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("test_iam_permissions")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          response = client.test_iam_permissions(resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.test_iam_permissions(resource, permissions) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      resource = ''
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecretManagerServiceCredentials_v1beta1.new("test_iam_permissions")

      Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecretManager::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecretManager.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.test_iam_permissions(resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end