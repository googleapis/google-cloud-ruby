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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dialogflow/v2/agent.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/dialogflow/v2/agent_pb"
require "google/cloud/dialogflow/v2/credentials"

module Google
  module Cloud
    module Dialogflow
      module V2
        # Agents are best described as Natural Language Understanding (NLU) modules
        # that transform user requests into actionable data. You can include agents
        # in your app, product, or service to determine user intent and respond to the
        # user in a natural way.
        #
        # After you create an agent, you can add {Google::Cloud::Dialogflow::V2::Intents Intents}, {Google::Cloud::Dialogflow::V2::Contexts Contexts},
        # {Google::Cloud::Dialogflow::V2::EntityTypes Entity Types}, {Google::Cloud::Dialogflow::V2::WebhookRequest Webhooks}, and so on to
        # manage the flow of a conversation and match user input to predefined intents
        # and actions.
        #
        # You can create an agent using both Dialogflow Standard Edition and
        # Dialogflow Enterprise Edition. For details, see
        # [Dialogflow Editions](https://cloud.google.com/dialogflow-enterprise/docs/editions).
        #
        # You can save your agent for backup or versioning by exporting the agent by
        # using the {Google::Cloud::Dialogflow::V2::Agents::ExportAgent ExportAgent} method. You can import a saved
        # agent by using the {Google::Cloud::Dialogflow::V2::Agents::ImportAgent ImportAgent} method.
        #
        # Dialogflow provides several
        # [prebuilt agents](https://dialogflow.com/docs/prebuilt-agents) for common
        # conversation scenarios such as determining a date and time, converting
        # currency, and so on.
        #
        # For more information about agents, see the
        # [Dialogflow documentation](https://dialogflow.com/docs/agents).
        #
        # @!attribute [r] agents_stub
        #   @return [Google::Cloud::Dialogflow::V2::Agents::Stub]
        class AgentsClient
          # @private
          attr_reader :agents_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dialogflow.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "search_agents" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "agents")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          # @private
          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = AgentsClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = AgentsClient::GRPC_INTERCEPTORS
          end

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
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
            require "google/cloud/dialogflow/v2/agent_services_pb"

            credentials ||= Google::Cloud::Dialogflow::V2::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Dialogflow::V2::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-dialogflow'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "agents_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dialogflow.v2.Agents",
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
            @agents_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Dialogflow::V2::Agents::Stub.method(:new)
            )

            @get_agent = Google::Gax.create_api_call(
              @agents_stub.method(:get_agent),
              defaults["get_agent"],
              exception_transformer: exception_transformer
            )
            @search_agents = Google::Gax.create_api_call(
              @agents_stub.method(:search_agents),
              defaults["search_agents"],
              exception_transformer: exception_transformer
            )
            @train_agent = Google::Gax.create_api_call(
              @agents_stub.method(:train_agent),
              defaults["train_agent"],
              exception_transformer: exception_transformer
            )
            @export_agent = Google::Gax.create_api_call(
              @agents_stub.method(:export_agent),
              defaults["export_agent"],
              exception_transformer: exception_transformer
            )
            @import_agent = Google::Gax.create_api_call(
              @agents_stub.method(:import_agent),
              defaults["import_agent"],
              exception_transformer: exception_transformer
            )
            @restore_agent = Google::Gax.create_api_call(
              @agents_stub.method(:restore_agent),
              defaults["restore_agent"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Retrieves the specified agent.
          #
          # @param parent [String]
          #   Required. The project that the agent to fetch is associated with.
          #   Format: +projects/<Project ID>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Dialogflow::V2::Agent]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Dialogflow::V2::Agent]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #   response = agents_client.get_agent(formatted_parent)

          def get_agent \
              parent,
              options: nil,
              &block
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::GetAgentRequest)
            @get_agent.call(req, options, &block)
          end

          # Returns the list of agents.
          #
          # Since there is at most one conversational agent per project, this method is
          # useful primarily for listing all agents across projects the caller has
          # access to. One can achieve that with a wildcard project collection id "-".
          # Refer to [List
          # Sub-Collections](https://cloud.google.com/apis/design/design_patterns#list_sub-collections).
          #
          # @param parent [String]
          #   Required. The project to list agents from.
          #   Format: +projects/<Project ID or '-'>+.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Dialogflow::V2::Agent>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dialogflow::V2::Agent>]
          #   An enumerable of Google::Cloud::Dialogflow::V2::Agent instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   agents_client.search_agents(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   agents_client.search_agents(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def search_agents \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::SearchAgentsRequest)
            @search_agents.call(req, options, &block)
          end

          # Trains the specified agent.
          #
          # Operation <response: {Google::Protobuf::Empty},
          #            metadata: {Google::Protobuf::Struct}>
          #
          # @param parent [String]
          #   Required. The project that the agent to train is associated with.
          #   Format: +projects/<Project ID>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #
          #   # Register a callback during the method call.
          #   operation = agents_client.train_agent(formatted_parent) do |op|
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

          def train_agent \
              parent,
              options: nil
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::TrainAgentRequest)
            operation = Google::Gax::Operation.new(
              @train_agent.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Protobuf::Struct,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Exports the specified agent to a ZIP file.
          #
          # Operation <response: {Google::Cloud::Dialogflow::V2::ExportAgentResponse ExportAgentResponse},
          #            metadata: {Google::Protobuf::Struct}>
          #
          # @param parent [String]
          #   Required. The project that the agent to export is associated with.
          #   Format: +projects/<Project ID>+.
          # @param agent_uri [String]
          #   Optional. The Google Cloud Storage URI to export the agent to.
          #   Note: The URI must start with
          #   "gs://". If left unspecified, the serialized agent is returned inline.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #
          #   # Register a callback during the method call.
          #   operation = agents_client.export_agent(formatted_parent) do |op|
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

          def export_agent \
              parent,
              agent_uri: nil,
              options: nil
            req = {
              parent: parent,
              agent_uri: agent_uri
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::ExportAgentRequest)
            operation = Google::Gax::Operation.new(
              @export_agent.call(req, options),
              @operations_client,
              Google::Cloud::Dialogflow::V2::ExportAgentResponse,
              Google::Protobuf::Struct,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Imports the specified agent from a ZIP file.
          #
          # Uploads new intents and entity types without deleting the existing ones.
          # Intents and entity types with the same name are replaced with the new
          # versions from ImportAgentRequest.
          #
          # Operation <response: {Google::Protobuf::Empty},
          #            metadata: {Google::Protobuf::Struct}>
          #
          # @param parent [String]
          #   Required. The project that the agent to import is associated with.
          #   Format: +projects/<Project ID>+.
          # @param agent_uri [String]
          #   The URI to a Google Cloud Storage file containing the agent to import.
          #   Note: The URI must start with "gs://".
          # @param agent_content [String]
          #   The agent to import.
          #
          #   Example for how to import an agent via the command line:
          #
          #   curl \
          #     'https://dialogflow.googleapis.com/v2/projects/<project_name>/agent:import\
          #      -X POST \
          #      -H 'Authorization: Bearer '$(gcloud auth print-access-token) \
          #      -H 'Accept: application/json' \
          #      -H 'Content-Type: application/json' \
          #      --compressed \
          #      --data-binary "{
          #         'agentContent': '$(cat <agent zip file> | base64 -w 0)'
          #      }"
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #
          #   # Register a callback during the method call.
          #   operation = agents_client.import_agent(formatted_parent) do |op|
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

          def import_agent \
              parent,
              agent_uri: nil,
              agent_content: nil,
              options: nil
            req = {
              parent: parent,
              agent_uri: agent_uri,
              agent_content: agent_content
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::ImportAgentRequest)
            operation = Google::Gax::Operation.new(
              @import_agent.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Protobuf::Struct,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Restores the specified agent from a ZIP file.
          #
          # Replaces the current agent version with a new one. All the intents and
          # entity types in the older version are deleted.
          #
          # Operation <response: {Google::Protobuf::Empty},
          #            metadata: {Google::Protobuf::Struct}>
          #
          # @param parent [String]
          #   Required. The project that the agent to restore is associated with.
          #   Format: +projects/<Project ID>+.
          # @param agent_uri [String]
          #   The URI to a Google Cloud Storage file containing the agent to restore.
          #   Note: The URI must start with "gs://".
          # @param agent_content [String]
          #   The agent to restore.
          #
          #   Example for how to restore an agent via the command line:
          #
          #   curl \
          #     'https://dialogflow.googleapis.com/v2/projects/<project_name>/agent:restore\
          #      -X POST \
          #      -H 'Authorization: Bearer '$(gcloud auth print-access-token) \
          #      -H 'Accept: application/json' \
          #      -H 'Content-Type: application/json' \
          #      --compressed \
          #      --data-binary "{
          #          'agentContent': '$(cat <agent zip file> | base64 -w 0)'
          #      }" \
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow"
          #
          #   agents_client = Google::Cloud::Dialogflow::Agents.new(version: :v2)
          #   formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")
          #
          #   # Register a callback during the method call.
          #   operation = agents_client.restore_agent(formatted_parent) do |op|
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

          def restore_agent \
              parent,
              agent_uri: nil,
              agent_content: nil,
              options: nil
            req = {
              parent: parent,
              agent_uri: agent_uri,
              agent_content: agent_content
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::RestoreAgentRequest)
            operation = Google::Gax::Operation.new(
              @restore_agent.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Protobuf::Struct,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end
        end
      end
    end
  end
end
