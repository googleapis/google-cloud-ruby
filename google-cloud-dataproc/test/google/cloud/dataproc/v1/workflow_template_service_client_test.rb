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

require "google/cloud/dataproc"
require "google/cloud/dataproc/v1/workflow_template_service_client"
require "google/cloud/dataproc/v1/workflow_templates_services_pb"
require "google/longrunning/operations_pb"

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

class MockWorkflowTemplateServiceCredentials_v1 < Google::Cloud::Dataproc::V1::Credentials
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

describe Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient do

  describe 'create_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#create_workflow_template."

    it 'invokes create_workflow_template without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
      template = {}

      # Create expected grpc response
      id = "id3355"
      name = "name3373707"
      version = 351608024
      expected_response = {
        id: id,
        name: name,
        version: version
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::WorkflowTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CreateWorkflowTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("create_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.create_workflow_template(formatted_parent, template)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_workflow_template(formatted_parent, template) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_workflow_template with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
      template = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CreateWorkflowTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("create_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_workflow_template(formatted_parent, template)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#get_workflow_template."

    it 'invokes get_workflow_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Create expected grpc response
      id = "id3355"
      name_2 = "name2-1052831874"
      version = 351608024
      expected_response = {
        id: id,
        name: name_2,
        version: version
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::WorkflowTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("get_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.get_workflow_template(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_workflow_template(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_workflow_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("get_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_workflow_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'instantiate_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#instantiate_workflow_template."

    it 'invokes instantiate_workflow_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/instantiate_workflow_template_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.instantiate_workflow_template(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes instantiate_workflow_template and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#instantiate_workflow_template.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/instantiate_workflow_template_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.instantiate_workflow_template(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes instantiate_workflow_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.instantiate_workflow_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'instantiate_inline_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#instantiate_inline_workflow_template."

    it 'invokes instantiate_inline_workflow_template without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
      template = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/instantiate_inline_workflow_template_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateInlineWorkflowTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_inline_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_inline_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.instantiate_inline_workflow_template(formatted_parent, template)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes instantiate_inline_workflow_template and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
      template = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#instantiate_inline_workflow_template.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/instantiate_inline_workflow_template_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateInlineWorkflowTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_inline_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_inline_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.instantiate_inline_workflow_template(formatted_parent, template)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes instantiate_inline_workflow_template with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
      template = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::InstantiateInlineWorkflowTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:instantiate_inline_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("instantiate_inline_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.instantiate_inline_workflow_template(formatted_parent, template)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#update_workflow_template."

    it 'invokes update_workflow_template without error' do
      # Create request parameters
      template = {}

      # Create expected grpc response
      id = "id3355"
      name = "name3373707"
      version = 351608024
      expected_response = {
        id: id,
        name: name,
        version: version
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::WorkflowTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateWorkflowTemplateRequest, request)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("update_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.update_workflow_template(template)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_workflow_template(template) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_workflow_template with error' do
      # Create request parameters
      template = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateWorkflowTemplateRequest, request)
        assert_equal(Google::Gax::to_proto(template, Google::Cloud::Dataproc::V1::WorkflowTemplate), request.template)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("update_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_workflow_template(template)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_workflow_templates' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#list_workflow_templates."

    it 'invokes list_workflow_templates without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")

      # Create expected grpc response
      next_page_token = ""
      templates_element = {}
      templates = [templates_element]
      expected_response = { next_page_token: next_page_token, templates: templates }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::ListWorkflowTemplatesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListWorkflowTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_workflow_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("list_workflow_templates")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.list_workflow_templates(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.templates.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_workflow_templates with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListWorkflowTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_workflow_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("list_workflow_templates")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_workflow_templates(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_workflow_template' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient#delete_workflow_template."

    it 'invokes delete_workflow_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("delete_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          response = client.delete_workflow_template(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_workflow_template(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_workflow_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteWorkflowTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_workflow_template, mock_method)

      # Mock auth layer
      mock_credentials = MockWorkflowTemplateServiceCredentials_v1.new("delete_workflow_template")

      Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_workflow_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end