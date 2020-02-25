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

require "google/cloud/automl"
require "google/cloud/automl/v1beta1/automl_client"
require "google/cloud/automl/v1beta1/service_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError_v1beta1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1beta1

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

class MockAutoMLCredentials_v1beta1 < Google::Cloud::AutoML::V1beta1::Credentials
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

describe Google::Cloud::AutoML::V1beta1::AutoMLClient do

  describe 'create_dataset' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#create_dataset."

    it 'invokes create_dataset without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
      dataset = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      example_count = 1517063674
      etag = "etag3123477"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description,
        example_count: example_count,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::Dataset)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::CreateDatasetRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(dataset, Google::Cloud::AutoML::V1beta1::Dataset), request.dataset)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("create_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.create_dataset(formatted_parent, dataset)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_dataset(formatted_parent, dataset) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_dataset with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
      dataset = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::CreateDatasetRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(dataset, Google::Cloud::AutoML::V1beta1::Dataset), request.dataset)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("create_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.create_dataset(formatted_parent, dataset)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_dataset' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#update_dataset."

    it 'invokes update_dataset without error' do
      # Create request parameters
      dataset = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      example_count = 1517063674
      etag = "etag3123477"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description,
        example_count: example_count,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::Dataset)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateDatasetRequest, request)
        assert_equal(Google::Gax::to_proto(dataset, Google::Cloud::AutoML::V1beta1::Dataset), request.dataset)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.update_dataset(dataset)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_dataset(dataset) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_dataset with error' do
      # Create request parameters
      dataset = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateDatasetRequest, request)
        assert_equal(Google::Gax::to_proto(dataset, Google::Cloud::AutoML::V1beta1::Dataset), request.dataset)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.update_dataset(dataset)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_dataset' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_dataset."

    it 'invokes get_dataset without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      example_count = 1517063674
      etag = "etag3123477"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description,
        example_count: example_count,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::Dataset)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetDatasetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_dataset(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_dataset(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_dataset with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetDatasetRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_dataset(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_datasets' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#list_datasets."

    it 'invokes list_datasets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      datasets_element = {}
      datasets = [datasets_element]
      expected_response = { next_page_token: next_page_token, datasets: datasets }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ListDatasetsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListDatasetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_datasets, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_datasets")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.list_datasets(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.datasets.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_datasets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListDatasetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_datasets, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_datasets")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_datasets(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_dataset' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#delete_dataset."

    it 'invokes delete_dataset without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_dataset_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteDatasetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.delete_dataset(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes delete_dataset and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#delete_dataset.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_dataset_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteDatasetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.delete_dataset(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes delete_dataset with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteDatasetRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_dataset, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_dataset")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.delete_dataset(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'import_data' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#import_data."

    it 'invokes import_data without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      input_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_data_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ImportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::InputConfig), request.input_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:import_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("import_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.import_data(formatted_name, input_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes import_data and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      input_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#import_data.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_data_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ImportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::InputConfig), request.input_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:import_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("import_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.import_data(formatted_name, input_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes import_data with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      input_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ImportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::InputConfig), request.input_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:import_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("import_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.import_data(formatted_name, input_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'export_data' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_data."

    it 'invokes export_data without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      output_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_data_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_data(formatted_name, output_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes export_data and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_data.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_data_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::OutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_data(formatted_name, output_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes export_data with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportDataRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::OutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_data, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_data")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.export_data(formatted_name, output_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#create_model."

    it 'invokes create_model without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
      model = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      dataset_id = "datasetId-2115646910"
      expected_response = {
        name: name,
        display_name: display_name,
        dataset_id: dataset_id
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::Model)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_model_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::CreateModelRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(model, Google::Cloud::AutoML::V1beta1::Model), request.model)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("create_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.create_model(formatted_parent, model)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_model and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
      model = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#create_model.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_model_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::CreateModelRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(model, Google::Cloud::AutoML::V1beta1::Model), request.model)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("create_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.create_model(formatted_parent, model)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_model with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
      model = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::CreateModelRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(model, Google::Cloud::AutoML::V1beta1::Model), request.model)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("create_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.create_model(formatted_parent, model)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_model."

    it 'invokes get_model without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      dataset_id = "datasetId-2115646910"
      expected_response = {
        name: name_2,
        display_name: display_name,
        dataset_id: dataset_id
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::Model)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_model(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_model(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_model with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetModelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_model(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_models' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#list_models."

    it 'invokes list_models without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      model_element = {}
      model = [model_element]
      expected_response = { next_page_token: next_page_token, model: model }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ListModelsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListModelsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_models, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_models")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.list_models(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.model.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_models with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListModelsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_models, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_models")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_models(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#delete_model."

    it 'invokes delete_model without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_model_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.delete_model(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes delete_model and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#delete_model.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_model_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.delete_model(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes delete_model with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeleteModelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:delete_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("delete_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.delete_model(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'deploy_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#deploy_model."

    it 'invokes deploy_model without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/deploy_model_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:deploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("deploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.deploy_model(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes deploy_model and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#deploy_model.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/deploy_model_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:deploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("deploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.deploy_model(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes deploy_model with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::DeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:deploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("deploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.deploy_model(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'undeploy_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#undeploy_model."

    it 'invokes undeploy_model without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/undeploy_model_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UndeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:undeploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("undeploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.undeploy_model(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes undeploy_model and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#undeploy_model.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/undeploy_model_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UndeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:undeploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("undeploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.undeploy_model(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes undeploy_model with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UndeployModelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:undeploy_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("undeploy_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.undeploy_model(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_model_evaluation' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_model_evaluation."

    it 'invokes get_model_evaluation without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_evaluation_path("[PROJECT]", "[LOCATION]", "[MODEL]", "[MODEL_EVALUATION]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      annotation_spec_id = "annotationSpecId60690191"
      display_name = "displayName1615086568"
      evaluated_example_count = 277565350
      expected_response = {
        name: name_2,
        annotation_spec_id: annotation_spec_id,
        display_name: display_name,
        evaluated_example_count: evaluated_example_count
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ModelEvaluation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetModelEvaluationRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_model_evaluation, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_model_evaluation")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_model_evaluation(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_model_evaluation(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_model_evaluation with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_evaluation_path("[PROJECT]", "[LOCATION]", "[MODEL]", "[MODEL_EVALUATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetModelEvaluationRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_model_evaluation, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_model_evaluation")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_model_evaluation(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'export_model' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_model."

    it 'invokes export_model without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_model_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportModelRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_model(formatted_name, output_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes export_model and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_model.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_model_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportModelRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_model(formatted_name, output_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes export_model with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportModelRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_model, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_model")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.export_model(formatted_name, output_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'export_evaluated_examples' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_evaluated_examples."

    it 'invokes export_evaluated_examples without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_evaluated_examples_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_evaluated_examples, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_evaluated_examples")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_evaluated_examples(formatted_name, output_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes export_evaluated_examples and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::AutoMLClient#export_evaluated_examples.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_evaluated_examples_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_evaluated_examples, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_evaluated_examples")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.export_evaluated_examples(formatted_name, output_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes export_evaluated_examples with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesOutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:export_evaluated_examples, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("export_evaluated_examples")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.export_evaluated_examples(formatted_name, output_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_model_evaluations' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#list_model_evaluations."

    it 'invokes list_model_evaluations without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Create expected grpc response
      next_page_token = ""
      model_evaluation_element = {}
      model_evaluation = [model_evaluation_element]
      expected_response = { next_page_token: next_page_token, model_evaluation: model_evaluation }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ListModelEvaluationsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListModelEvaluationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_model_evaluations, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_model_evaluations")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.list_model_evaluations(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.model_evaluation.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_model_evaluations with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListModelEvaluationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_model_evaluations, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_model_evaluations")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_model_evaluations(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_annotation_spec' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_annotation_spec."

    it 'invokes get_annotation_spec without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.annotation_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[ANNOTATION_SPEC]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      example_count = 1517063674
      expected_response = {
        name: name_2,
        display_name: display_name,
        example_count: example_count
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::AnnotationSpec)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetAnnotationSpecRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_annotation_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_annotation_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_annotation_spec(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_annotation_spec(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_annotation_spec with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.annotation_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[ANNOTATION_SPEC]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetAnnotationSpecRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_annotation_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_annotation_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_annotation_spec(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_table_spec' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_table_spec."

    it 'invokes get_table_spec without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      time_column_spec_id = "timeColumnSpecId1558734824"
      row_count = 1340416618
      valid_row_count = 406068761
      column_count = 122671386
      etag = "etag3123477"
      expected_response = {
        name: name_2,
        time_column_spec_id: time_column_spec_id,
        row_count: row_count,
        valid_row_count: valid_row_count,
        column_count: column_count,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::TableSpec)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetTableSpecRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_table_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_table_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_table_spec(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_table_spec(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_table_spec with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetTableSpecRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_table_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_table_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_table_spec(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_table_specs' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#list_table_specs."

    it 'invokes list_table_specs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Create expected grpc response
      next_page_token = ""
      table_specs_element = {}
      table_specs = [table_specs_element]
      expected_response = { next_page_token: next_page_token, table_specs: table_specs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ListTableSpecsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListTableSpecsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_table_specs, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_table_specs")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.list_table_specs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.table_specs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_table_specs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListTableSpecsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_table_specs, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_table_specs")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_table_specs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_table_spec' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#update_table_spec."

    it 'invokes update_table_spec without error' do
      # Create request parameters
      table_spec = {}

      # Create expected grpc response
      name = "name3373707"
      time_column_spec_id = "timeColumnSpecId1558734824"
      row_count = 1340416618
      valid_row_count = 406068761
      column_count = 122671386
      etag = "etag3123477"
      expected_response = {
        name: name,
        time_column_spec_id: time_column_spec_id,
        row_count: row_count,
        valid_row_count: valid_row_count,
        column_count: column_count,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::TableSpec)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateTableSpecRequest, request)
        assert_equal(Google::Gax::to_proto(table_spec, Google::Cloud::AutoML::V1beta1::TableSpec), request.table_spec)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_table_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_table_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.update_table_spec(table_spec)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_table_spec(table_spec) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_table_spec with error' do
      # Create request parameters
      table_spec = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateTableSpecRequest, request)
        assert_equal(Google::Gax::to_proto(table_spec, Google::Cloud::AutoML::V1beta1::TableSpec), request.table_spec)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_table_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_table_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.update_table_spec(table_spec)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_column_spec' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#get_column_spec."

    it 'invokes get_column_spec without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.column_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]", "[COLUMN_SPEC]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      expected_response = {
        name: name_2,
        display_name: display_name,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ColumnSpec)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetColumnSpecRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_column_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_column_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.get_column_spec(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_column_spec(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_column_spec with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.column_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]", "[COLUMN_SPEC]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::GetColumnSpecRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:get_column_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("get_column_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.get_column_spec(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_column_specs' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#list_column_specs."

    it 'invokes list_column_specs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")

      # Create expected grpc response
      next_page_token = ""
      column_specs_element = {}
      column_specs = [column_specs_element]
      expected_response = { next_page_token: next_page_token, column_specs: column_specs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ListColumnSpecsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListColumnSpecsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_column_specs, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_column_specs")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.list_column_specs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.column_specs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_column_specs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::ListColumnSpecsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:list_column_specs, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("list_column_specs")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.list_column_specs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_column_spec' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::AutoMLClient#update_column_spec."

    it 'invokes update_column_spec without error' do
      # Create request parameters
      column_spec = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      expected_response = {
        name: name,
        display_name: display_name,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::ColumnSpec)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateColumnSpecRequest, request)
        assert_equal(Google::Gax::to_proto(column_spec, Google::Cloud::AutoML::V1beta1::ColumnSpec), request.column_spec)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_column_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_column_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          response = client.update_column_spec(column_spec)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_column_spec(column_spec) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_column_spec with error' do
      # Create request parameters
      column_spec = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::UpdateColumnSpecRequest, request)
        assert_equal(Google::Gax::to_proto(column_spec, Google::Cloud::AutoML::V1beta1::ColumnSpec), request.column_spec)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:update_column_spec, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoMLCredentials_v1beta1.new("update_column_spec")

      Google::Cloud::AutoML::V1beta1::AutoML::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.update_column_spec(column_spec)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end