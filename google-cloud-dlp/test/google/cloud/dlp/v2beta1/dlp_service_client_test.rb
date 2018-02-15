# Copyright 2017 Google LLC
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
require "google/cloud/dlp/v2beta1/dlp_service_client"
require "google/privacy/dlp/v2beta1/dlp_services_pb"
require "google/longrunning/operations_pb"

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

class MockDlpServiceCredentials < Google::Cloud::Dlp::Credentials
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

describe Google::Cloud::Dlp::V2beta1::DlpServiceClient do

  describe 'inspect_content' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#inspect_content."

    it 'invokes inspect_content without error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      type = "text/plain"
      value = "My email is example@example.com."
      items_element = { type: type, value: value }
      items = [items_element]

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::InspectContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::InspectContentRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:inspect_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("inspect_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.inspect_content(inspect_config, items)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes inspect_content with error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      type = "text/plain"
      value = "My email is example@example.com."
      items_element = { type: type, value: value }
      items = [items_element]

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::InspectContentRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:inspect_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("inspect_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.inspect_content(inspect_config, items)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'redact_content' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#redact_content."

    it 'invokes redact_content without error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      type = "text/plain"
      value = "My email is example@example.com."
      items_element = { type: type, value: value }
      items = [items_element]

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::RedactContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::RedactContentRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:redact_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("redact_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.redact_content(inspect_config, items)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes redact_content with error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      type = "text/plain"
      value = "My email is example@example.com."
      items_element = { type: type, value: value }
      items = [items_element]

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::RedactContentRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:redact_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("redact_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.redact_content(inspect_config, items)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'deidentify_content' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#deidentify_content."

    it 'invokes deidentify_content without error' do
      # Create request parameters
      deidentify_config = {}
      inspect_config = {}
      items = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::DeidentifyContentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::DeidentifyContentRequest, request)
        assert_equal(Google::Gax::to_proto(deidentify_config, Google::Privacy::Dlp::V2beta1::DeidentifyConfig), request.deidentify_config)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:deidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("deidentify_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.deidentify_content(
            deidentify_config,
            inspect_config,
            items
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes deidentify_content with error' do
      # Create request parameters
      deidentify_config = {}
      inspect_config = {}
      items = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::DeidentifyContentRequest, request)
        assert_equal(Google::Gax::to_proto(deidentify_config, Google::Privacy::Dlp::V2beta1::DeidentifyConfig), request.deidentify_config)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        items = items.map do |req|
          Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ContentItem)
        end
        assert_equal(items, request.items)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:deidentify_content, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("deidentify_content")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.deidentify_content(
              deidentify_config,
              inspect_config,
              items
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'analyze_data_source_risk' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#analyze_data_source_risk."

    it 'invokes analyze_data_source_risk without error' do
      # Create request parameters
      privacy_metric = {}
      source_table = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/analyze_data_source_risk_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::AnalyzeDataSourceRiskRequest, request)
        assert_equal(Google::Gax::to_proto(privacy_metric, Google::Privacy::Dlp::V2beta1::PrivacyMetric), request.privacy_metric)
        assert_equal(Google::Gax::to_proto(source_table, Google::Privacy::Dlp::V2beta1::BigQueryTable), request.source_table)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:analyze_data_source_risk, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("analyze_data_source_risk")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.analyze_data_source_risk(privacy_metric, source_table)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes analyze_data_source_risk and returns an operation error.' do
      # Create request parameters
      privacy_metric = {}
      source_table = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#analyze_data_source_risk.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/analyze_data_source_risk_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::AnalyzeDataSourceRiskRequest, request)
        assert_equal(Google::Gax::to_proto(privacy_metric, Google::Privacy::Dlp::V2beta1::PrivacyMetric), request.privacy_metric)
        assert_equal(Google::Gax::to_proto(source_table, Google::Privacy::Dlp::V2beta1::BigQueryTable), request.source_table)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:analyze_data_source_risk, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("analyze_data_source_risk")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.analyze_data_source_risk(privacy_metric, source_table)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes analyze_data_source_risk with error' do
      # Create request parameters
      privacy_metric = {}
      source_table = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::AnalyzeDataSourceRiskRequest, request)
        assert_equal(Google::Gax::to_proto(privacy_metric, Google::Privacy::Dlp::V2beta1::PrivacyMetric), request.privacy_metric)
        assert_equal(Google::Gax::to_proto(source_table, Google::Privacy::Dlp::V2beta1::BigQueryTable), request.source_table)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:analyze_data_source_risk, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("analyze_data_source_risk")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.analyze_data_source_risk(privacy_metric, source_table)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_inspect_operation' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#create_inspect_operation."

    it 'invokes create_inspect_operation without error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      url = "gs://example_bucket/example_file.png"
      file_set = { url: url }
      cloud_storage_options = { file_set: file_set }
      storage_config = { cloud_storage_options: cloud_storage_options }
      output_config = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::InspectOperationResult)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_inspect_operation_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::CreateInspectOperationRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        assert_equal(Google::Gax::to_proto(storage_config, Google::Privacy::Dlp::V2beta1::StorageConfig), request.storage_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Privacy::Dlp::V2beta1::OutputStorageConfig), request.output_config)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:create_inspect_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("create_inspect_operation")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.create_inspect_operation(
            inspect_config,
            storage_config,
            output_config
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_inspect_operation and returns an operation error.' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      url = "gs://example_bucket/example_file.png"
      file_set = { url: url }
      cloud_storage_options = { file_set: file_set }
      storage_config = { cloud_storage_options: cloud_storage_options }
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#create_inspect_operation.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_inspect_operation_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::CreateInspectOperationRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        assert_equal(Google::Gax::to_proto(storage_config, Google::Privacy::Dlp::V2beta1::StorageConfig), request.storage_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Privacy::Dlp::V2beta1::OutputStorageConfig), request.output_config)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:create_inspect_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("create_inspect_operation")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.create_inspect_operation(
            inspect_config,
            storage_config,
            output_config
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_inspect_operation with error' do
      # Create request parameters
      name = "EMAIL_ADDRESS"
      info_types_element = { name: name }
      info_types = [info_types_element]
      inspect_config = { info_types: info_types }
      url = "gs://example_bucket/example_file.png"
      file_set = { url: url }
      cloud_storage_options = { file_set: file_set }
      storage_config = { cloud_storage_options: cloud_storage_options }
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::CreateInspectOperationRequest, request)
        assert_equal(Google::Gax::to_proto(inspect_config, Google::Privacy::Dlp::V2beta1::InspectConfig), request.inspect_config)
        assert_equal(Google::Gax::to_proto(storage_config, Google::Privacy::Dlp::V2beta1::StorageConfig), request.storage_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Privacy::Dlp::V2beta1::OutputStorageConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_inspect_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("create_inspect_operation")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_inspect_operation(
              inspect_config,
              storage_config,
              output_config
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_inspect_findings' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#list_inspect_findings."

    it 'invokes list_inspect_findings without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2beta1::DlpServiceClient.result_path("[RESULT]")

      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::ListInspectFindingsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListInspectFindingsRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_inspect_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_inspect_findings")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.list_inspect_findings(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes list_inspect_findings with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dlp::V2beta1::DlpServiceClient.result_path("[RESULT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListInspectFindingsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_inspect_findings, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_inspect_findings")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_inspect_findings(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_info_types' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#list_info_types."

    it 'invokes list_info_types without error' do
      # Create request parameters
      category = "PII"
      language_code = "en"

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::ListInfoTypesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListInfoTypesRequest, request)
        assert_equal(category, request.category)
        assert_equal(language_code, request.language_code)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_info_types, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_info_types")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.list_info_types(category, language_code)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes list_info_types with error' do
      # Create request parameters
      category = "PII"
      language_code = "en"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListInfoTypesRequest, request)
        assert_equal(category, request.category)
        assert_equal(language_code, request.language_code)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_info_types, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_info_types")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_info_types(category, language_code)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_root_categories' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dlp::V2beta1::DlpServiceClient#list_root_categories."

    it 'invokes list_root_categories without error' do
      # Create request parameters
      language_code = "en"

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Privacy::Dlp::V2beta1::ListRootCategoriesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListRootCategoriesRequest, request)
        assert_equal(language_code, request.language_code)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_root_categories, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_root_categories")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          response = client.list_root_categories(language_code)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes list_root_categories with error' do
      # Create request parameters
      language_code = "en"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Privacy::Dlp::V2beta1::ListRootCategoriesRequest, request)
        assert_equal(language_code, request.language_code)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_root_categories, mock_method)

      # Mock auth layer
      mock_credentials = MockDlpServiceCredentials.new("list_root_categories")

      Google::Privacy::Dlp::V2beta1::DlpService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dlp::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dlp.new(version: :v2beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_root_categories(language_code)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end