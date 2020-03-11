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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/translate/v3/translation_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/translate/v3/translation_service_pb"
require "google/cloud/translate/v3/credentials"
require "google/cloud/translate/version"

module Google
  module Cloud
    module Translate
      module V3
        # Provides natural language translation operations.
        #
        # @!attribute [r] translation_service_stub
        #   @return [Google::Cloud::Translate::V3::TranslationService::Stub]
        class TranslationServiceClient
          # @private
          attr_reader :translation_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "translate.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_glossaries" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "glossaries")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-translation"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = TranslationServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = TranslationServiceClient::GRPC_INTERCEPTORS
          end

          GLOSSARY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/glossaries/{glossary}"
          )

          private_constant :GLOSSARY_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          # Returns a fully-qualified glossary resource name string.
          # @param project [String]
          # @param location [String]
          # @param glossary [String]
          # @return [String]
          def self.glossary_path project, location, glossary
            GLOSSARY_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"glossary" => glossary
            )
          end

          # Returns a fully-qualified location resource name string.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def self.location_path project, location
            LOCATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location
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
            require "google/cloud/translate/v3/translation_service_services_pb"

            credentials ||= Google::Cloud::Translate::V3::Credentials.default

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
              updater_proc = Google::Cloud::Translate::V3::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Translate::VERSION

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
              "translation_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.translation.v3.TranslationService",
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
            @translation_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Translate::V3::TranslationService::Stub.method(:new)
            )

            @translate_text = Google::Gax.create_api_call(
              @translation_service_stub.method(:translate_text),
              defaults["translate_text"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @detect_language = Google::Gax.create_api_call(
              @translation_service_stub.method(:detect_language),
              defaults["detect_language"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_supported_languages = Google::Gax.create_api_call(
              @translation_service_stub.method(:get_supported_languages),
              defaults["get_supported_languages"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @batch_translate_text = Google::Gax.create_api_call(
              @translation_service_stub.method(:batch_translate_text),
              defaults["batch_translate_text"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_glossary = Google::Gax.create_api_call(
              @translation_service_stub.method(:create_glossary),
              defaults["create_glossary"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_glossaries = Google::Gax.create_api_call(
              @translation_service_stub.method(:list_glossaries),
              defaults["list_glossaries"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_glossary = Google::Gax.create_api_call(
              @translation_service_stub.method(:get_glossary),
              defaults["get_glossary"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @delete_glossary = Google::Gax.create_api_call(
              @translation_service_stub.method(:delete_glossary),
              defaults["delete_glossary"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Translates input text and returns translated text.
          #
          # @param contents [Array<String>]
          #   Required. The content of the input in string format.
          #   We recommend the total content be less than 30k codepoints.
          #   Use BatchTranslateText for larger text.
          # @param target_language_code [String]
          #   Required. The BCP-47 language code to use for translation of the input
          #   text, set to one of the language codes listed in Language Support.
          # @param parent [String]
          #   Required. Project or location to make a call. Must refer to a caller's
          #   project.
          #
          #   Format: `projects/{project-number-or-id}` or
          #   `projects/{project-number-or-id}/locations/{location-id}`.
          #
          #   For global calls, use `projects/{project-number-or-id}/locations/global` or
          #   `projects/{project-number-or-id}`.
          #
          #   Non-global location is required for requests using AutoML models or
          #   custom glossaries.
          #
          #   Models and glossaries must be within the same region (have same
          #   location-id), otherwise an INVALID_ARGUMENT (400) error is returned.
          # @param mime_type [String]
          #   Optional. The format of the source text, for example, "text/html",
          #    "text/plain". If left blank, the MIME type defaults to "text/html".
          # @param source_language_code [String]
          #   Optional. The BCP-47 language code of the input text if
          #   known, for example, "en-US" or "sr-Latn". Supported language codes are
          #   listed in Language Support. If the source language isn't specified, the API
          #   attempts to identify the source language automatically and returns the
          #   source language within the response.
          # @param model [String]
          #   Optional. The `model` type requested for this translation.
          #
          #   The format depends on model type:
          #
          #   * AutoML Translation models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/{model-id}`
          #
          #   * General (built-in) models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/nmt`,
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/base`
          #
          #
          #   For global (non-regionalized) requests, use `location-id` `global`.
          #   For example,
          #   `projects/{project-number-or-id}/locations/global/models/general/nmt`.
          #
          #   If missing, the system decides which google base model to use.
          # @param glossary_config [Google::Cloud::Translate::V3::TranslateTextGlossaryConfig | Hash]
          #   Optional. Glossary to be applied. The glossary must be
          #   within the same region (have the same location-id) as the model, otherwise
          #   an INVALID_ARGUMENT (400) error is returned.
          #   A hash of the same form as `Google::Cloud::Translate::V3::TranslateTextGlossaryConfig`
          #   can also be provided.
          # @param labels [Hash{String => String}]
          #   Optional. The labels with user-defined metadata for the request.
          #
          #   Label keys and values can be no longer than 63 characters
          #   (Unicode codepoints), can only contain lowercase letters, numeric
          #   characters, underscores and dashes. International characters are allowed.
          #   Label values are optional. Label keys must start with a letter.
          #
          #   See https://cloud.google.com/translate/docs/labels for more information.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Translate::V3::TranslateTextResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Translate::V3::TranslateTextResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #
          #   # TODO: Initialize `contents`:
          #   contents = []
          #
          #   # TODO: Initialize `target_language_code`:
          #   target_language_code = ''
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = translation_client.translate_text(contents, target_language_code, formatted_parent)

          def translate_text \
              contents,
              target_language_code,
              parent,
              mime_type: nil,
              source_language_code: nil,
              model: nil,
              glossary_config: nil,
              labels: nil,
              options: nil,
              &block
            req = {
              contents: contents,
              target_language_code: target_language_code,
              parent: parent,
              mime_type: mime_type,
              source_language_code: source_language_code,
              model: model,
              glossary_config: glossary_config,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::TranslateTextRequest)
            @translate_text.call(req, options, &block)
          end

          # Detects the language of text within a request.
          #
          # @param parent [String]
          #   Required. Project or location to make a call. Must refer to a caller's
          #   project.
          #
          #   Format: `projects/{project-number-or-id}/locations/{location-id}` or
          #   `projects/{project-number-or-id}`.
          #
          #   For global calls, use `projects/{project-number-or-id}/locations/global` or
          #   `projects/{project-number-or-id}`.
          #
          #   Only models within the same region (has same location-id) can be used.
          #   Otherwise an INVALID_ARGUMENT (400) error is returned.
          # @param model [String]
          #   Optional. The language detection model to be used.
          #
          #   Format:
          #   `projects/{project-number-or-id}/locations/{location-id}/models/language-detection/{model-id}`
          #
          #   Only one language detection model is currently supported:
          #   `projects/{project-number-or-id}/locations/{location-id}/models/language-detection/default`.
          #
          #   If not specified, the default model is used.
          # @param content [String]
          #   The content of the input stored as a string.
          # @param mime_type [String]
          #   Optional. The format of the source text, for example, "text/html",
          #   "text/plain". If left blank, the MIME type defaults to "text/html".
          # @param labels [Hash{String => String}]
          #   Optional. The labels with user-defined metadata for the request.
          #
          #   Label keys and values can be no longer than 63 characters
          #   (Unicode codepoints), can only contain lowercase letters, numeric
          #   characters, underscores and dashes. International characters are allowed.
          #   Label values are optional. Label keys must start with a letter.
          #
          #   See https://cloud.google.com/translate/docs/labels for more information.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Translate::V3::DetectLanguageResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Translate::V3::DetectLanguageResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = translation_client.detect_language(formatted_parent)

          def detect_language \
              parent,
              model: nil,
              content: nil,
              mime_type: nil,
              labels: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              model: model,
              content: content,
              mime_type: mime_type,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::DetectLanguageRequest)
            @detect_language.call(req, options, &block)
          end

          # Returns a list of supported languages for translation.
          #
          # @param parent [String]
          #   Required. Project or location to make a call. Must refer to a caller's
          #   project.
          #
          #   Format: `projects/{project-number-or-id}` or
          #   `projects/{project-number-or-id}/locations/{location-id}`.
          #
          #   For global calls, use `projects/{project-number-or-id}/locations/global` or
          #   `projects/{project-number-or-id}`.
          #
          #   Non-global location is required for AutoML models.
          #
          #   Only models within the same region (have same location-id) can be used,
          #   otherwise an INVALID_ARGUMENT (400) error is returned.
          # @param display_language_code [String]
          #   Optional. The language to use to return localized, human readable names
          #   of supported languages. If missing, then display names are not returned
          #   in a response.
          # @param model [String]
          #   Optional. Get supported languages of this model.
          #
          #   The format depends on model type:
          #
          #   * AutoML Translation models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/{model-id}`
          #
          #   * General (built-in) models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/nmt`,
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/base`
          #
          #
          #   Returns languages supported by the specified model.
          #   If missing, we get supported languages of Google general base (PBMT) model.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Translate::V3::SupportedLanguages]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Translate::V3::SupportedLanguages]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = translation_client.get_supported_languages(formatted_parent)

          def get_supported_languages \
              parent,
              display_language_code: nil,
              model: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              display_language_code: display_language_code,
              model: model
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::GetSupportedLanguagesRequest)
            @get_supported_languages.call(req, options, &block)
          end

          # Translates a large volume of text in asynchronous batch mode.
          # This function provides real-time output as the inputs are being processed.
          # If caller cancels a request, the partial results (for an input file, it's
          # all or nothing) may still be available on the specified output location.
          #
          # This call returns immediately and you can
          # use google.longrunning.Operation.name to poll the status of the call.
          #
          # @param parent [String]
          #   Required. Location to make a call. Must refer to a caller's project.
          #
          #   Format: `projects/{project-number-or-id}/locations/{location-id}`.
          #
          #   The `global` location is not supported for batch translation.
          #
          #   Only AutoML Translation models or glossaries within the same region (have
          #   the same location-id) can be used, otherwise an INVALID_ARGUMENT (400)
          #   error is returned.
          # @param source_language_code [String]
          #   Required. Source language code.
          # @param target_language_codes [Array<String>]
          #   Required. Specify up to 10 language codes here.
          # @param input_configs [Array<Google::Cloud::Translate::V3::InputConfig | Hash>]
          #   Required. Input configurations.
          #   The total number of files matched should be <= 1000.
          #   The total content size should be <= 100M Unicode codepoints.
          #   The files must use UTF-8 encoding.
          #   A hash of the same form as `Google::Cloud::Translate::V3::InputConfig`
          #   can also be provided.
          # @param output_config [Google::Cloud::Translate::V3::OutputConfig | Hash]
          #   Required. Output configuration.
          #   If 2 input configs match to the same file (that is, same input path),
          #   we don't generate output for duplicate inputs.
          #   A hash of the same form as `Google::Cloud::Translate::V3::OutputConfig`
          #   can also be provided.
          # @param models [Hash{String => String}]
          #   Optional. The models to use for translation. Map's key is target language
          #   code. Map's value is model name. Value can be a built-in general model,
          #   or an AutoML Translation model.
          #
          #   The value format depends on model type:
          #
          #   * AutoML Translation models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/{model-id}`
          #
          #   * General (built-in) models:
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/nmt`,
          #     `projects/{project-number-or-id}/locations/{location-id}/models/general/base`
          #
          #
          #   If the map is empty or a specific model is
          #   not requested for a language pair, then default google model (nmt) is used.
          # @param glossaries [Hash{String => Google::Cloud::Translate::V3::TranslateTextGlossaryConfig | Hash}]
          #   Optional. Glossaries to be applied for translation.
          #   It's keyed by target language code.
          #   A hash of the same form as `Google::Cloud::Translate::V3::TranslateTextGlossaryConfig`
          #   can also be provided.
          # @param labels [Hash{String => String}]
          #   Optional. The labels with user-defined metadata for the request.
          #
          #   Label keys and values can be no longer than 63 characters
          #   (Unicode codepoints), can only contain lowercase letters, numeric
          #   characters, underscores and dashes. International characters are allowed.
          #   Label values are optional. Label keys must start with a letter.
          #
          #   See https://cloud.google.com/translate/docs/labels for more information.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `source_language_code`:
          #   source_language_code = ''
          #
          #   # TODO: Initialize `target_language_codes`:
          #   target_language_codes = []
          #
          #   # TODO: Initialize `input_configs`:
          #   input_configs = []
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = translation_client.batch_translate_text(formatted_parent, source_language_code, target_language_codes, input_configs, output_config) do |op|
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

          def batch_translate_text \
              parent,
              source_language_code,
              target_language_codes,
              input_configs,
              output_config,
              models: nil,
              glossaries: nil,
              labels: nil,
              options: nil
            req = {
              parent: parent,
              source_language_code: source_language_code,
              target_language_codes: target_language_codes,
              input_configs: input_configs,
              output_config: output_config,
              models: models,
              glossaries: glossaries,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::BatchTranslateTextRequest)
            operation = Google::Gax::Operation.new(
              @batch_translate_text.call(req, options),
              @operations_client,
              Google::Cloud::Translate::V3::BatchTranslateResponse,
              Google::Cloud::Translate::V3::BatchTranslateMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Creates a glossary and returns the long-running operation. Returns
          # NOT_FOUND, if the project doesn't exist.
          #
          # @param parent [String]
          #   Required. The project name.
          # @param glossary [Google::Cloud::Translate::V3::Glossary | Hash]
          #   Required. The glossary to create.
          #   A hash of the same form as `Google::Cloud::Translate::V3::Glossary`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `glossary`:
          #   glossary = {}
          #
          #   # Register a callback during the method call.
          #   operation = translation_client.create_glossary(formatted_parent, glossary) do |op|
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

          def create_glossary \
              parent,
              glossary,
              options: nil
            req = {
              parent: parent,
              glossary: glossary
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::CreateGlossaryRequest)
            operation = Google::Gax::Operation.new(
              @create_glossary.call(req, options),
              @operations_client,
              Google::Cloud::Translate::V3::Glossary,
              Google::Cloud::Translate::V3::CreateGlossaryMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
          # exist.
          #
          # @param parent [String]
          #   Required. The name of the project from which to list all of the glossaries.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param filter [String]
          #   Optional. Filter specifying constraints of a list operation.
          #   Filtering is not supported yet, and the parameter currently has no effect.
          #   If missing, no filtering is performed.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Translate::V3::Glossary>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Translate::V3::Glossary>]
          #   An enumerable of Google::Cloud::Translate::V3::Glossary instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_parent = Google::Cloud::Translate::V3::TranslationServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   translation_client.list_glossaries(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   translation_client.list_glossaries(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_glossaries \
              parent,
              page_size: nil,
              filter: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::ListGlossariesRequest)
            @list_glossaries.call(req, options, &block)
          end

          # Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
          # exist.
          #
          # @param name [String]
          #   Required. The name of the glossary to retrieve.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Translate::V3::Glossary]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Translate::V3::Glossary]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")
          #   response = translation_client.get_glossary(formatted_name)

          def get_glossary \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::GetGlossaryRequest)
            @get_glossary.call(req, options, &block)
          end

          # Deletes a glossary, or cancels glossary construction
          # if the glossary isn't created yet.
          # Returns NOT_FOUND, if the glossary doesn't exist.
          #
          # @param name [String]
          #   Required. The name of the glossary to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/translate"
          #
          #   translation_client = Google::Cloud::Translate.new(version: :v3)
          #   formatted_name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path("[PROJECT]", "[LOCATION]", "[GLOSSARY]")
          #
          #   # Register a callback during the method call.
          #   operation = translation_client.delete_glossary(formatted_name) do |op|
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

          def delete_glossary \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Translate::V3::DeleteGlossaryRequest)
            operation = Google::Gax::Operation.new(
              @delete_glossary.call(req, options),
              @operations_client,
              Google::Cloud::Translate::V3::DeleteGlossaryResponse,
              Google::Cloud::Translate::V3::DeleteGlossaryMetadata,
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
