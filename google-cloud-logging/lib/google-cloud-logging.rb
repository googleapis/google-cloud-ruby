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
# Google::Cloud.logging and Google::Cloud#logging methods can be available, but
# the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Stackdriver Logging service.
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
    #   * `https://www.googleapis.com/auth/logging.admin`
    #
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Logging::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   logging = gcloud.logging
    #
    #   entries = logging.entries
    #   entries.each do |e|
    #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
    #   end
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   logging = gcloud.logging scope: platform_scope
    #
    def logging scope: nil, timeout: nil, client_config: nil
      Google::Cloud.logging @project, @keyfile, scope: scope,
                                                timeout: (timeout || @timeout),
                                                client_config: client_config
    end

    ##
    # Creates a new object for connecting to the Stackdriver Logging service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Project identifier for the Stackdriver Logging
    #   service you are connecting to. If not present, the default project for
    #   the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Logging::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/logging.admin`
    #
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::Logging::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   logging = Google::Cloud.logging
    #
    #   entries = logging.entries
    #   entries.each do |e|
    #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
    #   end
    #
    def self.logging project_id = nil, credentials = nil, scope: nil,
                     timeout: nil, client_config: nil
      require "google/cloud/logging"
      Google::Cloud::Logging.new project_id: project_id,
                                 credentials: credentials,
                                 scope: scope, timeout: timeout,
                                 client_config: client_config
    end
  end
end

# Add logging to top-level configuration
Google::Cloud.configure do |config|
  unless config.field? :use_logging
    config.add_field! :use_logging, nil, enum: [true, false]
  end
end

# Set the default logging configuration
Google::Cloud.configure.add_config! :logging do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["LOGGING_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "LOGGING_CREDENTIALS", "LOGGING_CREDENTIALS_JSON",
      "LOGGING_KEYFILE", "LOGGING_KEYFILE_JSON"
    )
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
  config.add_field! :log_name, nil, match: String
  config.add_field! :log_name_map, nil, match: Hash
  config.add_field! :labels, nil, match: Hash
  config.add_config! :monitored_resource do |mrconfig|
    mrconfig.add_field! :type, nil, match: String
    mrconfig.add_field! :labels, nil, match: Hash
  end
end
