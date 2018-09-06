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

##
# This file is here to be autorequired by bundler, so that the
# Google::Cloud.resource_manager and Google::Cloud#resource_manager methods can
# be available, but the library and all dependencies won't be loaded until
# required and used.


gem "google-cloud-core"
require "google/cloud"
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Resource Manager service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::ResourceManager::Manager]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   resource_manager = gcloud.resource_manager
    #   resource_manager.projects.each do |project|
    #     puts projects.project_id
    #   end
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   readonly_scope = \
    #     "https://www.googleapis.com/auth/cloudresourcemanager.readonly"
    #   resource_manager = gcloud.resource_manager scope: readonly_scope
    #
    def resource_manager scope: nil, retries: nil, timeout: nil
      Google::Cloud.resource_manager @keyfile, scope: scope,
                                               retries: (retries || @retries),
                                               timeout: (timeout || @timeout)
    end

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
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::ResourceManager::Manager]
    #
    # @example
    #   require "google/cloud"
    #
    #   resource_manager = Google::Cloud.resource_manager
    #   resource_manager.projects.each do |project|
    #     puts projects.project_id
    #   end
    #
    def self.resource_manager credentials = nil, scope: nil, retries: nil,
                              timeout: nil
      require "google/cloud/resource_manager"
      Google::Cloud::ResourceManager.new credentials: credentials, scope: scope,
                                         retries: retries, timeout: timeout
    end
  end
end

# Set the default resource manager configuration
Google::Cloud.configure.add_config! :resource_manager do |config|
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "RESOURCE_MANAGER_CREDENTIALS", "RESOURCE_MANAGER_CREDENTIALS_JSON",
      "RESOURCE_MANAGER_KEYFILE", "RESOURCE_MANAGER_KEYFILE_JSON"
    )
  end

  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :retries, nil, match: Integer
  config.add_field! :timeout, nil, match: Integer
end
