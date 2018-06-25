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

require "google/cloud/tasks/v2beta2"
require "google/cloud/tasks/v2beta2/cloud_tasks_client"
require "google/cloud/tasks/v2beta2/cloudtasks_services_pb"

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

class MockCloudTasksCredentials < Google::Cloud::Tasks::V2beta2::Credentials
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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#list_queues."

    it 'invokes list_queues without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      queues_element = {}
      queues = [queues_element]
      expected_response = { next_page_token: next_page_token, queues: queues }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::ListQueuesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ListQueuesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_queues, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("list_queues")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.list_queues(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.queues.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_queues with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ListQueuesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_queues, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("list_queues")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_queues(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_queue."

    it 'invokes get_queue without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::GetQueueRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("get_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.get_queue(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_queue(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_queue with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::GetQueueRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("get_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_queue(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#create_queue."

    it 'invokes create_queue without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")
      queue = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CreateQueueRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(queue, Google::Cloud::Tasks::V2beta2::Queue), request.queue)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("create_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.create_queue(formatted_parent, queue)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_queue(formatted_parent, queue) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_queue with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")
      queue = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CreateQueueRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(queue, Google::Cloud::Tasks::V2beta2::Queue), request.queue)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("create_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_queue(formatted_parent, queue)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#update_queue."

    it 'invokes update_queue without error' do
      # Create request parameters
      queue = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::UpdateQueueRequest, request)
        assert_equal(Google::Gax::to_proto(queue, Google::Cloud::Tasks::V2beta2::Queue), request.queue)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("update_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.update_queue(queue)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_queue(queue) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_queue with error' do
      # Create request parameters
      queue = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::UpdateQueueRequest, request)
        assert_equal(Google::Gax::to_proto(queue, Google::Cloud::Tasks::V2beta2::Queue), request.queue)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("update_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_queue(queue)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#delete_queue."

    it 'invokes delete_queue without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::DeleteQueueRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("delete_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.delete_queue(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_queue(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_queue with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::DeleteQueueRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("delete_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_queue(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'purge_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#purge_queue."

    it 'invokes purge_queue without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::PurgeQueueRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:purge_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("purge_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.purge_queue(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.purge_queue(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes purge_queue with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::PurgeQueueRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:purge_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("purge_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.purge_queue(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'pause_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#pause_queue."

    it 'invokes pause_queue without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::PauseQueueRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:pause_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("pause_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.pause_queue(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.pause_queue(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes pause_queue with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::PauseQueueRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:pause_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("pause_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.pause_queue(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'resume_queue' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#resume_queue."

    it 'invokes resume_queue without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Queue)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ResumeQueueRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:resume_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("resume_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.resume_queue(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.resume_queue(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes resume_queue with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ResumeQueueRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:resume_queue, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("resume_queue")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.resume_queue(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

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
      mock_credentials = MockCloudTasksCredentials.new("get_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("get_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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

  describe 'set_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
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
      mock_credentials = MockCloudTasksCredentials.new("set_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
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
      mock_credentials = MockCloudTasksCredentials.new("set_iam_policy")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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

  describe 'test_iam_permissions' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
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
      mock_credentials = MockCloudTasksCredentials.new("test_iam_permissions")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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
      formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
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
      mock_credentials = MockCloudTasksCredentials.new("test_iam_permissions")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

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

  describe 'list_tasks' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#list_tasks."

    it 'invokes list_tasks without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Create expected grpc response
      next_page_token = ""
      tasks_element = {}
      tasks = [tasks_element]
      expected_response = { next_page_token: next_page_token, tasks: tasks }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::ListTasksResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ListTasksRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("list_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.list_tasks(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.tasks.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_tasks with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::ListTasksRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("list_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_tasks(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_task' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#get_task."

    it 'invokes get_task without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::GetTaskRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("get_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.get_task(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_task(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_task with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::GetTaskRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("get_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_task(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_task' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#create_task."

    it 'invokes create_task without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
      task = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CreateTaskRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(task, Google::Cloud::Tasks::V2beta2::Task), request.task)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("create_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.create_task(formatted_parent, task)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_task(formatted_parent, task) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_task with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
      task = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CreateTaskRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(task, Google::Cloud::Tasks::V2beta2::Task), request.task)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("create_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_task(formatted_parent, task)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_task' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#delete_task."

    it 'invokes delete_task without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::DeleteTaskRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("delete_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.delete_task(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_task(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_task with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::DeleteTaskRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("delete_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_task(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'lease_tasks' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#lease_tasks."

    it 'invokes lease_tasks without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
      lease_duration = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::LeaseTasksResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::LeaseTasksRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(lease_duration, Google::Protobuf::Duration), request.lease_duration)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:lease_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("lease_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.lease_tasks(formatted_parent, lease_duration)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.lease_tasks(formatted_parent, lease_duration) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes lease_tasks with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
      lease_duration = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::LeaseTasksRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(lease_duration, Google::Protobuf::Duration), request.lease_duration)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:lease_tasks, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("lease_tasks")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.lease_tasks(formatted_parent, lease_duration)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'acknowledge_task' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#acknowledge_task."

    it 'invokes acknowledge_task without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::AcknowledgeTaskRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:acknowledge_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("acknowledge_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.acknowledge_task(formatted_name, schedule_time)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.acknowledge_task(formatted_name, schedule_time) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes acknowledge_task with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::AcknowledgeTaskRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:acknowledge_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("acknowledge_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.acknowledge_task(formatted_name, schedule_time)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'renew_lease' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#renew_lease."

    it 'invokes renew_lease without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}
      lease_duration = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::RenewLeaseRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        assert_equal(Google::Gax::to_proto(lease_duration, Google::Protobuf::Duration), request.lease_duration)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:renew_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("renew_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.renew_lease(
            formatted_name,
            schedule_time,
            lease_duration
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.renew_lease(
            formatted_name,
            schedule_time,
            lease_duration
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes renew_lease with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}
      lease_duration = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::RenewLeaseRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        assert_equal(Google::Gax::to_proto(lease_duration, Google::Protobuf::Duration), request.lease_duration)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:renew_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("renew_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.renew_lease(
              formatted_name,
              schedule_time,
              lease_duration
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_lease' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#cancel_lease."

    it 'invokes cancel_lease without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CancelLeaseRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:cancel_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("cancel_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.cancel_lease(formatted_name, schedule_time)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.cancel_lease(formatted_name, schedule_time) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_lease with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
      schedule_time = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::CancelLeaseRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(schedule_time, Google::Protobuf::Timestamp), request.schedule_time)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:cancel_lease, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("cancel_lease")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.cancel_lease(formatted_name, schedule_time)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_task' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Tasks::V2beta2::CloudTasksClient#run_task."

    it 'invokes run_task without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta2::Task)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::RunTaskRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:run_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("run_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          response = client.run_task(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.run_task(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes run_task with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Tasks::V2beta2::RunTaskRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:run_task, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudTasksCredentials.new("run_task")

      Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.stub(:new, mock_stub) do
        Google::Cloud::Tasks::V2beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Tasks::V2beta2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.run_task(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end