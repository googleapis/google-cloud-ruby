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
require "google/cloud/talent/v4beta1/job_service_client"
require "google/cloud/talent/v4beta1/job_service_services_pb"
require "google/longrunning/operations_pb"

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

class MockJobServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::JobServiceClient do

  describe 'create_job' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#create_job."

    it 'invokes create_job without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      job = {}

      # Create expected grpc response
      name = "name3373707"
      company = "company950484093"
      requisition_id = "requisitionId980224926"
      title = "title110371416"
      description = "description-1724546052"
      department = "department848184146"
      incentives = "incentives-1262874520"
      language_code = "languageCode-412800396"
      promotion_value = 353413845
      qualifications = "qualifications1903501412"
      responsibilities = "responsibilities-926952660"
      company_display_name = "companyDisplayName1982424170"
      expected_response = {
        name: name,
        company: company,
        requisition_id: requisition_id,
        title: title,
        description: description,
        department: department,
        incentives: incentives,
        language_code: language_code,
        promotion_value: promotion_value,
        qualifications: qualifications,
        responsibilities: responsibilities,
        company_display_name: company_display_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateJobRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Talent::V4beta1::Job), request.job)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("create_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.create_job(formatted_parent, job)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_job(formatted_parent, job) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_job with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      job = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateJobRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Talent::V4beta1::Job), request.job)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("create_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.create_job(formatted_parent, job)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_job' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#get_job."

    it 'invokes get_job without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::JobServiceClient.job_path("[PROJECT]", "[TENANT]", "[JOBS]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      company = "company950484093"
      requisition_id = "requisitionId980224926"
      title = "title110371416"
      description = "description-1724546052"
      department = "department848184146"
      incentives = "incentives-1262874520"
      language_code = "languageCode-412800396"
      promotion_value = 353413845
      qualifications = "qualifications1903501412"
      responsibilities = "responsibilities-926952660"
      company_display_name = "companyDisplayName1982424170"
      expected_response = {
        name: name_2,
        company: company,
        requisition_id: requisition_id,
        title: title,
        description: description,
        department: department,
        incentives: incentives,
        language_code: language_code,
        promotion_value: promotion_value,
        qualifications: qualifications,
        responsibilities: responsibilities,
        company_display_name: company_display_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetJobRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("get_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.get_job(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_job(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_job with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::JobServiceClient.job_path("[PROJECT]", "[TENANT]", "[JOBS]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::GetJobRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:get_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("get_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.get_job(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_job' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#update_job."

    it 'invokes update_job without error' do
      # Create request parameters
      job = {}

      # Create expected grpc response
      name = "name3373707"
      company = "company950484093"
      requisition_id = "requisitionId980224926"
      title = "title110371416"
      description = "description-1724546052"
      department = "department848184146"
      incentives = "incentives-1262874520"
      language_code = "languageCode-412800396"
      promotion_value = 353413845
      qualifications = "qualifications1903501412"
      responsibilities = "responsibilities-926952660"
      company_display_name = "companyDisplayName1982424170"
      expected_response = {
        name: name,
        company: company,
        requisition_id: requisition_id,
        title: title,
        description: description,
        department: department,
        incentives: incentives,
        language_code: language_code,
        promotion_value: promotion_value,
        qualifications: qualifications,
        responsibilities: responsibilities,
        company_display_name: company_display_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::Job)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateJobRequest, request)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Talent::V4beta1::Job), request.job)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("update_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.update_job(job)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_job(job) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_job with error' do
      # Create request parameters
      job = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::UpdateJobRequest, request)
        assert_equal(Google::Gax::to_proto(job, Google::Cloud::Talent::V4beta1::Job), request.job)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:update_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("update_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.update_job(job)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_job' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#delete_job."

    it 'invokes delete_job without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::JobServiceClient.job_path("[PROJECT]", "[TENANT]", "[JOBS]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteJobRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("delete_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.delete_job(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_job(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_job with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Talent::V4beta1::JobServiceClient.job_path("[PROJECT]", "[TENANT]", "[JOBS]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::DeleteJobRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:delete_job, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("delete_job")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.delete_job(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_jobs' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#list_jobs."

    it 'invokes list_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      filter = ''

      # Create expected grpc response
      next_page_token = ""
      jobs_element = {}
      jobs = [jobs_element]
      expected_response = { next_page_token: next_page_token, jobs: jobs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ListJobsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(filter, request.filter)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("list_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.list_jobs(formatted_parent, filter)

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
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      filter = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ListJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(filter, request.filter)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:list_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("list_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.list_jobs(formatted_parent, filter)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_delete_jobs' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#batch_delete_jobs."

    it 'invokes batch_delete_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      filter = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchDeleteJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(filter, request.filter)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_delete_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_delete_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.batch_delete_jobs(formatted_parent, filter)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.batch_delete_jobs(formatted_parent, filter) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_delete_jobs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      filter = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchDeleteJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(filter, request.filter)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_delete_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_delete_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.batch_delete_jobs(formatted_parent, filter)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_jobs' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#search_jobs."

    it 'invokes search_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Create expected grpc response
      next_page_token = ""
      estimated_total_size = 1882144769
      total_size = 705419236
      broadened_query_jobs_count = 1432104658
      matching_jobs_element = {}
      matching_jobs = [matching_jobs_element]
      expected_response = {
        next_page_token: next_page_token,
        estimated_total_size: estimated_total_size,
        total_size: total_size,
        broadened_query_jobs_count: broadened_query_jobs_count,
        matching_jobs: matching_jobs
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::SearchJobsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("search_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.search_jobs(formatted_parent, request_metadata)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.matching_jobs.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_jobs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("search_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.search_jobs(formatted_parent, request_metadata)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_jobs_for_alert' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#search_jobs_for_alert."

    it 'invokes search_jobs_for_alert without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Create expected grpc response
      next_page_token = ""
      estimated_total_size = 1882144769
      total_size = 705419236
      broadened_query_jobs_count = 1432104658
      matching_jobs_element = {}
      matching_jobs = [matching_jobs_element]
      expected_response = {
        next_page_token: next_page_token,
        estimated_total_size: estimated_total_size,
        total_size: total_size,
        broadened_query_jobs_count: broadened_query_jobs_count,
        matching_jobs: matching_jobs
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::SearchJobsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_jobs_for_alert, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("search_jobs_for_alert")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.search_jobs_for_alert(formatted_parent, request_metadata)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.matching_jobs.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_jobs_for_alert with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      request_metadata = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::SearchJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(request_metadata, Google::Cloud::Talent::V4beta1::RequestMetadata), request.request_metadata)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:search_jobs_for_alert, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("search_jobs_for_alert")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.search_jobs_for_alert(formatted_parent, request_metadata)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_create_jobs' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#batch_create_jobs."

    it 'invokes batch_create_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::JobOperationResult)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_create_jobs_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchCreateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_create_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_create_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.batch_create_jobs(formatted_parent, jobs)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_create_jobs and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Talent::V4beta1::JobServiceClient#batch_create_jobs.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_create_jobs_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchCreateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_create_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_create_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.batch_create_jobs(formatted_parent, jobs)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_create_jobs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchCreateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_create_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_create_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.batch_create_jobs(formatted_parent, jobs)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_update_jobs' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::JobServiceClient#batch_update_jobs."

    it 'invokes batch_update_jobs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::JobOperationResult)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_jobs_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchUpdateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_update_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_update_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.batch_update_jobs(formatted_parent, jobs)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_update_jobs and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Talent::V4beta1::JobServiceClient#batch_update_jobs.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_jobs_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchUpdateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_update_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_update_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          response = client.batch_update_jobs(formatted_parent, jobs)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_update_jobs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::JobServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      jobs = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::BatchUpdateJobsRequest, request)
        assert_equal(formatted_parent, request.parent)
        jobs = jobs.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::Job)
        end
        assert_equal(jobs, request.jobs)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:batch_update_jobs, mock_method)

      # Mock auth layer
      mock_credentials = MockJobServiceCredentials_v4beta1.new("batch_update_jobs")

      Google::Cloud::Talent::V4beta1::JobService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::JobService.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.batch_update_jobs(formatted_parent, jobs)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
