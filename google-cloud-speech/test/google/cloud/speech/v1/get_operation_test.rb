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

require_relative "./speech_client_test"
require "google/longrunning/operations_services_pb"

describe Google::Cloud::Speech::V1::SpeechClient, :get_operation do
  let(:custom_error) { CustomTestError_v1.new "Custom test error for Google::Cloud::Speech::V1::SpeechClient#get_operation." }

  it "invokes get_operation without error" do
    # Create request parameters
    name = "operation123"

    # Create expected grpc response
    expected_response = {}
    expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Speech::V1::LongRunningRecognizeResponse)
    result = Google::Protobuf::Any.new
    result.pack(expected_response)
    operation = Google::Longrunning::Operation.new(
      name: "operations/get_operation_test",
      done: true,
      response: result
    )

    # Mock Grpc layer
    mock_method = proc do |request|
      assert_instance_of(Google::Longrunning::GetOperationRequest, request)
      assert_equal(name, request.name)
      OpenStruct.new(execute: operation)
    end
    mock_stub = MockGrpcClientStub_v1.new(:get_operation, mock_method)

    # Mock auth layer
    mock_credentials = MockSpeechCredentials_v1.new("get_operation")

    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Longrunning::Operations::Stub.stub(:new, mock_stub) do
        Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Speech.new(version: :v1)

          # Call method
          response = client.get_operation(name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end
  end

  it "invokes get_operation and returns an operation error." do
    # Create request parameters
    name = "operation123"

    # Create expected grpc response
    operation_error = Google::Rpc::Status.new(
      message: "Operation error for Google::Cloud::Speech::V1::SpeechClient#get_operation."
    )
    operation = Google::Longrunning::Operation.new(
      name: "operations/get_operation_test",
      done: true,
      error: operation_error
    )

    # Mock Grpc layer
    mock_method = proc do |request|
      assert_instance_of(Google::Longrunning::GetOperationRequest, request)
      assert_equal(name, request.name)
      OpenStruct.new(execute: operation)
    end
    mock_stub = MockGrpcClientStub_v1.new(:get_operation, mock_method)

    # Mock auth layer
    mock_credentials = MockSpeechCredentials_v1.new("get_operation")

    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Longrunning::Operations::Stub.stub(:new, mock_stub) do
        Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Speech.new(version: :v1)

          # Call method
          response = client.get_operation(name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end
  end

  it "invokes get_operation with error" do
    # Create request parameters
    name = "operation123"

    # Mock Grpc layer
    mock_method = proc do |request|
      assert_instance_of(Google::Longrunning::GetOperationRequest, request)
      assert_equal(name, request.name)
      raise custom_error
    end
    mock_stub = MockGrpcClientStub_v1.new(:get_operation, mock_method)

    # Mock auth layer
    mock_credentials = MockSpeechCredentials_v1.new("get_operation")

    Google::Cloud::Speech::V1::Speech::Stub.stub(:new, mock_stub) do
      Google::Longrunning::Operations::Stub.stub(:new, mock_stub) do
        Google::Cloud::Speech::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Speech.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            response = client.get_operation(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
