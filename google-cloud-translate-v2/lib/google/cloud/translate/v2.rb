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


require "google/cloud/translate/v2/api"
require "google/cloud/translate/v2/version"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/env"

module Google
  module Cloud
    module Translate
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
      module V2
        ##
        # Creates a new object for connecting to Cloud Translation API. Each call creates a new connection.
        #
        # Like other Cloud Platform services, Google Cloud Translation API supports authentication using a project ID
        # and OAuth 2.0 credentials. In addition, it supports authentication using a public API access key. (If both the
        # API key and the project and OAuth 2.0 credentials are provided, the API key will be used.) Instructions and
        # configuration options are covered in the {file:AUTHENTICATION.md Authentication Guide}.
        #
        # @param [String] project_id Project identifier for the Cloud Translation service you are connecting to. If not
        #   present, the default project for the credentials is used.
        # @param [String, Hash, Google::Auth::Credentials] credentials The path to the keyfile as a String, the contents
        #   of the keyfile as a Hash, or a Google::Auth::Credentials object. (See {Translate::V2::Credentials})
        # @param [String] key a public API access key (not an OAuth 2.0 token)
        # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the set of resources and operations that
        #   the connection can access. See [Using OAuth 2.0 to Access Google
        #   APIs](https://developers.google.com/identity/protocols/OAuth2).
        #
        #   The default scope is:
        #
        #   * `https://www.googleapis.com/auth/cloud-platform`
        # @param [Integer] retries Number of times to retry requests on server error. The default value is `3`.
        #   Optional.
        # @param [Integer] timeout Default timeout to use in requests. Optional.
        # @param [String] endpoint Override of the endpoint host name. Optional. If the param is nil, uses the default
        #   endpoint.
        #
        # @return [Google::Cloud::Translate::V2::Api]
        #
        # @example
        #   require "google/cloud/translate/v2"
        #
        #   translate = Google::Cloud::Translate::V2.new(
        #     version: :v2,
        #     project_id: "my-todo-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   translation = translate.translate "Hello world!", to: "la"
        #   translation.text #=> "Salve mundi!"
        #
        # @example Using API Key.
        #   require "google/cloud/translate/v2"
        #
        #   translate = Google::Cloud::Translate::V2.new(
        #     key: "api-key-abc123XYZ789"
        #   )
        #
        #   translation = translate.translate "Hello world!", to: "la"
        #   translation.text #=> "Salve mundi!"
        #
        # @example Using API Key from the environment variable.
        #   require "google/cloud/translate/v2"
        #
        #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
        #
        #   translate = Google::Cloud::Translate::V2.new
        #
        #   translation = translate.translate "Hello world!", to: "la"
        #   translation.text #=> "Salve mundi!"
        #
        def self.new project_id: nil, credentials: nil, key: nil, scope: nil, retries: nil, timeout: nil, endpoint: nil
          project_id ||= default_project_id

          configuration = translation_config
          key ||= configuration&.key || ENV["TRANSLATE_KEY"] || ENV["GOOGLE_CLOUD_KEY"]
          retries ||= configuration&.retries
          timeout ||= configuration&.timeout
          endpoint ||= configuration&.endpoint

          if key
            return Google::Cloud::Translate::V2::Api.new(
              Google::Cloud::Translate::V2::Service.new(
                project_id.to_s, nil, retries: retries, timeout: timeout, key: key, host: endpoint
              )
            )
          end

          scope ||= configuration&.scope
          credentials ||= default_credentials scope: scope

          unless credentials.is_a? Google::Auth::Credentials
            credentials = Google::Cloud::Translate::V2::Credentials.new credentials, scope: scope
          end

          project_id = resolve_project_id project_id, credentials
          raise ArgumentError, "project_id is missing" if project_id.empty?

          Google::Cloud::Translate::V2::Api.new(
            Google::Cloud::Translate::V2::Service.new(
              project_id, credentials, retries: retries, timeout: timeout, host: endpoint
            )
          )
        end

        ##
        # @private Default project.
        def self.default_project_id
          translation_config&.project_id ||
            ENV["TRANSLATE_PROJECT"] ||
            Google::Cloud.configure.project_id ||
            Google::Cloud.env.project_id
        end

        ##
        # @private Default credentials.
        def self.default_credentials scope: nil
          translation_config&.credentials ||
            Google::Cloud::Config.credentials_from_env(
              "TRANSLATE_CREDENTIALS", "TRANSLATE_CREDENTIALS_JSON", "TRANSLATE_KEYFILE", "TRANSLATE_KEYFILE_JSON"
            ) ||
            Google::Cloud.configure.credentials ||
            Google::Cloud::Translate::V2::Credentials.default(scope: scope)
        end

        ##
        # @private Default configuration.
        def self.default_config
          Google::Cloud.configure
        end

        ##
        # @private Resolve project.
        def self.resolve_project_id project_id, credentials
          # Always cast to a string
          return project_id.to_s unless credentials.respond_to? :project_id

          # Always cast to a string
          project_id || credentials.project_id.to_s
        end

        ##
        # @private The global config from google-cloud-translate, or nil if not available
        def self.translation_config
          return nil unless Google::Cloud.configure.subconfig? :translate
          Google::Cloud.configure.translate
        end
      end
    end
  end
end
