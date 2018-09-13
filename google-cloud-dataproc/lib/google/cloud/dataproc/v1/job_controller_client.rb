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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dataproc/v1/jobs.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/dataproc/v1/jobs_pb"
require "google/cloud/dataproc/v1/credentials"

module Google
  module Cloud
    module Dataproc
      module V1
        # The JobController provides methods to manage jobs.
        #
        # @!attribute [r] job_controller_stub
        #   @return [Google::Cloud::Dataproc::V1::JobController::Stub]
        class JobControllerClient
          # @private
          attr_reader :job_controller_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dataproc.googleapis.com".freeze

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
            require "google/cloud/dataproc/v1/jobs_services_pb"

            credentials ||= Google::Cloud::Dataproc::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Dataproc::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-dataproc'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "job_controller_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dataproc.v1.JobController",
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
            @job_controller_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Dataproc::V1::JobController::Stub.method(:new)
            )

            @submit_job = Google::Gax.create_api_call(
              @job_controller_stub.method(:submit_job),
              defaults["submit_job"],
              exception_transformer: exception_transformer
            )
            @get_job = Google::Gax.create_api_call(
              @job_controller_stub.method(:get_job),
              defaults["get_job"],
              exception_transformer: exception_transformer
            )
            @list_jobs = Google::Gax.create_api_call(
              @job_controller_stub.method(:list_jobs),
              defaults["list_jobs"],
              exception_transformer: exception_transformer
            )
            @update_job = Google::Gax.create_api_call(
              @job_controller_stub.method(:update_job),
              defaults["update_job"],
              exception_transformer: exception_transformer
            )
            @cancel_job = Google::Gax.create_api_call(
              @job_controller_stub.method(:cancel_job),
              defaults["cancel_job"],
              exception_transformer: exception_transformer
            )
            @delete_job = Google::Gax.create_api_call(
              @job_controller_stub.method(:delete_job),
              defaults["delete_job"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Submits a job to a cluster.
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param job [Google::Cloud::Dataproc::V1::Job | Hash]
          #   Required. The job resource.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1::Job`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # TODO: Initialize `job`:
          #   job = {}
          #   response = job_controller_client.submit_job(project_id, region, job)

          def submit_job \
              project_id,
              region,
              job,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              job: job
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::SubmitJobRequest)
            @submit_job.call(req, options, &block)
          end

          # Gets the resource representation for a job in a project.
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param job_id [String]
          #   Required. The job ID.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # TODO: Initialize `job_id`:
          #   job_id = ''
          #   response = job_controller_client.get_job(project_id, region, job_id)

          def get_job \
              project_id,
              region,
              job_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              job_id: job_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::GetJobRequest)
            @get_job.call(req, options, &block)
          end

          # Lists regions/\\{region}/jobs in a project.
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param cluster_name [String]
          #   Optional. If set, the returned jobs list includes only jobs that were
          #   submitted to the named cluster.
          # @param job_state_matcher [Google::Cloud::Dataproc::V1::ListJobsRequest::JobStateMatcher]
          #   Optional. Specifies enumerated categories of jobs to list.
          #   (default = match ALL jobs).
          #
          #   If `filter` is provided, `jobStateMatcher` will be ignored.
          # @param filter [String]
          #   Optional. A filter constraining the jobs to list. Filters are
          #   case-sensitive and have the following syntax:
          #
          #   [field = value] AND [field [= value]] ...
          #
          #   where **field** is `status.state` or `labels.[KEY]`, and `[KEY]` is a label
          #   key. **value** can be `*` to match all values.
          #   `status.state` can be either `ACTIVE` or `NON_ACTIVE`.
          #   Only the logical `AND` operator is supported; space-separated items are
          #   treated as having an implicit `AND` operator.
          #
          #   Example filter:
          #
          #   status.state = ACTIVE AND labels.env = staging AND labels.starred = *
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1::Job>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1::Job>]
          #   An enumerable of Google::Cloud::Dataproc::V1::Job instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # Iterate over all results.
          #   job_controller_client.list_jobs(project_id, region).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   job_controller_client.list_jobs(project_id, region).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_jobs \
              project_id,
              region,
              page_size: nil,
              cluster_name: nil,
              job_state_matcher: nil,
              filter: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              page_size: page_size,
              cluster_name: cluster_name,
              job_state_matcher: job_state_matcher,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::ListJobsRequest)
            @list_jobs.call(req, options, &block)
          end

          # Updates a job in a project.
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param job_id [String]
          #   Required. The job ID.
          # @param job [Google::Cloud::Dataproc::V1::Job | Hash]
          #   Required. The changes to the job.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1::Job`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required. Specifies the path, relative to <code>Job</code>, of
          #   the field to update. For example, to update the labels of a Job the
          #   <code>update_mask</code> parameter would be specified as
          #   <code>labels</code>, and the `PATCH` request body would specify the new
          #   value. <strong>Note:</strong> Currently, <code>labels</code> is the only
          #   field that can be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # TODO: Initialize `job_id`:
          #   job_id = ''
          #
          #   # TODO: Initialize `job`:
          #   job = {}
          #
          #   # TODO: Initialize `update_mask`:
          #   update_mask = {}
          #   response = job_controller_client.update_job(project_id, region, job_id, job, update_mask)

          def update_job \
              project_id,
              region,
              job_id,
              job,
              update_mask,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              job_id: job_id,
              job: job,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::UpdateJobRequest)
            @update_job.call(req, options, &block)
          end

          # Starts a job cancellation request. To access the job resource
          # after cancellation, call
          # [regions/\\{region}/jobs.list](https://cloud.google.com/dataproc/docs/reference/rest/v1/projects.regions.jobs/list) or
          # [regions/\\{region}/jobs.get](https://cloud.google.com/dataproc/docs/reference/rest/v1/projects.regions.jobs/get).
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param job_id [String]
          #   Required. The job ID.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::Job]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::Job]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # TODO: Initialize `job_id`:
          #   job_id = ''
          #   response = job_controller_client.cancel_job(project_id, region, job_id)

          def cancel_job \
              project_id,
              region,
              job_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              job_id: job_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::CancelJobRequest)
            @cancel_job.call(req, options, &block)
          end

          # Deletes the job from the project. If the job is active, the delete fails,
          # and the response returns `FAILED_PRECONDITION`.
          #
          # @param project_id [String]
          #   Required. The ID of the Google Cloud Platform project that the job
          #   belongs to.
          # @param region [String]
          #   Required. The Cloud Dataproc region in which to handle the request.
          # @param job_id [String]
          #   Required. The job ID.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   job_controller_client = Google::Cloud::Dataproc::JobController.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `region`:
          #   region = ''
          #
          #   # TODO: Initialize `job_id`:
          #   job_id = ''
          #   job_controller_client.delete_job(project_id, region, job_id)

          def delete_job \
              project_id,
              region,
              job_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              region: region,
              job_id: job_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::DeleteJobRequest)
            @delete_job.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
