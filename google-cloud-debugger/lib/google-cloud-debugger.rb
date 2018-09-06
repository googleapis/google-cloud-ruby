# Copyright 2017 Google LLC
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
# Google::Cloud.debugger and Google::Cloud#debugger methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new debugger object for instrumenting Stackdriver Debugger for
    # an application. Each call creates a new debugger agent with independent
    # connection service.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
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
    #   * `https://www.googleapis.com/auth/logging.admin`
    #
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
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
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
    #   * `https://www.googleapis.com/auth/logging.admin`
    #
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

# Add debugger to top-level configuration
Google::Cloud.configure do |config|
  unless config.field? :use_debugger
    config.add_field! :use_debugger, nil, enum: [true, false]
  end
  unless config.field? :service_name
    config.add_field! :service_name, nil, match: String
  end
  unless config.field? :service_version
    config.add_field! :service_version, nil, match: String
  end
end

# Set the default debugger configuration
Google::Cloud.configure.add_config! :debugger do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["DEBUGGER_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env \
      "DEBUGGER_CREDENTIALS", "DEBUGGER_CREDENTIALS_JSON",
      "DEBUGGER_KEYFILE", "DEBUGGER_KEYFILE_JSON"
  end
  default_service = Google::Cloud::Config.deferred do
    ENV["DEBUGGER_SERVICE_NAME"]
  end
  default_version = Google::Cloud::Config.deferred do
    ENV["DEBUGGER_SERVICE_VERSION"]
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :service_name, default_service,
                    match: String, allow_nil: true
  config.add_field! :service_version, default_version,
                    match: String, allow_nil: true
  config.add_field! :app_root, nil, match: String
  config.add_field! :root, nil, match: String
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
  config.add_field! :allow_mutating_methods, false
  config.add_field! :evaluation_time_limit, 0.05, match: Numeric
end
