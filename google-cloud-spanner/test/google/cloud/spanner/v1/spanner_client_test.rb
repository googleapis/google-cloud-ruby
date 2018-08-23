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

require "google/cloud/spanner/v1"
require "google/cloud/spanner/v1/spanner_client"
require "google/spanner/v1/spanner_services_pb"

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

class MockSpannerCredentials_v1 < Google::Cloud::Spanner::V1::Credentials
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

describe Google::Cloud::Spanner::V1::SpannerClient do

  describe 'create_session' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#create_session."

    it 'invokes create_session without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::Session)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::CreateSessionRequest, request)
        assert_equal(formatted_database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("create_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.create_session(formatted_database)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_session(formatted_database) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_session with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::CreateSessionRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("create_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_session(formatted_database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_session' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#get_session."

    it 'invokes get_session without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::Session)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::GetSessionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("get_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.get_session(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_session(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_session with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::GetSessionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("get_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_session(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_sessions' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#list_sessions."

    it 'invokes list_sessions without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Create expected grpc response
      next_page_token = ""
      sessions_element = {}
      sessions = [sessions_element]
      expected_response = { next_page_token: next_page_token, sessions: sessions }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::ListSessionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ListSessionsRequest, request)
        assert_equal(formatted_database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_sessions, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("list_sessions")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.list_sessions(formatted_database)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.sessions.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_sessions with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ListSessionsRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_sessions, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("list_sessions")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_sessions(formatted_database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_session' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#delete_session."

    it 'invokes delete_session without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::DeleteSessionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("delete_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.delete_session(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_session(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_session with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::DeleteSessionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_session, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("delete_session")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_session(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'execute_sql' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#execute_sql."

    it 'invokes execute_sql without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::ResultSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ExecuteSqlRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:execute_sql, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("execute_sql")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.execute_sql(formatted_session, sql)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.execute_sql(formatted_session, sql) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes execute_sql with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ExecuteSqlRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:execute_sql, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("execute_sql")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.execute_sql(formatted_session, sql)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'execute_streaming_sql' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#execute_streaming_sql."

    it 'invokes execute_streaming_sql without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Create expected grpc response
      chunked_value = true
      resume_token = "103"
      expected_response = { chunked_value: chunked_value, resume_token: resume_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::PartialResultSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ExecuteSqlRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:execute_streaming_sql, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("execute_streaming_sql")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.execute_streaming_sql(formatted_session, sql)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes execute_streaming_sql with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ExecuteSqlRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:execute_streaming_sql, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("execute_streaming_sql")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.execute_streaming_sql(formatted_session, sql)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'read' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#read."

    it 'invokes read without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      columns = []
      key_set = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::ResultSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(columns, request.columns)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.read(
            formatted_session,
            table,
            columns,
            key_set
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.read(
            formatted_session,
            table,
            columns,
            key_set
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes read with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      columns = []
      key_set = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(columns, request.columns)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.read(
              formatted_session,
              table,
              columns,
              key_set
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'streaming_read' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#streaming_read."

    it 'invokes streaming_read without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      columns = []
      key_set = {}

      # Create expected grpc response
      chunked_value = true
      resume_token = "103"
      expected_response = { chunked_value: chunked_value, resume_token: resume_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::PartialResultSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(columns, request.columns)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:streaming_read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("streaming_read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.streaming_read(
            formatted_session,
            table,
            columns,
            key_set
          )

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes streaming_read with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      columns = []
      key_set = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::ReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(columns, request.columns)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:streaming_read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("streaming_read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.streaming_read(
              formatted_session,
              table,
              columns,
              key_set
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'begin_transaction' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#begin_transaction."

    it 'invokes begin_transaction without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      options_ = {}

      # Create expected grpc response
      id = "27"
      expected_response = { id: id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::Transaction)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::BeginTransactionRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(Google::Gax::to_proto(options_, Google::Spanner::V1::TransactionOptions), request.options)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("begin_transaction")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.begin_transaction(formatted_session, options_)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.begin_transaction(formatted_session, options_) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes begin_transaction with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      options_ = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::BeginTransactionRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(Google::Gax::to_proto(options_, Google::Spanner::V1::TransactionOptions), request.options)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("begin_transaction")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.begin_transaction(formatted_session, options_)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'commit' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#commit."

    it 'invokes commit without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      mutations = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::CommitResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::CommitRequest, request)
        assert_equal(formatted_session, request.session)
        mutations = mutations.map do |req|
          Google::Gax::to_proto(req, Google::Spanner::V1::Mutation)
        end
        assert_equal(mutations, request.mutations)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("commit")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.commit(formatted_session, mutations)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.commit(formatted_session, mutations) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes commit with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      mutations = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::CommitRequest, request)
        assert_equal(formatted_session, request.session)
        mutations = mutations.map do |req|
          Google::Gax::to_proto(req, Google::Spanner::V1::Mutation)
        end
        assert_equal(mutations, request.mutations)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("commit")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.commit(formatted_session, mutations)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'rollback' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#rollback."

    it 'invokes rollback without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      transaction_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::RollbackRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(transaction_id, request.transaction_id)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("rollback")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.rollback(formatted_session, transaction_id)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.rollback(formatted_session, transaction_id) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes rollback with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      transaction_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::RollbackRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(transaction_id, request.transaction_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("rollback")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.rollback(formatted_session, transaction_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'partition_query' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#partition_query."

    it 'invokes partition_query without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::PartitionResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::PartitionQueryRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_query, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("partition_query")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.partition_query(formatted_session, sql)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.partition_query(formatted_session, sql) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes partition_query with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      sql = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::PartitionQueryRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(sql, request.sql)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_query, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("partition_query")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.partition_query(formatted_session, sql)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'partition_read' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Spanner::V1::SpannerClient#partition_read."

    it 'invokes partition_read without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      key_set = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::V1::PartitionResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::PartitionReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("partition_read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          response = client.partition_read(
            formatted_session,
            table,
            key_set
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.partition_read(
            formatted_session,
            table,
            key_set
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes partition_read with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
      table = ''
      key_set = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::V1::PartitionReadRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(table, request.table)
        assert_equal(Google::Gax::to_proto(key_set, Google::Spanner::V1::KeySet), request.key_set)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_read, mock_method)

      # Mock auth layer
      mock_credentials = MockSpannerCredentials_v1.new("partition_read")

      Google::Spanner::V1::Spanner::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::V1::SpannerClient.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.partition_read(
              formatted_session,
              table,
              key_set
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end