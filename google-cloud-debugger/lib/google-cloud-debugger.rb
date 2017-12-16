# Copyright 2017 Google LLC
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
# Google::Cloud.debugger and Google::Cloud#debugger methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new debugger object for instrumenting Stackdriver Debugger for
    # an application. Each call creates a new debugger agent with independent
    # connection service.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] service_name Name for the debuggee application. Optional.
    # @param [String] service_version Version identifier for the debuggee
    #   application. Optional.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud_debugger`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Debugger::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   debugger = gcloud.debugger
    #
    #   debugger.start
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   debugger = gcloud.debugger scope: platform_scope
    #
    def debugger service_name: nil, service_version: nil, scope: nil,
                 timeout: nil, client_config: nil
      Google::Cloud.debugger @project, @keyfile,
                             service_name: service_name,
                             service_version: service_version,
                             scope: scope,
                             timeout: (timeout || @timeout),
                             client_config: client_config
    end

    ##
    # Creates a new debugger object for instrumenting Stackdriver Debugger for
    # an application. Each call creates a new debugger agent with independent
    # connection service.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Project identifier for the Stackdriver Debugger
    #   service you are connecting to. If not present, the default project for
    #   the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Debugger::Credentials})
    # @param [String] service_name Name for the debuggee application. Optional.
    # @param [String] service_version Version identifier for the debuggee
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud_debugger`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Debugger::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   debugger = Google::Cloud.debugger
    #
    #   debugger.start
    #
    def self.debugger project_id = nil, credentials = nil, service_name: nil,
                      service_version: nil, scope: nil, timeout: nil,
                      client_config: nil
      require "google/cloud/debugger"
      Google::Cloud::Debugger.new project_id: project_id,
                                  credentials: credentials,
                                  service_name: service_name,
                                  service_version: service_version,
                                  scope: scope, timeout: timeout,
                                  client_config: client_config
    end
  end
end
