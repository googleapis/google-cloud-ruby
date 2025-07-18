# frozen_string_literal: true

# Copyright 2025 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "google/cloud/errors"
require "google/cloud/maintenance/api/v1beta/maintenance_service_pb"
require "google/cloud/maintenance/api/v1beta/maintenance/rest/service_stub"
require "google/cloud/location/rest"

module Google
  module Cloud
    module Maintenance
      module Api
        module V1beta
          module Maintenance
            module Rest
              ##
              # REST client for the Maintenance service.
              #
              # Unified Maintenance service
              #
              class Client
                # @private
                API_VERSION = ""

                # @private
                DEFAULT_ENDPOINT_TEMPLATE = "maintenance.$UNIVERSE_DOMAIN$"

                include Paths

                # @private
                attr_reader :maintenance_stub

                ##
                # Configure the Maintenance Client class.
                #
                # See {::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client::Configuration}
                # for a description of the configuration fields.
                #
                # @example
                #
                #   # Modify the configuration for all Maintenance clients
                #   ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.configure do |config|
                #     config.timeout = 10.0
                #   end
                #
                # @yield [config] Configure the Client client.
                # @yieldparam config [Client::Configuration]
                #
                # @return [Client::Configuration]
                #
                def self.configure
                  @configure ||= begin
                    namespace = ["Google", "Cloud", "Maintenance", "Api", "V1beta"]
                    parent_config = while namespace.any?
                                      parent_name = namespace.join "::"
                                      parent_const = const_get parent_name
                                      break parent_const.configure if parent_const.respond_to? :configure
                                      namespace.pop
                                    end
                    default_config = Client::Configuration.new parent_config

                    default_config
                  end
                  yield @configure if block_given?
                  @configure
                end

                ##
                # Configure the Maintenance Client instance.
                #
                # The configuration is set to the derived mode, meaning that values can be changed,
                # but structural changes (adding new fields, etc.) are not allowed. Structural changes
                # should be made on {Client.configure}.
                #
                # See {::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client::Configuration}
                # for a description of the configuration fields.
                #
                # @yield [config] Configure the Client client.
                # @yieldparam config [Client::Configuration]
                #
                # @return [Client::Configuration]
                #
                def configure
                  yield @config if block_given?
                  @config
                end

                ##
                # The effective universe domain
                #
                # @return [String]
                #
                def universe_domain
                  @maintenance_stub.universe_domain
                end

                ##
                # Create a new Maintenance REST client object.
                #
                # @example
                #
                #   # Create a client using the default configuration
                #   client = ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new
                #
                #   # Create a client using a custom configuration
                #   client = ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new do |config|
                #     config.timeout = 10.0
                #   end
                #
                # @yield [config] Configure the Maintenance client.
                # @yieldparam config [Client::Configuration]
                #
                def initialize
                  # Create the configuration object
                  @config = Configuration.new Client.configure

                  # Yield the configuration if needed
                  yield @config if block_given?

                  # Create credentials
                  credentials = @config.credentials
                  # Use self-signed JWT if the endpoint is unchanged from default,
                  # but only if the default endpoint does not have a region prefix.
                  enable_self_signed_jwt = @config.endpoint.nil? ||
                                           (@config.endpoint == Configuration::DEFAULT_ENDPOINT &&
                                           !@config.endpoint.split(".").first.include?("-"))
                  credentials ||= Credentials.default scope: @config.scope,
                                                      enable_self_signed_jwt: enable_self_signed_jwt
                  if credentials.is_a?(::String) || credentials.is_a?(::Hash)
                    credentials = Credentials.new credentials, scope: @config.scope
                  end

                  @quota_project_id = @config.quota_project
                  @quota_project_id ||= credentials.quota_project_id if credentials.respond_to? :quota_project_id

                  @maintenance_stub = ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::ServiceStub.new(
                    endpoint: @config.endpoint,
                    endpoint_template: DEFAULT_ENDPOINT_TEMPLATE,
                    universe_domain: @config.universe_domain,
                    credentials: credentials,
                    logger: @config.logger
                  )

                  @maintenance_stub.logger(stub: true)&.info do |entry|
                    entry.set_system_name
                    entry.set_service
                    entry.message = "Created client for #{entry.service}"
                    entry.set_credentials_fields credentials
                    entry.set "customEndpoint", @config.endpoint if @config.endpoint
                    entry.set "defaultTimeout", @config.timeout if @config.timeout
                    entry.set "quotaProject", @quota_project_id if @quota_project_id
                  end

                  @location_client = Google::Cloud::Location::Locations::Rest::Client.new do |config|
                    config.credentials = credentials
                    config.quota_project = @quota_project_id
                    config.endpoint = @maintenance_stub.endpoint
                    config.universe_domain = @maintenance_stub.universe_domain
                    config.bindings_override = @config.bindings_override
                    config.logger = @maintenance_stub.logger if config.respond_to? :logger=
                  end
                end

                ##
                # Get the associated client for mix-in of the Locations.
                #
                # @return [Google::Cloud::Location::Locations::Rest::Client]
                #
                attr_reader :location_client

                ##
                # The logger used for request/response debug logging.
                #
                # @return [Logger]
                #
                def logger
                  @maintenance_stub.logger
                end

                # Service calls

                ##
                # Retrieves the statistics of a specific maintenance.
                #
                # @overload summarize_maintenances(request, options = nil)
                #   Pass arguments to `summarize_maintenances` via a request object, either of type
                #   {::Google::Cloud::Maintenance::Api::V1beta::SummarizeMaintenancesRequest} or an equivalent Hash.
                #
                #   @param request [::Google::Cloud::Maintenance::Api::V1beta::SummarizeMaintenancesRequest, ::Hash]
                #     A request object representing the call parameters. Required. To specify no
                #     parameters, or to keep all the default parameter values, pass an empty Hash.
                #   @param options [::Gapic::CallOptions, ::Hash]
                #     Overrides the default settings for this call, e.g, timeout, retries etc. Optional.
                #
                # @overload summarize_maintenances(parent: nil, page_size: nil, page_token: nil, filter: nil, order_by: nil)
                #   Pass arguments to `summarize_maintenances` via keyword arguments. Note that at
                #   least one keyword argument is required. To specify no parameters, or to keep all
                #   the default parameter values, pass an empty Hash as a request object (see above).
                #
                #   @param parent [::String]
                #     Required. The parent of the resource maintenance.
                #     eg. `projects/123/locations/*`
                #   @param page_size [::Integer]
                #     The maximum number of resource maintenances to send per page. The default
                #     page size is 20 and the maximum is 1000.
                #   @param page_token [::String]
                #     The page token: If the next_page_token from a previous response
                #     is provided, this request will send the subsequent page.
                #   @param filter [::String]
                #     Filter the list as specified in https://google.aip.dev/160.
                #     Supported fields include:
                #     - state
                #     - resource.location
                #     - resource.resourceName
                #     - resource.type
                #     - maintenance.maintenanceName
                #     - maintenanceStartTime
                #     - maintenanceCompleteTime
                #     Examples:
                #     - state="SCHEDULED"
                #     - resource.location="us-central1-c"
                #     - resource.resourceName=~"*/instance-20241212-211259"
                #     - maintenanceStartTime>"2000-10-11T20:44:51Z"
                #     - state="SCHEDULED" OR resource.type="compute.googleapis.com/Instance"
                #     - maintenance.maitenanceName="eb3b709c-9ca1-5472-9fb6-800a3849eda1" AND
                #     maintenanceCompleteTime>"2000-10-11T20:44:51Z"
                #   @param order_by [::String]
                #     Order results as specified in https://google.aip.dev/132.
                # @yield [result, operation] Access the result along with the TransportOperation object
                # @yieldparam result [::Gapic::Rest::PagedEnumerable<::Google::Cloud::Maintenance::Api::V1beta::MaintenanceSummary>]
                # @yieldparam operation [::Gapic::Rest::TransportOperation]
                #
                # @return [::Gapic::Rest::PagedEnumerable<::Google::Cloud::Maintenance::Api::V1beta::MaintenanceSummary>]
                #
                # @raise [::Google::Cloud::Error] if the REST call is aborted.
                #
                # @example Basic example
                #   require "google/cloud/maintenance/api/v1beta"
                #
                #   # Create a client object. The client can be reused for multiple calls.
                #   client = Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new
                #
                #   # Create a request. To set request fields, pass in keyword arguments.
                #   request = Google::Cloud::Maintenance::Api::V1beta::SummarizeMaintenancesRequest.new
                #
                #   # Call the summarize_maintenances method.
                #   result = client.summarize_maintenances request
                #
                #   # The returned object is of type Gapic::PagedEnumerable. You can iterate
                #   # over elements, and API calls will be issued to fetch pages as needed.
                #   result.each do |item|
                #     # Each element is of type ::Google::Cloud::Maintenance::Api::V1beta::MaintenanceSummary.
                #     p item
                #   end
                #
                def summarize_maintenances request, options = nil
                  raise ::ArgumentError, "request must be provided" if request.nil?

                  request = ::Gapic::Protobuf.coerce request, to: ::Google::Cloud::Maintenance::Api::V1beta::SummarizeMaintenancesRequest

                  # Converts hash and nil to an options object
                  options = ::Gapic::CallOptions.new(**options.to_h) if options.respond_to? :to_h

                  # Customize the options with defaults
                  call_metadata = @config.rpcs.summarize_maintenances.metadata.to_h

                  # Set x-goog-api-client, x-goog-user-project and x-goog-api-version headers
                  call_metadata[:"x-goog-api-client"] ||= ::Gapic::Headers.x_goog_api_client \
                    lib_name: @config.lib_name, lib_version: @config.lib_version,
                    gapic_version: ::Google::Cloud::Maintenance::Api::V1beta::VERSION,
                    transports_version_send: [:rest]

                  call_metadata[:"x-goog-api-version"] = API_VERSION unless API_VERSION.empty?
                  call_metadata[:"x-goog-user-project"] = @quota_project_id if @quota_project_id

                  options.apply_defaults timeout:      @config.rpcs.summarize_maintenances.timeout,
                                         metadata:     call_metadata,
                                         retry_policy: @config.rpcs.summarize_maintenances.retry_policy

                  options.apply_defaults timeout:      @config.timeout,
                                         metadata:     @config.metadata,
                                         retry_policy: @config.retry_policy

                  @maintenance_stub.summarize_maintenances request, options do |result, operation|
                    result = ::Gapic::Rest::PagedEnumerable.new @maintenance_stub, :summarize_maintenances, "maintenances", request, result, options
                    yield result, operation if block_given?
                    throw :response, result
                  end
                rescue ::Gapic::Rest::Error => e
                  raise ::Google::Cloud::Error.from_error(e)
                end

                ##
                # Retrieve a collection of resource maintenances.
                #
                # @overload list_resource_maintenances(request, options = nil)
                #   Pass arguments to `list_resource_maintenances` via a request object, either of type
                #   {::Google::Cloud::Maintenance::Api::V1beta::ListResourceMaintenancesRequest} or an equivalent Hash.
                #
                #   @param request [::Google::Cloud::Maintenance::Api::V1beta::ListResourceMaintenancesRequest, ::Hash]
                #     A request object representing the call parameters. Required. To specify no
                #     parameters, or to keep all the default parameter values, pass an empty Hash.
                #   @param options [::Gapic::CallOptions, ::Hash]
                #     Overrides the default settings for this call, e.g, timeout, retries etc. Optional.
                #
                # @overload list_resource_maintenances(parent: nil, page_size: nil, page_token: nil, filter: nil, order_by: nil)
                #   Pass arguments to `list_resource_maintenances` via keyword arguments. Note that at
                #   least one keyword argument is required. To specify no parameters, or to keep all
                #   the default parameter values, pass an empty Hash as a request object (see above).
                #
                #   @param parent [::String]
                #     Required. The parent of the resource maintenance.
                #   @param page_size [::Integer]
                #     The maximum number of resource maintenances to send per page.
                #   @param page_token [::String]
                #     The page token: If the next_page_token from a previous response
                #     is provided, this request will send the subsequent page.
                #   @param filter [::String]
                #     Filter the list as specified in https://google.aip.dev/160.
                #   @param order_by [::String]
                #     Order results as specified in https://google.aip.dev/132.
                # @yield [result, operation] Access the result along with the TransportOperation object
                # @yieldparam result [::Gapic::Rest::PagedEnumerable<::Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance>]
                # @yieldparam operation [::Gapic::Rest::TransportOperation]
                #
                # @return [::Gapic::Rest::PagedEnumerable<::Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance>]
                #
                # @raise [::Google::Cloud::Error] if the REST call is aborted.
                #
                # @example Basic example
                #   require "google/cloud/maintenance/api/v1beta"
                #
                #   # Create a client object. The client can be reused for multiple calls.
                #   client = Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new
                #
                #   # Create a request. To set request fields, pass in keyword arguments.
                #   request = Google::Cloud::Maintenance::Api::V1beta::ListResourceMaintenancesRequest.new
                #
                #   # Call the list_resource_maintenances method.
                #   result = client.list_resource_maintenances request
                #
                #   # The returned object is of type Gapic::PagedEnumerable. You can iterate
                #   # over elements, and API calls will be issued to fetch pages as needed.
                #   result.each do |item|
                #     # Each element is of type ::Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance.
                #     p item
                #   end
                #
                def list_resource_maintenances request, options = nil
                  raise ::ArgumentError, "request must be provided" if request.nil?

                  request = ::Gapic::Protobuf.coerce request, to: ::Google::Cloud::Maintenance::Api::V1beta::ListResourceMaintenancesRequest

                  # Converts hash and nil to an options object
                  options = ::Gapic::CallOptions.new(**options.to_h) if options.respond_to? :to_h

                  # Customize the options with defaults
                  call_metadata = @config.rpcs.list_resource_maintenances.metadata.to_h

                  # Set x-goog-api-client, x-goog-user-project and x-goog-api-version headers
                  call_metadata[:"x-goog-api-client"] ||= ::Gapic::Headers.x_goog_api_client \
                    lib_name: @config.lib_name, lib_version: @config.lib_version,
                    gapic_version: ::Google::Cloud::Maintenance::Api::V1beta::VERSION,
                    transports_version_send: [:rest]

                  call_metadata[:"x-goog-api-version"] = API_VERSION unless API_VERSION.empty?
                  call_metadata[:"x-goog-user-project"] = @quota_project_id if @quota_project_id

                  options.apply_defaults timeout:      @config.rpcs.list_resource_maintenances.timeout,
                                         metadata:     call_metadata,
                                         retry_policy: @config.rpcs.list_resource_maintenances.retry_policy

                  options.apply_defaults timeout:      @config.timeout,
                                         metadata:     @config.metadata,
                                         retry_policy: @config.retry_policy

                  @maintenance_stub.list_resource_maintenances request, options do |result, operation|
                    result = ::Gapic::Rest::PagedEnumerable.new @maintenance_stub, :list_resource_maintenances, "resource_maintenances", request, result, options
                    yield result, operation if block_given?
                    throw :response, result
                  end
                rescue ::Gapic::Rest::Error => e
                  raise ::Google::Cloud::Error.from_error(e)
                end

                ##
                # Retrieve a single resource maintenance.
                #
                # @overload get_resource_maintenance(request, options = nil)
                #   Pass arguments to `get_resource_maintenance` via a request object, either of type
                #   {::Google::Cloud::Maintenance::Api::V1beta::GetResourceMaintenanceRequest} or an equivalent Hash.
                #
                #   @param request [::Google::Cloud::Maintenance::Api::V1beta::GetResourceMaintenanceRequest, ::Hash]
                #     A request object representing the call parameters. Required. To specify no
                #     parameters, or to keep all the default parameter values, pass an empty Hash.
                #   @param options [::Gapic::CallOptions, ::Hash]
                #     Overrides the default settings for this call, e.g, timeout, retries etc. Optional.
                #
                # @overload get_resource_maintenance(name: nil)
                #   Pass arguments to `get_resource_maintenance` via keyword arguments. Note that at
                #   least one keyword argument is required. To specify no parameters, or to keep all
                #   the default parameter values, pass an empty Hash as a request object (see above).
                #
                #   @param name [::String]
                #     Required. The resource name of the resource within a service.
                # @yield [result, operation] Access the result along with the TransportOperation object
                # @yieldparam result [::Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance]
                # @yieldparam operation [::Gapic::Rest::TransportOperation]
                #
                # @return [::Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance]
                #
                # @raise [::Google::Cloud::Error] if the REST call is aborted.
                #
                # @example Basic example
                #   require "google/cloud/maintenance/api/v1beta"
                #
                #   # Create a client object. The client can be reused for multiple calls.
                #   client = Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new
                #
                #   # Create a request. To set request fields, pass in keyword arguments.
                #   request = Google::Cloud::Maintenance::Api::V1beta::GetResourceMaintenanceRequest.new
                #
                #   # Call the get_resource_maintenance method.
                #   result = client.get_resource_maintenance request
                #
                #   # The returned object is of type Google::Cloud::Maintenance::Api::V1beta::ResourceMaintenance.
                #   p result
                #
                def get_resource_maintenance request, options = nil
                  raise ::ArgumentError, "request must be provided" if request.nil?

                  request = ::Gapic::Protobuf.coerce request, to: ::Google::Cloud::Maintenance::Api::V1beta::GetResourceMaintenanceRequest

                  # Converts hash and nil to an options object
                  options = ::Gapic::CallOptions.new(**options.to_h) if options.respond_to? :to_h

                  # Customize the options with defaults
                  call_metadata = @config.rpcs.get_resource_maintenance.metadata.to_h

                  # Set x-goog-api-client, x-goog-user-project and x-goog-api-version headers
                  call_metadata[:"x-goog-api-client"] ||= ::Gapic::Headers.x_goog_api_client \
                    lib_name: @config.lib_name, lib_version: @config.lib_version,
                    gapic_version: ::Google::Cloud::Maintenance::Api::V1beta::VERSION,
                    transports_version_send: [:rest]

                  call_metadata[:"x-goog-api-version"] = API_VERSION unless API_VERSION.empty?
                  call_metadata[:"x-goog-user-project"] = @quota_project_id if @quota_project_id

                  options.apply_defaults timeout:      @config.rpcs.get_resource_maintenance.timeout,
                                         metadata:     call_metadata,
                                         retry_policy: @config.rpcs.get_resource_maintenance.retry_policy

                  options.apply_defaults timeout:      @config.timeout,
                                         metadata:     @config.metadata,
                                         retry_policy: @config.retry_policy

                  @maintenance_stub.get_resource_maintenance request, options do |result, operation|
                    yield result, operation if block_given?
                  end
                rescue ::Gapic::Rest::Error => e
                  raise ::Google::Cloud::Error.from_error(e)
                end

                ##
                # Configuration class for the Maintenance REST API.
                #
                # This class represents the configuration for Maintenance REST,
                # providing control over timeouts, retry behavior, logging, transport
                # parameters, and other low-level controls. Certain parameters can also be
                # applied individually to specific RPCs. See
                # {::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client::Configuration::Rpcs}
                # for a list of RPCs that can be configured independently.
                #
                # Configuration can be applied globally to all clients, or to a single client
                # on construction.
                #
                # @example
                #
                #   # Modify the global config, setting the timeout for
                #   # summarize_maintenances to 20 seconds,
                #   # and all remaining timeouts to 10 seconds.
                #   ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.configure do |config|
                #     config.timeout = 10.0
                #     config.rpcs.summarize_maintenances.timeout = 20.0
                #   end
                #
                #   # Apply the above configuration only to a new client.
                #   client = ::Google::Cloud::Maintenance::Api::V1beta::Maintenance::Rest::Client.new do |config|
                #     config.timeout = 10.0
                #     config.rpcs.summarize_maintenances.timeout = 20.0
                #   end
                #
                # @!attribute [rw] endpoint
                #   A custom service endpoint, as a hostname or hostname:port. The default is
                #   nil, indicating to use the default endpoint in the current universe domain.
                #   @return [::String,nil]
                # @!attribute [rw] credentials
                #   Credentials to send with calls. You may provide any of the following types:
                #    *  (`String`) The path to a service account key file in JSON format
                #    *  (`Hash`) A service account key as a Hash
                #    *  (`Google::Auth::Credentials`) A googleauth credentials object
                #       (see the [googleauth docs](https://rubydoc.info/gems/googleauth/Google/Auth/Credentials))
                #    *  (`Signet::OAuth2::Client`) A signet oauth2 client object
                #       (see the [signet docs](https://rubydoc.info/gems/signet/Signet/OAuth2/Client))
                #    *  (`nil`) indicating no credentials
                #
                #   Warning: If you accept a credential configuration (JSON file or Hash) from an
                #   external source for authentication to Google Cloud, you must validate it before
                #   providing it to a Google API client library. Providing an unvalidated credential
                #   configuration to Google APIs can compromise the security of your systems and data.
                #   For more information, refer to [Validate credential configurations from external
                #   sources](https://cloud.google.com/docs/authentication/external/externally-sourced-credentials).
                #   @return [::Object]
                # @!attribute [rw] scope
                #   The OAuth scopes
                #   @return [::Array<::String>]
                # @!attribute [rw] lib_name
                #   The library name as recorded in instrumentation and logging
                #   @return [::String]
                # @!attribute [rw] lib_version
                #   The library version as recorded in instrumentation and logging
                #   @return [::String]
                # @!attribute [rw] timeout
                #   The call timeout in seconds.
                #   @return [::Numeric]
                # @!attribute [rw] metadata
                #   Additional headers to be sent with the call.
                #   @return [::Hash{::Symbol=>::String}]
                # @!attribute [rw] retry_policy
                #   The retry policy. The value is a hash with the following keys:
                #    *  `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
                #    *  `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
                #    *  `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
                #    *  `:retry_codes` (*type:* `Array<String>`) - The error codes that should
                #       trigger a retry.
                #   @return [::Hash]
                # @!attribute [rw] quota_project
                #   A separate project against which to charge quota.
                #   @return [::String]
                # @!attribute [rw] universe_domain
                #   The universe domain within which to make requests. This determines the
                #   default endpoint URL. The default value of nil uses the environment
                #   universe (usually the default "googleapis.com" universe).
                #   @return [::String,nil]
                # @!attribute [rw] logger
                #   A custom logger to use for request/response debug logging, or the value
                #   `:default` (the default) to construct a default logger, or `nil` to
                #   explicitly disable logging.
                #   @return [::Logger,:default,nil]
                #
                class Configuration
                  extend ::Gapic::Config

                  # @private
                  # The endpoint specific to the default "googleapis.com" universe. Deprecated.
                  DEFAULT_ENDPOINT = "maintenance.googleapis.com"

                  config_attr :endpoint,      nil, ::String, nil
                  config_attr :credentials,   nil do |value|
                    allowed = [::String, ::Hash, ::Proc, ::Symbol, ::Google::Auth::Credentials, ::Google::Auth::BaseClient, ::Signet::OAuth2::Client, nil]
                    allowed.any? { |klass| klass === value }
                  end
                  config_attr :scope,         nil, ::String, ::Array, nil
                  config_attr :lib_name,      nil, ::String, nil
                  config_attr :lib_version,   nil, ::String, nil
                  config_attr :timeout,       nil, ::Numeric, nil
                  config_attr :metadata,      nil, ::Hash, nil
                  config_attr :retry_policy,  nil, ::Hash, ::Proc, nil
                  config_attr :quota_project, nil, ::String, nil
                  config_attr :universe_domain, nil, ::String, nil

                  # @private
                  # Overrides for http bindings for the RPCs of this service
                  # are only used when this service is used as mixin, and only
                  # by the host service.
                  # @return [::Hash{::Symbol=>::Array<::Gapic::Rest::GrpcTranscoder::HttpBinding>}]
                  config_attr :bindings_override, {}, ::Hash, nil
                  config_attr :logger, :default, ::Logger, nil, :default

                  # @private
                  def initialize parent_config = nil
                    @parent_config = parent_config unless parent_config.nil?

                    yield self if block_given?
                  end

                  ##
                  # Configurations for individual RPCs
                  # @return [Rpcs]
                  #
                  def rpcs
                    @rpcs ||= begin
                      parent_rpcs = nil
                      parent_rpcs = @parent_config.rpcs if defined?(@parent_config) && @parent_config.respond_to?(:rpcs)
                      Rpcs.new parent_rpcs
                    end
                  end

                  ##
                  # Configuration RPC class for the Maintenance API.
                  #
                  # Includes fields providing the configuration for each RPC in this service.
                  # Each configuration object is of type `Gapic::Config::Method` and includes
                  # the following configuration fields:
                  #
                  #  *  `timeout` (*type:* `Numeric`) - The call timeout in seconds
                  #  *  `metadata` (*type:* `Hash{Symbol=>String}`) - Additional headers
                  #  *  `retry_policy (*type:* `Hash`) - The retry policy. The policy fields
                  #     include the following keys:
                  #      *  `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
                  #      *  `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
                  #      *  `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
                  #      *  `:retry_codes` (*type:* `Array<String>`) - The error codes that should
                  #         trigger a retry.
                  #
                  class Rpcs
                    ##
                    # RPC-specific configuration for `summarize_maintenances`
                    # @return [::Gapic::Config::Method]
                    #
                    attr_reader :summarize_maintenances
                    ##
                    # RPC-specific configuration for `list_resource_maintenances`
                    # @return [::Gapic::Config::Method]
                    #
                    attr_reader :list_resource_maintenances
                    ##
                    # RPC-specific configuration for `get_resource_maintenance`
                    # @return [::Gapic::Config::Method]
                    #
                    attr_reader :get_resource_maintenance

                    # @private
                    def initialize parent_rpcs = nil
                      summarize_maintenances_config = parent_rpcs.summarize_maintenances if parent_rpcs.respond_to? :summarize_maintenances
                      @summarize_maintenances = ::Gapic::Config::Method.new summarize_maintenances_config
                      list_resource_maintenances_config = parent_rpcs.list_resource_maintenances if parent_rpcs.respond_to? :list_resource_maintenances
                      @list_resource_maintenances = ::Gapic::Config::Method.new list_resource_maintenances_config
                      get_resource_maintenance_config = parent_rpcs.get_resource_maintenance if parent_rpcs.respond_to? :get_resource_maintenance
                      @get_resource_maintenance = ::Gapic::Config::Method.new get_resource_maintenance_config

                      yield self if block_given?
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
