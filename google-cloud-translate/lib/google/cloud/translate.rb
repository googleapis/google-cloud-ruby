# Copyright 2019 Google LLC
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


require "google-cloud-translate"
require "google/cloud/config"
require "google/gax"
require "pathname"

module Google
  module Cloud
    ##
    # # Google Cloud Translation API
    #
    # [Google Cloud Translation API](https://cloud.google.com/translation/)
    # provides a simple, programmatic interface for translating an arbitrary
    # string into any supported language. It is highly responsive, so websites
    # and applications can integrate with Translation API for fast, dynamic
    # translation of source text. Language detection is also available in cases
    # where the source language is unknown.
    #
    # Translation API supports more than one hundred different languages, from
    # Afrikaans to Zulu. Used in combination, this enables translation between
    # thousands of language pairs. Also, you can send in HTML and receive HTML
    # with translated text back. You don't need to extract your source text or
    # reassemble the translated content.
    #
    # The google-cloud-translate 2.0 gem contains a generated v3 client and a legacy hand-written v2 client.
    # To use the legacy v2 client, call {Google::Cloud::Translate.new} and specify `version: :v2`.
    # See [Migrating to Translation v3](https://cloud.google.com/translate/docs/migrate-to-v3) for details regarding
    # differences between v2 and v3.
    #
    # See {file:OVERVIEW.md Translation Overview}.
    #
    module Translate
      FILE_DIR = File.realdirpath Pathname.new(__FILE__).join("..").join("translate")

      AVAILABLE_VERSIONS = Dir["#{FILE_DIR}/*"]
                           .select { |file| File.directory? file }
                           .select { |dir| Google::Gax::VERSION_MATCHER.match File.basename(dir) }
                           .select { |dir| File.exist? dir + ".rb" }
                           .map { |dir| File.basename dir }

      ##
      # Provides natural language translation operations.
      #
      # @overload new(version:, credentials:, scopes:, client_config:, timeout:)
      #   @param version [Symbol, String]
      #     The major version of the service to be used. By default `:v3` is used.
      #   @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel,
      #     GRPC::Core::ChannelCredentials, Proc]
      #     Provides the means for authenticating requests made by the client. This parameter can be many types.
      #     A `Google::Auth::Credentials` uses a the properties of its represented keyfile for authenticating requests
      #     made by this client.
      #     A `String` will be treated as the path to the keyfile to be used for the construction of credentials for
      #     this client.
      #     A `Hash` will be treated as the contents of a keyfile to be used for the construction of credentials for
      #     this client.
      #     A `GRPC::Core::Channel` will be used to make calls through.
      #     A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials should already
      #     be composed with a `GRPC::Core::CallCredentials` object.
      #     A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the metadata for
      #     requests, generally, to give OAuth credentials.
      #   @param scopes [Array<String>]
      #     The OAuth scopes for this service. This parameter is ignored if an updater_proc is supplied.
      #   @param client_config [Hash]
      #     A Hash for call options for each method. See Google::Gax#construct_settings for the structure of this data.
      #     Falls back to the default config if not specified or the specified config is missing data points.
      #   @param timeout [Numeric]
      #     The default timeout, in seconds, for calls made through this client.
      #   @param metadata [Hash]
      #     Default metadata to be sent with each request. This can be overridden on a per call basis.
      #   @param service_address [String]
      #     Override for the service hostname, or `nil` to leave as the default.
      #   @param service_port [Integer]
      #     Override for the service port, or `nil` to leave as the default.
      #   @param exception_transformer [Proc]
      #     An optional proc that intercepts any exceptions raised during an API call to inject custom error handling.
      # @overload new(version:, project_id:, credentials:, key:, scope:, retries:, timeout:, endpoint:)
      #   @param version [Symbol, String]
      #     The major version of the service to be used. Specifying `:v2` will return the legacy client.
      #   @param [String] project_id Project identifier for the Cloud Translation service you are connecting to. If not
      #     present, the default project for the credentials is used.
      #   @param [String, Hash, Google::Auth::Credentials] credentials The path to the keyfile as a String, the contents
      #     of the keyfile as a Hash, or a Google::Auth::Credentials object. (See
      #     {Google::Cloud::Translate::V2::Credentials})
      #   @param [String] key a public API access key (not an OAuth 2.0 token)
      #   @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the set of resources and operations that
      #     the connection can access. See [Using OAuth 2.0 to Access Google
      #     APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #     The default scope is:
      #
      #     * `https://www.googleapis.com/auth/cloud-platform`
      #   @param [Integer] retries Number of times to retry requests on server error. The default value is `3`.
      #     Optional.
      #   @param [Integer] timeout Default timeout to use in requests. Optional.
      #   @param [String] endpoint Override of the endpoint host name. Optional. If the param is nil, uses the default
      #     endpoint.
      #
      # @example Using the v3 client.
      #   require "google/cloud/translate"
      #
      #   client = Google::Cloud::Translate.new
      #
      #   project_id = "my-project-id"
      #   location_id = "us-central1"
      #   model_id = "my-automl-model-id"
      #
      #   # The `model` type requested for this translation.
      #   model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
      #   # The content to translate in string format
      #   contents = ["Hello, world!"]
      #   # Required. The BCP-47 language code to use for translation.
      #   target_language = "fr"
      #   # Optional. The BCP-47 language code of the input text.
      #   source_language = "en"
      #   # Optional. Can be "text/plain" or "text/html".
      #   mime_type = "text/plain"
      #   parent = client.class.location_path project_id, location_id
      #
      #   response = client.translate_text contents, target_language, parent,
      #     source_language_code: source_language, model: model, mime_type: mime_type
      #
      #   # Display the translation for each input text provided
      #   response.translations.each do |translation|
      #     puts "Translated text: #{translation.translated_text}"
      #   end
      #
      # @example Using the legacy v2 client.
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
      #     version: :v2,
      #     project_id: "my-todo-project",
      #     credentials: "/path/to/keyfile.json"
      #   )
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      # @example Using the legacy v2 client with an API Key.
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
      #     version: :v2,
      #     key: "api-key-abc123XYZ789"
      #   )
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      # @example Using API Key from the environment variable.
      #   require "google/cloud/translate"
      #
      #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
      #
      #   translate = Google::Cloud::Translate.new version: :v2
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      def self.new *args, version: :v3, **kwargs
        unless AVAILABLE_VERSIONS.include? version.to_s.downcase
          raise "The version: #{version} is not available. The available versions " \
            "are: [#{AVAILABLE_VERSIONS.join ', '}]"
        end

        require "#{FILE_DIR}/#{version.to_s.downcase}"
        version_module = Google::Cloud::Translate
                         .constants
                         .select { |sym| sym.to_s.casecmp(version.to_s).zero? }
                         .first
        Google::Cloud::Translate.const_get(version_module).new(*args, **kwargs)
      end

      ##
      # Configure the Google Cloud Translate library.
      #
      # The following Translate configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Translate project.
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to the keyfile as a String, the contents of
      #   the keyfile as a Hash, or a Google::Auth::Credentials object. (See
      #   {Google::Cloud::Translate::V2::Credentials})
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling the set of resources and operations that
      #   the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil` to use the default endpoint.
      #
      # @note These values are only used by the legacy v2 client.
      #
      # @return [Google::Cloud::Config] The configuration object the Google::Cloud::Translate library uses.
      #
      def self.configure
        yield Google::Cloud.configure.translate if block_given?

        Google::Cloud.configure.translate
      end
    end
  end
end
