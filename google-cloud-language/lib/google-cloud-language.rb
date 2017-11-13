# Copyright 2016 Google Inc. All rights reserved.
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

##
# This file is here to be autorequired by bundler, so that the
# Google::Cloud.language and Google::Cloud#language methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Natural Language API.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `"https://www.googleapis.com/auth/cloud-platform"`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Language::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   language = gcloud.language
    #
    #   content = "Star Wars is a great movie. The Death Star is fearsome."
    #   document = language.document content
    #   annotation = document.annotate
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   language = gcloud.language scope: platform_scope
    #
    def language scope: nil, timeout: nil, client_config: nil
      Google::Cloud.language @project, @keyfile,
                             scope: scope, timeout: (timeout || @timeout),
                             client_config: client_config
    end

    ##
    # Creates a new object for connecting to the Natural Language API.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Identifier for a Natural Language project. If
    #   not present, the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Language::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `"https://www.googleapis.com/auth/cloud-platform"`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Language::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   language = Google::Cloud.language
    #
    #   content = "Star Wars is a great movie. The Death Star is fearsome."
    #   document = language.document content
    #   annotation = document.annotate
    #
    def self.language project_id = nil, credentials = nil, scope: nil,
                      timeout: nil, client_config: nil
      require "google/cloud/language"
      Google::Cloud::Language.new project_id: project_id,
                                  credentials: credentials,
                                  scope: scope, timeout: timeout,
                                  client_config: client_config
    end
  end
end
