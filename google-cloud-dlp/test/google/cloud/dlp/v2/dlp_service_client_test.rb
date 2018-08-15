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

require "google/cloud/dlp"
require "google/cloud/dlp/v2/dlp_service_client"
require "google/privacy/dlp/v2/dlp_services_pb"

class CustomTestError_v2 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v2

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

class MockDlpServiceCredentials_v2 < Google::Cloud::Dlp::V2::Credentials
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

describe Google::Cloud::Dlp::V2::DlpServiceClient do

  describe 'inspect_content' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#inspect_content."

    it 'invokes inspect_content without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::InspectContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::InspectContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:inspect_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("inspect_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.inspect_content(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.inspect_content(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes inspect_content with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::InspectContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:inspect_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("inspect_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.inspect_content(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'redact_image' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#redact_image."

    it 'invokes redact_image without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      redacted_image = "28"
      extracted_text = "extractedText998260012"
      expected_response = { redacted_image: redacted_image, extracted_text: extracted_text }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::RedactImageResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::RedactImageRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:redact_image, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("redact_image")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.redact_image(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.redact_image(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes redact_image with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::RedactImageRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:redact_image, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("redact_image")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.redact_image(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'deidentify_content' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#deidentify_content."

    it 'invokes deidentify_content without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DeidentifyContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeidentifyContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:deidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("deidentify_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.deidentify_content(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.deidentify_content(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes deidentify_content with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeidentifyContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:deidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("deidentify_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.deidentify_content(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'reidentify_content' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#reidentify_content."

    it 'invokes reidentify_content without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ReidentifyContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ReidentifyContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:reidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("reidentify_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.reidentify_content(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.reidentify_content(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes reidentify_content with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ReidentifyContentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:reidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("reidentify_content")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.reidentify_content(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_info_types' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#list_info_types."

    it 'invokes list_info_types without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ListInfoTypesResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_info_types, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_info_types")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.list_info_types

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_info_types do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_info_types with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_info_types, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_info_types")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_info_types
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_inspect_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#create_inspect_template."

    it 'invokes create_inspect_template without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::InspectTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateInspectTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.create_inspect_template(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_inspect_template(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_inspect_template with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateInspectTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_inspect_template(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_inspect_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#update_inspect_template."

    it 'invokes update_inspect_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::InspectTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateInspectTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.update_inspect_template(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_inspect_template(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_inspect_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateInspectTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_inspect_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_inspect_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#get_inspect_template."

    it 'invokes get_inspect_template without error' do
      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::InspectTemplate)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.get_inspect_template

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_inspect_template do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_inspect_template with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_inspect_template
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_inspect_templates' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#list_inspect_templates."

    it 'invokes list_inspect_templates without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      next_page_token = ""
      inspect_templates_element = {}
      inspect_templates = [inspect_templates_element]
      expected_response = { next_page_token: next_page_token, inspect_templates: inspect_templates }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ListInspectTemplatesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListInspectTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_inspect_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_inspect_templates")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.list_inspect_templates(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.inspect_templates.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_inspect_templates with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListInspectTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_inspect_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_inspect_templates")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_inspect_templates(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_inspect_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#delete_inspect_template."

    it 'invokes delete_inspect_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteInspectTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.delete_inspect_template(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_inspect_template(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_inspect_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteInspectTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_inspect_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_inspect_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_inspect_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_deidentify_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#create_deidentify_template."

    it 'invokes create_deidentify_template without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DeidentifyTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateDeidentifyTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.create_deidentify_template(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_deidentify_template(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_deidentify_template with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateDeidentifyTemplateRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_deidentify_template(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_deidentify_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#update_deidentify_template."

    it 'invokes update_deidentify_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DeidentifyTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.update_deidentify_template(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_deidentify_template(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_deidentify_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_deidentify_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_deidentify_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#get_deidentify_template."

    it 'invokes get_deidentify_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DeidentifyTemplate)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.get_deidentify_template(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_deidentify_template(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_deidentify_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_deidentify_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_deidentify_templates' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#list_deidentify_templates."

    it 'invokes list_deidentify_templates without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      next_page_token = ""
      deidentify_templates_element = {}
      deidentify_templates = [deidentify_templates_element]
      expected_response = { next_page_token: next_page_token, deidentify_templates: deidentify_templates }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ListDeidentifyTemplatesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListDeidentifyTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_deidentify_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_deidentify_templates")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.list_deidentify_templates(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.deidentify_templates.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_deidentify_templates with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListDeidentifyTemplatesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_deidentify_templates, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_deidentify_templates")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_deidentify_templates(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_deidentify_template' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#delete_deidentify_template."

    it 'invokes delete_deidentify_template without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.delete_deidentify_template(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_deidentify_template(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_deidentify_template with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteDeidentifyTemplateRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_deidentify_template, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_deidentify_template")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_deidentify_template(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_dlp_job' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#create_dlp_job."

    it 'invokes create_dlp_job without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      name = "name3373707"
      job_trigger_name = "jobTriggerName1819490804"
      expected_response = { name: name, job_trigger_name: job_trigger_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DlpJob)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateDlpJobRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.create_dlp_job(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_dlp_job(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_dlp_job with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateDlpJobRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_dlp_job(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_dlp_jobs' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#list_dlp_jobs."

    it 'invokes list_dlp_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      jobs_element = {}
      jobs = [jobs_element]
      expected_response = { next_page_token: next_page_token, jobs: jobs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ListDlpJobsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListDlpJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_dlp_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_dlp_jobs")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.list_dlp_jobs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.jobs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_dlp_jobs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListDlpJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_dlp_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_dlp_jobs")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_dlp_jobs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_dlp_job' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#get_dlp_job."

    it 'invokes get_dlp_job without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      job_trigger_name = "jobTriggerName1819490804"
      expected_response = { name: name_2, job_trigger_name: job_trigger_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::DlpJob)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.get_dlp_job(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_dlp_job(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_dlp_job with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_dlp_job(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_dlp_job' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#delete_dlp_job."

    it 'invokes delete_dlp_job without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.delete_dlp_job(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_dlp_job(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_dlp_job with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_dlp_job(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_dlp_job' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#cancel_dlp_job."

    it 'invokes cancel_dlp_job without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CancelDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:cancel_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("cancel_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.cancel_dlp_job(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.cancel_dlp_job(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_dlp_job with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CancelDlpJobRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:cancel_dlp_job, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("cancel_dlp_job")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.cancel_dlp_job(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_job_triggers' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#list_job_triggers."

    it 'invokes list_job_triggers without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      job_triggers_element = {}
      job_triggers = [job_triggers_element]
      expected_response = { next_page_token: next_page_token, job_triggers: job_triggers }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::ListJobTriggersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListJobTriggersRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_job_triggers, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_job_triggers")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.list_job_triggers(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.job_triggers.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_job_triggers with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::ListJobTriggersRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_job_triggers, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("list_job_triggers")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_job_triggers(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_job_trigger' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#get_job_trigger."

    it 'invokes get_job_trigger without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::JobTrigger)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetJobTriggerRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.get_job_trigger(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_job_trigger(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_job_trigger with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::GetJobTriggerRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("get_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_job_trigger(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_job_trigger' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#delete_job_trigger."

    it 'invokes delete_job_trigger without error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteJobTriggerRequest, request)
        assert_equal(name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.delete_job_trigger(name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_job_trigger(name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_job_trigger with error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::DeleteJobTriggerRequest, request)
        assert_equal(name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("delete_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_job_trigger(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_job_trigger' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#update_job_trigger."

    it 'invokes update_job_trigger without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::JobTrigger)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateJobTriggerRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.update_job_trigger(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_job_trigger(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_job_trigger with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::UpdateJobTriggerRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("update_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_job_trigger(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_job_trigger' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dlp::V2::DlpServiceClient#create_job_trigger."

    it 'invokes create_job_trigger without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2::JobTrigger)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateJobTriggerRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          response = client.create_job_trigger(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_job_trigger(formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_job_trigger with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2::CreateJobTriggerRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_job_trigger, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials_v2.new("create_job_trigger")

      Google::Privacy::Dlp::V2::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_job_trigger(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end