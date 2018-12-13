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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/scheduler/v1beta1/cloudscheduler.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/scheduler/v1beta1/cloudscheduler_pb"
require "google/cloud/scheduler/v1beta1/credentials"

module Google
  module Cloud
    module Scheduler
      module V1beta1
        # The Cloud Scheduler API allows external entities to reliably
        # schedule asynchronous jobs.
        #
        # @!attribute [r] cloud_scheduler_stub
        #   @return [Google::Cloud::Scheduler::V1beta1::CloudScheduler::Stub]
        class CloudSchedulerClient
          # @private
          attr_reader :cloud_scheduler_stub

          # The default address of the service.
          SERVICE_ADDRESS = "cloudscheduler.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_jobs" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "jobs")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          JOB_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/jobs/{job}"
          )

          private_constant :JOB_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified location resource name string.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def self.location_path project, location
            LOCATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location
            )
          end

          # Returns a fully-qualified job resource name string.
          # @param project [String]
          # @param location [String]
          # @param job [String]
          # @return [String]
          def self.job_path project, location, job
            JOB_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"job" => job
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/scheduler/v1beta1/cloudscheduler_services_pb"

            credentials ||= Google::Cloud::Scheduler::V1beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Scheduler::V1beta1::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-scheduler'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "cloud_scheduler_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.scheduler.v1beta1.CloudScheduler",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @cloud_scheduler_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Scheduler::V1beta1::CloudScheduler::Stub.method(:new)
            )

            @list_jobs = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:list_jobs),
              defaults["list_jobs"],
              exception_transformer: exception_transformer
            )
            @get_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:get_job),
              defaults["get_job"],
              exception_transformer: exception_transformer
            )
            @create_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:create_job),
              defaults["create_job"],
              exception_transformer: exception_transformer
            )
            @update_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:update_job),
              defaults["update_job"],
              exception_transformer: exception_transformer
            )
            @delete_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:delete_job),
              defaults["delete_job"],
              exception_transformer: exception_transformer
            )
            @pause_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:pause_job),
              defaults["pause_job"],
              exception_transformer: exception_transformer
            )
            @resume_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:resume_job),
              defaults["resume_job"],
              exception_transformer: exception_transformer
            )
            @run_job = Google::Gax.create_api_call(
              @cloud_scheduler_stub.method(:run_job),
              defaults["run_job"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists jobs.
          #
          # @param parent [String]
          #   Required.
          #
          #   The location name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID`.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Scheduler::V1beta1::Job>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Scheduler::V1beta1::Job>]
          #   An enumerable of Google::Cloud::Scheduler::V1beta1::Job instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   cloud_scheduler_client.list_jobs(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cloud_scheduler_client.list_jobs(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_jobs \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::ListJobsRequest)
            @list_jobs.call(req, options, &block)
          end

          # Gets a job.
          #
          # @param name [String]
          #   Required.
          #
          #   The job name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path("[PROJECT]", "[LOCATION]", "[JOB]")
          #   response = cloud_scheduler_client.get_job(formatted_name)

          def get_job \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::GetJobRequest)
            @get_job.call(req, options, &block)
          end

          # Creates a job.
          #
          # @param parent [String]
          #   Required.
          #
          #   The location name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID`.
          # @param job [Google::Cloud::Scheduler::V1beta1::Job | Hash]
          #   Required.
          #
          #   The job to add. The user can optionally specify a name for the
          #   job in {Google::Cloud::Scheduler::V1beta1::Job#name name}. {Google::Cloud::Scheduler::V1beta1::Job#name name} cannot be the same as an
          #   existing job. If a name is not specified then the system will
          #   generate a random unique name that will be returned
          #   ({Google::Cloud::Scheduler::V1beta1::Job#name name}) in the response.
          #   A hash of the same form as `Google::Cloud::Scheduler::V1beta1::Job`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `job`:
          #   job = {}
          #   response = cloud_scheduler_client.create_job(formatted_parent, job)

          def create_job \
              parent,
              job,
              options: nil,
              &block
            req = {
              parent: parent,
              job: job
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::CreateJobRequest)
            @create_job.call(req, options, &block)
          end

          # Updates a job.
          #
          # If successful, the updated {Google::Cloud::Scheduler::V1beta1::Job Job} is returned. If the job does
          # not exist, `NOT_FOUND` is returned.
          #
          # If UpdateJob does not successfully return, it is possible for the
          # job to be in an {Google::Cloud::Scheduler::V1beta1::Job::State::UPDATE_FAILED Job::State::UPDATE_FAILED} state. A job in this state may
          # not be executed. If this happens, retry the UpdateJob request
          # until a successful response is received.
          #
          # @param job [Google::Cloud::Scheduler::V1beta1::Job | Hash]
          #   Required.
          #
          #   The new job properties. {Google::Cloud::Scheduler::V1beta1::Job#name name} must be specified.
          #
          #   Output only fields cannot be modified using UpdateJob.
          #   Any value specified for an output only field will be ignored.
          #   A hash of the same form as `Google::Cloud::Scheduler::V1beta1::Job`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   A  mask used to specify which fields of the job are being updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #
          #   # TODO: Initialize `job`:
          #   job = {}
          #   response = cloud_scheduler_client.update_job(job)

          def update_job \
              job,
              update_mask: nil,
              options: nil,
              &block
            req = {
              job: job,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::UpdateJobRequest)
            @update_job.call(req, options, &block)
          end

          # Deletes a job.
          #
          # @param name [String]
          #   Required.
          #
          #   The job name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path("[PROJECT]", "[LOCATION]", "[JOB]")
          #   cloud_scheduler_client.delete_job(formatted_name)

          def delete_job \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::DeleteJobRequest)
            @delete_job.call(req, options, &block)
            nil
          end

          # Pauses a job.
          #
          # If a job is paused then the system will stop executing the job
          # until it is re-enabled via {Google::Cloud::Scheduler::V1beta1::CloudScheduler::ResumeJob ResumeJob}. The
          # state of the job is stored in {Google::Cloud::Scheduler::V1beta1::Job#state state}; if paused it
          # will be set to {Google::Cloud::Scheduler::V1beta1::Job::State::PAUSED Job::State::PAUSED}. A job must be in {Google::Cloud::Scheduler::V1beta1::Job::State::ENABLED Job::State::ENABLED}
          # to be paused.
          #
          # @param name [String]
          #   Required.
          #
          #   The job name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path("[PROJECT]", "[LOCATION]", "[JOB]")
          #   response = cloud_scheduler_client.pause_job(formatted_name)

          def pause_job \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::PauseJobRequest)
            @pause_job.call(req, options, &block)
          end

          # Resume a job.
          #
          # This method reenables a job after it has been {Google::Cloud::Scheduler::V1beta1::Job::State::PAUSED Job::State::PAUSED}. The
          # state of a job is stored in {Google::Cloud::Scheduler::V1beta1::Job#state Job#state}; after calling this method it
          # will be set to {Google::Cloud::Scheduler::V1beta1::Job::State::ENABLED Job::State::ENABLED}. A job must be in
          # {Google::Cloud::Scheduler::V1beta1::Job::State::PAUSED Job::State::PAUSED} to be resumed.
          #
          # @param name [String]
          #   Required.
          #
          #   The job name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path("[PROJECT]", "[LOCATION]", "[JOB]")
          #   response = cloud_scheduler_client.resume_job(formatted_name)

          def resume_job \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::ResumeJobRequest)
            @resume_job.call(req, options, &block)
          end

          # Forces a job to run now.
          #
          # When this method is called, Cloud Scheduler will dispatch the job, even
          # if the job is already running.
          #
          # @param name [String]
          #   Required.
          #
          #   The job name. For example:
          #   `projects/PROJECT_ID/locations/LOCATION_ID/jobs/JOB_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Scheduler::V1beta1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Scheduler::V1beta1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/scheduler"
          #
          #   cloud_scheduler_client = Google::Cloud::Scheduler.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path("[PROJECT]", "[LOCATION]", "[JOB]")
          #   response = cloud_scheduler_client.run_job(formatted_name)

          def run_job \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Scheduler::V1beta1::RunJobRequest)
            @run_job.call(req, options, &block)
          end
        end
      end
    end
  end
end
