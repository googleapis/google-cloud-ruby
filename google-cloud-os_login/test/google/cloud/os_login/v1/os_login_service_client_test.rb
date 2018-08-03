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

require "google/cloud/os_login"
require "google/cloud/os_login/v1/os_login_service_client"
require "google/cloud/oslogin/v1/oslogin_services_pb"

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

class MockOsLoginServiceCredentials_v1 < Google::Cloud::OsLogin::V1::Credentials
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

describe Google::Cloud::OsLogin::V1::OsLoginServiceClient do

  describe 'delete_posix_account' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#delete_posix_account."

    it 'invokes delete_posix_account without error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.project_path("[USER]", "[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::DeletePosixAccountRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_posix_account, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("delete_posix_account")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.delete_posix_account(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_posix_account(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_posix_account with error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.project_path("[USER]", "[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::DeletePosixAccountRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_posix_account, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("delete_posix_account")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_posix_account(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_ssh_public_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#delete_ssh_public_key."

    it 'invokes delete_ssh_public_key without error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::DeleteSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("delete_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.delete_ssh_public_key(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_ssh_public_key(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_ssh_public_key with error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::DeleteSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("delete_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_ssh_public_key(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_login_profile' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#get_login_profile."

    it 'invokes get_login_profile without error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      suspended = false
      expected_response = { name: name_2, suspended: suspended }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Oslogin::V1::LoginProfile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::GetLoginProfileRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_login_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("get_login_profile")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.get_login_profile(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_login_profile(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_login_profile with error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::GetLoginProfileRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_login_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("get_login_profile")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_login_profile(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_ssh_public_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#get_ssh_public_key."

    it 'invokes get_ssh_public_key without error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")

      # Create expected grpc response
      key = "key106079"
      expiration_time_usec = 2058878882
      fingerprint = "fingerprint-1375934236"
      expected_response = {
        key: key,
        expiration_time_usec: expiration_time_usec,
        fingerprint: fingerprint
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Oslogin::Common::SshPublicKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::GetSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("get_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.get_ssh_public_key(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_ssh_public_key(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_ssh_public_key with error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::GetSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("get_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_ssh_public_key(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'import_ssh_public_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#import_ssh_public_key."

    it 'invokes import_ssh_public_key without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")
      ssh_public_key = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Oslogin::V1::ImportSshPublicKeyResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::ImportSshPublicKeyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(ssh_public_key, Google::Cloud::Oslogin::Common::SshPublicKey), request.ssh_public_key)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("import_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.import_ssh_public_key(formatted_parent, ssh_public_key)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.import_ssh_public_key(formatted_parent, ssh_public_key) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes import_ssh_public_key with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")
      ssh_public_key = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::ImportSshPublicKeyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(ssh_public_key, Google::Cloud::Oslogin::Common::SshPublicKey), request.ssh_public_key)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("import_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.import_ssh_public_key(formatted_parent, ssh_public_key)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_ssh_public_key' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::OsLogin::V1::OsLoginServiceClient#update_ssh_public_key."

    it 'invokes update_ssh_public_key without error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")
      ssh_public_key = {}

      # Create expected grpc response
      key = "key106079"
      expiration_time_usec = 2058878882
      fingerprint = "fingerprint-1375934236"
      expected_response = {
        key: key,
        expiration_time_usec: expiration_time_usec,
        fingerprint: fingerprint
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Oslogin::Common::SshPublicKey)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::UpdateSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(ssh_public_key, Google::Cloud::Oslogin::Common::SshPublicKey), request.ssh_public_key)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("update_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          response = client.update_ssh_public_key(formatted_name, ssh_public_key)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_ssh_public_key(formatted_name, ssh_public_key) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_ssh_public_key with error' do
      # Create request parameters
      formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.fingerprint_path("[USER]", "[FINGERPRINT]")
      ssh_public_key = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Oslogin::V1::UpdateSshPublicKeyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(ssh_public_key, Google::Cloud::Oslogin::Common::SshPublicKey), request.ssh_public_key)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_ssh_public_key, mock_method)

      # Mock auth layer
      mock_credentials = MockOsLoginServiceCredentials_v1.new("update_ssh_public_key")

      Google::Cloud::Oslogin::V1::OsLoginService::Stub.stub(:new, mock_stub) do
        Google::Cloud::OsLogin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::OsLogin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_ssh_public_key(formatted_name, ssh_public_key)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end