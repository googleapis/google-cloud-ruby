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
# Google::Cloud.spanner and Google::Cloud#spanner methods can be available, but
# the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Spanner service.
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
    #   The default scopes are:
    #
    #   * `https://www.googleapis.com/auth/spanner`
    #   * `https://www.googleapis.com/auth/spanner.data`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [String] lib_name Library name. This will be added as a prefix
    #   to the API call tracking header `x-goog-api-client` with provided
    #   lib version for telemetry. Optional. For example prefix looks like
    #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
    #   `spanner-activerecord/0.0.1` is provided custom library name and
    #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
    #   with version.
    # @param [String] lib_version Library version. This will be added as a
    #   prefix to the API call tracking header `x-goog-api-client` with
    #   provided lib name for telemetry. Optional. For example prefix look like
    #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
    #   `spanner-activerecord/0.0.1` is provided custom library name and
    #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
    #   with version.
    #
    # @return [Google::Cloud::Spanner::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   spanner = gcloud.spanner
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   spanner = gcloud.spanner scope: platform_scope
    #
    def spanner scope: nil, timeout: nil, lib_name: nil, lib_version: nil
      Google::Cloud.spanner @project, @keyfile, scope: scope,
                                                timeout: (timeout || @timeout),
                                                lib_name: lib_name,
                                                lib_version: lib_version
    end

    ##
    # Creates a new object for connecting to the Spanner service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String] project_id Project identifier for the Spanner service you
    #   are connecting to. If not present, the default project for the
    #   credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Spanner::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scopes are:
    #
    #   * `https://www.googleapis.com/auth/spanner`
    #   * `https://www.googleapis.com/auth/spanner.data`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [String] lib_name Library name. This will be added as a prefix
    #   to the API call tracking header `x-goog-api-client` with provided
    #   lib version for telemetry. Optional. For example prefix looks like
    #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
    #   `spanner-activerecord/0.0.1` is provided custom library name and
    #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
    #   with version.
    # @param [String] lib_version Library version. This will be added as a
    #   prefix to the API call tracking header `x-goog-api-client` with
    #   provided lib name for telemetry. Optional. For example prefix look like
    #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
    #   `spanner-activerecord/0.0.1` is provided custom library name and
    #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
    #   with version.
    #
    # @return [Google::Cloud::Spanner::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   spanner = Google::Cloud.spanner
    #
    def self.spanner project_id = nil, credentials = nil, scope: nil,
                     timeout: nil, lib_name: nil, lib_version: nil
      require "google/cloud/spanner"
      Google::Cloud::Spanner.new project_id: project_id,
                                 credentials: credentials,
                                 scope: scope, timeout: timeout,
                                 lib_name: lib_name, lib_version: lib_version
    end
  end
end

# rubocop:disable Metrics/BlockLength

# Set the default spanner configuration
Google::Cloud.configure.add_config! :spanner do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["SPANNER_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "SPANNER_CREDENTIALS", "SPANNER_CREDENTIALS_JSON",
      "SPANNER_KEYFILE", "SPANNER_KEYFILE_JSON"
    )
  end
  default_emulator = Google::Cloud::Config.deferred do
    ENV["SPANNER_EMULATOR_HOST"]
  end

  default_query_options = Google::Cloud::Config.deferred do
    query_options = {}
    optimizer_version = ENV["SPANNER_OPTIMIZER_VERSION"]
    query_options[:optimizer_version] = optimizer_version if optimizer_version
    query_options = nil if query_options.empty?
    query_options
  end

  default_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/spanner.admin",
    "https://www.googleapis.com/auth/spanner.data"
  ]

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, default_scopes, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :endpoint, "spanner.googleapis.com", match: String
  config.add_field! :emulator_host, default_emulator, match: String, allow_nil: true
  config.add_field! :lib_name, nil, match: String, allow_nil: true
  config.add_field! :lib_version, nil, match: String, allow_nil: true
  config.add_field! :query_options, default_query_options, match: Hash, allow_nil: true
end

# rubocop:enable Metrics/BlockLength
