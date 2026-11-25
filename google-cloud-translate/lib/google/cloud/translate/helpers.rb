# frozen_string_literal: true

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


module Google
  module Cloud
    module Translate
      ##
      # Creates a new object for connecting to the legacy V2 version of the
      # Cloud Translation API.
      #
      # Like other Cloud Platform services, Google Cloud Translation API supports authentication using a project ID
      # and OAuth 2.0 credentials. In addition, it supports authentication using a public API access key. (If both the
      # API key and the project and OAuth 2.0 credentials are provided, the API key will be used.) Instructions and
      # configuration options are covered in the {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Cloud Translation service you are connecting to. If not
      #   present, the default project for the credentials is used.
      # @param [Google::Auth::Credentials] credentials A Google::Auth::Credentials
      #   object.
      #   @note Warning: Passing a `String` to a keyfile path or a `Hash` of credentials
      #     is deprecated. Providing an unvalidated credential configuration to
      #     Google APIs can compromise the security of your systems and data.
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
      # @param [String] universe_domain Override of the universe domain. Optional. If the param is nil, uses the
      #   configured `universe_domain`, `ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]`, or `"googleapis.com"`.
      #
      # @return [Google::Cloud::Translate::V2::Api]
      #
      # @example
      #   require "googleauth"
      #   require "google/cloud/translate/v2"
      #
      #   credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
      #     json_key_io: ::File.open("/path/to/keyfile.json")
      #   )
      #
      #   translate = Google::Cloud::Translate::V2.new(
      #     version: :v2,
      #     project_id: "my-todo-project",
      #     credentials: credentials
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
      def self.translation_v2_service project_id: nil,
                                      credentials: nil,
                                      key: nil,
                                      scope: nil,
                                      retries: nil,
                                      timeout: nil,
                                      endpoint: nil,
                                      universe_domain: nil
        require "google/cloud/translate/v2"
        options = {
          project_id:  project_id,
          credentials: credentials,
          key:         key,
          scope:       scope,
          retries:     retries,
          timeout:     timeout,
          endpoint:    endpoint
        }
        # `Translate::V2.new` shares `Google::Cloud.configure.translate` (via
        # `V2.translation_config`) and `ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]`.
        # Resolve `universe_domain` here as well so we can omit the keyword when
        # unset (keeping GDU callers compatible with `google-cloud-translate-v2 <= 1.2.1`)
        # while forwarding configured universes so older V2 gems fail closed
        # with `ArgumentError` instead of silently routing to `googleapis.com`.
        env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]&.strip
        universe_domain ||= configure.universe_domain
        universe_domain ||= env_universe unless env_universe.nil? || env_universe.empty?
        options[:universe_domain] = universe_domain unless universe_domain.nil?

        Google::Cloud::Translate::V2.new(**options)
      end

      # Additional config keys used by V2
      configure do |config|
        config.add_field! :project_id, nil, match: ::String
        config.add_field! :key,        nil, match: ::String
        config.add_field! :retries,    nil, match: ::Integer
      end
    end
  end
end
