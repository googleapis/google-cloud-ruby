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
require "google/cloud/talent/v4beta1/profile_service_client"
require "google/cloud/talent/v4beta1/profile_service_services_pb"

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

class MockProfileServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::ProfileServiceClient do

  describe 'list_profiles' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#list_profiles."

    it 'invokes list_profiles without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")

      # Create expected grpc response
      next_page_token = ""
      profiles_element = {}
      profiles = [profiles_element]
      expected_response = { next_page_token: next_page_token, profiles: profiles }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ListProfilesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("list_profiles")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.list_profiles(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.profiles.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_profiles with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("list_profiles")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.list_profiles(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_profile' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#create_profile."

    it 'invokes create_profile without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      profile = {}

      # Create expected grpc response
      name = "name3373707"
      external_id = "externalId-1153075697"
      source = "source-896505829"
      uri = "uri116076"
      group_id = "groupId506361563"
      processed = true
      keyword_snippet = "keywordSnippet1325317319"
      expected_response = {
        name: name,
        external_id: external_id,
        source: source,
        uri: uri,
        group_id: group_id,
        processed: processed,
        keyword_snippet: keyword_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Profile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateProfileRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(profile, Google::Cloud::Talent::V4beta1::Profile), request.profile)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("create_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.create_profile(formatted_parent, profile)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_profile(formatted_parent, profile) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_profile with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      profile = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateProfileRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(profile, Google::Cloud::Talent::V4beta1::Profile), request.profile)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("create_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.create_profile(formatted_parent, profile)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_profile' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#get_profile."

    it 'invokes get_profile without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      external_id = "externalId-1153075697"
      source = "source-896505829"
      uri = "uri116076"
      group_id = "groupId506361563"
      processed = true
      keyword_snippet = "keywordSnippet1325317319"
      expected_response = {
        name: name_2,
        external_id: external_id,
        source: source,
        uri: uri,
        group_id: group_id,
        processed: processed,
        keyword_snippet: keyword_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Profile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetProfileRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("get_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.get_profile(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_profile(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_profile with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetProfileRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("get_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.get_profile(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_profile' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#update_profile."

    it 'invokes update_profile without error' do
      # Create request parameters
      profile = {}

      # Create expected grpc response
      name = "name3373707"
      external_id = "externalId-1153075697"
      source = "source-896505829"
      uri = "uri116076"
      group_id = "groupId506361563"
      processed = true
      keyword_snippet = "keywordSnippet1325317319"
      expected_response = {
        name: name,
        external_id: external_id,
        source: source,
        uri: uri,
        group_id: group_id,
        processed: processed,
        keyword_snippet: keyword_snippet
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Profile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateProfileRequest, request)
        assert_equal(Google::Gax::to_proto(profile, Google::Cloud::Talent::V4beta1::Profile), request.profile)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("update_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.update_profile(profile)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_profile(profile) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_profile with error' do
      # Create request parameters
      profile = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateProfileRequest, request)
        assert_equal(Google::Gax::to_proto(profile, Google::Cloud::Talent::V4beta1::Profile), request.profile)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("update_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.update_profile(profile)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_profile' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#delete_profile."

    it 'invokes delete_profile without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteProfileRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("delete_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.delete_profile(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_profile(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_profile with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteProfileRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("delete_profile")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.delete_profile(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_profiles' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ProfileServiceClient#search_profiles."

    it 'invokes search_profiles without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Create expected grpc response
      estimated_total_size = 1882144769
      next_page_token = ""
      result_set_id = "resultSetId-770306950"
      summarized_profiles_element = {}
      summarized_profiles = [summarized_profiles_element]
      expected_response = {
        estimated_total_size: estimated_total_size,
        next_page_token: next_page_token,
        result_set_id: result_set_id,
        summarized_profiles: summarized_profiles
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::SearchProfilesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("search_profiles")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          response = client.search_profiles(formatted_parent, request_metadata)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.summarized_profiles.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_profiles with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockProfileServiceCredentials_v4beta1.new("search_profiles")

      Google::Cloud::Talent::V4beta1::ProfileService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.search_profiles(formatted_parent, request_metadata)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
