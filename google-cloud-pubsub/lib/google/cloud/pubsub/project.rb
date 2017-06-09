# Copyright 2015 Google Inc. All rights reserved.
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


require "google/cloud/errors"
require "google/cloud/env"
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/topic"
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
        #     project: "my-project",
        #     keyfile: "/path/to/keyfile.json"
        #   )
        #
        #   pubsub.project #=> "my-project"
        #
        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
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
        #   specified here.
        # @param [Boolean] skip_lookup Optionally create a {Topic} object
        #   without verifying the topic resource exists on the Pub/Sub service.
        #   Calls made on this object will raise errors if the topic resource
        #   does not exist. Default is `false`.
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
        def topic topic_name, project: nil, skip_lookup: nil
          ensure_service!
          options = { project: project }
          return Topic.new_lazy(topic_name, service, options) if skip_lookup
          grpc = service.get_topic topic_name
          Topic.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias_method :get_topic, :topic
        alias_method :find_topic, :topic

        ##
        # Creates a new topic.
        #
        # @param [String] topic_name Name of a topic.
        #
        # @return [Google::Cloud::Pubsub::Topic]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.create_topic "my-topic"
        #
        def create_topic topic_name
          ensure_service!
          grpc = service.create_topic topic_name
          Topic.from_grpc grpc, service
        end
        alias_method :new_topic, :create_topic

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
        alias_method :find_topics, :topics
        alias_method :list_topics, :topics

        ##
        # Publishes one or more messages to the given topic.
        #
        # @param [String] topic_name Name of a topic.
        # @param [String, File] data The message data.
        # @param [Hash] attributes Optional attributes for the message.
        # @yield [publisher] a block for publishing multiple messages in one
        #   request
        # @yieldparam [Topic::Publisher] publisher the topic publisher object
        #
        # @return [Message, Array<Message>] Returns the published message when
        #   called without a block, or an array of messages when called with a
        #   block.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   msg = pubsub.publish "my-topic", "task completed"
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   msg = pubsub.publish "my-topic", File.open("message.txt")
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   msg = pubsub.publish "my-topic", "task completed", foo: :bar,
        #                                                   this: :that
        #
        # @example Multiple messages can be sent at the same time using a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   msgs = pubsub.publish "my-topic" do |p|
        #     p.publish "task 1 completed", foo: :bar
        #     p.publish "task 2 completed", foo: :baz
        #     p.publish "task 3 completed", foo: :bif
        #   end
        #
        def publish topic_name, data = nil, attributes = {}
          # Fix parameters
          if data.is_a?(::Hash) && attributes.empty?
            attributes = data
            data = nil
          end
          ensure_service!
          publisher = Topic::Publisher.new data, attributes
          yield publisher if block_given?
          return nil if publisher.messages.count.zero?
          publish_batch_messages topic_name, publisher
        end

        ##
        # Creates a new {Subscription} object for the provided topic.
        #
        # @param [String] topic_name Name of a topic.
        # @param [String] subscription_name Name of the new subscription. Must
        #   start with a letter, and contain only letters ([A-Za-z]), numbers
        #   ([0-9], dashes (-), underscores (_), periods (.), tildes (~), plus
        #   (+) or percent signs (%). It must be between 3 and 255 characters in
        #   length, and it must not start with "goog".
        # @param [Integer] deadline The maximum number of seconds after a
        #   subscriber receives a message before the subscriber should
        #   acknowledge the message.
        # @param [Boolean] retain_acked Indicates whether to retain acknowledged
        #   messages. If `true`, then messages are not expunged from the
        #   subscription's backlog, even if they are acknowledged, until they
        #   fall out of the `retention_duration` window. Default is `false`.
        # @param [Numeric] retention How long to retain unacknowledged messages
        #   in the subscription's backlog, from the moment a message is
        #   published. If `retain_acked` is `true`, then this also configures
        #   the retention of acknowledged messages, and thus configures how far
        #   back in time a {#seek} can be done. Cannot be more than 604,800
        #   seconds (7 days) or less than 600 seconds (10 minutes). Default is
        #   604,800 seconds (7 days).
        # @param [String] endpoint A URL locating the endpoint to which messages
        #   should be pushed.
        #
        # @return [Google::Cloud::Pubsub::Subscription]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscribe "my-topic", "my-topic-sub"
        #   sub.name #=> "my-topic-sub"
        #
        # @example Wait 2 minutes for acknowledgement and push all to endpoint:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscribe "my-topic", "my-topic-sub",
        #                          deadline: 120,
        #                          endpoint: "https://example.com/push"
        #
        def subscribe topic_name, subscription_name, deadline: nil,
                      retain_acked: false, retention: nil, endpoint: nil
          ensure_service!
          options = { deadline: deadline, retain_acked: retain_acked,
                      retention: retention, endpoint: endpoint }
          grpc = service.create_subscription topic_name,
                                             subscription_name, options
          Subscription.from_grpc grpc, service
        end
        alias_method :create_subscription, :subscribe
        alias_method :new_subscription, :subscribe

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
        alias_method :get_subscription, :subscription
        alias_method :find_subscription, :subscription

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
        alias_method :find_subscriptions, :subscriptions
        alias_method :list_subscriptions, :subscriptions


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
        alias_method :find_snapshots, :snapshots
        alias_method :list_snapshots, :snapshots

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
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
