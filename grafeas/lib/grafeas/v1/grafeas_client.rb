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
# https://github.com/googleapis/googleapis/blob/master/grafeas/v1/grafeas.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "grafeas/v1/grafeas_pb"
require "grafeas/v1/credentials"
require "grafeas/version"

module Grafeas
  module V1
    # [Grafeas](https://grafeas.io) API.
    #
    # Retrieves analysis results of Cloud components such as Docker container
    # images.
    #
    # Analysis results are stored as a series of occurrences. An `Occurrence`
    # contains information about a specific analysis instance on a resource. An
    # occurrence refers to a `Note`. A note contains details describing the
    # analysis and is generally stored in a separate project, called a `Provider`.
    # Multiple occurrences can refer to the same note.
    #
    # For example, an SSL vulnerability could affect multiple images. In this case,
    # there would be one note for the vulnerability and an occurrence for each
    # image with the vulnerability referring to that note.
    #
    # @!attribute [r] grafeas_stub
    #   @return [Grafeas::V1::GrafeasService::Stub]
    class GrafeasClient
      # @private
      attr_reader :grafeas_stub

      # The default address of the service.
      SERVICE_ADDRESS = "containeranalysis.googleapis.com".freeze

      # The default port of the service.
      DEFAULT_SERVICE_PORT = 443

      # The default set of gRPC interceptors.
      GRPC_INTERCEPTORS = []

      DEFAULT_TIMEOUT = 30

      PAGE_DESCRIPTORS = {
        "list_occurrences" => Google::Gax::PageDescriptor.new(
          "page_token",
          "next_page_token",
          "occurrences"),
        "list_notes" => Google::Gax::PageDescriptor.new(
          "page_token",
          "next_page_token",
          "notes"),
        "list_note_occurrences" => Google::Gax::PageDescriptor.new(
          "page_token",
          "next_page_token",
          "occurrences")
      }.freeze

      private_constant :PAGE_DESCRIPTORS

      # The scopes needed to make gRPC calls to all of the methods defined in
      # this service.
      ALL_SCOPES = [
        "https://www.googleapis.com/auth/cloud-platform"
      ].freeze


      NOTE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
        "projects/{project}/notes/{note}"
      )

      private_constant :NOTE_PATH_TEMPLATE

      OCCURRENCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
        "projects/{project}/occurrences/{occurrence}"
      )

      private_constant :OCCURRENCE_PATH_TEMPLATE

      PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
        "projects/{project}"
      )

      private_constant :PROJECT_PATH_TEMPLATE

      # Returns a fully-qualified note resource name string.
      # @param project [String]
      # @param note [String]
      # @return [String]
      def self.note_path project, note
        NOTE_PATH_TEMPLATE.render(
          :"project" => project,
          :"note" => note
        )
      end

      # Returns a fully-qualified occurrence resource name string.
      # @param project [String]
      # @param occurrence [String]
      # @return [String]
      def self.occurrence_path project, occurrence
        OCCURRENCE_PATH_TEMPLATE.render(
          :"project" => project,
          :"occurrence" => occurrence
        )
      end

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
        require "grafeas/v1/grafeas_services_pb"

        credentials ||= Grafeas::V1::Credentials.default

        if credentials.is_a?(String) || credentials.is_a?(Hash)
          updater_proc = Grafeas::V1::Credentials.new(credentials).updater_proc
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

        package_version = Grafeas::VERSION

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
          "grafeas_client_config.json"
        )
        defaults = client_config_file.open do |f|
          Google::Gax.construct_settings(
            "grafeas.v1.Grafeas",
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
        @grafeas_stub = Google::Gax::Grpc.create_stub(
          service_path,
          port,
          chan_creds: chan_creds,
          channel: channel,
          updater_proc: updater_proc,
          scopes: scopes,
          interceptors: interceptors,
          &Grafeas::V1::GrafeasService::Stub.method(:new)
        )

        @delete_occurrence = Google::Gax.create_api_call(
          @grafeas_stub.method(:delete_occurrence),
          defaults["delete_occurrence"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @delete_note = Google::Gax.create_api_call(
          @grafeas_stub.method(:delete_note),
          defaults["delete_note"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @get_occurrence = Google::Gax.create_api_call(
          @grafeas_stub.method(:get_occurrence),
          defaults["get_occurrence"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @list_occurrences = Google::Gax.create_api_call(
          @grafeas_stub.method(:list_occurrences),
          defaults["list_occurrences"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @create_occurrence = Google::Gax.create_api_call(
          @grafeas_stub.method(:create_occurrence),
          defaults["create_occurrence"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @batch_create_occurrences = Google::Gax.create_api_call(
          @grafeas_stub.method(:batch_create_occurrences),
          defaults["batch_create_occurrences"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @update_occurrence = Google::Gax.create_api_call(
          @grafeas_stub.method(:update_occurrence),
          defaults["update_occurrence"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @get_occurrence_note = Google::Gax.create_api_call(
          @grafeas_stub.method(:get_occurrence_note),
          defaults["get_occurrence_note"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @get_note = Google::Gax.create_api_call(
          @grafeas_stub.method(:get_note),
          defaults["get_note"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @list_notes = Google::Gax.create_api_call(
          @grafeas_stub.method(:list_notes),
          defaults["list_notes"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @create_note = Google::Gax.create_api_call(
          @grafeas_stub.method(:create_note),
          defaults["create_note"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @batch_create_notes = Google::Gax.create_api_call(
          @grafeas_stub.method(:batch_create_notes),
          defaults["batch_create_notes"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'parent' => request.parent}
          end
        )
        @update_note = Google::Gax.create_api_call(
          @grafeas_stub.method(:update_note),
          defaults["update_note"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
        @list_note_occurrences = Google::Gax.create_api_call(
          @grafeas_stub.method(:list_note_occurrences),
          defaults["list_note_occurrences"],
          exception_transformer: exception_transformer,
          params_extractor: proc do |request|
            {'name' => request.name}
          end
        )
      end

      # Service calls

      # Deletes the specified occurrence. For example, use this method to delete an
      # occurrence when the occurrence is no longer applicable for the given
      # resource.
      #
      # @param name [String]
      #   The name of the occurrence in the form of
      #   `projects/[PROJECT_ID]/occurrences/[OCCURRENCE_ID]`.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result []
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      #   grafeas_client.delete_occurrence(formatted_name)

      def delete_occurrence \
          name,
          options: nil,
          &block
        req = {
          name: name
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::DeleteOccurrenceRequest)
        @delete_occurrence.call(req, options, &block)
        nil
      end

      # Deletes the specified note.
      #
      # @param name [String]
      #   The name of the note in the form of
      #   `projects/[PROVIDER_ID]/notes/[NOTE_ID]`.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result []
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      #   grafeas_client.delete_note(formatted_name)

      def delete_note \
          name,
          options: nil,
          &block
        req = {
          name: name
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::DeleteNoteRequest)
        @delete_note.call(req, options, &block)
        nil
      end

      # Gets the specified occurrence.
      #
      # @param name [String]
      #   The name of the occurrence in the form of
      #   `projects/[PROJECT_ID]/occurrences/[OCCURRENCE_ID]`.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Occurrence]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Occurrence]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      #   response = grafeas_client.get_occurrence(formatted_name)

      def get_occurrence \
          name,
          options: nil,
          &block
        req = {
          name: name
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::GetOccurrenceRequest)
        @get_occurrence.call(req, options, &block)
      end

      # Lists occurrences for the specified project.
      #
      # @param parent [String]
      #   The name of the project to list occurrences for in the form of
      #   `projects/[PROJECT_ID]`.
      # @param filter [String]
      #   The filter expression.
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
      # @yieldparam result [Google::Gax::PagedEnumerable<Grafeas::V1::Occurrence>]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Google::Gax::PagedEnumerable<Grafeas::V1::Occurrence>]
      #   An enumerable of Grafeas::V1::Occurrence instances.
      #   See Google::Gax::PagedEnumerable documentation for other
      #   operations such as per-page iteration or access to the response
      #   object.
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # Iterate over all results.
      #   grafeas_client.list_occurrences(formatted_parent).each do |element|
      #     # Process element.
      #   end
      #
      #   # Or iterate over results one page at a time.
      #   grafeas_client.list_occurrences(formatted_parent).each_page do |page|
      #     # Process each page at a time.
      #     page.each do |element|
      #       # Process element.
      #     end
      #   end

      def list_occurrences \
          parent,
          filter: nil,
          page_size: nil,
          options: nil,
          &block
        req = {
          parent: parent,
          filter: filter,
          page_size: page_size
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::ListOccurrencesRequest)
        @list_occurrences.call(req, options, &block)
      end

      # Creates a new occurrence.
      #
      # @param parent [String]
      #   The name of the project in the form of `projects/[PROJECT_ID]`, under which
      #   the occurrence is to be created.
      # @param occurrence [Grafeas::V1::Occurrence | Hash]
      #   The occurrence to create.
      #   A hash of the same form as `Grafeas::V1::Occurrence`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Occurrence]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Occurrence]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # TODO: Initialize `occurrence`:
      #   occurrence = {}
      #   response = grafeas_client.create_occurrence(formatted_parent, occurrence)

      def create_occurrence \
          parent,
          occurrence,
          options: nil,
          &block
        req = {
          parent: parent,
          occurrence: occurrence
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::CreateOccurrenceRequest)
        @create_occurrence.call(req, options, &block)
      end

      # Creates new occurrences in batch.
      #
      # @param parent [String]
      #   The name of the project in the form of `projects/[PROJECT_ID]`, under which
      #   the occurrences are to be created.
      # @param occurrences [Array<Grafeas::V1::Occurrence | Hash>]
      #   The occurrences to create. Max allowed length is 1000.
      #   A hash of the same form as `Grafeas::V1::Occurrence`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::BatchCreateOccurrencesResponse]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::BatchCreateOccurrencesResponse]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # TODO: Initialize `occurrences`:
      #   occurrences = []
      #   response = grafeas_client.batch_create_occurrences(formatted_parent, occurrences)

      def batch_create_occurrences \
          parent,
          occurrences,
          options: nil,
          &block
        req = {
          parent: parent,
          occurrences: occurrences
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::BatchCreateOccurrencesRequest)
        @batch_create_occurrences.call(req, options, &block)
      end

      # Updates the specified occurrence.
      #
      # @param name [String]
      #   The name of the occurrence in the form of
      #   `projects/[PROJECT_ID]/occurrences/[OCCURRENCE_ID]`.
      # @param occurrence [Grafeas::V1::Occurrence | Hash]
      #   The updated occurrence.
      #   A hash of the same form as `Grafeas::V1::Occurrence`
      #   can also be provided.
      # @param update_mask [Google::Protobuf::FieldMask | Hash]
      #   The fields to update.
      #   A hash of the same form as `Google::Protobuf::FieldMask`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Occurrence]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Occurrence]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      #
      #   # TODO: Initialize `occurrence`:
      #   occurrence = {}
      #   response = grafeas_client.update_occurrence(formatted_name, occurrence)

      def update_occurrence \
          name,
          occurrence,
          update_mask: nil,
          options: nil,
          &block
        req = {
          name: name,
          occurrence: occurrence,
          update_mask: update_mask
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::UpdateOccurrenceRequest)
        @update_occurrence.call(req, options, &block)
      end

      # Gets the note attached to the specified occurrence. Consumer projects can
      # use this method to get a note that belongs to a provider project.
      #
      # @param name [String]
      #   The name of the occurrence in the form of
      #   `projects/[PROJECT_ID]/occurrences/[OCCURRENCE_ID]`.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Note]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Note]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      #   response = grafeas_client.get_occurrence_note(formatted_name)

      def get_occurrence_note \
          name,
          options: nil,
          &block
        req = {
          name: name
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::GetOccurrenceNoteRequest)
        @get_occurrence_note.call(req, options, &block)
      end

      # Gets the specified note.
      #
      # @param name [String]
      #   The name of the note in the form of
      #   `projects/[PROVIDER_ID]/notes/[NOTE_ID]`.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Note]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Note]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      #   response = grafeas_client.get_note(formatted_name)

      def get_note \
          name,
          options: nil,
          &block
        req = {
          name: name
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::GetNoteRequest)
        @get_note.call(req, options, &block)
      end

      # Lists notes for the specified project.
      #
      # @param parent [String]
      #   The name of the project to list notes for in the form of
      #   `projects/[PROJECT_ID]`.
      # @param filter [String]
      #   The filter expression.
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
      # @yieldparam result [Google::Gax::PagedEnumerable<Grafeas::V1::Note>]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Google::Gax::PagedEnumerable<Grafeas::V1::Note>]
      #   An enumerable of Grafeas::V1::Note instances.
      #   See Google::Gax::PagedEnumerable documentation for other
      #   operations such as per-page iteration or access to the response
      #   object.
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # Iterate over all results.
      #   grafeas_client.list_notes(formatted_parent).each do |element|
      #     # Process element.
      #   end
      #
      #   # Or iterate over results one page at a time.
      #   grafeas_client.list_notes(formatted_parent).each_page do |page|
      #     # Process each page at a time.
      #     page.each do |element|
      #       # Process element.
      #     end
      #   end

      def list_notes \
          parent,
          filter: nil,
          page_size: nil,
          options: nil,
          &block
        req = {
          parent: parent,
          filter: filter,
          page_size: page_size
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::ListNotesRequest)
        @list_notes.call(req, options, &block)
      end

      # Creates a new note.
      #
      # @param parent [String]
      #   The name of the project in the form of `projects/[PROJECT_ID]`, under which
      #   the note is to be created.
      # @param note_id [String]
      #   The ID to use for this note.
      # @param note [Grafeas::V1::Note | Hash]
      #   The note to create.
      #   A hash of the same form as `Grafeas::V1::Note`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Note]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Note]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # TODO: Initialize `note_id`:
      #   note_id = ''
      #
      #   # TODO: Initialize `note`:
      #   note = {}
      #   response = grafeas_client.create_note(formatted_parent, note_id, note)

      def create_note \
          parent,
          note_id,
          note,
          options: nil,
          &block
        req = {
          parent: parent,
          note_id: note_id,
          note: note
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::CreateNoteRequest)
        @create_note.call(req, options, &block)
      end

      # Creates new notes in batch.
      #
      # @param parent [String]
      #   The name of the project in the form of `projects/[PROJECT_ID]`, under which
      #   the notes are to be created.
      # @param notes [Hash{String => Grafeas::V1::Note | Hash}]
      #   The notes to create. Max allowed length is 1000.
      #   A hash of the same form as `Grafeas::V1::Note`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::BatchCreateNotesResponse]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::BatchCreateNotesResponse]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      #
      #   # TODO: Initialize `notes`:
      #   notes = {}
      #   response = grafeas_client.batch_create_notes(formatted_parent, notes)

      def batch_create_notes \
          parent,
          notes,
          options: nil,
          &block
        req = {
          parent: parent,
          notes: notes
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::BatchCreateNotesRequest)
        @batch_create_notes.call(req, options, &block)
      end

      # Updates the specified note.
      #
      # @param name [String]
      #   The name of the note in the form of
      #   `projects/[PROVIDER_ID]/notes/[NOTE_ID]`.
      # @param note [Grafeas::V1::Note | Hash]
      #   The updated note.
      #   A hash of the same form as `Grafeas::V1::Note`
      #   can also be provided.
      # @param update_mask [Google::Protobuf::FieldMask | Hash]
      #   The fields to update.
      #   A hash of the same form as `Google::Protobuf::FieldMask`
      #   can also be provided.
      # @param options [Google::Gax::CallOptions]
      #   Overrides the default settings for this call, e.g, timeout,
      #   retries, etc.
      # @yield [result, operation] Access the result along with the RPC operation
      # @yieldparam result [Grafeas::V1::Note]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Grafeas::V1::Note]
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      #
      #   # TODO: Initialize `note`:
      #   note = {}
      #   response = grafeas_client.update_note(formatted_name, note)

      def update_note \
          name,
          note,
          update_mask: nil,
          options: nil,
          &block
        req = {
          name: name,
          note: note,
          update_mask: update_mask
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::UpdateNoteRequest)
        @update_note.call(req, options, &block)
      end

      # Lists occurrences referencing the specified note. Provider projects can use
      # this method to get all occurrences across consumer projects referencing the
      # specified note.
      #
      # @param name [String]
      #   The name of the note to list occurrences for in the form of
      #   `projects/[PROVIDER_ID]/notes/[NOTE_ID]`.
      # @param filter [String]
      #   The filter expression.
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
      # @yieldparam result [Google::Gax::PagedEnumerable<Grafeas::V1::Occurrence>]
      # @yieldparam operation [GRPC::ActiveCall::Operation]
      # @return [Google::Gax::PagedEnumerable<Grafeas::V1::Occurrence>]
      #   An enumerable of Grafeas::V1::Occurrence instances.
      #   See Google::Gax::PagedEnumerable documentation for other
      #   operations such as per-page iteration or access to the response
      #   object.
      # @raise [Google::Gax::GaxError] if the RPC is aborted.
      # @example
      #   require "grafeas"
      #
      #   grafeas_client = Grafeas.new(version: :v1)
      #   formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      #
      #   # Iterate over all results.
      #   grafeas_client.list_note_occurrences(formatted_name).each do |element|
      #     # Process element.
      #   end
      #
      #   # Or iterate over results one page at a time.
      #   grafeas_client.list_note_occurrences(formatted_name).each_page do |page|
      #     # Process each page at a time.
      #     page.each do |element|
      #       # Process element.
      #     end
      #   end

      def list_note_occurrences \
          name,
          filter: nil,
          page_size: nil,
          options: nil,
          &block
        req = {
          name: name,
          filter: filter,
          page_size: page_size
        }.delete_if { |_, v| v.nil? }
        req = Google::Gax::to_proto(req, Grafeas::V1::ListNoteOccurrencesRequest)
        @list_note_occurrences.call(req, options, &block)
      end
    end
  end
end
