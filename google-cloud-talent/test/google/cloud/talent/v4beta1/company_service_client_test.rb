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
require "google/cloud/talent/v4beta1/company_service_client"
require "google/cloud/talent/v4beta1/company_service_services_pb"

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

class MockCompanyServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::CompanyServiceClient do

  describe 'create_company' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompanyServiceClient#create_company."

    it 'invokes create_company without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompanyServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      company = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      external_id = "externalId-1153075697"
      headquarters_address = "headquartersAddress-1879520036"
      hiring_agency = false
      eeo_text = "eeoText-1652097123"
      website_uri = "websiteUri-2118185016"
      career_site_uri = "careerSiteUri1223331861"
      image_uri = "imageUri-877823864"
      suspended = false
      expected_response = {
        name: name,
        display_name: display_name,
        external_id: external_id,
        headquarters_address: headquarters_address,
        hiring_agency: hiring_agency,
        eeo_text: eeo_text,
        website_uri: website_uri,
        career_site_uri: career_site_uri,
        image_uri: image_uri,
        suspended: suspended
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Company)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateCompanyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(company, Google::Cloud::Talent::V4beta1::Company), request.company)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("create_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          response = client.create_company(formatted_parent, company)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_company(formatted_parent, company) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_company with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompanyServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      company = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateCompanyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(company, Google::Cloud::Talent::V4beta1::Company), request.company)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("create_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.create_company(formatted_parent, company)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_company' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompanyServiceClient#get_company."

    it 'invokes get_company without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::CompanyServiceClient.company_path("[PROJECT]", "[TENANT]", "[COMPANY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      external_id = "externalId-1153075697"
      headquarters_address = "headquartersAddress-1879520036"
      hiring_agency = false
      eeo_text = "eeoText-1652097123"
      website_uri = "websiteUri-2118185016"
      career_site_uri = "careerSiteUri1223331861"
      image_uri = "imageUri-877823864"
      suspended = false
      expected_response = {
        name: name_2,
        display_name: display_name,
        external_id: external_id,
        headquarters_address: headquarters_address,
        hiring_agency: hiring_agency,
        eeo_text: eeo_text,
        website_uri: website_uri,
        career_site_uri: career_site_uri,
        image_uri: image_uri,
        suspended: suspended
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Company)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetCompanyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("get_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          response = client.get_company(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_company(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_company with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::CompanyServiceClient.company_path("[PROJECT]", "[TENANT]", "[COMPANY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetCompanyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("get_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.get_company(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_company' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompanyServiceClient#update_company."

    it 'invokes update_company without error' do
      # Create request parameters
      company = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      external_id = "externalId-1153075697"
      headquarters_address = "headquartersAddress-1879520036"
      hiring_agency = false
      eeo_text = "eeoText-1652097123"
      website_uri = "websiteUri-2118185016"
      career_site_uri = "careerSiteUri1223331861"
      image_uri = "imageUri-877823864"
      suspended = false
      expected_response = {
        name: name,
        display_name: display_name,
        external_id: external_id,
        headquarters_address: headquarters_address,
        hiring_agency: hiring_agency,
        eeo_text: eeo_text,
        website_uri: website_uri,
        career_site_uri: career_site_uri,
        image_uri: image_uri,
        suspended: suspended
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Company)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateCompanyRequest, request)
        assert_equal(Google::Gax::to_proto(company, Google::Cloud::Talent::V4beta1::Company), request.company)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("update_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          response = client.update_company(company)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_company(company) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_company with error' do
      # Create request parameters
      company = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateCompanyRequest, request)
        assert_equal(Google::Gax::to_proto(company, Google::Cloud::Talent::V4beta1::Company), request.company)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("update_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.update_company(company)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_company' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompanyServiceClient#delete_company."

    it 'invokes delete_company without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::CompanyServiceClient.company_path("[PROJECT]", "[TENANT]", "[COMPANY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteCompanyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("delete_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          response = client.delete_company(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_company(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_company with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::CompanyServiceClient.company_path("[PROJECT]", "[TENANT]", "[COMPANY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteCompanyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_company, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("delete_company")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.delete_company(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_companies' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompanyServiceClient#list_companies."

    it 'invokes list_companies without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompanyServiceClient.tenant_path("[PROJECT]", "[TENANT]")

      # Create expected grpc response
      next_page_token = ""
      companies_element = {}
      companies = [companies_element]
      expected_response = { next_page_token: next_page_token, companies: companies }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ListCompaniesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListCompaniesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_companies, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("list_companies")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          response = client.list_companies(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.companies.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_companies with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompanyServiceClient.tenant_path("[PROJECT]", "[TENANT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListCompaniesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_companies, mock_method)

      # Mock auth layer
      mock_credentials = MockCompanyServiceCredentials_v4beta1.new("list_companies")

      Google::Cloud::Talent::V4beta1::CompanyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::CompanyService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.list_companies(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
