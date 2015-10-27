#--
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

require "gcloud/gce"
require "gcloud/pubsub/connection"
require "gcloud/pubsub/credentials"
require "gcloud/pubsub/errors"
require "gcloud/pubsub/topic"

module Gcloud
  module Pubsub
    ##
    # = Project
    #
    # Represents the project that pubsub messages are pushed to and pulled from.
    # Topic is a named resource to which messages are sent by publishers.
    # Subscription is a named resource representing the stream of messages from
    # a single, specific topic, to be delivered to the subscribing application.
    # Message is a combination of data and attributes that a publisher sends to
    # a topic and is eventually delivered to subscribers.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    # See Gcloud#pubsub
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials #:nodoc:
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      # The Pub/Sub project connected to.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #   pubsub = gcloud.pubsub
      #
      #   pubsub.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["PUBSUB_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      # rubocop:disable Metrics/AbcSize
      # Disabled rubocop because there isn't much benefit to adding indirection

      ##
      # Retrieves topic by name.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:autocreate]</code>::
      #   Flag to control whether the requested topic will be created if it does
      #   not exist. The default value is +false+. (+Boolean+)
      # <code>options[:project]</code>::
      #   If the topic belongs to a project other than the one currently
      #   connected to, the alternate project ID can be specified here.
      #   (+String+)
      # <code>options[:skip_lookup]</code>::
      #   Optionally create a Topic object without verifying the topic resource
      #   exists on the Pub/Sub service. Calls made on this object will raise
      #   errors if the topic resource does not exist. Default is +false+.
      #   (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Topic or nil if topic does not exist. Will return a
      # newly created Gcloud::Pubsub::Topic if the topic does not exist and
      # +autocreate+ is set to +true+.
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "existing-topic"
      #
      # By default +nil+ will be returned if the topic does not exist.
      # the topic will be created in Pub/Sub when needed.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "non-existing-topic" #=> nil
      #
      # The topic will be created if the topic does not exist and the
      # +autocreate+ option is set to true.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "non-existing-topic", autocreate: true
      #
      # A topic in a different project can be created using the +project+ flag.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "another-topic", project: "another-project"
      #
      # The lookup against the Pub/Sub service can be skipped using the
      # +skip_lookup+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "another-topic", skip_lookup: true
      #
      def topic topic_name, options = {}
        ensure_connection!
        return Topic.new_lazy(topic_name, connection) if options[:skip_lookup]
        resp = connection.get_topic topic_name
        return Topic.from_gapi(resp.data, connection) if resp.success?
        if resp.status == 404
          return create_topic(topic_name) if options[:autocreate]
          return nil
        end
        fail ApiError.from_response(resp)
      end
      alias_method :get_topic, :topic
      alias_method :find_topic, :topic

      # rubocop:enable Metrics/AbcSize

      ##
      # Creates a new topic.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Topic
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.create_topic "my-topic"
      #
      def create_topic topic_name
        ensure_connection!
        resp = connection.create_topic topic_name
        if resp.success?
          Topic.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :new_topic, :create_topic

      ##
      # Retrieves a list of topics for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      #   (+String+)
      # <code>options[:token]</code>::
      #   The +token+ value returned by the last call to +topics+; indicates
      #   that this is a continuation of a call, and that the system should
      #   return the next page of data. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of topics to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Pubsub::Topic (Gcloud::Pubsub::Topic::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topics = pubsub.topics
      #   topics.each do |topic|
      #     puts topic.name
      #   end
      #
      # If you have a significant number of topics, you may need to paginate
      # through them: (See Topic::List#token)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   all_topics = []
      #   tmp_topics = pubsub.topics
      #   while tmp_topics.any? do
      #     tmp_topics.each do |topic|
      #       all_topics << topic
      #     end
      #     # break loop if no more topics available
      #     break if tmp_topics.token.nil?
      #     # get the next group of topics
      #     tmp_topics = pubsub.topics token: tmp_topics.token
      #   end
      #
      def topics options = {}
        ensure_connection!
        resp = connection.list_topics options
        if resp.success?
          Topic::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_topics, :topics
      alias_method :list_topics, :topics

      ##
      # Publishes one or more messages to the given topic.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      # +data+::
      #   The message data. (+String+)
      # +attributes+::
      #   Optional attributes for the message. (+Hash+)
      # <code>attributes[:autocreate]</code>::
      #   Flag to control whether the provided topic will be created if it does
      #   not exist.
      #
      # === Returns
      #
      # Message object when called without a block,
      # Array of Message objects when called with a block
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   msg = pubsub.publish "my-topic", "new-message"
      #
      # Additionally, a message can be published with attributes:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   msg = pubsub.publish "my-topic", "new-message", foo: :bar,
      #                                                   this: :that
      #
      # Multiple messages can be published at the same time by passing a block:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   msgs = pubsub.publish "my-topic" do |batch|
      #     batch.publish "new-message-1", foo: :bar
      #     batch.publish "new-message-2", foo: :baz
      #     batch.publish "new-message-3", foo: :bif
      #   end
      #
      # Additionally, the topic will be created if the topic does previously not
      # exist and the +autocreate+ option is provided.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   msg = pubsub.publish "new-topic", "new-message", autocreate: true
      #
      def publish topic_name, data = nil, attributes = {}
        # Fix parameters
        if data.is_a?(::Hash) && attributes.empty?
          attributes = data
          data = nil
        end
        # extract autocreate option
        autocreate = attributes.delete :autocreate
        ensure_connection!
        batch = Topic::Batch.new data, attributes
        yield batch if block_given?
        return nil if batch.messages.count.zero?
        publish_batch_messages topic_name, batch, autocreate
      end

      # rubocop:disable Metrics/AbcSize
      # Disabling because this is very close to the limit.

      ##
      # Creates a new Subscription object on the current Topic.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      # +subscription_name+::
      #   Name of the new subscription. Must start with a letter, and contain
      #   only letters ([A-Za-z]), numbers ([0-9], dashes (-), underscores (_),
      #   periods (.), tildes (~), plus (+) or percent signs (%). It must be
      #   between 3 and 255 characters in length, and it must not start with
      #   "goog". (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:deadline]</code>::
      #   The maximum number of seconds after a subscriber receives a message
      #   before the subscriber should acknowledge the message. (+Integer+)
      # <code>options[:endpoint]</code>::
      #   A URL locating the endpoint to which messages should be pushed.
      #   e.g. "https://example.com/push" (+String+)
      # <code>attributes[:autocreate]</code>::
      #   Flag to control whether the provided topic will be created if it does
      #   not exist.
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscribe "my-topic", "my-topic-sub"
      #   puts sub.name # => "my-topic-sub"
      #
      # The name is optional, and will be generated if not given.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscribe "my-topic"
      #   puts sub.name # => "generated-sub-name"
      #
      # The subscription can be created that waits two minutes for
      # acknowledgement and pushed all messages to an endpoint
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscribe "my-topic", "my-topic-sub",
      #                          deadline: 120,
      #                          endpoint: "https://example.com/push"
      #
      # Additionally, the topic will be created if the topic does previously not
      # exist and the +autocreate+ option is provided.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscribe "new-topic", "new-topic-sub", autocreate: true
      #
      def subscribe topic_name, subscription_name, options = {}
        ensure_connection!
        resp = connection.create_subscription topic_name,
                                              subscription_name, options
        return Subscription.from_gapi(resp.data, connection) if resp.success?
        if options[:autocreate] && resp.status == 404
          create_topic topic_name
          return subscribe(topic_name, subscription_name,
                           options.merge(autocreate: false))
        end
        fail ApiError.from_response(resp)
      end
      alias_method :create_subscription, :subscribe
      alias_method :new_subscription, :subscribe

      # rubocop:enable Metrics/AbcSize

      ##
      # Retrieves subscription by name.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:skip_lookup]</code>::
      #   Optionally create a Subscription object without verifying the
      #   subscription resource exists on the Pub/Sub service. Calls made on
      #   this object will raise errors if the service resource does not exist.
      #   Default is +false+. (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription or +nil+ if the subscription does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.subscription "my-sub"
      #   puts subscription.name
      #
      # The lookup against the Pub/Sub service can be skipped using the
      # +skip_lookup+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   # No API call is made to retrieve the subscription information.
      #   subscription = pubsub.subscription "my-sub", skip_lookup: true
      #   puts subscription.name
      #
      def subscription subscription_name, options = {}
        ensure_connection!
        if options[:skip_lookup]
          return Subscription.new_lazy(subscription_name, connection)
        end
        resp = connection.get_subscription subscription_name
        return Subscription.from_gapi(resp.data, connection) if resp.success?
        return nil if resp.status == 404
        fail ApiError.from_response(resp)
      end
      alias_method :get_subscription, :subscription
      alias_method :find_subscription, :subscription

      ##
      # Retrieves a list of subscriptions for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:prefix]</code>::
      #   Filter results to subscriptions whose names begin with this prefix.
      #   (+String+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of subscriptions to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Pubsub::Subscription
      # (Gcloud::Pubsub::Subscription::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscriptions = pubsub.subscriptions
      #   subscriptions.each do |subscription|
      #     puts subscription.name
      #   end
      #
      # If you have a significant number of subscriptions, you may need to
      # paginate through them: (See Subscription::List#token)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   all_subs = []
      #   tmp_subs = pubsub.subscriptions
      #   while tmp_subs.any? do
      #     tmp_subs.each do |subscription|
      #       all_subs << subscription
      #     end
      #     # break loop if no more subscriptions available
      #     break if tmp_subs.token.nil?
      #     # get the next group of subscriptions
      #     tmp_subs = pubsub.subscriptions token: tmp_subs.token
      #   end
      #
      def subscriptions options = {}
        ensure_connection!
        resp = connection.list_subscriptions options
        if resp.success?
          Subscription::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_subscriptions, :subscriptions
      alias_method :list_subscriptions, :subscriptions

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      ##
      # Call the publish API with arrays of data data and attrs.
      def publish_batch_messages topic_name, batch, autocreate = false
        resp = connection.publish topic_name, batch.messages
        if resp.success?
          batch.to_gcloud_messages resp.data["messageIds"]
        elsif autocreate && resp.status == 404
          create_topic topic_name
          publish_batch_messages topic_name, batch, false
        else
          fail ApiError.from_response(resp)
        end
      end
    end
  end
end
