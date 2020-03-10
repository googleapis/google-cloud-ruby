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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dataproc/v1beta2/autoscaling_policies.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/dataproc/v1beta2/autoscaling_policies_pb"
require "google/cloud/dataproc/v1beta2/credentials"
require "google/cloud/dataproc/version"

module Google
  module Cloud
    module Dataproc
      module V1beta2
        # The API interface for managing autoscaling policies in the
        # Cloud Dataproc API.
        #
        # @!attribute [r] autoscaling_policy_service_stub
        #   @return [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub]
        class AutoscalingPolicyServiceClient
          # @private
          attr_reader :autoscaling_policy_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dataproc.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_autoscaling_policies" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "policies")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          AUTOSCALING_POLICY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/regions/{region}/autoscalingPolicies/{autoscaling_policy}"
          )

          private_constant :AUTOSCALING_POLICY_PATH_TEMPLATE

          REGION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/regions/{region}"
          )

          private_constant :REGION_PATH_TEMPLATE

          # Returns a fully-qualified autoscaling_policy resource name string.
          # @param project [String]
          # @param region [String]
          # @param autoscaling_policy [String]
          # @return [String]
          def self.autoscaling_policy_path project, region, autoscaling_policy
            AUTOSCALING_POLICY_PATH_TEMPLATE.render(
              :"project" => project,
              :"region" => region,
              :"autoscaling_policy" => autoscaling_policy
            )
          end

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
            require "google/cloud/dataproc/v1beta2/autoscaling_policies_services_pb"

            credentials ||= Google::Cloud::Dataproc::V1beta2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Dataproc::V1beta2::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Dataproc::VERSION

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
              "autoscaling_policy_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dataproc.v1beta2.AutoscalingPolicyService",
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
            @autoscaling_policy_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.method(:new)
            )

            @create_autoscaling_policy = Google::Gax.create_api_call(
              @autoscaling_policy_service_stub.method(:create_autoscaling_policy),
              defaults["create_autoscaling_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_autoscaling_policy = Google::Gax.create_api_call(
              @autoscaling_policy_service_stub.method(:update_autoscaling_policy),
              defaults["update_autoscaling_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'policy.name' => request.policy.name}
              end
            )
            @get_autoscaling_policy = Google::Gax.create_api_call(
              @autoscaling_policy_service_stub.method(:get_autoscaling_policy),
              defaults["get_autoscaling_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_autoscaling_policies = Google::Gax.create_api_call(
              @autoscaling_policy_service_stub.method(:list_autoscaling_policies),
              defaults["list_autoscaling_policies"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_autoscaling_policy = Google::Gax.create_api_call(
              @autoscaling_policy_service_stub.method(:delete_autoscaling_policy),
              defaults["delete_autoscaling_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Creates new autoscaling policy.
          #
          # @param parent [String]
          #   Required. The "resource name" of the region or location, as described
          #   in https://cloud.google.com/apis/design/resource_names.
          #
          #   * For `projects.regions.autoscalingPolicies.create`, the resource name
          #     has the following format:
          #     `projects/{project_id}/regions/{region}`
          #
          #   * For `projects.locations.autoscalingPolicies.create`, the resource name
          #     has the following format:
          #     `projects/{project_id}/locations/{location}`
          # @param policy [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy | Hash]
          #   Required. The autoscaling policy to create.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   autoscaling_policy_client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)
          #   formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")
          #
          #   # TODO: Initialize `policy`:
          #   policy = {}
          #   response = autoscaling_policy_client.create_autoscaling_policy(formatted_parent, policy)

          def create_autoscaling_policy \
              parent,
              policy,
              options: nil,
              &block
            req = {
              parent: parent,
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1beta2::CreateAutoscalingPolicyRequest)
            @create_autoscaling_policy.call(req, options, &block)
          end

          # Updates (replaces) autoscaling policy.
          #
          # Disabled check for update_mask, because all updates will be full
          # replacements.
          #
          # @param policy [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy | Hash]
          #   Required. The updated autoscaling policy.
          #   A hash of the same form as `Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   autoscaling_policy_client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)
          #
          #   # TODO: Initialize `policy`:
          #   policy = {}
          #   response = autoscaling_policy_client.update_autoscaling_policy(policy)

          def update_autoscaling_policy \
              policy,
              options: nil,
              &block
            req = {
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1beta2::UpdateAutoscalingPolicyRequest)
            @update_autoscaling_policy.call(req, options, &block)
          end

          # Retrieves autoscaling policy.
          #
          # @param name [String]
          #   Required. The "resource name" of the autoscaling policy, as described
          #   in https://cloud.google.com/apis/design/resource_names.
          #
          #   * For `projects.regions.autoscalingPolicies.get`, the resource name
          #     of the policy has the following format:
          #     `projects/{project_id}/regions/{region}/autoscalingPolicies/{policy_id}`
          #
          #   * For `projects.locations.autoscalingPolicies.get`, the resource name
          #     of the policy has the following format:
          #     `projects/{project_id}/locations/{location}/autoscalingPolicies/{policy_id}`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   autoscaling_policy_client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)
          #   formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")
          #   response = autoscaling_policy_client.get_autoscaling_policy(formatted_name)

          def get_autoscaling_policy \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1beta2::GetAutoscalingPolicyRequest)
            @get_autoscaling_policy.call(req, options, &block)
          end

          # Lists autoscaling policies in the project.
          #
          # @param parent [String]
          #   Required. The "resource name" of the region or location, as described
          #   in https://cloud.google.com/apis/design/resource_names.
          #
          #   * For `projects.regions.autoscalingPolicies.list`, the resource name
          #     of the region has the following format:
          #     `projects/{project_id}/regions/{region}`
          #
          #   * For `projects.locations.autoscalingPolicies.list`, the resource name
          #     of the location has the following format:
          #     `projects/{project_id}/locations/{location}`
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy>]
          #   An enumerable of Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dataproc"
          #
          #   autoscaling_policy_client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)
          #   formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")
          #
          #   # Iterate over all results.
          #   autoscaling_policy_client.list_autoscaling_policies(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   autoscaling_policy_client.list_autoscaling_policies(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_autoscaling_policies \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1beta2::ListAutoscalingPoliciesRequest)
            @list_autoscaling_policies.call(req, options, &block)
          end

          # Deletes an autoscaling policy. It is an error to delete an autoscaling
          # policy that is in use by one or more clusters.
          #
          # @param name [String]
          #   Required. The "resource name" of the autoscaling policy, as described
          #   in https://cloud.google.com/apis/design/resource_names.
          #
          #   * For `projects.regions.autoscalingPolicies.delete`, the resource name
          #     of the policy has the following format:
          #     `projects/{project_id}/regions/{region}/autoscalingPolicies/{policy_id}`
          #
          #   * For `projects.locations.autoscalingPolicies.delete`, the resource name
          #     of the policy has the following format:
          #     `projects/{project_id}/locations/{location}/autoscalingPolicies/{policy_id}`
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
          #   autoscaling_policy_client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)
          #   formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")
          #   autoscaling_policy_client.delete_autoscaling_policy(formatted_name)

          def delete_autoscaling_policy \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dataproc::V1beta2::DeleteAutoscalingPolicyRequest)
            @delete_autoscaling_policy.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
