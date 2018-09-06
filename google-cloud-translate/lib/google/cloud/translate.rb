# Copyright 2016 Google LLC
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
require "google/cloud/translate/api"
require "google/cloud/config"
require "google/cloud/env"

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
    # See {file:OVERVIEW.md Translation Overview}.
    #
    module Translate
      ##
      # Creates a new object for connecting to Cloud Translation API. Each call
      # creates a new connection.
      #
      # Like other Cloud Platform services, Google Cloud Translation API
      # supports authentication using a project ID and OAuth 2.0 credentials. In
      # addition, it supports authentication using a public API access key. (If
      # both the API key and the project and OAuth 2.0 credentials are provided,
      # the API key will be used.) Instructions and configuration options are
      # covered in the {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Cloud Translation
      #   service you are connecting to. If not present, the default project for
      #   the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Translate::Credentials})
      # @param [String] key a public API access key (not an OAuth 2.0 token)
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Translate::Api]
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
      #     project_id: "my-todo-project",
      #     credentials: "/path/to/keyfile.json"
      #   )
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      # @example Using API Key.
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
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
      #   translate = Google::Cloud::Translate.new
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      def self.new project_id: nil, credentials: nil, key: nil, scope: nil,
                   retries: nil, timeout: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string

        key ||= configure.key
        if key
          return Google::Cloud::Translate::Api.new(
            Google::Cloud::Translate::Service.new(
              project_id, nil, retries: retries, timeout: timeout, key: key
            )
          )
        end

        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        retries ||= configure.retries
        timeout ||= configure.timeout
        credentials ||= keyfile || default_credentials(scope: scope)
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Translate::Credentials.new credentials, scope: scope
        end

        Translate::Api.new(
          Translate::Service.new(
            project_id, credentials, retries: retries, timeout: timeout
          )
        )
      end

      ##
      # Configure the Google Cloud Translate library.
      #
      # The following Translate configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Translate project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Translate::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Translate library uses.
      #
      def self.configure
        yield Google::Cloud.configure.translate if block_given?

        Google::Cloud.configure.translate
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.translate.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.translate.credentials ||
          Google::Cloud.configure.credentials ||
          Translate::Credentials.default(scope: scope)
      end
    end
  end
end
