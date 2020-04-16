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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/talent/v4beta1/application_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/talent/v4beta1/application_service_pb"
require "google/cloud/talent/v4beta1/credentials"
require "google/cloud/talent/version"

module Google
  module Cloud
    module Talent
      module V4beta1
        # A service that handles application management, including CRUD and
        # enumeration.
        #
        # @!attribute [r] application_service_stub
        #   @return [Google::Cloud::Talent::V4beta1::ApplicationService::Stub]
        class ApplicationServiceClient
          # @private
          attr_reader :application_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "jobs.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_applications" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "applications")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/jobs"
          ].freeze


          APPLICATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}/profiles/{profile}/applications/{application}"
          )

          private_constant :APPLICATION_PATH_TEMPLATE

          COMPANY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}/companies/{company}"
          )

          private_constant :COMPANY_PATH_TEMPLATE

          COMPANY_WITHOUT_TENANT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/companies/{company}"
          )

          private_constant :COMPANY_WITHOUT_TENANT_PATH_TEMPLATE

          JOB_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}/jobs/{job}"
          )

          private_constant :JOB_PATH_TEMPLATE

          JOB_WITHOUT_TENANT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/jobs/{job}"
          )

          private_constant :JOB_WITHOUT_TENANT_PATH_TEMPLATE

          PROFILE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}/profiles/{profile}"
          )

          private_constant :PROFILE_PATH_TEMPLATE

          # Returns a fully-qualified application resource name string.
          # @param project [String]
          # @param tenant [String]
          # @param profile [String]
          # @param application [String]
          # @return [String]
          def self.application_path project, tenant, profile, application
            APPLICATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant,
              :"profile" => profile,
              :"application" => application
            )
          end

          # Returns a fully-qualified company resource name string.
          # @param project [String]
          # @param tenant [String]
          # @param company [String]
          # @return [String]
          def self.company_path project, tenant, company
            COMPANY_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant,
              :"company" => company
            )
          end

          # Returns a fully-qualified company_without_tenant resource name string.
          # @deprecated Multi-pattern resource names will have unified creation and parsing helper functions.
          # This helper function will be deleted in the next major version.
          # @param project [String]
          # @param company [String]
          # @return [String]
          def self.company_without_tenant_path project, company
            COMPANY_WITHOUT_TENANT_PATH_TEMPLATE.render(
              :"project" => project,
              :"company" => company
            )
          end

          # Returns a fully-qualified job resource name string.
          # @param project [String]
          # @param tenant [String]
          # @param job [String]
          # @return [String]
          def self.job_path project, tenant, job
            JOB_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant,
              :"job" => job
            )
          end

          # Returns a fully-qualified job_without_tenant resource name string.
          # @deprecated Multi-pattern resource names will have unified creation and parsing helper functions.
          # This helper function will be deleted in the next major version.
          # @param project [String]
          # @param job [String]
          # @return [String]
          def self.job_without_tenant_path project, job
            JOB_WITHOUT_TENANT_PATH_TEMPLATE.render(
              :"project" => project,
              :"job" => job
            )
          end

          # Returns a fully-qualified profile resource name string.
          # @param project [String]
          # @param tenant [String]
          # @param profile [String]
          # @return [String]
          def self.profile_path project, tenant, profile
            PROFILE_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant,
              :"profile" => profile
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/talent/v4beta1/application_service_services_pb"

            credentials ||= Google::Cloud::Talent::V4beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Talent::V4beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Talent::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "application_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.talent.v4beta1.ApplicationService",
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
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @application_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Talent::V4beta1::ApplicationService::Stub.method(:new)
            )

            @delete_application = Google::Gax.create_api_call(
              @application_service_stub.method(:delete_application),
              defaults["delete_application"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_application = Google::Gax.create_api_call(
              @application_service_stub.method(:create_application),
              defaults["create_application"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_application = Google::Gax.create_api_call(
              @application_service_stub.method(:get_application),
              defaults["get_application"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_application = Google::Gax.create_api_call(
              @application_service_stub.method(:update_application),
              defaults["update_application"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'application.name' => request.application.name}
              end
            )
            @list_applications = Google::Gax.create_api_call(
              @application_service_stub.method(:list_applications),
              defaults["list_applications"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
          end

          # Service calls

          # Deletes specified application.
          #
          # @param name [String]
          #   Required. The resource name of the application to be deleted.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}/applications/{application_id}".
          #   For example, "projects/foo/tenants/bar/profiles/baz/applications/qux".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   application_client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)
          #   formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")
          #   application_client.delete_application(formatted_name)

          def delete_application \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::DeleteApplicationRequest)
            @delete_application.call(req, options, &block)
            nil
          end

          # Creates a new application entity.
          #
          # @param parent [String]
          #   Required. Resource name of the profile under which the application is created.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}".
          #   For example, "projects/foo/tenants/bar/profiles/baz".
          # @param application [Google::Cloud::Talent::V4beta1::Application | Hash]
          #   Required. The application to be created.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::Application`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Application]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Application]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   application_client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
          #
          #   # TODO: Initialize `application`:
          #   application = {}
          #   response = application_client.create_application(formatted_parent, application)

          def create_application \
              parent,
              application,
              options: nil,
              &block
            req = {
              parent: parent,
              application: application
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::CreateApplicationRequest)
            @create_application.call(req, options, &block)
          end

          # Retrieves specified application.
          #
          # @param name [String]
          #   Required. The resource name of the application to be retrieved.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}/applications/{application_id}".
          #   For example, "projects/foo/tenants/bar/profiles/baz/applications/qux".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Application]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Application]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   application_client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)
          #   formatted_name = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.application_path("[PROJECT]", "[TENANT]", "[PROFILE]", "[APPLICATION]")
          #   response = application_client.get_application(formatted_name)

          def get_application \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::GetApplicationRequest)
            @get_application.call(req, options, &block)
          end

          # Updates specified application.
          #
          # @param application [Google::Cloud::Talent::V4beta1::Application | Hash]
          #   Required. The application resource to replace the current resource in the system.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::Application`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Strongly recommended for the best service experience.
          #
          #   If {Google::Cloud::Talent::V4beta1::UpdateApplicationRequest#update_mask update_mask} is provided, only the specified fields in
          #   {Google::Cloud::Talent::V4beta1::UpdateApplicationRequest#application application} are updated. Otherwise all the fields are updated.
          #
          #   A field mask to specify the application fields to be updated. Only
          #   top level fields of {Google::Cloud::Talent::V4beta1::Application Application} are supported.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Application]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Application]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   application_client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)
          #
          #   # TODO: Initialize `application`:
          #   application = {}
          #   response = application_client.update_application(application)

          def update_application \
              application,
              update_mask: nil,
              options: nil,
              &block
            req = {
              application: application,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::UpdateApplicationRequest)
            @update_application.call(req, options, &block)
          end

          # Lists all applications associated with the profile.
          #
          # @param parent [String]
          #   Required. Resource name of the profile under which the application is created.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}", for
          #   example, "projects/foo/tenants/bar/profiles/baz".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::Application>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::Application>]
          #   An enumerable of Google::Cloud::Talent::V4beta1::Application instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   application_client = Google::Cloud::Talent::ApplicationService.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ApplicationServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
          #
          #   # Iterate over all results.
          #   application_client.list_applications(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   application_client.list_applications(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_applications \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::ListApplicationsRequest)
            @list_applications.call(req, options, &block)
          end
        end
      end
    end
  end
end
