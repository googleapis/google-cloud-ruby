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
# This file is here to be autorequired by bundler, so that the .language and
# #language methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Language service.
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
    # @param [Integer] retries This option is not currently supported.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Language::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   language = gcloud.language
    #
    #   content = "Darth Vader is the best villain in Star Wars."
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
    def language scope: nil, retries: nil, timeout: nil
      Google::Cloud.language @project, @keyfile, scope: scope,
                                                 retries: (retries || @retries),
                                                 timeout: (timeout || @timeout)
    end

    ##
    # Creates a new object for connecting to the Language service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project Project identifier for the Language service you
    #   are connecting to.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `"https://www.googleapis.com/auth/cloud-platform"`
    # @param [Integer] retries  This option is not currently supported.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Language::Project]
    #
    # @example
    #   require "google/cloud/language"
    #
    #   language = Google::Cloud.language
    #
    #   content = "Darth Vader is the best villain in Star Wars."
    #   document = language.document content
    #   annotation = document.annotate
    #
    def self.language project = nil, keyfile = nil, scope: nil, retries: nil,
                      timeout: nil
      require "google/cloud/language"
      project ||= Google::Cloud::Language::Project.default_project
      if keyfile.nil?
        credentials = Google::Cloud::Language::Credentials.default scope: scope
      else
        credentials = Google::Cloud::Language::Credentials.new(
          keyfile, scope: scope)
      end
      Google::Cloud::Language::Project.new(
        Google::Cloud::Language::Service.new(
          project, credentials, retries: retries, timeout: timeout))
    end
  end
end
