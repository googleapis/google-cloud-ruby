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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/language/v1/language_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/language/v1/language_service_pb"
require "google/cloud/language/v1/credentials"

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
          # @private
          attr_reader :language_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "language.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

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
            require "google/cloud/language/v1/language_service_services_pb"

            credentials ||= Google::Cloud::Language::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Language::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-language'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
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
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @language_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Language::V1::LanguageService::Stub.method(:new)
            )

            @analyze_sentiment = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_sentiment),
              defaults["analyze_sentiment"],
              exception_transformer: exception_transformer
            )
            @analyze_entities = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_entities),
              defaults["analyze_entities"],
              exception_transformer: exception_transformer
            )
            @analyze_entity_sentiment = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_entity_sentiment),
              defaults["analyze_entity_sentiment"],
              exception_transformer: exception_transformer
            )
            @analyze_syntax = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_syntax),
              defaults["analyze_syntax"],
              exception_transformer: exception_transformer
            )
            @classify_text = Google::Gax.create_api_call(
              @language_service_stub.method(:classify_text),
              defaults["classify_text"],
              exception_transformer: exception_transformer
            )
            @annotate_text = Google::Gax.create_api_call(
              @language_service_stub.method(:annotate_text),
              defaults["annotate_text"],
              exception_transformer: exception_transformer
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::AnalyzeSentimentResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::AnalyzeSentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #   response = language_service_client.analyze_sentiment(document)

          def analyze_sentiment \
              document,
              encoding_type: nil,
              options: nil,
              &block
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeSentimentRequest)
            @analyze_sentiment.call(req, options, &block)
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::AnalyzeEntitiesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::AnalyzeEntitiesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #   response = language_service_client.analyze_entities(document)

          def analyze_entities \
              document,
              encoding_type: nil,
              options: nil,
              &block
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeEntitiesRequest)
            @analyze_entities.call(req, options, &block)
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::AnalyzeEntitySentimentResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::AnalyzeEntitySentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #   response = language_service_client.analyze_entity_sentiment(document)

          def analyze_entity_sentiment \
              document,
              encoding_type: nil,
              options: nil,
              &block
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeEntitySentimentRequest)
            @analyze_entity_sentiment.call(req, options, &block)
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::AnalyzeSyntaxResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::AnalyzeSyntaxResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #   response = language_service_client.analyze_syntax(document)

          def analyze_syntax \
              document,
              encoding_type: nil,
              options: nil,
              &block
            req = {
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnalyzeSyntaxRequest)
            @analyze_syntax.call(req, options, &block)
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::ClassifyTextResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::ClassifyTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #   response = language_service_client.classify_text(document)

          def classify_text \
              document,
              options: nil,
              &block
            req = {
              document: document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::ClassifyTextRequest)
            @classify_text.call(req, options, &block)
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
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Language::V1::AnnotateTextResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Language::V1::AnnotateTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language"
          #
          #   language_service_client = Google::Cloud::Language.new(version: :v1)
          #
          #   # TODO: Initialize +document+:
          #   document = {}
          #
          #   # TODO: Initialize +features+:
          #   features = {}
          #   response = language_service_client.annotate_text(document, features)

          def annotate_text \
              document,
              features,
              encoding_type: nil,
              options: nil,
              &block
            req = {
              document: document,
              features: features,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Language::V1::AnnotateTextRequest)
            @annotate_text.call(req, options, &block)
          end
        end
      end
    end
  end
end
