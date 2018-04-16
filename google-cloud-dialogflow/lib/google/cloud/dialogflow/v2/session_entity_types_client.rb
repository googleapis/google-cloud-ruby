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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dialogflow/v2/session_entity_type.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/dialogflow/v2/session_entity_type_pb"
require "google/cloud/dialogflow/credentials"

module Google
  module Cloud
    module Dialogflow
      module V2
        # Entities are extracted from user input and represent parameters that are
        # meaningful to your application. For example, a date range, a proper name
        # such as a geographic location or landmark, and so on. Entities represent
        # actionable data for your application.
        #
        # Session entity types are referred to as **User** entity types and are
        # entities that are built for an individual user such as
        # favorites, preferences, playlists, and so on. You can redefine a session
        # entity type at the session level.
        #
        # For more information about entity types, see the
        # [Dialogflow documentation](https://dialogflow.com/docs/entities).
        #
        # @!attribute [r] session_entity_types_stub
        #   @return [Google::Cloud::Dialogflow::V2::SessionEntityTypes::Stub]
        class SessionEntityTypesClient
          attr_reader :session_entity_types_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dialogflow.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_session_entity_types" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "session_entity_types")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          SESSION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/agent/sessions/{session}"
          )

          private_constant :SESSION_PATH_TEMPLATE

          SESSION_ENTITY_TYPE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/agent/sessions/{session}/entityTypes/{entity_type}"
          )

          private_constant :SESSION_ENTITY_TYPE_PATH_TEMPLATE

          # Returns a fully-qualified session resource name string.
          # @param project [String]
          # @param session [String]
          # @return [String]
          def self.session_path project, session
            SESSION_PATH_TEMPLATE.render(
              :"project" => project,
              :"session" => session
            )
          end

          # Returns a fully-qualified session_entity_type resource name string.
          # @param project [String]
          # @param session [String]
          # @param entity_type [String]
          # @return [String]
          def self.session_entity_type_path project, session, entity_type
            SESSION_ENTITY_TYPE_PATH_TEMPLATE.render(
              :"project" => project,
              :"session" => session,
              :"entity_type" => entity_type
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
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/dialogflow/v2/session_entity_type_services_pb"

            credentials ||= Google::Cloud::Dialogflow::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Dialogflow::Credentials.new(credentials).updater_proc
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
            client_config_file = Pathname.new(__dir__).join(
              "session_entity_types_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dialogflow.v2.SessionEntityTypes",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            @session_entity_types_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Cloud::Dialogflow::V2::SessionEntityTypes::Stub.method(:new)
            )

            @list_session_entity_types = Google::Gax.create_api_call(
              @session_entity_types_stub.method(:list_session_entity_types),
              defaults["list_session_entity_types"]
            )
            @get_session_entity_type = Google::Gax.create_api_call(
              @session_entity_types_stub.method(:get_session_entity_type),
              defaults["get_session_entity_type"]
            )
            @create_session_entity_type = Google::Gax.create_api_call(
              @session_entity_types_stub.method(:create_session_entity_type),
              defaults["create_session_entity_type"]
            )
            @update_session_entity_type = Google::Gax.create_api_call(
              @session_entity_types_stub.method(:update_session_entity_type),
              defaults["update_session_entity_type"]
            )
            @delete_session_entity_type = Google::Gax.create_api_call(
              @session_entity_types_stub.method(:delete_session_entity_type),
              defaults["delete_session_entity_type"]
            )
          end

          # Service calls

          # Returns the list of all session entity types in the specified session.
          #
          # @param parent [String]
          #   Required. The session to list all session entity types from.
          #   Format: +projects/<Project ID>/agent/sessions/<Session ID>+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dialogflow::V2::SessionEntityType>]
          #   An enumerable of Google::Cloud::Dialogflow::V2::SessionEntityType instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   session_entity_types_client = Google::Cloud::Dialogflow::V2::SessionEntityTypes.new
          #   formatted_parent = Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.session_path("[PROJECT]", "[SESSION]")
          #
          #   # Iterate over all results.
          #   session_entity_types_client.list_session_entity_types(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   session_entity_types_client.list_session_entity_types(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_session_entity_types \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::ListSessionEntityTypesRequest)
            @list_session_entity_types.call(req, options)
          end

          # Retrieves the specified session entity type.
          #
          # @param name [String]
          #   Required. The name of the session entity type. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
          #   Display Name>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::SessionEntityType]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   session_entity_types_client = Google::Cloud::Dialogflow::V2::SessionEntityTypes.new
          #   formatted_name = Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.session_entity_type_path("[PROJECT]", "[SESSION]", "[ENTITY_TYPE]")
          #   response = session_entity_types_client.get_session_entity_type(formatted_name)

          def get_session_entity_type \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::GetSessionEntityTypeRequest)
            @get_session_entity_type.call(req, options)
          end

          # Creates a session entity type.
          #
          # @param parent [String]
          #   Required. The session to create a session entity type for.
          #   Format: +projects/<Project ID>/agent/sessions/<Session ID>+.
          # @param session_entity_type [Google::Cloud::Dialogflow::V2::SessionEntityType | Hash]
          #   Required. The session entity type to create.
          #   A hash of the same form as `Google::Cloud::Dialogflow::V2::SessionEntityType`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::SessionEntityType]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   session_entity_types_client = Google::Cloud::Dialogflow::V2::SessionEntityTypes.new
          #   formatted_parent = Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.session_path("[PROJECT]", "[SESSION]")
          #
          #   # TODO: Initialize +session_entity_type+:
          #   session_entity_type = {}
          #   response = session_entity_types_client.create_session_entity_type(formatted_parent, session_entity_type)

          def create_session_entity_type \
              parent,
              session_entity_type,
              options: nil
            req = {
              parent: parent,
              session_entity_type: session_entity_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::CreateSessionEntityTypeRequest)
            @create_session_entity_type.call(req, options)
          end

          # Updates the specified session entity type.
          #
          # @param session_entity_type [Google::Cloud::Dialogflow::V2::SessionEntityType | Hash]
          #   Required. The entity type to update. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
          #   Display Name>+.
          #   A hash of the same form as `Google::Cloud::Dialogflow::V2::SessionEntityType`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. The mask to control which fields get updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::SessionEntityType]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   session_entity_types_client = Google::Cloud::Dialogflow::V2::SessionEntityTypes.new
          #
          #   # TODO: Initialize +session_entity_type+:
          #   session_entity_type = {}
          #   response = session_entity_types_client.update_session_entity_type(session_entity_type)

          def update_session_entity_type \
              session_entity_type,
              update_mask: nil,
              options: nil
            req = {
              session_entity_type: session_entity_type,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::UpdateSessionEntityTypeRequest)
            @update_session_entity_type.call(req, options)
          end

          # Deletes the specified session entity type.
          #
          # @param name [String]
          #   Required. The name of the entity type to delete. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
          #   Display Name>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   session_entity_types_client = Google::Cloud::Dialogflow::V2::SessionEntityTypes.new
          #   formatted_name = Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.session_entity_type_path("[PROJECT]", "[SESSION]", "[ENTITY_TYPE]")
          #   session_entity_types_client.delete_session_entity_type(formatted_name)

          def delete_session_entity_type \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::DeleteSessionEntityTypeRequest)
            @delete_session_entity_type.call(req, options)
            nil
          end
        end
      end
    end
  end
end
