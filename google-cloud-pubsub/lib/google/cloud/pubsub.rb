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


require "google-cloud-pubsub"
require "google/cloud/pubsub/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Pub/Sub
    #
    # Google Cloud Pub/Sub is designed to provide reliable, many-to-many,
    # asynchronous messaging between applications. Publisher applications can
    # send messages to a "topic" and other applications can subscribe to that
    # topic to receive the messages. By decoupling senders and receivers, Google
    # Cloud Pub/Sub allows developers to communicate between independently
    # written applications.
    #
    # See {file:OVERVIEW.md Google Cloud Pub/Sub Overview}.
    #
    module Pubsub
      ##
      # Creates a new object for connecting to the Pub/Sub service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Pub/Sub service
      #   you are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Pubsub::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/pubsub`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] emulator_host Pub/Sub emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Pubsub::Project]
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, emulator_host: nil, project: nil,
                   keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        emulator_host ||= configure.emulator_host
        if emulator_host
          return Pubsub::Project.new(
            Pubsub::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host, timeout: timeout,
              client_config: client_config
            )
          )
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Pubsub::Credentials.new credentials, scope: scope
        end

        Pubsub::Project.new(
          Pubsub::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Configure the Google Cloud Pubsub library.
      #
      # The following Pubsub configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Pubsub project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Pubsub::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["PUBSUB_EMULATOR_HOST"]`
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Pubsub library uses.
      #
      def self.configure
        yield Google::Cloud.configure.pubsub if block_given?

        Google::Cloud.configure.pubsub
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.pubsub.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.pubsub.credentials ||
          Google::Cloud.configure.credentials ||
          Pubsub::Credentials.default(scope: scope)
      end
    end
  end
end
