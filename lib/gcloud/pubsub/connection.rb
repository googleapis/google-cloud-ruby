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

require "gcloud/version"
require "google/api_client"

module Gcloud
  module Pubsub
    ##
    # Represents the connection to Pub/Sub,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @pubsub = @client.discovered_api "pubsub", API_VERSION
      end

      ##
      # Gets the configuration of a topic.
      # Since the topic only has the name attribute,
      # this method is only useful to check the existence of a topic.
      # If other attributes are added in the future,
      # they will be returned here.
      def get_topic topic_name, options = {}
        @client.execute(
          api_method: @pubsub.projects.topics.get,
          parameters: { topic: topic_path(topic_name, options) }
        )
      end

      ##
      # Creates the given topic with the given name.
      def create_topic topic_name, options = {}
        @client.execute(
          api_method: @pubsub.projects.topics.create,
          parameters: { name: topic_path(topic_name, options) }
        )
      end

      ##
      # Lists matching topics.
      def list_topics options = {}
        params = { project: project_path(options),
                   pageToken: options.delete(:token),
                   pageSize: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @pubsub.projects.topics.list,
          parameters: params
        )
      end

      ##
      # Deletes the topic with the given name.
      # All subscriptions to this topic are also deleted.
      # Returns NOT_FOUND if the topic does not exist.
      # After a topic is deleted, a new topic may be created with the same name.
      def delete_topic topic
        @client.execute(
          api_method: @pubsub.projects.topics.delete,
          parameters: { topic: topic }
        )
      end

      def get_topic_policy topic_name, options = {}
        @client.execute(
          api_method: @pubsub.projects.topics.get_iam_policy,
          parameters: { resource: topic_path(topic_name, options) }
        )
      end

      def set_topic_policy topic_name, new_policy, options = {}
        @client.execute(
          api_method: @pubsub.projects.topics.set_iam_policy,
          parameters: { resource: topic_path(topic_name, options) },
          body_object: { policy: new_policy }
        )
      end

      def test_topic_permissions topic_name, permissions, options = {}
        @client.execute(
          api_method: @pubsub.projects.topics.test_iam_permissions,
          parameters: { resource: topic_path(topic_name, options) },
          body_object: { permissions: permissions }
        )
      end

      ##
      # Creates a subscription on a given topic for a given subscriber.
      def create_subscription topic, subscription_name, options = {}
        data = subscription_data topic, options
        @client.execute(
          api_method: @pubsub.projects.subscriptions.create,
          parameters: { name: subscription_path(subscription_name, options) },
          body_object: data
        )
      end

      ##
      # Gets the details of a subscription.
      def get_subscription subscription_name, options = {}
        @client.execute(
          api_method: @pubsub.projects.subscriptions.get,
          parameters: {
            subscription: subscription_path(subscription_name, options) }
        )
      end

      ##
      # Lists matching subscriptions by project.
      def list_subscriptions options = {}
        params = { project: project_path(options),
                   pageToken: options.delete(:token),
                   pageSize: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @pubsub.projects.subscriptions.list,
          parameters: params
        )
      end

      ##
      # Lists matching subscriptions by project and topic.
      def list_topics_subscriptions topic, options = {}
        params = { topic: topic,
                   pageToken: options.delete(:token),
                   pageSize: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @pubsub.projects.topics.subscriptions.list,
          parameters: params
        )
      end

      ##
      # Deletes an existing subscription.
      # All pending messages in the subscription are immediately dropped.
      def delete_subscription subscription
        @client.execute(
          api_method: @pubsub.projects.subscriptions.delete,
          parameters: { subscription: subscription }
        )
      end

      def get_subscription_policy subscription_name, options = {}
        @client.execute(
          api_method: @pubsub.projects.subscriptions.get_iam_policy,
          parameters: {
            resource: subscription_path(subscription_name, options) }
        )
      end

      def set_subscription_policy subscription_name, new_policy, options = {}
        @client.execute(
          api_method: @pubsub.projects.subscriptions.set_iam_policy,
          parameters: {
            resource: subscription_path(subscription_name, options) },
          body_object: { policy: new_policy }
        )
      end

      def test_subscription_permissions subscription_name,
                                        permissions, options = {}
        @client.execute(
          api_method: @pubsub.projects.subscriptions.test_iam_permissions,
          parameters: {
            resource: subscription_path(subscription_name, options) },
          body_object: { permissions: permissions }
        )
      end

      ##
      # Adds one or more messages to the topic.
      # Returns NOT_FOUND if the topic does not exist.
      # The messages parameter is an array of arrays.
      # The first element is the data, second is attributes hash.
      def publish topic, messages
        gapi_msgs = messages.map do |data, attributes|
          { data: [data].pack("m"), attributes: attributes }
        end
        @client.execute(
          api_method:  @pubsub.projects.topics.publish,
          parameters:  { topic: topic_path(topic) },
          body_object: { messages: gapi_msgs }
        )
      end

      ##
      # Pulls a single message from the server.
      def pull subscription, options = {}
        body = { returnImmediately: !(!options.fetch(:immediate, true)),
                 maxMessages:          options.fetch(:max, 100).to_i }

        @client.execute(
          api_method:  @pubsub.projects.subscriptions.pull,
          parameters:  { subscription: subscription },
          body_object: body
        )
      end

      ##
      # Acknowledges receipt of a message.
      def acknowledge subscription, *ack_ids
        @client.execute(
          api_method:  @pubsub.projects.subscriptions.acknowledge,
          parameters:  { subscription: subscription },
          body_object: { ackIds: ack_ids }
        )
      end

      ##
      # Modifies the PushConfig for a specified subscription.
      def modify_push_config subscription, endpoint, attributes
        @client.execute(
          api_method:  @pubsub.projects.subscriptions.modify_push_config,
          parameters:  { subscription: subscription },
          body_object: { pushConfig: { pushEndpoint: endpoint,
                                       attributes: attributes } }
        )
      end

      ##
      # Modifies the ack deadline for a specific message.
      def modify_ack_deadline subscription, ids, deadline
        ids = Array ids
        @client.execute(
          api_method:  @pubsub.projects.subscriptions.modify_ack_deadline,
          parameters:  { subscription: subscription },
          body_object: { ackIds: ids, ackDeadlineSeconds: deadline }
        )
      end

      def project_path options = {}
        project_name = options[:project] || project
        "projects/#{project_name}"
      end

      def topic_path topic_name, options = {}
        return topic_name if topic_name.to_s.include? "/"
        "#{project_path(options)}/topics/#{topic_name}"
      end

      def subscription_path subscription_name, options = {}
        return subscription_name if subscription_name.to_s.include? "/"
        "#{project_path(options)}/subscriptions/#{subscription_name}"
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end

      protected

      def subscription_data topic, options = {}
        deadline   = options[:deadline]
        endpoint   = options[:endpoint]
        attributes = hashify options[:attributes]

        data = { topic: topic }
        data[:ackDeadlineSeconds] = deadline if deadline
        if endpoint
          data[:pushConfig] = { pushEndpoint: endpoint,
                                attributes:   attributes }
        end
        data
      end

      ##
      # Make sure the object is converted to a hash
      # Ruby 1.9.3 doesn't support to_h, so here we are.
      def hashify hash
        if hash.respond_to? :to_h
          hash.to_h
        else
          Hash.try_convert(hash) || {}
        end
      end
    end
  end
end
