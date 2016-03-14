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
    # @private Represents the connection to Pub/Sub,
    # as well as expose the API calls.
    class Connection
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = nil # @credentials.client
        @pubsub = @client.discovered_api "pubsub", API_VERSION
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

      def inspect
        "#{self.class}(#{@project})"
      end

      protected

      def subscription_data topic, options = {}
        deadline   = options[:deadline]
        endpoint   = options[:endpoint]
        attributes = (options[:attributes] || {}).to_h

        data = { topic: topic_path(topic) }
        data[:ackDeadlineSeconds] = deadline if deadline
        if endpoint
          data[:pushConfig] = { pushEndpoint: endpoint,
                                attributes:   attributes }
        end
        data
      end
    end
  end
end
