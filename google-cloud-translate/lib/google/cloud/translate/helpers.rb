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
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to the keyfile as a String, the contents
      #   of the keyfile as a Hash, or a Google::Auth::Credentials object.
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
      def self.translation_v2_service project_id: nil,
                                      credentials: nil,
                                      key: nil,
                                      scope: nil,
                                      retries: nil,
                                      timeout: nil,
                                      endpoint: nil
        require "google/cloud/translate/v2"
        Google::Cloud::Translate::V2.new project_id:  project_id,
                                         credentials: credentials,
                                         key:         key,
                                         scope:       scope,
                                         retries:     retries,
                                         timeout:     timeout,
                                         endpoint:    endpoint
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
