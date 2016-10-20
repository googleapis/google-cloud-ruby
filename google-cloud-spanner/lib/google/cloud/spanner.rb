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


require "google-cloud-spanner"
require "google/cloud/spanner/project"

module Google
  module Cloud
    ##
    # # Google Cloud Spanner
    #
    module Spanner
      ##
      # Creates a new object for connecting to the Spanner service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project Project identifier for the Spanner service you
      #   are connecting to.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
      #   file path the file must be readable.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scopes are:
      #
      #   * `https://www.googleapis.com/auth/spanner`
      #   * `https://www.googleapis.com/auth/spanner.data`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      #
      # @return [Google::Cloud::Spanner::Project]
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      def self.new project: nil, keyfile: nil, scope: nil, timeout: nil,
                   client_config: nil
        project ||= Google::Cloud::Spanner::Project.default_project
        if keyfile.nil?
          credentials = Google::Cloud::Spanner::Credentials.default scope: scope
        else
          credentials = Google::Cloud::Spanner::Credentials.new(
            keyfile, scope: scope)
        end
        Google::Cloud::Spanner::Project.new(
          Google::Cloud::Spanner::Service.new(
            project, credentials, timeout: timeout,
                                  client_config: client_config))
      end
    end
  end
end
