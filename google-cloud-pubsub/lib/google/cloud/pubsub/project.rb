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
require "google/cloud/env"
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/topic"
require "google/cloud/pubsub/batch_publisher"
require "google/cloud/pubsub/snapshot"

module Google
  module Cloud
    module Pubsub
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
      #   pubsub = Google::Cloud::Pubsub.new
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
        #   pubsub = Google::Cloud::Pubsub.new(
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
        # @private Default project.
        def self.default_project_id
          ENV["PUBSUB_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        ##
        # Retrieves topic by name.
        #
        # @param [String] topic_name Name of a topic.
        # @param [String] project If the topic belongs to a project other than
        #   the one currently connected to, the alternate project ID can be
        #   specified here. Optional.
        # @param [Boolean] skip_lookup Optionally create a {Topic} object
        #   without verifying the topic resource exists on the Pub/Sub service.
        #   Calls made on this object will raise errors if the topic resource
        #   does not exist. Default is `false`. Optional.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Topic#publish_async}
        #   is called. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #   * `:max_bytes` (Integer) The maximum size of messages to be
        #     collected before the batch is published. Default is 10,000,000
        #     (10MB).
        #   * `:max_messages` (Integer) The maximum number of messages to be
        #     collected before the batch is published. Default is 1,000.
        #   * `:interval` (Numeric) The number of seconds to collect messages
        #     before the batch is published. Default is 0.25.
        #   * `:threads` (Hash) The number of threads to create to handle
        #     concurrent calls by the publisher:
        #     * `:publish` (Integer) The number of threads used to publish
        #       messages. Default is 4.
        #     * `:callback` (Integer) The number of threads to handle the
        #       published messages' callbacks. Default is 8.
        #
        # @return [Google::Cloud::Pubsub::Topic, nil] Returns `nil` if topic
        #   does not exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "existing-topic"
        #
        # @example By default `nil` will be returned if topic does not exist.
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "non-existing-topic" # nil
        #
        # @example Create topic in a different project with the `project` flag.
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "another-topic", project: "another-project"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "another-topic", skip_lookup: true
        #
        # @example Configuring AsyncPublisher to increase concurrent callbacks:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "my-topic",
        #                        async: { threads: { callback: 16 } }
        #
        #   topic.publish_async "task completed" do |result|
        #     if result.succeeded?
        #       log_publish_success result.data
        #     else
        #       log_publish_failure result.data, result.error
        #     end
        #   end
        #
        #   topic.async_publisher.stop.wait!
        #
        def topic topic_name, project: nil, skip_lookup: nil, async: nil
          ensure_service!
          options = { project: project }
          return Topic.new_lazy(topic_name, service, options) if skip_lookup
          grpc = service.get_topic topic_name
          Topic.from_grpc grpc, service, async: async
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_topic topic
        alias find_topic topic

        ##
        # Creates a new topic.
        #
        # @param [String] topic_name Name of a topic.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Topic#publish_async}
        #   is called. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #   * `:max_bytes` (Integer) The maximum size of messages to be
        #     collected before the batch is published. Default is 10,000,000
        #     (10MB).
        #   * `:max_messages` (Integer) The maximum number of messages to be
        #     collected before the batch is published. Default is 1,000.
        #   * `:interval` (Numeric) The number of seconds to collect messages
        #     before the batch is published. Default is 0.25.
        #   * `:threads` (Hash) The number of threads to create to handle
        #     concurrent calls by the publisher:
        #     * `:publish` (Integer) The number of threads used to publish
        #       messages. Default is 4.
        #     * `:callback` (Integer) The number of threads to handle the
        #       published messages' callbacks. Default is 8.
        #
        # @return [Google::Cloud::Pubsub::Topic]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.create_topic "my-topic"
        #
        def create_topic topic_name, async: nil
          ensure_service!
          grpc = service.create_topic topic_name
          Topic.from_grpc grpc, service, async: async
        end
        alias new_topic create_topic

        ##
        # Retrieves a list of topics for the given project.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `topics`; indicates that this is a continuation of a call, and that
        #   the system should return the next page of data.
        # @param [Integer] max Maximum number of topics to return.
        #
        # @return [Array<Google::Cloud::Pubsub::Topic>] (See
        #   {Google::Cloud::Pubsub::Topic::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topics = pubsub.topics
        #   topics.each do |topic|
        #     puts topic.name
        #   end
        #
        # @example Retrieve all topics: (See {Topic::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topics = pubsub.topics
        #   topics.all do |topic|
        #     puts topic.name
        #   end
        #
        def topics token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_topics options
          Topic::List.from_grpc grpc, service, max
        end
        alias find_topics topics
        alias list_topics topics

        ##
        # Retrieves subscription by name.
        #
        # @param [String] subscription_name Name of a subscription.
        # @param [String] project If the subscription belongs to a project other
        #   than the one currently connected to, the alternate project ID can be
        #   specified here.
        # @param [Boolean] skip_lookup Optionally create a {Subscription} object
        #   without verifying the subscription resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::Pubsub::Subscription, nil] Returns `nil` if
        #   the subscription does not exist
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-sub"
        #   sub.name #=> "projects/my-project/subscriptions/my-sub"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   # No API call is made to retrieve the subscription information.
        #   sub = pubsub.subscription "my-sub", skip_lookup: true
        #   sub.name #=> "projects/my-project/subscriptions/my-sub"
        #
        def subscription subscription_name, project: nil, skip_lookup: nil
          ensure_service!
          options = { project: project }
          if skip_lookup
            return Subscription.new_lazy subscription_name, service, options
          end
          grpc = service.get_subscription subscription_name
          Subscription.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_subscription subscription
        alias find_subscription subscription

        ##
        # Retrieves a list of subscriptions for the given project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of subscriptions to return.
        #
        # @return [Array<Google::Cloud::Pubsub::Subscription>] (See
        #   {Google::Cloud::Pubsub::Subscription::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   subs = pubsub.subscriptions
        #   subs.each do |sub|
        #     puts sub.name
        #   end
        #
        # @example Retrieve all subscriptions: (See {Subscription::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   subs = pubsub.subscriptions
        #   subs.all do |sub|
        #     puts sub.name
        #   end
        #
        def subscriptions token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_subscriptions options
          Subscription::List.from_grpc grpc, service, max
        end
        alias find_subscriptions subscriptions
        alias list_subscriptions subscriptions


        ##
        # Retrieves a list of snapshots for the given project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of snapshots to return.
        #
        # @return [Array<Google::Cloud::Pubsub::Snapshot>] (See
        #   {Google::Cloud::Pubsub::Snapshot::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   snapshots = pubsub.snapshots
        #   snapshots.each do |snapshot|
        #     puts snapshot.name
        #   end
        #
        # @example Retrieve all snapshots: (See {Snapshot::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   snapshots = pubsub.snapshots
        #   snapshots.all do |snapshot|
        #     puts snapshot.name
        #   end
        #
        def snapshots token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_snapshots options
          Snapshot::List.from_grpc grpc, service, max
        end
        alias find_snapshots snapshots
        alias list_snapshots snapshots

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # Call the publish API with arrays of data data and attrs.
        def publish_batch_messages topic_name, batch
          grpc = service.publish topic_name, batch.messages
          batch.to_gcloud_messages Array(grpc.message_ids)
        end
      end
    end
  end
end
