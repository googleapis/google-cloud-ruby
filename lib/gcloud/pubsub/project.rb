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

      ##
      # Retrieves topic by name.
      # The difference between this method and Project#topic is that this
      # method makes an API call to Pub/Sub to verify the topic exists.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Topic or nil if topic does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.get_topic "my-topic"
      #
      def get_topic topic_name
        ensure_connection!
        resp = connection.get_topic topic_name
        if resp.success?
          Topic.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_topic, :get_topic

      ##
      # Retrieves topic by name.
      # The difference between this method and Project#get_topic is that this
      # method does not make an API call to Pub/Sub to verify the topic exists.
      #
      # === Parameters
      #
      # +topic_name+::
      #   Name of a topic. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:autocreate]</code>::
      #   Flag to control whether the topic should be created when needed.
      #   The default value is +true+. (+Boolean+)
      # <code>options[:project]</code>::
      #   If the topic belongs to a project other than the one currently
      #   connected to, the alternate project ID can be specified here.
      #   (+String+)
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
      #   topic = pubsub.topic "existing-topic"
      #   msg = topic.publish "This is the first API call to Pub/Sub."
      #
      # By default the topic will be created in Pub/Sub when needed.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "non-existing-topic"
      #   msg = topic.publish "This will create the topic in Pub/Sub."
      #
      # Setting the +autocomplete+ flag to false will not create the topic.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "non-existing-topic"
      #   msg = topic.publish "This raises." #=> Gcloud::Pubsub::NotFoundError
      #
      # A topic in a different project can be created using the +project+ flag.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "another-topic", project: "another-project"
      #
      def topic topic_name, options = {}
        ensure_connection!

        Topic.new_lazy topic_name, connection, options
      end

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
      # Retrieves subscription by name.
      # The difference between this method and Project#get_subscription is
      # that this method does not make an API call to Pub/Sub to verify the
      # subscription exists.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.get_subscription "my-topic-subscription"
      #   puts subscription.name
      #
      def subscription subscription_name
        ensure_connection!

        Subscription.new_lazy subscription_name, connection
      end

      ##
      # Retrieves subscription by name.
      # The difference between this method and Project#subscription is that
      # this method makes an API call to Pub/Sub to verify the subscription
      # exists.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. (+String+)
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
      #   subscription = pubsub.get_subscription "my-topic-subscription"
      #   puts subscription.name
      #
      def get_subscription subscription_name
        ensure_connection!
        resp = connection.get_subscription subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          nil
        end
      end
      alias_method :find_subscription, :get_subscription

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
    end
  end
end
