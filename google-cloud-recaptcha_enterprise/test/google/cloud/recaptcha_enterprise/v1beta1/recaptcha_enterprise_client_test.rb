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

require "google/cloud/recaptcha_enterprise"
require "google/cloud/recaptcha_enterprise/v1beta1/recaptcha_enterprise_client"
require "google/cloud/recaptchaenterprise/v1beta1/recaptchaenterprise_services_pb"

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

class MockRecaptchaEnterpriseCredentials_v1beta1 < Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials
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

describe Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient do

  describe 'create_assessment' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient#create_assessment."

    it 'invokes create_assessment without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path("[PROJECT]")
      assessment = {}

      # Create expected grpc response
      name = "name3373707"
      score = 1.0926453E7
      expected_response = { name: name, score: score }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Recaptchaenterprise::V1beta1::Assessment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Recaptchaenterprise::V1beta1::CreateAssessmentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(assessment, Google::Cloud::Recaptchaenterprise::V1beta1::Assessment), request.assessment)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_assessment, mock_method)

      # Mock auth layer
      mock_credentials = MockRecaptchaEnterpriseCredentials_v1beta1.new("create_assessment")

      Google::Cloud::Recaptchaenterprise::V1beta1::RecaptchaEnterprise::Stub.stub(:new, mock_stub) do
        Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)

          # Call method
          response = client.create_assessment(formatted_parent, assessment)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_assessment(formatted_parent, assessment) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_assessment with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path("[PROJECT]")
      assessment = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Recaptchaenterprise::V1beta1::CreateAssessmentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(assessment, Google::Cloud::Recaptchaenterprise::V1beta1::Assessment), request.assessment)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:create_assessment, mock_method)

      # Mock auth layer
      mock_credentials = MockRecaptchaEnterpriseCredentials_v1beta1.new("create_assessment")

      Google::Cloud::Recaptchaenterprise::V1beta1::RecaptchaEnterprise::Stub.stub(:new, mock_stub) do
        Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.create_assessment(formatted_parent, assessment)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'annotate_assessment' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient#annotate_assessment."

    it 'invokes annotate_assessment without error' do
      # Create request parameters
      formatted_name = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path("[PROJECT]", "[ASSESSMENT]")
      annotation = :ANNOTATION_UNSPECIFIED

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Recaptchaenterprise::V1beta1::AnnotateAssessmentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Recaptchaenterprise::V1beta1::AnnotateAssessmentRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(annotation, request.annotation)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:annotate_assessment, mock_method)

      # Mock auth layer
      mock_credentials = MockRecaptchaEnterpriseCredentials_v1beta1.new("annotate_assessment")

      Google::Cloud::Recaptchaenterprise::V1beta1::RecaptchaEnterprise::Stub.stub(:new, mock_stub) do
        Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)

          # Call method
          response = client.annotate_assessment(formatted_name, annotation)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.annotate_assessment(formatted_name, annotation) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes annotate_assessment with error' do
      # Create request parameters
      formatted_name = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path("[PROJECT]", "[ASSESSMENT]")
      annotation = :ANNOTATION_UNSPECIFIED

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Recaptchaenterprise::V1beta1::AnnotateAssessmentRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(annotation, request.annotation)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:annotate_assessment, mock_method)

      # Mock auth layer
      mock_credentials = MockRecaptchaEnterpriseCredentials_v1beta1.new("annotate_assessment")

      Google::Cloud::Recaptchaenterprise::V1beta1::RecaptchaEnterprise::Stub.stub(:new, mock_stub) do
        Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.annotate_assessment(formatted_name, annotation)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
