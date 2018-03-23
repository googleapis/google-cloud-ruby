# Copyright 2017 Google LLC
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

require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/database/v1/database_admin_client"
require "google/spanner/admin/database/v1/spanner_database_admin_services_pb"
require "google/longrunning/operations_pb"

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

class MockDatabaseAdminCredentials < Google::Cloud::Spanner::Admin::Database::Credentials
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

describe Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient do

  describe 'list_databases' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#list_databases."

    it 'invokes list_databases without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      next_page_token = ""
      databases_element = {}
      databases = [databases_element]
      expected_response = { next_page_token: next_page_token, databases: databases }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Database::V1::ListDatabasesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::ListDatabasesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_databases, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("list_databases")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.list_databases(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.databases.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_databases with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::ListDatabasesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_databases, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("list_databases")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_databases(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_database' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#create_database."

    it 'invokes create_database without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      create_statement = ''

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Database::V1::Database)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_database_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::CreateDatabaseRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(create_statement, request.create_statement)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("create_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.create_database(formatted_parent, create_statement)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_database and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      create_statement = ''

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#create_database.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_database_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::CreateDatabaseRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(create_statement, request.create_statement)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("create_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.create_database(formatted_parent, create_statement)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_database with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      create_statement = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::CreateDatabaseRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(create_statement, request.create_statement)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("create_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_database(formatted_parent, create_statement)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_database' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#get_database."

    it 'invokes get_database without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Database::V1::Database)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::GetDatabaseRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.get_database(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_database with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::GetDatabaseRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_database(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_database_ddl' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#update_database_ddl."

    it 'invokes update_database_ddl without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
      statements = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_database_ddl_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(statements, request.statements)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_database_ddl, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("update_database_ddl")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.update_database_ddl(formatted_database, statements)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes update_database_ddl and returns an operation error.' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
      statements = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#update_database_ddl.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_database_ddl_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(statements, request.statements)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_database_ddl, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("update_database_ddl")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.update_database_ddl(formatted_database, statements)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes update_database_ddl with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
      statements = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(statements, request.statements)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_database_ddl, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("update_database_ddl")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_database_ddl(formatted_database, statements)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'drop_database' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#drop_database."

    it 'invokes drop_database without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::DropDatabaseRequest, request)
        assert_equal(formatted_database, request.database)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:drop_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("drop_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.drop_database(formatted_database)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes drop_database with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::DropDatabaseRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:drop_database, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("drop_database")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.drop_database(formatted_database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_database_ddl' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#get_database_ddl."

    it 'invokes get_database_ddl without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Database::V1::GetDatabaseDdlResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::GetDatabaseDdlRequest, request)
        assert_equal(formatted_database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_database_ddl, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_database_ddl")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.get_database_ddl(formatted_database)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_database_ddl with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Database::V1::GetDatabaseDdlRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_database_ddl, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_database_ddl")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_database_ddl(formatted_database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
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
      mock_stub = MockGrpcClientStub.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("set_iam_policy")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.set_iam_policy(formatted_resource, policy)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("set_iam_policy")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

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
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_iam_policy")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.get_iam_policy(formatted_resource)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("get_iam_policy")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
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
      mock_stub = MockGrpcClientStub.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("test_iam_permissions")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

          # Call method
          response = client.test_iam_permissions(formatted_resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockDatabaseAdminCredentials.new("test_iam_permissions")

      Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Database::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)

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