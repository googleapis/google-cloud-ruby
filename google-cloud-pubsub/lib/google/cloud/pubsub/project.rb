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


require "google/cloud/errors"
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/topic"
require "google/cloud/pubsub/batch_publisher"
require "google/cloud/pubsub/schema"
require "google/cloud/pubsub/snapshot"

module Google
  module Cloud
    module PubSub
      DEFAULT_COMPRESS = false
      DEFAULT_COMPRESSION_BYTES_THRESHOLD = 240

      ##
      # # Project
      #
      # Represents the project that pubsub messages are pushed to and pulled
      # from. {Topic} is a named resource to which messages are sent by
      # publishers. {Subscription} is a named resource representing the stream
      # of messages from a single, specific topic, to be delivered to the
      # subscribing application. {Message} is a combination of data and
      # attributes that a publisher sends to a topic and is eventually delivered
      # to subscribers.
      #
      # See {Google::Cloud#pubsub}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Pub/Sub Project instance.
        def initialize service
          @service = service
        end

        # The Pub/Sub project connected to.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   pubsub.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # The universe domain the client is connected to
        #
        # @return [String]
        #
        def universe_domain
          service.universe_domain
        end

        ##
        # Retrieve a client for managing topics.
        #
        # @return [Google::Cloud::PubSub::V1::TopicAdmin::Client]
        #
        def topic_admin_client
          return mocked_topic_admin if mocked_topic_admin
          @topic_admin_client ||= V1::TopicAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_topic_admin

        ##
        # Retrieve a client for managing subscriptions.
        #
        # @return [Google::Cloud::PubSub::V1::SubscriptionAdmin::Client]
        #
        def subscription_admin_client
          return mocked_subscription_admin if mocked_subscription_admin
          @subscription_admin_client ||= V1::SubscriptionAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_subscription_admin

        ##
        # Retrieve a client for managing schemas.
        #
        # @return [Google::Cloud::PubSub::V1::SchemaAdmin::Client]
        #
        def schema_admin_client
          return mocked_schema_admin if mocked_schema_admin
          @schema_admin_client ||= V1::SchemaAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_schema_admin


        def project_path options = {}
          project_name = options[:project] || project
          "projects/#{project_name}"
        end

        def publisher_path topic_name, options = {}
          return topic_name if topic_name.to_s.include? "/"
          "#{project_path options}/topics/#{topic_name}"
        end

        ##
        # Retrieves a Publisher by topic name or full project path.
        #
        # @param [String] topic_name Name of a topic. The value can be a simple
        #   topic ID (relative name), in which case the current project ID will
        #   be supplied, or a fully-qualified topic name in the form
        #   `projects/{project_id}/topics/{topic_id}`.
        # @param [String] project If the topic belongs to a project other than
        #   the one currently connected to, the alternate project ID can be
        #   specified here. Optional. Not used if a fully-qualified topic name
        #   is provided for `topic_name`.
        # @param [Boolean] skip_lookup Optionally create a {Publisher} object
        #   without verifying the topic resource exists on the Pub/Sub service.
        #   Calls made on this object will raise errors if the topic resource
        #   does not exist. Default is `false`. Optional.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Publisher#publish_async}
        #   is called. Optional.
        #
        # @return [Google::Cloud::PubSub::Publisher]
        #
        def publisher topic_name, project: nil, skip_lookup: nil, async: nil
          ensure_service!
          options = { project: project, async: async }
          return Publisher.from_name topic_name, service, options if skip_lookup
          grpc = topic_admin_client.get_topic topic: publisher_path(topic_name, options)
          Publisher.from_grpc grpc
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
