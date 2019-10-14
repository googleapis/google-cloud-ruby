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

require "helper"

require "google/gax"

require "google/cloud/talent"
require "google/cloud/talent/v4beta1/application_service_client"
require "google/cloud/talent/v4beta1/application_service_services_pb"

class CustomTestError_v4beta1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v4beta1

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

class MockApplicationServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::ApplicationServiceClient do

  describe 'create_application' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ApplicationServiceClient#create_application."

    it 'invokes create_application without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
      application = {}

      # Create expected grpc response
      name = "name3373707"
      external_id = "externalId-1153075697"
      profile = "profile-309425751"
      job = "job105405"
      company = "company950484093"
      outcome_notes = "outcomeNotes-355961964"
      job_title_snippet = "jobTitleSnippet-1100512972"
      expected_response = {
        name: name,
        external_id: external_id,
        profile: profile,
        job: job,
        company: company,
        outcome_notes: outcome_notes,
        job_title_snippet: job_title_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Application)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateApplicationRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(application, Google::Cloud::Talent::V4beta1::Application), request.application)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("create_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          response = client.create_application(formatted_parent, application)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_application(formatted_parent, application) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_application with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
      application = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateApplicationRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(application, Google::Cloud::Talent::V4beta1::Application), request.application)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("create_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.create_application(formatted_parent, application)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_application' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ApplicationServiceClient#get_application."

    it 'invokes get_application without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      external_id = "externalId-1153075697"
      profile = "profile-309425751"
      job = "job105405"
      company = "company950484093"
      outcome_notes = "outcomeNotes-355961964"
      job_title_snippet = "jobTitleSnippet-1100512972"
      expected_response = {
        name: name_2,
        external_id: external_id,
        profile: profile,
        job: job,
        company: company,
        outcome_notes: outcome_notes,
        job_title_snippet: job_title_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Application)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetApplicationRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("get_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          response = client.get_application(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_application(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_application with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetApplicationRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("get_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.get_application(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_application' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ApplicationServiceClient#update_application."

    it 'invokes update_application without error' do
      # Create request parameters
      application = {}

      # Create expected grpc response
      name = "name3373707"
      external_id = "externalId-1153075697"
      profile = "profile-309425751"
      job = "job105405"
      company = "company950484093"
      outcome_notes = "outcomeNotes-355961964"
      job_title_snippet = "jobTitleSnippet-1100512972"
      expected_response = {
        name: name,
        external_id: external_id,
        profile: profile,
        job: job,
        company: company,
        outcome_notes: outcome_notes,
        job_title_snippet: job_title_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Application)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateApplicationRequest, request)
        assert_equal(Google::Gax::to_proto(application, Google::Cloud::Talent::V4beta1::Application), request.application)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("update_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          response = client.update_application(application)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_application(application) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_application with error' do
      # Create request parameters
      application = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateApplicationRequest, request)
        assert_equal(Google::Gax::to_proto(application, Google::Cloud::Talent::V4beta1::Application), request.application)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("update_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.update_application(application)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_application' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ApplicationServiceClient#delete_application."

    it 'invokes delete_application without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteApplicationRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("delete_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          response = client.delete_application(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_application(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_application with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteApplicationRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_application, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("delete_application")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.delete_application(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_applications' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ApplicationServiceClient#list_applications."

    it 'invokes list_applications without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Create expected grpc response
      next_page_token = ""
      applications_element = {}
      applications = [applications_element]
      expected_response = { next_page_token: next_page_token, applications: applications }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ListApplicationsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListApplicationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_applications, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("list_applications")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          response = client.list_applications(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.applications.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_applications with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListApplicationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_applications, mock_method)

      # Mock auth layer
      mock_credentials = MockApplicationServiceCredentials_v4beta1.new("list_applications")

      Google::Cloud::Talent::V4beta1::ApplicationService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.list_applications(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
