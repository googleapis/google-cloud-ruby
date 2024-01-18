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
    module PubSub
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
      #   Google::Auth::Credentials object. (See {PubSub::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/pubsub`
      # @param [Numeric] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] emulator_host Pub/Sub emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      # @param universe_domain [String] A custom universe domain. Optional.
      #
      # @return [Google::Cloud::PubSub::Project]
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      def self.new project_id: nil,
                   credentials: nil,
                   scope: nil,
                   timeout: nil,
                   universe_domain: nil,
                   endpoint: nil,
                   emulator_host: nil,
                   project: nil,
                   keyfile: nil
        project_id ||= (project || default_project_id)
        scope ||= configure.scope
        timeout ||= configure.timeout
        endpoint ||= configure.endpoint
        universe_domain ||= configure.universe_domain
        emulator_host ||= configure.emulator_host

        if emulator_host
          credentials = :this_channel_is_insecure
          endpoint = emulator_host
        else
          credentials ||= (keyfile || default_credentials(scope: scope))
          unless credentials.is_a? Google::Auth::Credentials
            credentials = PubSub::Credentials.new credentials, scope: scope
          end
        end

        project_id ||= credentials.project_id if credentials.respond_to? :project_id
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        service = PubSub::Service.new project_id, credentials,
                                      host: endpoint,
                                      timeout: timeout,
                                      universe_domain: universe_domain
        PubSub::Project.new service
      end

      ##
      # Configure the Google Cloud PubSub library.
      #
      # The following PubSub configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a PubSub project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {PubSub::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Numeric) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["PUBSUB_EMULATOR_HOST"]`
      # * `on_error` - (Proc) A Proc to be run when an error is encountered
      #   on a background thread. The Proc must take the error object as the
      #   single argument. (See {Subscriber.on_error}.)
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::PubSub library uses.
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
          PubSub::Credentials.default(scope: scope)
      end
    end

    ## Legacy veneer namespace
    Pubsub = PubSub unless const_defined? :Pubsub
  end
  ## Legacy generated client namespace
  Pubsub = Cloud::PubSub unless const_defined? :Pubsub
end
