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

require "google/cloud/tasks"
require "google/cloud/tasks/v2beta2/cloud_tasks_client"
require "google/cloud/tasks/v2beta2/cloudtasks_services_pb"

class CustomTestError_v2beta2 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v2beta2

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

class MockCloudTasksCredentials_v2beta2 < Google::Cloud::Tasks::V2beta2::Credentials
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

describe Google::Cloud::Tasks::V2beta2::CloudTasksClient do

  describe 'list_queues' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#list_queues."

    it 'invokes list_queues without error' do
      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::ListQueuesResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:list_queues, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("list_queues")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.list_queues

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_queues do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_queues with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:list_queues, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("list_queues")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.list_queues
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_queue."

    it 'invokes get_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.get_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.get_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#create_queue."

    it 'invokes create_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:create_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("create_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.create_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:create_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("create_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.create_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#update_queue."

    it 'invokes update_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:update_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("update_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.update_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:update_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("update_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.update_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#delete_queue."

    it 'invokes delete_queue without error' do

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:delete_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("delete_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.delete_queue

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_queue do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:delete_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("delete_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.delete_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'purge_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#purge_queue."

    it 'invokes purge_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:purge_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("purge_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.purge_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.purge_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes purge_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:purge_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("purge_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.purge_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'pause_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#pause_queue."

    it 'invokes pause_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:pause_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("pause_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.pause_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.pause_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes pause_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:pause_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("pause_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.pause_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'resume_queue' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#resume_queue."

    it 'invokes resume_queue without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:resume_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("resume_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.resume_queue

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.resume_queue do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes resume_queue with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:resume_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("resume_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.resume_queue
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.get_iam_policy

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_iam_policy do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.get_iam_policy
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("set_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.set_iam_policy

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_iam_policy do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("set_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.set_iam_policy
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("test_iam_permissions")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.test_iam_permissions

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.test_iam_permissions do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("test_iam_permissions")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.test_iam_permissions
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_tasks' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#list_tasks."

    it 'invokes list_tasks without error' do
      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::ListTasksResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:list_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("list_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.list_tasks

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_tasks do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_tasks with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:list_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("list_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.list_tasks
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_task' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_task."

    it 'invokes get_task without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.get_task

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_task do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_task with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:get_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("get_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.get_task
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_task' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#create_task."

    it 'invokes create_task without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:create_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("create_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.create_task

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_task do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_task with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:create_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("create_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.create_task
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_task' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#delete_task."

    it 'invokes delete_task without error' do

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:delete_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("delete_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.delete_task

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_task do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_task with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:delete_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("delete_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.delete_task
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'lease_tasks' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#lease_tasks."

    it 'invokes lease_tasks without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::LeaseTasksResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:lease_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("lease_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.lease_tasks

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.lease_tasks do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes lease_tasks with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:lease_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("lease_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.lease_tasks
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'acknowledge_task' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#acknowledge_task."

    it 'invokes acknowledge_task without error' do

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:acknowledge_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("acknowledge_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.acknowledge_task

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.acknowledge_task do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes acknowledge_task with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:acknowledge_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("acknowledge_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.acknowledge_task
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'renew_lease' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#renew_lease."

    it 'invokes renew_lease without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:renew_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("renew_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.renew_lease

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.renew_lease do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes renew_lease with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:renew_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("renew_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.renew_lease
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_lease' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#cancel_lease."

    it 'invokes cancel_lease without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:cancel_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("cancel_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.cancel_lease

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.cancel_lease do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_lease with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:cancel_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("cancel_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.cancel_lease
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_task' do
    custom_error = CustomTestError_v2beta2.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#run_task."

    it 'invokes run_task without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:run_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("run_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          response = client.run_task

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.run_task do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes run_task with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2beta2.new(:run_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials_v2beta2.new("run_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks.new(version: :v2beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2beta2 do
            client.run_task
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end