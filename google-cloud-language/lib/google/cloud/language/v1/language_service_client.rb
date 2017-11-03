# Copyright 2017, Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/language/v1/language_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/language/v1/language_service_pb"
require "google/cloud/language/credentials"

module Google
  module Cloud
    module Language
      module V1
        # Provides text analysis operations such as sentiment analysis and entity
        # recognition.
        #
        # @!attribute [r] language_service_stub
        #   @return [Google::Cloud::Language::V1::LanguageService::Stub]
        class LanguageServiceClient
          attr_reader :language_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "language.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

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
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
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
            require "google/cloud/language/v1/language_service_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
              warn "`service_path` and `port` parameters are deprecated and will be removed"
            end

            credentials ||= Google::Cloud::Language::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Language::Credentials.new(credentials).updater_proc
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

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.6.8 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "language_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.language.v1.LanguageService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @language_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Cloud::Language::V1::LanguageService::Stub.method(:new)
            )

            @analyze_sentiment = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_sentiment),
              defaults["analyze_sentiment"]
            )
            @analyze_entities = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_entities),
              defaults["analyze_entities"]
            )
            @analyze_entity_sentiment = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_entity_sentiment),
              defaults["analyze_entity_sentiment"]
            )
            @analyze_syntax = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_syntax),
              defaults["analyze_syntax"]
            )
            @classify_text = Google::Gax.create_api_call(
              @language_service_stub.method(:classify_text),
              defaults["classify_text"]
            )
            @annotate_text = Google::Gax.create_api_call(
              @language_service_stub.method(:annotate_text),
              defaults["annotate_text"]
            )
          end

          # Service calls

          # Analyzes the sentiment of the provided text.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate sentence offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeSentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   response = language_service_client.analyze_sentiment(document)

          def analyze_sentiment \
              document,
              encoding_type: nil,
              options: nil
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeSentimentRequest)
            @analyze_sentiment.call(req, options)
          end

          # Finds named entities (currently proper names and common nouns) in the text
          # along with entity types, salience, mentions for each entity, and
          # other properties.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeEntitiesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   response = language_service_client.analyze_entities(document)

          def analyze_entities \
              document,
              encoding_type: nil,
              options: nil
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeEntitiesRequest)
            @analyze_entities.call(req, options)
          end

          # Finds entities, similar to {Google::Cloud::Language::V1::LanguageService::AnalyzeEntities AnalyzeEntities} in the text and analyzes
          # sentiment associated with each entity and its mentions.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeEntitySentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   response = language_service_client.analyze_entity_sentiment(document)

          def analyze_entity_sentiment \
              document,
              encoding_type: nil,
              options: nil
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeEntitySentimentRequest)
            @analyze_entity_sentiment.call(req, options)
          end

          # Analyzes the syntax of the text and provides sentence boundaries and
          # tokenization along with part of speech tags, dependency trees, and other
          # properties.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeSyntaxResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   response = language_service_client.analyze_syntax(document)

          def analyze_syntax \
              document,
              encoding_type: nil,
              options: nil
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeSyntaxRequest)
            @analyze_syntax.call(req, options)
          end

          # Classifies a document into categories.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::ClassifyTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   response = language_service_client.classify_text(document)

          def classify_text \
              document,
              options: nil
            req = {
              document: document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::ClassifyTextRequest)
            @classify_text.call(req, options)
          end

          # A convenience method that provides all the features that analyzeSentiment,
          # analyzeEntities, and analyzeSyntax provide in one call.
          #
          # @param document [Google::Cloud::Language::V1::Document | Hash]
          #   Input document.
          #   A hash of the same form as `Google::Cloud::Language::V1::Document`
          #   can also be provided.
          # @param features [Google::Cloud::Language::V1::AnnotateTextRequest::Features | Hash]
          #   The enabled features.
          #   A hash of the same form as `Google::Cloud::Language::V1::AnnotateTextRequest::Features`
          #   can also be provided.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnnotateTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1"
          #
          #   language_service_client = Google::Cloud::Language::V1.new
          #   document = {}
          #   features = {}
          #   response = language_service_client.annotate_text(document, features)

          def annotate_text \
              document,
              features,
              encoding_type: nil,
              options: nil
            req = {
              document: document,
              features: features,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnnotateTextRequest)
            @annotate_text.call(req, options)
          end
        end
      end
    end
  end
end
