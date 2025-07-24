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
require "google/cloud/pubsub/publisher"
require "google/cloud/pubsub/subscriber"

module Google
  module Cloud
    module PubSub
      DEFAULT_COMPRESS = false
      DEFAULT_COMPRESSION_BYTES_THRESHOLD = 240

      ##
      # # Project
      #
      # Represents the project that pubsub messages are pushed to and pulled
      # from.
      #
      # {Google::Cloud::PubSub::V1::Topic} is a named resource to which
      # messages are sent by using {Publisher}.
      # {Google::Cloud::PubSub::V1::Subscription} is a named resource representing the stream
      # of messages from a single, specific topic, to be delivered to the
      # subscribing application via {Subscriber}. {Message} is a combination of data and
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
      #   publisher = pubsub.publisher "my-topic"
      #   publisher.publish "task completed"
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
        # Retrieve a client for managing subscriptions.
        #
        # @return [Google::Cloud::PubSub::V1::SubscriptionAdmin::Client]
        #
        def subscription_admin
          service.subscription_admin
        end

        ##
        # Retrieve a client for managing topics.
        #
        # @return [Google::Cloud::PubSub::V1::TopicAdmin::Client]
        #
        def topic_admin
          service.topic_admin
        end

        ##
        # Retrieve a client for managing schemas.
        #
        # @return [Google::Cloud::PubSub::V1::SchemaService::Client]
        #
        def schemas
          service.schemas
        end

        ##
        # Retrieve a client specific for Iam Policy related functions.
        #
        # @return [Google::Iam::V1::IAMPolicy::Client]
        #
        def iam
          service.iam
        end

        ##
        # Retrieves a Publisher by topic name or full project path.
        #
        # @param [String] topic_name Name of a topic. The value can be a simple
        #   topic ID (relative name) or a fully-qualified topic name.
        # @param [String] project The alternate project ID can be specified here.
        #   Optional. Not used if a fully-qualified topic name is provided
        #   for `topic_name`.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Publisher#publish_async}
        #   is called. Optional.
        #
        # @return [Google::Cloud::PubSub::Publisher]
        #
        def publisher topic_name, project: nil, async: nil
          ensure_service!
          options = { project: project, async: async }
          grpc = topic_admin.get_topic topic: service.topic_path(topic_name, options)
          Publisher.from_grpc grpc, service, async: async
        end

        ##
        # Retrieves a Subscriber by subscription name or full project path.
        #
        # @param [String] subscription_name Name of a subscription. The value can
        #   be a simple subscription ID (relative name) or a fully-qualified
        #   subscription name.
        # @param [String] project The alternate project ID can be specified here.
        #   Optional. Not used if a fully-qualified topic name is provided
        #   for `topic_name`.
        # @param [Boolean] skip_lookup Optionally create a {Google::Cloud::PubSub::V1::Subscription}
        #   object without verifying the subscription resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::PubSub::Subscriber, nil] Returns `nil` if
        #   the subscription does not exist.
        #
        def subscriber subscription_name, project: nil, skip_lookup: nil
          ensure_service!
          options = { project: project }
          return Subscriber.from_name subscription_name, service, options if skip_lookup
          grpc = subscription_admin.get_subscription subscription: service.subscription_path(subscription_name, options)
          Subscriber.from_grpc grpc, service
        end

        ##
        # Returns a fully-qualified project path in the form of
        #   `projects/{project_id}`
        # @param [String] project_name A project name. Optional.
        #   If provided, this will be used in place of the default `project_id`.
        #
        def project_path project_name: nil
          service.project_path options: { "project" => project_name }.compact
        end

        ##
        # Returns a fully-qualified topic path in the form of
        #   `projects/{project_id}/topics/{topic_name}`
        # @param [String] topic_name A topic name.
        # @param [String] project_name A project name. Optional.
        #   If provided, this will be used in place of the default `project_id`.
        #
        def topic_path topic_name, project_name: nil
          service.topic_path topic_name, options: { "project" => project_name }.compact
        end

        ##
        # Returns a fully-qualified subscription path in the form of
        #   `projects/{project_id}/subscriptions/{subscription_name}`
        # @param [String] subscription_name A subscription name.
        # @param [String] project_name A project name. Optional.
        #   If provided, this will be used in place of the default `project_id`.
        #
        def subscription_path subscription_name, project_name: nil
          service.subscription_path subscription_name, options: { "project" => project_name }.compact
        end

        ##
        # Returns a fully-qualified snapshot path in the form of
        #   `projects/{project_id}/snapshots/{snapshot_name}`
        # @param [String] snapshot_name A snapshot name.
        # @param [String] project_name A project name. Optional.
        #   If provided, this will be used in place of the default `project_id`.
        #
        def snapshot_path snapshot_name, project_name: nil
          service.snapshot_path snapshot_name, options: { "project" => project_name }.compact
        end

        ##
        # Returns a fully-qualified schema path in the form of
        #   `projects/{project_id}/schemas/{schema_name}`
        # @param [String] schema_name A schema name.
        # @param [String] project_name A project name. Optional.
        #   If provided, this will be used in place of the default `project_id`.
        #
        def schema_path schema_name, project_name: nil
          service.schema_path schema_name, options: { "project" => project_name }.compact
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
