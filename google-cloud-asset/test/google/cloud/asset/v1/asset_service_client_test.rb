# Copyright 2020 Google LLC
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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/asset"
require "google/cloud/asset/v1/asset_service_client"
require "google/cloud/asset/v1/asset_service_services_pb"
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

class MockAssetServiceCredentials_v1 < Google::Cloud::Asset::V1::Credentials
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

describe Google::Cloud::Asset::V1::AssetServiceClient do

  describe 'export_assets' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#export_assets."

    it 'invokes export_assets without error' do
      # Create request parameters
      parent = ''
      output_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::ExportAssetsResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_assets_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::ExportAssetsRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Asset::V1::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:export_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("export_assets")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.export_assets(parent, output_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes export_assets and returns an operation error.' do
      # Create request parameters
      parent = ''
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Asset::V1::AssetServiceClient#export_assets.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_assets_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::ExportAssetsRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Asset::V1::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:export_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("export_assets")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.export_assets(parent, output_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes export_assets with error' do
      # Create request parameters
      parent = ''
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::ExportAssetsRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::Asset::V1::OutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:export_assets, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("export_assets")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.export_assets(parent, output_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_get_assets_history' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#batch_get_assets_history."

    it 'invokes batch_get_assets_history without error' do
      # Create request parameters
      parent = ''
      content_type = :CONTENT_TYPE_UNSPECIFIED
      read_time_window = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::BatchGetAssetsHistoryResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::BatchGetAssetsHistoryRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(content_type, request.content_type)
        assert_equal(Google::Gax::to_proto(read_time_window, Google::Cloud::Asset::V1::TimeWindow), request.read_time_window)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_get_assets_history, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("batch_get_assets_history")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.batch_get_assets_history(
            parent,
            content_type,
            read_time_window
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_get_assets_history(
            parent,
            content_type,
            read_time_window
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_get_assets_history with error' do
      # Create request parameters
      parent = ''
      content_type = :CONTENT_TYPE_UNSPECIFIED
      read_time_window = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::BatchGetAssetsHistoryRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(content_type, request.content_type)
        assert_equal(Google::Gax::to_proto(read_time_window, Google::Cloud::Asset::V1::TimeWindow), request.read_time_window)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_get_assets_history, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("batch_get_assets_history")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.batch_get_assets_history(
              parent,
              content_type,
              read_time_window
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_feed' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#create_feed."

    it 'invokes create_feed without error' do
      # Create request parameters
      parent = ''
      feed_id = ''
      feed = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::Feed)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::CreateFeedRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(feed_id, request.feed_id)
        assert_equal(Google::Gax::to_proto(feed, Google::Cloud::Asset::V1::Feed), request.feed)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("create_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.create_feed(
            parent,
            feed_id,
            feed
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_feed(
            parent,
            feed_id,
            feed
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_feed with error' do
      # Create request parameters
      parent = ''
      feed_id = ''
      feed = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::CreateFeedRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(feed_id, request.feed_id)
        assert_equal(Google::Gax::to_proto(feed, Google::Cloud::Asset::V1::Feed), request.feed)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("create_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_feed(
              parent,
              feed_id,
              feed
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_feed' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#get_feed."

    it 'invokes get_feed without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::Feed)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::GetFeedRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("get_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.get_feed(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_feed(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_feed with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::GetFeedRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("get_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_feed(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_feeds' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#list_feeds."

    it 'invokes list_feeds without error' do
      # Create request parameters
      parent = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::ListFeedsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::ListFeedsRequest, request)
        assert_equal(parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_feeds, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("list_feeds")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.list_feeds(parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_feeds(parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_feeds with error' do
      # Create request parameters
      parent = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::ListFeedsRequest, request)
        assert_equal(parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_feeds, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("list_feeds")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_feeds(parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_feed' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#update_feed."

    it 'invokes update_feed without error' do
      # Create request parameters
      feed = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Asset::V1::Feed)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::UpdateFeedRequest, request)
        assert_equal(Google::Gax::to_proto(feed, Google::Cloud::Asset::V1::Feed), request.feed)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("update_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.update_feed(feed, update_mask)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_feed(feed, update_mask) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_feed with error' do
      # Create request parameters
      feed = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::UpdateFeedRequest, request)
        assert_equal(Google::Gax::to_proto(feed, Google::Cloud::Asset::V1::Feed), request.feed)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("update_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_feed(feed, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_feed' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Asset::V1::AssetServiceClient#delete_feed."

    it 'invokes delete_feed without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::DeleteFeedRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("delete_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          response = client.delete_feed(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_feed(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_feed with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Asset::V1::DeleteFeedRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_feed, mock_method)

      # Mock auth layer
      mock_credentials = MockAssetServiceCredentials_v1.new("delete_feed")

      Google::Cloud::Asset::V1::AssetService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Asset::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Asset.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_feed(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end