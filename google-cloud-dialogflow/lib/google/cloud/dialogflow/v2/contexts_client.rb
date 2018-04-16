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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/dialogflow/v2/context.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/dialogflow/v2/context_pb"
require "google/cloud/dialogflow/credentials"

module Google
  module Cloud
    module Dialogflow
      module V2
        # A context represents additional information included with user input or with
        # an intent returned by the Dialogflow API. Contexts are helpful for
        # differentiating user input which may be vague or have a different meaning
        # depending on additional details from your application such as user setting
        # and preferences, previous user input, where the user is in your application,
        # geographic location, and so on.
        #
        # You can include contexts as input parameters of a
        # {Google::Cloud::Dialogflow::V2::Sessions::DetectIntent DetectIntent} (or
        # {Google::Cloud::Dialogflow::V2::Sessions::StreamingDetectIntent StreamingDetectIntent}) request,
        # or as output contexts included in the returned intent.
        # Contexts expire when an intent is matched, after the number of +DetectIntent+
        # requests specified by the +lifespan_count+ parameter, or after 10 minutes
        # if no intents are matched for a +DetectIntent+ request.
        #
        # For more information about contexts, see the
        # [Dialogflow documentation](https://dialogflow.com/docs/contexts).
        #
        # @!attribute [r] contexts_stub
        #   @return [Google::Cloud::Dialogflow::V2::Contexts::Stub]
        class ContextsClient
          attr_reader :contexts_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dialogflow.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_contexts" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "contexts")
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

          CONTEXT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/agent/sessions/{session}/contexts/{context}"
          )

          private_constant :CONTEXT_PATH_TEMPLATE

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

          # Returns a fully-qualified context resource name string.
          # @param project [String]
          # @param session [String]
          # @param context [String]
          # @return [String]
          def self.context_path project, session, context
            CONTEXT_PATH_TEMPLATE.render(
              :"project" => project,
              :"session" => session,
              :"context" => context
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
            require "google/cloud/dialogflow/v2/context_services_pb"

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
              "contexts_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.dialogflow.v2.Contexts",
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
            @contexts_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Cloud::Dialogflow::V2::Contexts::Stub.method(:new)
            )

            @list_contexts = Google::Gax.create_api_call(
              @contexts_stub.method(:list_contexts),
              defaults["list_contexts"]
            )
            @get_context = Google::Gax.create_api_call(
              @contexts_stub.method(:get_context),
              defaults["get_context"]
            )
            @create_context = Google::Gax.create_api_call(
              @contexts_stub.method(:create_context),
              defaults["create_context"]
            )
            @update_context = Google::Gax.create_api_call(
              @contexts_stub.method(:update_context),
              defaults["update_context"]
            )
            @delete_context = Google::Gax.create_api_call(
              @contexts_stub.method(:delete_context),
              defaults["delete_context"]
            )
            @delete_all_contexts = Google::Gax.create_api_call(
              @contexts_stub.method(:delete_all_contexts),
              defaults["delete_all_contexts"]
            )
          end

          # Service calls

          # Returns the list of all contexts in the specified session.
          #
          # @param parent [String]
          #   Required. The session to list all contexts from.
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
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Dialogflow::V2::Context>]
          #   An enumerable of Google::Cloud::Dialogflow::V2::Context instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #   formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")
          #
          #   # Iterate over all results.
          #   contexts_client.list_contexts(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   contexts_client.list_contexts(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_contexts \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::ListContextsRequest)
            @list_contexts.call(req, options)
          end

          # Retrieves the specified context.
          #
          # @param name [String]
          #   Required. The name of the context. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>/contexts/<Context ID>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::Context]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #   formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")
          #   response = contexts_client.get_context(formatted_name)

          def get_context \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::GetContextRequest)
            @get_context.call(req, options)
          end

          # Creates a context.
          #
          # @param parent [String]
          #   Required. The session to create a context for.
          #   Format: +projects/<Project ID>/agent/sessions/<Session ID>+.
          # @param context [Google::Cloud::Dialogflow::V2::Context | Hash]
          #   Required. The context to create.
          #   A hash of the same form as `Google::Cloud::Dialogflow::V2::Context`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::Context]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #   formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")
          #
          #   # TODO: Initialize +context+:
          #   context = {}
          #   response = contexts_client.create_context(formatted_parent, context)

          def create_context \
              parent,
              context,
              options: nil
            req = {
              parent: parent,
              context: context
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::CreateContextRequest)
            @create_context.call(req, options)
          end

          # Updates the specified context.
          #
          # @param context [Google::Cloud::Dialogflow::V2::Context | Hash]
          #   Required. The context to update.
          #   A hash of the same form as `Google::Cloud::Dialogflow::V2::Context`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. The mask to control which fields get updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Dialogflow::V2::Context]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #
          #   # TODO: Initialize +context+:
          #   context = {}
          #   response = contexts_client.update_context(context)

          def update_context \
              context,
              update_mask: nil,
              options: nil
            req = {
              context: context,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::UpdateContextRequest)
            @update_context.call(req, options)
          end

          # Deletes the specified context.
          #
          # @param name [String]
          #   Required. The name of the context to delete. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>/contexts/<Context ID>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #   formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")
          #   contexts_client.delete_context(formatted_name)

          def delete_context \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::DeleteContextRequest)
            @delete_context.call(req, options)
            nil
          end

          # Deletes all active contexts in the specified session.
          #
          # @param parent [String]
          #   Required. The name of the session to delete all contexts from. Format:
          #   +projects/<Project ID>/agent/sessions/<Session ID>+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dialogflow/v2"
          #
          #   contexts_client = Google::Cloud::Dialogflow::V2::Contexts.new
          #   formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")
          #   contexts_client.delete_all_contexts(formatted_parent)

          def delete_all_contexts \
              parent,
              options: nil
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::DeleteAllContextsRequest)
            @delete_all_contexts.call(req, options)
            nil
          end
        end
      end
    end
  end
end
