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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/language/v1beta1/language_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require 'json'
require 'pathname'

require 'google/gax'
require 'google/cloud/language/v1beta1/language_service_services'

module Google
  module Cloud
    module Language
      module V1beta1
        # Provides text analysis operations such as sentiment analysis and entity
        # recognition.
        #
        # @!attribute [r] stub
        #   @return [Google::Cloud::Language::V1beta1::LanguageService::Stub]
        class LanguageServiceApi
          attr_reader :stub

          # The default address of the service.
          SERVICE_ADDRESS = 'language.googleapis.com'.freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = 'gapic/0.1.0'.freeze

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            'https://www.googleapis.com/auth/cloud-platform'
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
          def initialize(
            service_path: SERVICE_ADDRESS,
            port: DEFAULT_SERVICE_PORT,
            channel: nil,
            chan_creds: nil,
            scopes: ALL_SCOPES,
            client_config: {},
            timeout: DEFAULT_TIMEOUT,
            app_name: 'gax',
            app_version: Google::Gax::VERSION
          )
            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
            headers = { :'x-goog-api-client' => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              'language_service_client_config.json'
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                'google.cloud.language.v1beta1.LanguageService',
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Cloud::Language::V1beta1::LanguageService::Stub.method(:new)
            )

            @analyze_sentiment = Google::Gax.create_api_call(
              @stub.method(:analyze_sentiment),
              defaults['analyze_sentiment']
            )
            @analyze_entities = Google::Gax.create_api_call(
              @stub.method(:analyze_entities),
              defaults['analyze_entities']
            )
            @annotate_text = Google::Gax.create_api_call(
              @stub.method(:annotate_text),
              defaults['annotate_text']
            )
          end

          # Service calls

          # Analyzes the sentiment of the provided text.
          #
          # @param document [Google::Cloud::Language::V1beta1::Document]
          #   Input document. Currently, +analyzeSentiment+ only supports English text
          #   (Document#language="EN").
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1beta1::AnalyzeSentimentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def analyze_sentiment(
            document,
            options: nil
          )
            req = Google::Cloud::Language::V1beta1::AnalyzeSentimentRequest.new(
              document: document
            )
            @analyze_sentiment.call(req, options)
          end

          # Finds named entities (currently finds proper names) in the text,
          # entity types, salience, mentions for each entity, and other properties.
          #
          # @param document [Google::Cloud::Language::V1beta1::Document]
          #   Input document.
          # @param encoding_type [Google::Cloud::Language::V1beta1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1beta1::AnalyzeEntitiesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def analyze_entities(
            document,
            encoding_type,
            options: nil
          )
            req = Google::Cloud::Language::V1beta1::AnalyzeEntitiesRequest.new(
              document: document,
              encoding_type: encoding_type
            )
            @analyze_entities.call(req, options)
          end

          # Advanced API that analyzes the document and provides a full set of text
          # annotations, including semantic, syntactic, and sentiment information. This
          # API is intended for users who are familiar with machine learning and need
          # in-depth text features to build upon.
          #
          # @param document [Google::Cloud::Language::V1beta1::Document]
          #   Input document.
          # @param features [Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features]
          #   The enabled features.
          # @param encoding_type [Google::Cloud::Language::V1beta1::EncodingType]
          #   The encoding type used by the API to calculate offsets.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Language::V1beta1::AnnotateTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def annotate_text(
            document,
            features,
            encoding_type,
            options: nil
          )
            req = Google::Cloud::Language::V1beta1::AnnotateTextRequest.new(
              document: document,
              features: features,
              encoding_type: encoding_type
            )
            @annotate_text.call(req, options)
          end
        end
      end
    end
  end
end
