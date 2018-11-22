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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dataproc/v1/workflow_templates.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/dataproc/v1/workflow_templates_pb"
require "google/cloud/dataproc/v1/credentials"

module Google
  module Cloud
    module Dataproc
      module V1
        # The API interface for managing Workflow Templates in the
        # Cloud Dataproc API.
        #
        # @!attribute [r] workflow_template_service_stub
        #   @return [Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub]
        class WorkflowTemplateServiceClient
          # @private
          attr_reader :workflow_template_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dataproc.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_workflow_templates" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "templates")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = WorkflowTemplateServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = WorkflowTemplateServiceClient::GRPC_INTERCEPTORS
          end

          REGION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/regions/{region}"
          )

          private_constant :REGION_PATH_TEMPLATE

          WORKFLOW_TEMPLATE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/regions/{region}/workflowTemplates/{workflow_template}"
          )

          private_constant :WORKFLOW_TEMPLATE_PATH_TEMPLATE

          # Returns a fully-qualified region resource name string.
          # @param project [String]
          # @param region [String]
          # @return [String]
          def self.region_path project, region
            REGION_PATH_TEMPLATE.render(
              :"project" => project,
              :"region" => region
            )
          end

          # Returns a fully-qualified workflow_template resource name string.
          # @param project [String]
          # @param region [String]
          # @param workflow_template [String]
          # @return [String]
          def self.workflow_template_path project, region, workflow_template
            WORKFLOW_TEMPLATE_PATH_TEMPLATE.render(
              :"project" => project,
              :"region" => region,
              :"workflow_template" => workflow_template
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
            require "google/cloud/dataproc/v1/workflow_templates_services_pb"

            credentials ||= Google::Cloud::Dataproc::V1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

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
              "workflow_template_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dataproc.v1.WorkflowTemplateService",
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
            @workflow_template_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Dataproc::V1::WorkflowTemplateService::Stub.method(:new)
            )

            @create_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:create_workflow_template),
              defaults["create_workflow_template"],
              exception_transformer: exception_transformer
            )
            @get_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:get_workflow_template),
              defaults["get_workflow_template"],
              exception_transformer: exception_transformer
            )
            @instantiate_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:instantiate_workflow_template),
              defaults["instantiate_workflow_template"],
              exception_transformer: exception_transformer
            )
            @instantiate_inline_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:instantiate_inline_workflow_template),
              defaults["instantiate_inline_workflow_template"],
              exception_transformer: exception_transformer
            )
            @update_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:update_workflow_template),
              defaults["update_workflow_template"],
              exception_transformer: exception_transformer
            )
            @list_workflow_templates = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:list_workflow_templates),
              defaults["list_workflow_templates"],
              exception_transformer: exception_transformer
            )
            @delete_workflow_template = Google::Gax.create_api_call(
              @workflow_template_service_stub.method(:delete_workflow_template),
              defaults["delete_workflow_template"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Creates new workflow template.
          #
          # @param parent [String]
          #   Required. The "resource name" of the region, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}`
          # @param template [Google::Cloud::Dataproc::V1::WorkflowTemplate | Hash]
          #   Required. The Dataproc workflow template to create.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1::WorkflowTemplate`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
          #
          #   # TODO: Initialize `template`:
          #   template = {}
          #   response = workflow_template_service_client.create_workflow_template(formatted_parent, template)

          def create_workflow_template \
              parent,
              template,
              options: nil,
              &block
            req = {
              parent: parent,
              template: template
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::CreateWorkflowTemplateRequest)
            @create_workflow_template.call(req, options, &block)
          end

          # Retrieves the latest workflow template.
          #
          # Can retrieve previously instantiated template by specifying optional
          # version parameter.
          #
          # @param name [String]
          #   Required. The "resource name" of the workflow template, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
          # @param version [Integer]
          #   Optional. The version of workflow template to retrieve. Only previously
          #   instatiated versions can be retrieved.
          #
          #   If unspecified, retrieves the current version.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")
          #   response = workflow_template_service_client.get_workflow_template(formatted_name)

          def get_workflow_template \
              name,
              version: nil,
              options: nil,
              &block
            req = {
              name: name,
              version: version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::GetWorkflowTemplateRequest)
            @get_workflow_template.call(req, options, &block)
          end

          # Instantiates a template and begins execution.
          #
          # The returned Operation can be used to track execution of
          # workflow by polling
          # {Google::Longrunning::Operations::GetOperation operations::get}.
          # The Operation will complete when entire workflow is finished.
          #
          # The running workflow can be aborted via
          # {Google::Longrunning::Operations::CancelOperation operations::cancel}.
          # This will cause any inflight jobs to be cancelled and workflow-owned
          # clusters to be deleted.
          #
          # The {Google::Longrunning::Operation#metadata Operation#metadata} will be
          # {Google::Cloud::Dataproc::V1::WorkflowMetadata WorkflowMetadata}.
          #
          # On successful completion,
          # {Google::Longrunning::Operation#response Operation#response} will be
          # {Google::Protobuf::Empty Empty}.
          #
          # @param name [String]
          #   Required. The "resource name" of the workflow template, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
          # @param version [Integer]
          #   Optional. The version of workflow template to instantiate. If specified,
          #   the workflow will be instantiated only if the current version of
          #   the workflow template has the supplied version.
          #
          #   This option cannot be used to instantiate a previous version of
          #   workflow template.
          # @param request_id [String]
          #   Optional. A tag that prevents multiple concurrent workflow
          #   instances with the same tag from running. This mitigates risk of
          #   concurrent instances started due to retries.
          #
          #   It is recommended to always set this value to a
          #   [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).
          #
          #   The tag must contain only letters (a-z, A-Z), numbers (0-9),
          #   underscores (_), and hyphens (-). The maximum length is 40 characters.
          # @param parameters [Hash{String => String}]
          #   Optional. Map from parameter names to values that should be used for those
          #   parameters. Values may not exceed 100 characters.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")
          #
          #   # Register a callback during the method call.
          #   operation = workflow_template_service_client.instantiate_workflow_template(formatted_name) do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Or use the return value to register a callback.
          #   operation.on_done do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Manually reload the operation.
          #   operation.reload!
          #
          #   # Or block until the operation completes, triggering callbacks on
          #   # completion.
          #   operation.wait_until_done!

          def instantiate_workflow_template \
              name,
              version: nil,
              request_id: nil,
              parameters: nil,
              options: nil
            req = {
              name: name,
              version: version,
              request_id: request_id,
              parameters: parameters
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::InstantiateWorkflowTemplateRequest)
            operation = Google::Gax::Operation.new(
              @instantiate_workflow_template.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::Dataproc::V1::WorkflowMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Instantiates a template and begins execution.
          #
          # This method is equivalent to executing the sequence
          # {Google::Cloud::Dataproc::V1::WorkflowTemplateService::CreateWorkflowTemplate CreateWorkflowTemplate}, {Google::Cloud::Dataproc::V1::WorkflowTemplateService::InstantiateWorkflowTemplate InstantiateWorkflowTemplate},
          # {Google::Cloud::Dataproc::V1::WorkflowTemplateService::DeleteWorkflowTemplate DeleteWorkflowTemplate}.
          #
          # The returned Operation can be used to track execution of
          # workflow by polling
          # {Google::Longrunning::Operations::GetOperation operations::get}.
          # The Operation will complete when entire workflow is finished.
          #
          # The running workflow can be aborted via
          # {Google::Longrunning::Operations::CancelOperation operations::cancel}.
          # This will cause any inflight jobs to be cancelled and workflow-owned
          # clusters to be deleted.
          #
          # The {Google::Longrunning::Operation#metadata Operation#metadata} will be
          # {Google::Cloud::Dataproc::V1::WorkflowMetadata WorkflowMetadata}.
          #
          # On successful completion,
          # {Google::Longrunning::Operation#response Operation#response} will be
          # {Google::Protobuf::Empty Empty}.
          #
          # @param parent [String]
          #   Required. The "resource name" of the workflow template region, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}`
          # @param template [Google::Cloud::Dataproc::V1::WorkflowTemplate | Hash]
          #   Required. The workflow template to instantiate.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1::WorkflowTemplate`
          #   can also be provided.
          # @param request_id [String]
          #   Optional. A tag that prevents multiple concurrent workflow
          #   instances with the same tag from running. This mitigates risk of
          #   concurrent instances started due to retries.
          #
          #   It is recommended to always set this value to a
          #   [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).
          #
          #   The tag must contain only letters (a-z, A-Z), numbers (0-9),
          #   underscores (_), and hyphens (-). The maximum length is 40 characters.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
          #
          #   # TODO: Initialize `template`:
          #   template = {}
          #
          #   # Register a callback during the method call.
          #   operation = workflow_template_service_client.instantiate_inline_workflow_template(formatted_parent, template) do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Or use the return value to register a callback.
          #   operation.on_done do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Manually reload the operation.
          #   operation.reload!
          #
          #   # Or block until the operation completes, triggering callbacks on
          #   # completion.
          #   operation.wait_until_done!

          def instantiate_inline_workflow_template \
              parent,
              template,
              request_id: nil,
              options: nil
            req = {
              parent: parent,
              template: template,
              request_id: request_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::InstantiateInlineWorkflowTemplateRequest)
            operation = Google::Gax::Operation.new(
              @instantiate_inline_workflow_template.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::Dataproc::V1::WorkflowMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Updates (replaces) workflow template. The updated template
          # must contain version that matches the current server version.
          #
          # @param template [Google::Cloud::Dataproc::V1::WorkflowTemplate | Hash]
          #   Required. The updated workflow template.
          #
          #   The `template.version` field must match the current version.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1::WorkflowTemplate`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #
          #   # TODO: Initialize `template`:
          #   template = {}
          #   response = workflow_template_service_client.update_workflow_template(template)

          def update_workflow_template \
              template,
              options: nil,
              &block
            req = {
              template: template
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::UpdateWorkflowTemplateRequest)
            @update_workflow_template.call(req, options, &block)
          end

          # Lists workflows that match the specified filter in the request.
          #
          # @param parent [String]
          #   Required. The "resource name" of the region, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}`
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1::WorkflowTemplate>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1::WorkflowTemplate>]
          #   An enumerable of Google::Cloud::Dataproc::V1::WorkflowTemplate instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_parent = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.region_path("[PROJECT]", "[REGION]")
          #
          #   # Iterate over all results.
          #   workflow_template_service_client.list_workflow_templates(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   workflow_template_service_client.list_workflow_templates(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_workflow_templates \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::ListWorkflowTemplatesRequest)
            @list_workflow_templates.call(req, options, &block)
          end

          # Deletes a workflow template. It does not cancel in-progress workflows.
          #
          # @param name [String]
          #   Required. The "resource name" of the workflow template, as described
          #   in https://cloud.google.com/apis/design/resource_names of the form
          #   `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
          # @param version [Integer]
          #   Optional. The version of workflow template to delete. If specified,
          #   will only delete the template if the current server version matches
          #   specified version.
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
          #   workflow_template_service_client = Google::Cloud::Dataproc::WorkflowTemplate.new(version: :v1)
          #   formatted_name = Google::Cloud::Dataproc::V1::WorkflowTemplateServiceClient.workflow_template_path("[PROJECT]", "[REGION]", "[WORKFLOW_TEMPLATE]")
          #   workflow_template_service_client.delete_workflow_template(formatted_name)

          def delete_workflow_template \
              name,
              version: nil,
              options: nil,
              &block
            req = {
              name: name,
              version: version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1::DeleteWorkflowTemplateRequest)
            @delete_workflow_template.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
