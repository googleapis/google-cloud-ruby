# Copyright 2015 Google LLC
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


require "google-cloud-resource_manager"
require "google/cloud/resource_manager/manager"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Resource Manager
    #
    # The Resource Manager API provides methods that you can use to
    # programmatically manage your projects in the Google Cloud Platform.
    #
    # See {file:OVERVIEW.md Resource Manager Overview}.
    #
    module ResourceManager
      ##
      # Creates a new `Project` instance connected to the Resource Manager
      # service. Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {ResourceManager::Credentials})
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
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::ResourceManager::Manager]
      #
      # @example
      #   require "google/cloud/resource_manager"
      #
      #   resource_manager = Google::Cloud::ResourceManager.new
      #   resource_manager.projects.each do |project|
      #     puts projects.project_id
      #   end
      #
      def self.new credentials: nil, scope: nil, retries: nil, timeout: nil,
                   keyfile: nil
        scope ||= configure.scope
        retries ||= configure.retries
        timeout ||= configure.timeout
        credentials ||= keyfile
        credentials ||= default_credentials(scope: scope)
        unless credentials.is_a? Google::Auth::Credentials
          credentials = ResourceManager::Credentials.new credentials,
                                                         scope: scope
        end

        ResourceManager::Manager.new(
          ResourceManager::Service.new(
            credentials, retries: retries, timeout: timeout
          )
        )
      end

      ##
      # Configure the Google Cloud Resource Manager library.
      #
      # The following Resource Manager configuration parameters are supported:
      #
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {ResourceManager::Credentials})
      #   (The parameter `keyfile` is also available but deprecated.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::ResourceManager library uses.
      #
      def self.configure
        yield Google::Cloud.configure.resource_manager if block_given?

        Google::Cloud.configure.resource_manager
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.resource_manager.credentials ||
          Google::Cloud.configure.credentials ||
          ResourceManager::Credentials.default(scope: scope)
      end
    end
  end
end
