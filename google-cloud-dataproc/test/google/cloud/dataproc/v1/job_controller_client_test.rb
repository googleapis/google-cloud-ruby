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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/dataproc"
require "google/cloud/dataproc/v1/job_controller_client"
require "google/cloud/dataproc/v1/jobs_services_pb"

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

class MockJobControllerCredentials_v1 < Google::Cloud::Dataproc::V1::Credentials
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

describe Google::Cloud::Dataproc::V1::JobControllerClient do

  describe 'submit_job' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#submit_job."

    it 'invokes submit_job without error' do
      # Create request parameters
      project_id = ''
      region = ''
      job = {}

      # Create expected grpc response
      driver_output_resource_uri = "driverOutputResourceUri-542229086"
      driver_control_files_uri = "driverControlFilesUri207057643"
      expected_response = { driver_output_resource_uri: driver_output_resource_uri, driver_control_files_uri: driver_control_files_uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::SubmitJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Dataproc::V1::Job), request.job)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:submit_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("submit_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.submit_job(
            project_id,
            region,
            job
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.submit_job(
            project_id,
            region,
            job
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes submit_job with error' do
      # Create request parameters
      project_id = ''
      region = ''
      job = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::SubmitJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Dataproc::V1::Job), request.job)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:submit_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("submit_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.submit_job(
              project_id,
              region,
              job
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_job' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#get_job."

    it 'invokes get_job without error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Create expected grpc response
      driver_output_resource_uri = "driverOutputResourceUri-542229086"
      driver_control_files_uri = "driverControlFilesUri207057643"
      expected_response = { driver_output_resource_uri: driver_output_resource_uri, driver_control_files_uri: driver_control_files_uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("get_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.get_job(
            project_id,
            region,
            job_id
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_job(
            project_id,
            region,
            job_id
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_job with error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("get_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_job(
              project_id,
              region,
              job_id
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_jobs' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#list_jobs."

    it 'invokes list_jobs without error' do
      # Create request parameters
      project_id = ''
      region = ''

      # Create expected grpc response
      next_page_token = ""
      jobs_element = {}
      jobs = [jobs_element]
      expected_response = { next_page_token: next_page_token, jobs: jobs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::ListJobsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListJobsRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("list_jobs")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.list_jobs(project_id, region)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.jobs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_jobs with error' do
      # Create request parameters
      project_id = ''
      region = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListJobsRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("list_jobs")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_jobs(project_id, region)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_job' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#update_job."

    it 'invokes update_job without error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''
      job = {}
      update_mask = {}

      # Create expected grpc response
      driver_output_resource_uri = "driverOutputResourceUri-542229086"
      driver_control_files_uri = "driverControlFilesUri207057643"
      expected_response = { driver_output_resource_uri: driver_output_resource_uri, driver_control_files_uri: driver_control_files_uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Dataproc::V1::Job), request.job)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("update_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.update_job(
            project_id,
            region,
            job_id,
            job,
            update_mask
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_job(
            project_id,
            region,
            job_id,
            job,
            update_mask
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_job with error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''
      job = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Dataproc::V1::Job), request.job)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("update_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_job(
              project_id,
              region,
              job_id,
              job,
              update_mask
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_job' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#cancel_job."

    it 'invokes cancel_job without error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Create expected grpc response
      driver_output_resource_uri = "driverOutputResourceUri-542229086"
      driver_control_files_uri = "driverControlFilesUri207057643"
      expected_response = { driver_output_resource_uri: driver_output_resource_uri, driver_control_files_uri: driver_control_files_uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CancelJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:cancel_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("cancel_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.cancel_job(
            project_id,
            region,
            job_id
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.cancel_job(
            project_id,
            region,
            job_id
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_job with error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CancelJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:cancel_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("cancel_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.cancel_job(
              project_id,
              region,
              job_id
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_job' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Dataproc::V1::JobControllerClient#delete_job."

    it 'invokes delete_job without error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("delete_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          response = client.delete_job(
            project_id,
            region,
            job_id
          )

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_job(
            project_id,
            region,
            job_id
          ) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_job with error' do
      # Create request parameters
      project_id = ''
      region = ''
      job_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteJobRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(job_id, request.job_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobControllerCredentials_v1.new("delete_job")

      Google::Cloud::Dataproc::V1::JobController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::JobController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_job(
              project_id,
              region,
              job_id
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end