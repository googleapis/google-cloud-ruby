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


module Google
  module Cloud
    module Scheduler
      module V1beta1
        # Request message for listing jobs using {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ListJobs ListJobs}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The location name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Requested page size.
        #
        #     The maximum page size is 500. If unspecified, the page size will
        #     be the maximum. Fewer jobs than requested might be returned,
        #     even if more jobs exist; use next_page_token to determine if more
        #     jobs exist.
        # @!attribute [rw] page_token
        #   @return [String]
        #     A token identifying a page of results the server will return. To
        #     request the first page results, page_token must be empty. To
        #     request the next page of results, page_token must be the value of
        #     {Google::Cloud::Scheduler::V1beta1::ListJobsResponse#next_page_token next_page_token} returned from
        #     the previous call to {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ListJobs ListJobs}. It is an error to
        #     switch the value of {Google::Cloud::Scheduler::V1beta1::ListJobsRequest#filter filter} or
        #     {Google::Cloud::Scheduler::V1beta1::ListJobsRequest#order_by order_by} while iterating through pages.
        class ListJobsRequest; end

        # Response message for listing jobs using {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ListJobs ListJobs}.
        # @!attribute [rw] jobs
        #   @return [Array<Google::Cloud::Scheduler::V1beta1::Job>]
        #     The list of jobs.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve next page of results. Pass this value in the
        #     {Google::Cloud::Scheduler::V1beta1::ListJobsRequest#page_token page_token} field in the subsequent call to
        #     {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ListJobs ListJobs} to retrieve the next page of results.
        #     If this is empty it indicates that there are no more results
        #     through which to paginate.
        #
        #     The page token is valid for only 2 hours.
        class ListJobsResponse; end

        # Request message for {Google::Cloud::Scheduler::V1beta1::CloudScheduler::GetJob GetJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     The job name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
        class GetJobRequest; end

        # Request message for {Google::Cloud::Scheduler::V1beta1::CloudScheduler::CreateJob CreateJob}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The location name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID`.
        # @!attribute [rw] job
        #   @return [Google::Cloud::Scheduler::V1beta1::Job]
        #     Required.
        #
        #     The job to add. The user can optionally specify a name for the
        #     job in {Google::Cloud::Scheduler::V1beta1::Job#name name}. {Google::Cloud::Scheduler::V1beta1::Job#name name} cannot be the same as an
        #     existing job. If a name is not specified then the system will
        #     generate a random unique name that will be returned
        #     ({Google::Cloud::Scheduler::V1beta1::Job#name name}) in the response.
        class CreateJobRequest; end

        # Request message for {Google::Cloud::Scheduler::V1beta1::CloudScheduler::UpdateJob UpdateJob}.
        # @!attribute [rw] job
        #   @return [Google::Cloud::Scheduler::V1beta1::Job]
        #     Required.
        #
        #     The new job properties. {Google::Cloud::Scheduler::V1beta1::Job#name name} must be specified.
        #
        #     Output only fields cannot be modified using UpdateJob.
        #     Any value specified for an output only field will be ignored.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     A  mask used to specify which fields of the job are being updated.
        class UpdateJobRequest; end

        # Request message for deleting a job using
        # {Google::Cloud::Scheduler::V1beta1::CloudScheduler::DeleteJob DeleteJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     The job name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
        class DeleteJobRequest; end

        # Request message for {Google::Cloud::Scheduler::V1beta1::CloudScheduler::PauseJob PauseJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     The job name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
        class PauseJobRequest; end

        # Request message for {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ResumeJob ResumeJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     The job name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
        class ResumeJobRequest; end

        # Request message for forcing a job to run now using
        # {Google::Cloud::Scheduler::V1beta1::CloudScheduler::RunJob RunJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     The job name. For example:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
        class RunJobRequest; end
      end
    end
  end
end