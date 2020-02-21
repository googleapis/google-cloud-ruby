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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/security_center/v1/securitycenter_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/security_center/v1/securitycenter_service_pb"
require "google/cloud/security_center/v1/run_asset_discovery_response_pb"
require "google/cloud/security_center/v1/credentials"
require "google/cloud/security_center/version"

module Google
  module Cloud
    module SecurityCenter
      module V1
        # V1 APIs for Security Center service.
        #
        # @!attribute [r] security_center_stub
        #   @return [Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub]
        class SecurityCenterClient
          # @private
          attr_reader :security_center_stub

          # The default address of the service.
          SERVICE_ADDRESS = "securitycenter.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "group_assets" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "group_by_results"),
            "group_findings" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "group_by_results"),
            "list_assets" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "list_assets_results"),
            "list_findings" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "list_findings_results"),
            "list_sources" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "sources")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = SecurityCenterClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = SecurityCenterClient::GRPC_INTERCEPTORS
          end

          ASSET_SECURITY_MARKS_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/assets/{asset}/securityMarks"
          )

          private_constant :ASSET_SECURITY_MARKS_PATH_TEMPLATE

          FINDING_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/sources/{source}/findings/{finding}"
          )

          private_constant :FINDING_PATH_TEMPLATE

          FINDING_SECURITY_MARKS_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/sources/{source}/findings/{finding}/securityMarks"
          )

          private_constant :FINDING_SECURITY_MARKS_PATH_TEMPLATE

          ORGANIZATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}"
          )

          private_constant :ORGANIZATION_PATH_TEMPLATE

          ORGANIZATION_SETTINGS_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/organizationSettings"
          )

          private_constant :ORGANIZATION_SETTINGS_PATH_TEMPLATE

          SOURCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/sources/{source}"
          )

          private_constant :SOURCE_PATH_TEMPLATE

          # Returns a fully-qualified asset_security_marks resource name string.
          # @deprecated Multi-pattern resource names will have unified creation and parsing helper functions.
          # This helper function will be deleted in the next major version.
          # @param organization [String]
          # @param asset [String]
          # @return [String]
          def self.asset_security_marks_path organization, asset
            ASSET_SECURITY_MARKS_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"asset" => asset
            )
          end

          # Returns a fully-qualified finding resource name string.
          # @param organization [String]
          # @param source [String]
          # @param finding [String]
          # @return [String]
          def self.finding_path organization, source, finding
            FINDING_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"source" => source,
              :"finding" => finding
            )
          end

          # Returns a fully-qualified finding_security_marks resource name string.
          # @deprecated Multi-pattern resource names will have unified creation and parsing helper functions.
          # This helper function will be deleted in the next major version.
          # @param organization [String]
          # @param source [String]
          # @param finding [String]
          # @return [String]
          def self.finding_security_marks_path organization, source, finding
            FINDING_SECURITY_MARKS_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"source" => source,
              :"finding" => finding
            )
          end

          # Returns a fully-qualified organization resource name string.
          # @param organization [String]
          # @return [String]
          def self.organization_path organization
            ORGANIZATION_PATH_TEMPLATE.render(
              :"organization" => organization
            )
          end

          # Returns a fully-qualified organization_settings resource name string.
          # @param organization [String]
          # @return [String]
          def self.organization_settings_path organization
            ORGANIZATION_SETTINGS_PATH_TEMPLATE.render(
              :"organization" => organization
            )
          end

          # Returns a fully-qualified source resource name string.
          # @param organization [String]
          # @param source [String]
          # @return [String]
          def self.source_path organization, source
            SOURCE_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"source" => source
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
            require "google/cloud/security_center/v1/securitycenter_service_services_pb"

            credentials ||= Google::Cloud::SecurityCenter::V1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version,
              metadata: metadata,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::SecurityCenter::V1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::SecurityCenter::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "security_center_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.securitycenter.v1.SecurityCenter",
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
            @security_center_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::SecurityCenter::V1::SecurityCenter::Stub.method(:new)
            )

            @create_source = Google::Gax.create_api_call(
              @security_center_stub.method(:create_source),
              defaults["create_source"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_finding = Google::Gax.create_api_call(
              @security_center_stub.method(:create_finding),
              defaults["create_finding"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @security_center_stub.method(:get_iam_policy),
              defaults["get_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @get_organization_settings = Google::Gax.create_api_call(
              @security_center_stub.method(:get_organization_settings),
              defaults["get_organization_settings"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_source = Google::Gax.create_api_call(
              @security_center_stub.method(:get_source),
              defaults["get_source"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @group_assets = Google::Gax.create_api_call(
              @security_center_stub.method(:group_assets),
              defaults["group_assets"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @group_findings = Google::Gax.create_api_call(
              @security_center_stub.method(:group_findings),
              defaults["group_findings"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_assets = Google::Gax.create_api_call(
              @security_center_stub.method(:list_assets),
              defaults["list_assets"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_findings = Google::Gax.create_api_call(
              @security_center_stub.method(:list_findings),
              defaults["list_findings"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_sources = Google::Gax.create_api_call(
              @security_center_stub.method(:list_sources),
              defaults["list_sources"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @run_asset_discovery = Google::Gax.create_api_call(
              @security_center_stub.method(:run_asset_discovery),
              defaults["run_asset_discovery"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @set_finding_state = Google::Gax.create_api_call(
              @security_center_stub.method(:set_finding_state),
              defaults["set_finding_state"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_iam_policy = Google::Gax.create_api_call(
              @security_center_stub.method(:set_iam_policy),
              defaults["set_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @security_center_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @update_finding = Google::Gax.create_api_call(
              @security_center_stub.method(:update_finding),
              defaults["update_finding"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'finding.name' => request.finding.name}
              end
            )
            @update_organization_settings = Google::Gax.create_api_call(
              @security_center_stub.method(:update_organization_settings),
              defaults["update_organization_settings"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'organization_settings.name' => request.organization_settings.name}
              end
            )
            @update_source = Google::Gax.create_api_call(
              @security_center_stub.method(:update_source),
              defaults["update_source"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'source.name' => request.source.name}
              end
            )
            @update_security_marks = Google::Gax.create_api_call(
              @security_center_stub.method(:update_security_marks),
              defaults["update_security_marks"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'security_marks.name' => request.security_marks.name}
              end
            )
          end

          # Service calls

          # Creates a source.
          #
          # @param parent [String]
          #   Required. Resource name of the new source's parent. Its format should be
          #   "organizations/[organization_id]".
          # @param source [Google::Cloud::SecurityCenter::V1::Source | Hash]
          #   Required. The Source being created, only the display_name and description will be
          #   used. All other fields will be ignored.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::Source`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Source]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Source]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
          #
          #   # TODO: Initialize `source`:
          #   source = {}
          #   response = security_center_client.create_source(formatted_parent, source)

          def create_source \
              parent,
              source,
              options: nil,
              &block
            req = {
              parent: parent,
              source: source
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::CreateSourceRequest)
            @create_source.call(req, options, &block)
          end

          # Creates a finding. The corresponding source must exist for finding creation
          # to succeed.
          #
          # @param parent [String]
          #   Required. Resource name of the new finding's parent. Its format should be
          #   "organizations/[organization_id]/sources/[source_id]".
          # @param finding_id [String]
          #   Required. Unique identifier provided by the client within the parent scope.
          #   It must be alphanumeric and less than or equal to 32 characters and
          #   greater than 0 characters in length.
          # @param finding [Google::Cloud::SecurityCenter::V1::Finding | Hash]
          #   Required. The Finding being created. The name and security_marks will be ignored as
          #   they are both output only fields on this resource.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::Finding`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Finding]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Finding]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
          #
          #   # TODO: Initialize `finding_id`:
          #   finding_id = ''
          #
          #   # TODO: Initialize `finding`:
          #   finding = {}
          #   response = security_center_client.create_finding(formatted_parent, finding_id, finding)

          def create_finding \
              parent,
              finding_id,
              finding,
              options: nil,
              &block
            req = {
              parent: parent,
              finding_id: finding_id,
              finding: finding
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::CreateFindingRequest)
            @create_finding.call(req, options, &block)
          end

          # Gets the access control policy on the specified Source.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   See the operation documentation for the appropriate value for this field.
          # @param options_ [Google::Iam::V1::GetPolicyOptions | Hash]
          #   OPTIONAL: A `GetPolicyOptions` object for specifying options to
          #   `GetIamPolicy`. This field is only used by Cloud IAM.
          #   A hash of the same form as `Google::Iam::V1::GetPolicyOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #   response = security_center_client.get_iam_policy(resource)

          def get_iam_policy \
              resource,
              options_: nil,
              options: nil,
              &block
            req = {
              resource: resource,
              options: options_
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
            @get_iam_policy.call(req, options, &block)
          end

          # Gets the settings for an organization.
          #
          # @param name [String]
          #   Required. Name of the organization to get organization settings for. Its format is
          #   "organizations/[organization_id]/organizationSettings".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::OrganizationSettings]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::OrganizationSettings]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path("[ORGANIZATION]")
          #   response = security_center_client.get_organization_settings(formatted_name)

          def get_organization_settings \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::GetOrganizationSettingsRequest)
            @get_organization_settings.call(req, options, &block)
          end

          # Gets a source.
          #
          # @param name [String]
          #   Required. Relative resource name of the source. Its format is
          #   "organizations/[organization_id]/source/[source_id]".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Source]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Source]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
          #   response = security_center_client.get_source(formatted_name)

          def get_source \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::GetSourceRequest)
            @get_source.call(req, options, &block)
          end

          # Filters an organization's assets and  groups them by their specified
          # properties.
          #
          # @param parent [String]
          #   Required. Name of the organization to groupBy. Its format is
          #   "organizations/[organization_id]".
          # @param group_by [String]
          #   Required. Expression that defines what assets fields to use for grouping. The string
          #   value should follow SQL syntax: comma separated list of fields. For
          #   example:
          #   "security_center_properties.resource_project,security_center_properties.project".
          #
          #   The following fields are supported when compare_duration is not set:
          #
          #   * security_center_properties.resource_project
          #   * security_center_properties.resource_project_display_name
          #   * security_center_properties.resource_type
          #   * security_center_properties.resource_parent
          #   * security_center_properties.resource_parent_display_name
          #
          #   The following fields are supported when compare_duration is set:
          #
          #   * security_center_properties.resource_type
          #   * security_center_properties.resource_project_display_name
          #   * security_center_properties.resource_parent_display_name
          # @param filter [String]
          #   Expression that defines the filter to apply across assets.
          #   The expression is a list of zero or more restrictions combined via logical
          #   operators `AND` and `OR`.
          #   Parentheses are supported, and `OR` has higher precedence than `AND`.
          #
          #   Restrictions have the form `<field> <operator> <value>` and may have a `-`
          #   character in front of them to indicate negation. The fields map to those
          #   defined in the Asset resource. Examples include:
          #
          #   * name
          #   * security_center_properties.resource_name
          #   * resource_properties.a_property
          #   * security_marks.marks.marka
          #
          #   The supported operators are:
          #
          #   * `=` for all value types.
          #   * `>`, `<`, `>=`, `<=` for integer values.
          #   * `:`, meaning substring matching, for strings.
          #
          #   The supported value types are:
          #
          #   * string literals in quotes.
          #   * integer literals without quotes.
          #   * boolean literals `true` and `false` without quotes.
          #
          #   The following field and operator combinations are supported:
          #
          #   * name: `=`
          #   * update_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #     "update_time = \"2019-06-10T16:07:18-07:00\""
          #     "update_time = 1560208038000"
          #
          #   * create_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #     "create_time = \"2019-06-10T16:07:18-07:00\""
          #     "create_time = 1560208038000"
          #
          #   * iam_policy.policy_blob: `=`, `:`
          #   * resource_properties: `=`, `:`, `>`, `<`, `>=`, `<=`
          #   * security_marks.marks: `=`, `:`
          #   * security_center_properties.resource_name: `=`, `:`
          #   * security_center_properties.resource_display_name: `=`, `:`
          #   * security_center_properties.resource_type: `=`, `:`
          #   * security_center_properties.resource_parent: `=`, `:`
          #   * security_center_properties.resource_parent_display_name: `=`, `:`
          #   * security_center_properties.resource_project: `=`, `:`
          #   * security_center_properties.resource_project_display_name: `=`, `:`
          #   * security_center_properties.resource_owners: `=`, `:`
          #
          #   For example, `resource_properties.size = 100` is a valid filter string.
          # @param compare_duration [Google::Protobuf::Duration | Hash]
          #   When compare_duration is set, the GroupResult's "state_change" property is
          #   updated to indicate whether the asset was added, removed, or remained
          #   present during the compare_duration period of time that precedes the
          #   read_time. This is the time between (read_time - compare_duration) and
          #   read_time.
          #
          #   The state change value is derived based on the presence of the asset at the
          #   two points in time. Intermediate state changes between the two times don't
          #   affect the result. For example, the results aren't affected if the asset is
          #   removed and re-created again.
          #
          #   Possible "state_change" values when compare_duration is specified:
          #
          #   * "ADDED":   indicates that the asset was not present at the start of
          #     compare_duration, but present at reference_time.
          #   * "REMOVED": indicates that the asset was present at the start of
          #     compare_duration, but not present at reference_time.
          #   * "ACTIVE":  indicates that the asset was present at both the
          #     start and the end of the time period defined by
          #     compare_duration and reference_time.
          #
          #   If compare_duration is not specified, then the only possible state_change
          #   is "UNUSED", which will be the state_change set for all assets present at
          #   read_time.
          #
          #   If this field is set then `state_change` must be a specified field in
          #   `group_by`.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Time used as a reference point when filtering assets. The filter is limited
          #   to assets existing at the supplied time and their values are those at that
          #   specific time. Absence of this field will default to the API's version of
          #   NOW.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::GroupResult>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::GroupResult>]
          #   An enumerable of Google::Cloud::SecurityCenter::V1::GroupResult instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
          #
          #   # TODO: Initialize `group_by`:
          #   group_by = ''
          #
          #   # Iterate over all results.
          #   security_center_client.group_assets(formatted_parent, group_by).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   security_center_client.group_assets(formatted_parent, group_by).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def group_assets \
              parent,
              group_by,
              filter: nil,
              compare_duration: nil,
              read_time: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              group_by: group_by,
              filter: filter,
              compare_duration: compare_duration,
              read_time: read_time,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::GroupAssetsRequest)
            @group_assets.call(req, options, &block)
          end

          # Filters an organization or source's findings and  groups them by their
          # specified properties.
          #
          # To group across all sources provide a `-` as the source id.
          # Example: /v1/organizations/{organization_id}/sources/-/findings
          #
          # @param parent [String]
          #   Required. Name of the source to groupBy. Its format is
          #   "organizations/[organization_id]/sources/[source_id]". To groupBy across
          #   all sources provide a source_id of `-`. For example:
          #   organizations/{organization_id}/sources/-
          # @param group_by [String]
          #   Required. Expression that defines what assets fields to use for grouping (including
          #   `state_change`). The string value should follow SQL syntax: comma separated
          #   list of fields. For example: "parent,resource_name".
          #
          #   The following fields are supported:
          #
          #   * resource_name
          #   * category
          #   * state
          #   * parent
          #
          #   The following fields are supported when compare_duration is set:
          #
          #   * state_change
          # @param filter [String]
          #   Expression that defines the filter to apply across findings.
          #   The expression is a list of one or more restrictions combined via logical
          #   operators `AND` and `OR`.
          #   Parentheses are supported, and `OR` has higher precedence than `AND`.
          #
          #   Restrictions have the form `<field> <operator> <value>` and may have a `-`
          #   character in front of them to indicate negation. Examples include:
          #
          #   * name
          #     * source_properties.a_property
          #   * security_marks.marks.marka
          #
          #   The supported operators are:
          #
          #   * `=` for all value types.
          #   * `>`, `<`, `>=`, `<=` for integer values.
          #   * `:`, meaning substring matching, for strings.
          #
          #   The supported value types are:
          #
          #   * string literals in quotes.
          #   * integer literals without quotes.
          #   * boolean literals `true` and `false` without quotes.
          #
          #   The following field and operator combinations are supported:
          #
          #   * name: `=`
          #   * parent: `=`, `:`
          #   * resource_name: `=`, `:`
          #   * state: `=`, `:`
          #   * category: `=`, `:`
          #   * external_uri: `=`, `:`
          #   * event_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #     "event_time = \"2019-06-10T16:07:18-07:00\""
          #     "event_time = 1560208038000"
          #
          #   * security_marks.marks: `=`, `:`
          #   * source_properties: `=`, `:`, `>`, `<`, `>=`, `<=`
          #
          #   For example, `source_properties.size = 100` is a valid filter string.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Time used as a reference point when filtering findings. The filter is
          #   limited to findings existing at the supplied time and their values are
          #   those at that specific time. Absence of this field will default to the
          #   API's version of NOW.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param compare_duration [Google::Protobuf::Duration | Hash]
          #   When compare_duration is set, the GroupResult's "state_change" attribute is
          #   updated to indicate whether the finding had its state changed, the
          #   finding's state remained unchanged, or if the finding was added during the
          #   compare_duration period of time that precedes the read_time. This is the
          #   time between (read_time - compare_duration) and read_time.
          #
          #   The state_change value is derived based on the presence and state of the
          #   finding at the two points in time. Intermediate state changes between the
          #   two times don't affect the result. For example, the results aren't affected
          #   if the finding is made inactive and then active again.
          #
          #   Possible "state_change" values when compare_duration is specified:
          #
          #   * "CHANGED":   indicates that the finding was present at the start of
          #     compare_duration, but changed its state at read_time.
          #   * "UNCHANGED": indicates that the finding was present at the start of
          #     compare_duration and did not change state at read_time.
          #   * "ADDED":     indicates that the finding was not present at the start
          #     of compare_duration, but was present at read_time.
          #
          #   If compare_duration is not specified, then the only possible state_change
          #   is "UNUSED",  which will be the state_change set for all findings present
          #   at read_time.
          #
          #   If this field is set then `state_change` must be a specified field in
          #   `group_by`.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::GroupResult>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::GroupResult>]
          #   An enumerable of Google::Cloud::SecurityCenter::V1::GroupResult instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
          #
          #   # TODO: Initialize `group_by`:
          #   group_by = ''
          #
          #   # Iterate over all results.
          #   security_center_client.group_findings(formatted_parent, group_by).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   security_center_client.group_findings(formatted_parent, group_by).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def group_findings \
              parent,
              group_by,
              filter: nil,
              read_time: nil,
              compare_duration: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              group_by: group_by,
              filter: filter,
              read_time: read_time,
              compare_duration: compare_duration,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::GroupFindingsRequest)
            @group_findings.call(req, options, &block)
          end

          # Lists an organization's assets.
          #
          # @param parent [String]
          #   Required. Name of the organization assets should belong to. Its format is
          #   "organizations/[organization_id]".
          # @param filter [String]
          #   Expression that defines the filter to apply across assets.
          #   The expression is a list of zero or more restrictions combined via logical
          #   operators `AND` and `OR`.
          #   Parentheses are supported, and `OR` has higher precedence than `AND`.
          #
          #   Restrictions have the form `<field> <operator> <value>` and may have a `-`
          #   character in front of them to indicate negation. The fields map to those
          #   defined in the Asset resource. Examples include:
          #
          #   * name
          #   * security_center_properties.resource_name
          #   * resource_properties.a_property
          #   * security_marks.marks.marka
          #
          #   The supported operators are:
          #
          #   * `=` for all value types.
          #   * `>`, `<`, `>=`, `<=` for integer values.
          #   * `:`, meaning substring matching, for strings.
          #
          #   The supported value types are:
          #
          #   * string literals in quotes.
          #   * integer literals without quotes.
          #   * boolean literals `true` and `false` without quotes.
          #
          #   The following are the allowed field and operator combinations:
          #
          #   * name: `=`
          #   * update_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #     "update_time = \"2019-06-10T16:07:18-07:00\""
          #     "update_time = 1560208038000"
          #
          #   * create_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #     "create_time = \"2019-06-10T16:07:18-07:00\""
          #     "create_time = 1560208038000"
          #
          #   * iam_policy.policy_blob: `=`, `:`
          #   * resource_properties: `=`, `:`, `>`, `<`, `>=`, `<=`
          #   * security_marks.marks: `=`, `:`
          #   * security_center_properties.resource_name: `=`, `:`
          #   * security_center_properties.resource_display_name: `=`, `:`
          #   * security_center_properties.resource_type: `=`, `:`
          #   * security_center_properties.resource_parent: `=`, `:`
          #   * security_center_properties.resource_parent_display_name: `=`, `:`
          #   * security_center_properties.resource_project: `=`, `:`
          #   * security_center_properties.resource_project_display_name: `=`, `:`
          #   * security_center_properties.resource_owners: `=`, `:`
          #
          #   For example, `resource_properties.size = 100` is a valid filter string.
          # @param order_by [String]
          #   Expression that defines what fields and order to use for sorting. The
          #   string value should follow SQL syntax: comma separated list of fields. For
          #   example: "name,resource_properties.a_property". The default sorting order
          #   is ascending. To specify descending order for a field, a suffix " desc"
          #   should be appended to the field name. For example: "name
          #   desc,resource_properties.a_property". Redundant space characters in the
          #   syntax are insignificant. "name desc,resource_properties.a_property" and "
          #   name     desc  ,   resource_properties.a_property  " are equivalent.
          #
          #   The following fields are supported:
          #   name
          #   update_time
          #   resource_properties
          #   security_marks.marks
          #   security_center_properties.resource_name
          #   security_center_properties.resource_display_name
          #   security_center_properties.resource_parent
          #   security_center_properties.resource_parent_display_name
          #   security_center_properties.resource_project
          #   security_center_properties.resource_project_display_name
          #   security_center_properties.resource_type
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Time used as a reference point when filtering assets. The filter is limited
          #   to assets existing at the supplied time and their values are those at that
          #   specific time. Absence of this field will default to the API's version of
          #   NOW.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param compare_duration [Google::Protobuf::Duration | Hash]
          #   When compare_duration is set, the ListAssetsResult's "state_change"
          #   attribute is updated to indicate whether the asset was added, removed, or
          #   remained present during the compare_duration period of time that precedes
          #   the read_time. This is the time between (read_time - compare_duration) and
          #   read_time.
          #
          #   The state_change value is derived based on the presence of the asset at the
          #   two points in time. Intermediate state changes between the two times don't
          #   affect the result. For example, the results aren't affected if the asset is
          #   removed and re-created again.
          #
          #   Possible "state_change" values when compare_duration is specified:
          #
          #   * "ADDED":   indicates that the asset was not present at the start of
          #     compare_duration, but present at read_time.
          #   * "REMOVED": indicates that the asset was present at the start of
          #     compare_duration, but not present at read_time.
          #   * "ACTIVE":  indicates that the asset was present at both the
          #     start and the end of the time period defined by
          #     compare_duration and read_time.
          #
          #   If compare_duration is not specified, then the only possible state_change
          #   is "UNUSED",  which will be the state_change set for all assets present at
          #   read_time.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. A field mask to specify the ListAssetsResult fields to be listed in the
          #   response.
          #   An empty field mask will list all fields.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::ListAssetsResponse::ListAssetsResult>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::ListAssetsResponse::ListAssetsResult>]
          #   An enumerable of Google::Cloud::SecurityCenter::V1::ListAssetsResponse::ListAssetsResult instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
          #
          #   # Iterate over all results.
          #   security_center_client.list_assets(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   security_center_client.list_assets(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_assets \
              parent,
              filter: nil,
              order_by: nil,
              read_time: nil,
              compare_duration: nil,
              field_mask: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              order_by: order_by,
              read_time: read_time,
              compare_duration: compare_duration,
              field_mask: field_mask,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::ListAssetsRequest)
            @list_assets.call(req, options, &block)
          end

          # Lists an organization or source's findings.
          #
          # To list across all sources provide a `-` as the source id.
          # Example: /v1/organizations/{organization_id}/sources/-/findings
          #
          # @param parent [String]
          #   Required. Name of the source the findings belong to. Its format is
          #   "organizations/[organization_id]/sources/[source_id]". To list across all
          #   sources provide a source_id of `-`. For example:
          #   organizations/{organization_id}/sources/-
          # @param filter [String]
          #   Expression that defines the filter to apply across findings.
          #   The expression is a list of one or more restrictions combined via logical
          #   operators `AND` and `OR`.
          #   Parentheses are supported, and `OR` has higher precedence than `AND`.
          #
          #   Restrictions have the form `<field> <operator> <value>` and may have a `-`
          #   character in front of them to indicate negation. Examples include:
          #
          #   * name
          #     * source_properties.a_property
          #   * security_marks.marks.marka
          #
          #   The supported operators are:
          #
          #   * `=` for all value types.
          #   * `>`, `<`, `>=`, `<=` for integer values.
          #   * `:`, meaning substring matching, for strings.
          #
          #   The supported value types are:
          #
          #   * string literals in quotes.
          #   * integer literals without quotes.
          #   * boolean literals `true` and `false` without quotes.
          #
          #   The following field and operator combinations are supported:
          #
          #   name: `=`
          #   parent: `=`, `:`
          #   resource_name: `=`, `:`
          #   state: `=`, `:`
          #   category: `=`, `:`
          #   external_uri: `=`, `:`
          #   event_time: `=`, `>`, `<`, `>=`, `<=`
          #
          #     Usage: This should be milliseconds since epoch or an RFC3339 string.
          #     Examples:
          #       "event_time = \"2019-06-10T16:07:18-07:00\""
          #       "event_time = 1560208038000"
          #
          #   security_marks.marks: `=`, `:`
          #   source_properties: `=`, `:`, `>`, `<`, `>=`, `<=`
          #
          #   For example, `source_properties.size = 100` is a valid filter string.
          # @param order_by [String]
          #   Expression that defines what fields and order to use for sorting. The
          #   string value should follow SQL syntax: comma separated list of fields. For
          #   example: "name,resource_properties.a_property". The default sorting order
          #   is ascending. To specify descending order for a field, a suffix " desc"
          #   should be appended to the field name. For example: "name
          #   desc,source_properties.a_property". Redundant space characters in the
          #   syntax are insignificant. "name desc,source_properties.a_property" and "
          #   name     desc  ,   source_properties.a_property  " are equivalent.
          #
          #   The following fields are supported:
          #   name
          #   parent
          #   state
          #   category
          #   resource_name
          #   event_time
          #   source_properties
          #   security_marks.marks
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Time used as a reference point when filtering findings. The filter is
          #   limited to findings existing at the supplied time and their values are
          #   those at that specific time. Absence of this field will default to the
          #   API's version of NOW.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param compare_duration [Google::Protobuf::Duration | Hash]
          #   When compare_duration is set, the ListFindingsResult's "state_change"
          #   attribute is updated to indicate whether the finding had its state changed,
          #   the finding's state remained unchanged, or if the finding was added in any
          #   state during the compare_duration period of time that precedes the
          #   read_time. This is the time between (read_time - compare_duration) and
          #   read_time.
          #
          #   The state_change value is derived based on the presence and state of the
          #   finding at the two points in time. Intermediate state changes between the
          #   two times don't affect the result. For example, the results aren't affected
          #   if the finding is made inactive and then active again.
          #
          #   Possible "state_change" values when compare_duration is specified:
          #
          #   * "CHANGED":   indicates that the finding was present at the start of
          #     compare_duration, but changed its state at read_time.
          #   * "UNCHANGED": indicates that the finding was present at the start of
          #     compare_duration and did not change state at read_time.
          #   * "ADDED":     indicates that the finding was not present at the start
          #     of compare_duration, but was present at read_time.
          #
          #   If compare_duration is not specified, then the only possible state_change
          #   is "UNUSED", which will be the state_change set for all findings present at
          #   read_time.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. A field mask to specify the Finding fields to be listed in the response.
          #   An empty field mask will list all fields.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::ListFindingsResponse::ListFindingsResult>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::ListFindingsResponse::ListFindingsResult>]
          #   An enumerable of Google::Cloud::SecurityCenter::V1::ListFindingsResponse::ListFindingsResult instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path("[ORGANIZATION]", "[SOURCE]")
          #
          #   # Iterate over all results.
          #   security_center_client.list_findings(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   security_center_client.list_findings(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_findings \
              parent,
              filter: nil,
              order_by: nil,
              read_time: nil,
              compare_duration: nil,
              field_mask: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              order_by: order_by,
              read_time: read_time,
              compare_duration: compare_duration,
              field_mask: field_mask,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::ListFindingsRequest)
            @list_findings.call(req, options, &block)
          end

          # Lists all sources belonging to an organization.
          #
          # @param parent [String]
          #   Required. Resource name of the parent of sources to list. Its format should be
          #   "organizations/[organization_id]".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::Source>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecurityCenter::V1::Source>]
          #   An enumerable of Google::Cloud::SecurityCenter::V1::Source instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
          #
          #   # Iterate over all results.
          #   security_center_client.list_sources(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   security_center_client.list_sources(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_sources \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::ListSourcesRequest)
            @list_sources.call(req, options, &block)
          end

          # Runs asset discovery. The discovery is tracked with a long-running
          # operation.
          #
          # This API can only be called with limited frequency for an organization. If
          # it is called too frequently the caller will receive a TOO_MANY_REQUESTS
          # error.
          #
          # @param parent [String]
          #   Required. Name of the organization to run asset discovery for. Its format is
          #   "organizations/[organization_id]".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_parent = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path("[ORGANIZATION]")
          #
          #   # Register a callback during the method call.
          #   operation = security_center_client.run_asset_discovery(formatted_parent) do |op|
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

          def run_asset_discovery \
              parent,
              options: nil
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryRequest)
            operation = Google::Gax::Operation.new(
              @run_asset_discovery.call(req, options),
              @operations_client,
              Google::Cloud::SecurityCenter::V1::RunAssetDiscoveryResponse,
              Google::Protobuf::Empty,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Updates the state of a finding.
          #
          # @param name [String]
          #   Required. The relative resource name of the finding. See:
          #   https://cloud.google.com/apis/design/resource_names#relative_resource_name
          #   Example:
          #   "organizations/{organization_id}/sources/{source_id}/finding/{finding_id}".
          # @param state [Google::Cloud::SecurityCenter::V1::Finding::State]
          #   Required. The desired State of the finding.
          # @param start_time [Google::Protobuf::Timestamp | Hash]
          #   Required. The time at which the updated state takes effect.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Finding]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Finding]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #   formatted_name = Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path("[ORGANIZATION]", "[SOURCE]", "[FINDING]")
          #
          #   # TODO: Initialize `state`:
          #   state = :STATE_UNSPECIFIED
          #
          #   # TODO: Initialize `start_time`:
          #   start_time = {}
          #   response = security_center_client.set_finding_state(formatted_name, state, start_time)

          def set_finding_state \
              name,
              state,
              start_time,
              options: nil,
              &block
            req = {
              name: name,
              state: state,
              start_time: start_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::SetFindingStateRequest)
            @set_finding_state.call(req, options, &block)
          end

          # Sets the access control policy on the specified Source.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   See the operation documentation for the appropriate value for this field.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the `resource`. The size of
          #   the policy is limited to a few 10s of KB. An empty policy is a
          #   valid policy but certain Cloud Platform services (such as Projects)
          #   might reject them.
          #   A hash of the same form as `Google::Iam::V1::Policy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #
          #   # TODO: Initialize `policy`:
          #   policy = {}
          #   response = security_center_client.set_iam_policy(resource, policy)

          def set_iam_policy \
              resource,
              policy,
              options: nil,
              &block
            req = {
              resource: resource,
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
            @set_iam_policy.call(req, options, &block)
          end

          # Returns the permissions that a caller has on the specified source.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   See the operation documentation for the appropriate value for this field.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the `resource`. Permissions with
          #   wildcards (such as '*' or 'storage.*') are not allowed. For more
          #   information see
          #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::TestIamPermissionsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::TestIamPermissionsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #
          #   # TODO: Initialize `permissions`:
          #   permissions = []
          #   response = security_center_client.test_iam_permissions(resource, permissions)

          def test_iam_permissions \
              resource,
              permissions,
              options: nil,
              &block
            req = {
              resource: resource,
              permissions: permissions
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
            @test_iam_permissions.call(req, options, &block)
          end

          # Creates or updates a finding. The corresponding source must exist for a
          # finding creation to succeed.
          #
          # @param finding [Google::Cloud::SecurityCenter::V1::Finding | Hash]
          #   Required. The finding resource to update or create if it does not already exist.
          #   parent, security_marks, and update_time will be ignored.
          #
          #   In the case of creation, the finding id portion of the name must be
          #   alphanumeric and less than or equal to 32 characters and greater than 0
          #   characters in length.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::Finding`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The FieldMask to use when updating the finding resource. This field should
          #   not be specified when creating a finding.
          #
          #   When updating a finding, an empty mask is treated as updating all mutable
          #   fields and replacing source_properties.  Individual source_properties can
          #   be added/updated by using "source_properties.<property key>" in the field
          #   mask.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Finding]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Finding]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `finding`:
          #   finding = {}
          #   response = security_center_client.update_finding(finding)

          def update_finding \
              finding,
              update_mask: nil,
              options: nil,
              &block
            req = {
              finding: finding,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::UpdateFindingRequest)
            @update_finding.call(req, options, &block)
          end

          # Updates an organization's settings.
          #
          # @param organization_settings [Google::Cloud::SecurityCenter::V1::OrganizationSettings | Hash]
          #   Required. The organization settings resource to update.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::OrganizationSettings`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The FieldMask to use when updating the settings resource.
          #
          #    If empty all mutable fields will be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::OrganizationSettings]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::OrganizationSettings]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `organization_settings`:
          #   organization_settings = {}
          #   response = security_center_client.update_organization_settings(organization_settings)

          def update_organization_settings \
              organization_settings,
              update_mask: nil,
              options: nil,
              &block
            req = {
              organization_settings: organization_settings,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::UpdateOrganizationSettingsRequest)
            @update_organization_settings.call(req, options, &block)
          end

          # Updates a source.
          #
          # @param source [Google::Cloud::SecurityCenter::V1::Source | Hash]
          #   Required. The source resource to update.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::Source`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The FieldMask to use when updating the source resource.
          #
          #   If empty all mutable fields will be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::Source]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::Source]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `source`:
          #   source = {}
          #   response = security_center_client.update_source(source)

          def update_source \
              source,
              update_mask: nil,
              options: nil,
              &block
            req = {
              source: source,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::UpdateSourceRequest)
            @update_source.call(req, options, &block)
          end

          # Updates security marks.
          #
          # @param security_marks [Google::Cloud::SecurityCenter::V1::SecurityMarks | Hash]
          #   Required. The security marks resource to update.
          #   A hash of the same form as `Google::Cloud::SecurityCenter::V1::SecurityMarks`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The FieldMask to use when updating the security marks resource.
          #
          #   The field mask must not contain duplicate fields.
          #   If empty or set to "marks", all marks will be replaced.  Individual
          #   marks can be updated using "marks.<mark_key>".
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param start_time [Google::Protobuf::Timestamp | Hash]
          #   The time at which the updated SecurityMarks take effect.
          #   If not set uses current server time.  Updates will be applied to the
          #   SecurityMarks that are active immediately preceding this time.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecurityCenter::V1::SecurityMarks]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecurityCenter::V1::SecurityMarks]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/security_center"
          #
          #   security_center_client = Google::Cloud::SecurityCenter.new(version: :v1)
          #
          #   # TODO: Initialize `security_marks`:
          #   security_marks = {}
          #   response = security_center_client.update_security_marks(security_marks)

          def update_security_marks \
              security_marks,
              update_mask: nil,
              start_time: nil,
              options: nil,
              &block
            req = {
              security_marks: security_marks,
              update_mask: update_mask,
              start_time: start_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecurityCenter::V1::UpdateSecurityMarksRequest)
            @update_security_marks.call(req, options, &block)
          end
        end
      end
    end
  end
end
