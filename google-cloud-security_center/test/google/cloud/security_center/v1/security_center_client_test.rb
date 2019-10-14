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

require "google/cloud/security_center"
require "google/cloud/security_center/v1/security_center_client"
require "google/cloud/security_center/v1/securitycenter_service_services_pb"
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

class MockSecurityCenterCredentials_v1 < Google::Cloud::SecurityCenter::V1::Credentials
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

describe Google::Cloud::SecurityCenter::V1::SecurityCenterClient do

  describe 'create_source' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#create_source."

    it 'invokes create_source without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
      source = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Source)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::CreateSourceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(source, Google::Cloud::SecurityCenter::V1::Source), request.source)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("create_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.create_source(formatted_parent, source)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_source(formatted_parent, source) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_source with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
      source = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::CreateSourceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(source, Google::Cloud::SecurityCenter::V1::Source), request.source)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("create_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_source(formatted_parent, source)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_finding' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#create_finding."

    it 'invokes create_finding without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      finding_id = ''
      finding = {}

      # Create expected grpc response
      name = "name3373707"
      parent_2 = "parent21175163357"
      resource_name = "resourceName979421212"
      category = "category50511102"
      external_uri = "externalUri-1385596168"
      expected_response = {
        name: name,
        parent: parent_2,
        resource_name: resource_name,
        category: category,
        external_uri: external_uri
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Finding)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::CreateFindingRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(finding_id, request.finding_id)
        assert_equal(Google::Gax::to_proto(finding, Google::Cloud::SecurityCenter::V1::Finding), request.finding)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_finding, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("create_finding")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.create_finding(
            formatted_parent,
            finding_id,
            finding
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_finding(
            formatted_parent,
            finding_id,
            finding
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_finding with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      finding_id = ''
      finding = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::CreateFindingRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(finding_id, request.finding_id)
        assert_equal(Google::Gax::to_proto(finding, Google::Cloud::SecurityCenter::V1::Finding), request.finding)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_finding, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("create_finding")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_finding(
              formatted_parent,
              finding_id,
              finding
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

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
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_iam_policy")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

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
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_iam_policy")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_iam_policy(formatted_resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_organization_settings' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#get_organization_settings."

    it 'invokes get_organization_settings without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path("[ORGANIZATION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      enable_asset_discovery = false
      expected_response = { name: name_2, enable_asset_discovery: enable_asset_discovery }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::OrganizationSettings)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GetOrganizationSettingsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_organization_settings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_organization_settings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.get_organization_settings(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_organization_settings(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_organization_settings with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GetOrganizationSettingsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_organization_settings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_organization_settings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_organization_settings(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_source' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#get_source."

    it 'invokes get_source without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Source)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GetSourceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.get_source(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_source(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_source with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GetSourceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("get_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_source(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'group_assets' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#group_assets."

    it 'invokes group_assets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
      group_by = ''

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      group_by_results_element = {}
      group_by_results = [group_by_results_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        group_by_results: group_by_results
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::GroupAssetsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GroupAssetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(group_by, request.group_by)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:group_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("group_assets")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.group_assets(formatted_parent, group_by)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.group_by_results.to_a, response.to_a)
        end
      end
    end

    it 'invokes group_assets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
      group_by = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GroupAssetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(group_by, request.group_by)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:group_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("group_assets")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.group_assets(formatted_parent, group_by)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'group_findings' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#group_findings."

    it 'invokes group_findings without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      group_by = ''

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      group_by_results_element = {}
      group_by_results = [group_by_results_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        group_by_results: group_by_results
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::GroupFindingsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GroupFindingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(group_by, request.group_by)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:group_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("group_findings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.group_findings(formatted_parent, group_by)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.group_by_results.to_a, response.to_a)
        end
      end
    end

    it 'invokes group_findings with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      group_by = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::GroupFindingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(group_by, request.group_by)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:group_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("group_findings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.group_findings(formatted_parent, group_by)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_assets' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#list_assets."

    it 'invokes list_assets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      list_assets_results_element = {}
      list_assets_results = [list_assets_results_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        list_assets_results: list_assets_results
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::ListAssetsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListAssetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_assets")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.list_assets(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.list_assets_results.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_assets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListAssetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_assets")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_assets(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_findings' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#list_findings."

    it 'invokes list_findings without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

      # Create expected grpc response
      next_page_token = ""
      total_size = 705419236
      list_findings_results_element = {}
      list_findings_results = [list_findings_results_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        list_findings_results: list_findings_results
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::ListFindingsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListFindingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_findings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.list_findings(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.list_findings_results.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_findings with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListFindingsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_findings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_findings(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_sources' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#list_sources."

    it 'invokes list_sources without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      next_page_token = ""
      sources_element = {}
      sources = [sources_element]
      expected_response = { next_page_token: next_page_token, sources: sources }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::ListSourcesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListSourcesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_sources, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_sources")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.list_sources(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.sources.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_sources with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::ListSourcesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_sources, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("list_sources")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_sources(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_asset_discovery' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#run_asset_discovery."

    it 'invokes run_asset_discovery without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/run_asset_discovery_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:run_asset_discovery, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("run_asset_discovery")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.run_asset_discovery(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes run_asset_discovery and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#run_asset_discovery.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/run_asset_discovery_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:run_asset_discovery, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("run_asset_discovery")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.run_asset_discovery(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes run_asset_discovery with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:run_asset_discovery, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("run_asset_discovery")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.run_asset_discovery(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_finding_state' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#set_finding_state."

    it 'invokes set_finding_state without error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path("[ORGANIZATION]", "[SOURCE]", "[FINDING]")
      state = :STATE_UNSPECIFIED
      start_time = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      parent = "parent-995424086"
      resource_name = "resourceName979421212"
      category = "category50511102"
      external_uri = "externalUri-1385596168"
      expected_response = {
        name: name_2,
        parent: parent,
        resource_name: resource_name,
        category: category,
        external_uri: external_uri
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Finding)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::SetFindingStateRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(state, request.state)
        assert_equal(Google::Gax::to_proto(start_time, Google::Protobuf::Timestamp), request.start_time)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_finding_state, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("set_finding_state")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.set_finding_state(
            formatted_name,
            state,
            start_time
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_finding_state(
            formatted_name,
            state,
            start_time
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_finding_state with error' do
      # Create request parameters
      formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path("[ORGANIZATION]", "[SOURCE]", "[FINDING]")
      state = :STATE_UNSPECIFIED
      start_time = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::SetFindingStateRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(state, request.state)
        assert_equal(Google::Gax::to_proto(start_time, Google::Protobuf::Timestamp), request.start_time)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_finding_state, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("set_finding_state")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_finding_state(
              formatted_name,
              state,
              start_time
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
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
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("set_iam_policy")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

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
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("set_iam_policy")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_iam_policy(formatted_resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
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
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("test_iam_permissions")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

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
      formatted_resource = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("test_iam_permissions")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.test_iam_permissions(formatted_resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_finding' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#update_finding."

    it 'invokes update_finding without error' do
      # Create request parameters
      finding = {}

      # Create expected grpc response
      name = "name3373707"
      parent = "parent-995424086"
      resource_name = "resourceName979421212"
      category = "category50511102"
      external_uri = "externalUri-1385596168"
      expected_response = {
        name: name,
        parent: parent,
        resource_name: resource_name,
        category: category,
        external_uri: external_uri
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Finding)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateFindingRequest, request)
        assert_equal(Google::Gax::to_proto(finding, Google::Cloud::SecurityCenter::V1::Finding), request.finding)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_finding, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_finding")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.update_finding(finding)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_finding(finding) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_finding with error' do
      # Create request parameters
      finding = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateFindingRequest, request)
        assert_equal(Google::Gax::to_proto(finding, Google::Cloud::SecurityCenter::V1::Finding), request.finding)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_finding, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_finding")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_finding(finding)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_organization_settings' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#update_organization_settings."

    it 'invokes update_organization_settings without error' do
      # Create request parameters
      organization_settings = {}

      # Create expected grpc response
      name = "name3373707"
      enable_asset_discovery = false
      expected_response = { name: name, enable_asset_discovery: enable_asset_discovery }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::OrganizationSettings)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateOrganizationSettingsRequest, request)
        assert_equal(Google::Gax::to_proto(organization_settings, Google::Cloud::SecurityCenter::V1::OrganizationSettings), request.organization_settings)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_organization_settings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_organization_settings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.update_organization_settings(organization_settings)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_organization_settings(organization_settings) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_organization_settings with error' do
      # Create request parameters
      organization_settings = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateOrganizationSettingsRequest, request)
        assert_equal(Google::Gax::to_proto(organization_settings, Google::Cloud::SecurityCenter::V1::OrganizationSettings), request.organization_settings)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_organization_settings, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_organization_settings")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_organization_settings(organization_settings)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_source' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#update_source."

    it 'invokes update_source without error' do
      # Create request parameters
      source = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::Source)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateSourceRequest, request)
        assert_equal(Google::Gax::to_proto(source, Google::Cloud::SecurityCenter::V1::Source), request.source)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.update_source(source)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_source(source) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_source with error' do
      # Create request parameters
      source = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateSourceRequest, request)
        assert_equal(Google::Gax::to_proto(source, Google::Cloud::SecurityCenter::V1::Source), request.source)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_source, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_source")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_source(source)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_security_marks' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::SecurityCenter::V1::SecurityCenterClient#update_security_marks."

    it 'invokes update_security_marks without error' do
      # Create request parameters
      security_marks = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::SecurityCenter::V1::SecurityMarks)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateSecurityMarksRequest, request)
        assert_equal(Google::Gax::to_proto(security_marks, Google::Cloud::SecurityCenter::V1::SecurityMarks), request.security_marks)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_security_marks, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_security_marks")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          response = client.update_security_marks(security_marks)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_security_marks(security_marks) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_security_marks with error' do
      # Create request parameters
      security_marks = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::SecurityCenter::V1::UpdateSecurityMarksRequest, request)
        assert_equal(Google::Gax::to_proto(security_marks, Google::Cloud::SecurityCenter::V1::SecurityMarks), request.security_marks)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_security_marks, mock_method)

      # Mock auth layer
      mock_credentials = MockSecurityCenterCredentials_v1.new("update_security_marks")

      Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.stub(:new, mock_stub) do
        Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::SecurityCenter.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_security_marks(security_marks)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
