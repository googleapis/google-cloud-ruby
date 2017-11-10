# Copyright 2017, Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/monitoring"
require "google/cloud/monitoring/v3/group_service_client"
require "google/monitoring/v3/group_service_services_pb"

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

class MockGroupServiceCredentials < Google::Cloud::Monitoring::Credentials
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

describe Google::Cloud::Monitoring::V3::GroupServiceClient do

  describe 'list_groups' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#list_groups."

    it 'invokes list_groups without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      group_element = {}
      group = [group_element]
      expected_response = { next_page_token: next_page_token, group: group }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListGroupsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListGroupsRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_groups, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("list_groups")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.list_groups(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.group.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_groups with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListGroupsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_groups, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("list_groups")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_groups(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_group' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#get_group."

    it 'invokes get_group without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      parent_name = "parentName1015022848"
      filter = "filter-1274492040"
      is_cluster = false
      expected_response = {
        name: name_2,
        display_name: display_name,
        parent_name: parent_name,
        filter: filter,
        is_cluster: is_cluster
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Group)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetGroupRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("get_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.get_group(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_group with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetGroupRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("get_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_group(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_group' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#create_group."

    it 'invokes create_group without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")
      group = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      parent_name = "parentName1015022848"
      filter = "filter-1274492040"
      is_cluster = false
      expected_response = {
        name: name_2,
        display_name: display_name,
        parent_name: parent_name,
        filter: filter,
        is_cluster: is_cluster
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Group)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateGroupRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(group, Google::Monitoring::V3::Group), request.group)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:create_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("create_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.create_group(formatted_name, group)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_group with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")
      group = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateGroupRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(group, Google::Monitoring::V3::Group), request.group)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("create_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_group(formatted_name, group)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_group' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#update_group."

    it 'invokes update_group without error' do
      # Create request parameters
      group = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      parent_name = "parentName1015022848"
      filter = "filter-1274492040"
      is_cluster = false
      expected_response = {
        name: name,
        display_name: display_name,
        parent_name: parent_name,
        filter: filter,
        is_cluster: is_cluster
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Group)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateGroupRequest, request)
        assert_equal(Google::Gax::to_proto(group, Google::Monitoring::V3::Group), request.group)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:update_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("update_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.update_group(group)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_group with error' do
      # Create request parameters
      group = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateGroupRequest, request)
        assert_equal(Google::Gax::to_proto(group, Google::Monitoring::V3::Group), request.group)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("update_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_group(group)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_group' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#delete_group."

    it 'invokes delete_group without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteGroupRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("delete_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.delete_group(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_group with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteGroupRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_group, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("delete_group")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_group(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_group_members' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::GroupServiceClient#list_group_members."

    it 'invokes list_group_members without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Create expected grpc response
      next_page_token = ""
      total_size = -705419236
      members_element = {}
      members = [members_element]
      expected_response = {
        next_page_token: next_page_token,
        total_size: total_size,
        members: members
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListGroupMembersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListGroupMembersRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_group_members, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("list_group_members")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          response = client.list_group_members(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.members.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_group_members with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListGroupMembersRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_group_members, mock_method)

      # Mock auth layer
      mock_credentials = MockGroupServiceCredentials.new("list_group_members")

      Google::Monitoring::V3::GroupService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Group.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_group_members(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end