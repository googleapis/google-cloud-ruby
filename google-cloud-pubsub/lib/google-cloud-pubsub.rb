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
# Google::Cloud.pubsub and Google::Cloud#pubsub methods can be available, but
# the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Pub/Sub service.
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
    #   * `https://www.googleapis.com/auth/pubsub`
    # @param [Numeric] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::PubSub::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   pubsub = gcloud.pubsub
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   pubsub = gcloud.pubsub scope: platform_scope
    #
    def pubsub scope: nil, timeout: nil
      timeout ||= @timeout
      Google::Cloud.pubsub @project, @keyfile, scope: scope, timeout: timeout
    end

    ##
    # Creates a new object for connecting to the Pub/Sub service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String] project_id Project identifier for the Pub/Sub service you
    #   are connecting to. If not present, the default project for the
    #   credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object.
    #   (See {Google::Cloud::PubSub::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/pubsub`
    # @param [Numeric] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::PubSub::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   pubsub = Google::Cloud.pubsub
    #
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    def self.pubsub project_id = nil,
                    credentials = nil,
                    scope: nil,
                    timeout: nil
      require "google/cloud/pubsub"
      Google::Cloud::PubSub.new project_id: project_id, credentials: credentials, scope: scope, timeout: timeout
    end
  end
end

# Set the default pubsub configuration
Google::Cloud.configure.add_config! :pubsub do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["PUBSUB_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "PUBSUB_CREDENTIALS", "PUBSUB_CREDENTIALS_JSON", "PUBSUB_KEYFILE", "PUBSUB_KEYFILE_JSON"
    )
  end
  default_emulator = Google::Cloud::Config.deferred do
    ENV["PUBSUB_EMULATOR_HOST"]
  end
  default_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/pubsub"
  ]

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds, match: [String, Hash, Google::Auth::Credentials], allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, default_scopes, match: [String, Array]
  config.add_field! :quota_project, nil, match: String
  config.add_field! :timeout, nil, match: Numeric
  config.add_field! :emulator_host, default_emulator, match: String, allow_nil: true
  config.add_field! :on_error, nil, match: Proc
  config.add_field! :endpoint, "pubsub.googleapis.com", match: String
end
