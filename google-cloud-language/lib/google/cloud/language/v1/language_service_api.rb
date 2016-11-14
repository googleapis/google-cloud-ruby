# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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

module Google
  module Cloud
    module Language
      module V1
        # Provides text analysis operations such as sentiment analysis and entity
        # recognition.
        #
        # @!attribute [r] language_service_stub
        #   @return [Google::Cloud::Language::V1::LanguageService::Stub]
        class LanguageServiceApi
          attr_reader :language_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "language.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param app_name [String]
          #   The codename of the calling service.
          # @param app_version [String]
          #   The version of the calling service.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: "gax",
              app_version: Google::Gax::VERSION
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/language/v1/language_service_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
              "ruby/#{RUBY_VERSION}".freeze
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
            @analyze_syntax = Google::Gax.create_api_call(
              @language_service_stub.method(:analyze_syntax),
              defaults["analyze_syntax"]
            )
            @annotate_text = Google::Gax.create_api_call(
              @language_service_stub.method(:annotate_text),
              defaults["annotate_text"]
            )
          end

          # Service calls

          # Analyzes the sentiment of the provided text.
          #
          # @param document [Google::Cloud::Language::V1::Document]
          #   Input document. Currently, +analyzeSentiment+ only supports English text
          #   (Document#language="EN").
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate sentence offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeSentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1/language_service_api"
          #
          #   Document = Google::Cloud::Language::V1::Document
          #   LanguageServiceApi = Google::Cloud::Language::V1::LanguageServiceApi
          #
          #   language_service_api = LanguageServiceApi.new
          #   document = Document.new
          #   response = language_service_api.analyze_sentiment(document)

          def analyze_sentiment \
              document,
              encoding_type: nil,
              options: nil
            req = Google::Cloud::Language::V1::AnalyzeSentimentRequest.new({
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? })
            @analyze_sentiment.call(req, options)
          end

          # Finds named entities (currently finds proper names) in the text,
          # entity types, salience, mentions for each entity, and other properties.
          #
          # @param document [Google::Cloud::Language::V1::Document]
          #   Input document.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeEntitiesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1/language_service_api"
          #
          #   Document = Google::Cloud::Language::V1::Document
          #   EncodingType = Google::Cloud::Language::V1::EncodingType
          #   LanguageServiceApi = Google::Cloud::Language::V1::LanguageServiceApi
          #
          #   language_service_api = LanguageServiceApi.new
          #   document = Document.new
          #   encoding_type = EncodingType::NONE
          #   response = language_service_api.analyze_entities(document, encoding_type)

          def analyze_entities \
              document,
              encoding_type,
              options: nil
            req = Google::Cloud::Language::V1::AnalyzeEntitiesRequest.new({
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? })
            @analyze_entities.call(req, options)
          end

          # Analyzes the syntax of the text and provides sentence boundaries and
          # tokenization along with part of speech tags, dependency trees, and other
          # properties.
          #
          # @param document [Google::Cloud::Language::V1::Document]
          #   Input document.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnalyzeSyntaxResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1/language_service_api"
          #
          #   Document = Google::Cloud::Language::V1::Document
          #   EncodingType = Google::Cloud::Language::V1::EncodingType
          #   LanguageServiceApi = Google::Cloud::Language::V1::LanguageServiceApi
          #
          #   language_service_api = LanguageServiceApi.new
          #   document = Document.new
          #   encoding_type = EncodingType::NONE
          #   response = language_service_api.analyze_syntax(document, encoding_type)

          def analyze_syntax \
              document,
              encoding_type,
              options: nil
            req = Google::Cloud::Language::V1::AnalyzeSyntaxRequest.new({
              document: document,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? })
            @analyze_syntax.call(req, options)
          end

          # A convenience method that provides all the features that analyzeSentiment,
          # analyzeEntities, and analyzeSyntax provide in one call.
          #
          # @param document [Google::Cloud::Language::V1::Document]
          #   Input document.
          # @param features [Google::Cloud::Language::V1::AnnotateTextRequest::Features]
          #   The enabled features.
          # @param encoding_type [Google::Cloud::Language::V1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1::AnnotateTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/language/v1/language_service_api"
          #
          #   Document = Google::Cloud::Language::V1::Document
          #   EncodingType = Google::Cloud::Language::V1::EncodingType
          #   Features = Google::Cloud::Language::V1::AnnotateTextRequest::Features
          #   LanguageServiceApi = Google::Cloud::Language::V1::LanguageServiceApi
          #
          #   language_service_api = LanguageServiceApi.new
          #   document = Document.new
          #   features = Features.new
          #   encoding_type = EncodingType::NONE
          #   response = language_service_api.annotate_text(document, features, encoding_type)

          def annotate_text \
              document,
              features,
              encoding_type,
              options: nil
            req = Google::Cloud::Language::V1::AnnotateTextRequest.new({
              document: document,
              features: features,
              encoding_type: encoding_type
            }.delete_if { |_, v| v.nil? })
            @annotate_text.call(req, options)
          end
        end
      end
    end
  end
end
