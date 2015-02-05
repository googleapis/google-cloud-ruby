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
    # Represents the connection to Pubsub,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1beta1"

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
      def get_topic topic_name
        @client.execute(
          api_method: @pubsub.topics.get,
          parameters: { topic: topic_slug(topic_name) }
        )
      end

      ##
      # Creates the given topic with the given name.
      def create_topic topic_name
        @client.execute(
          api_method: @pubsub.topics.create,
          body_object: { name: topic_path(topic_name) }
        )
      end

      ##
      # Lists matching topics.
      def list_topics
        @client.execute(
          api_method: @pubsub.topics.list,
          parameters: { query: project_query }
        )
      end

      ##
      # Deletes the topic with the given name.
      # All subscriptions to this topic are also deleted.
      # Returns NOT_FOUND if the topic does not exist.
      # After a topic is deleted, a new topic may be created with the same name.
      def delete_topic topic_name
        @client.execute(
          api_method: @pubsub.topics.delete,
          parameters: { topic: topic_slug(topic_name) }
        )
      end

      ##
      # Creates a subscription on a given topic for a given subscriber.
      def create_subscription topic_name, subscription_name = nil,
                              deadline = nil, endpoint = nil
        data = subscription_data topic_name, subscription_name,
                                 deadline, endpoint
        @client.execute(
          api_method: @pubsub.subscriptions.create,
          body_object: data
        )
      end

      ##
      # Gets the details of a subscription.
      def get_subscription subscription_name
        @client.execute(
          api_method: @pubsub.subscriptions.get,
          parameters: { subscription: subscription_slug(subscription_name) }
        )
      end

      ##
      # Lists matching topics.
      def list_subscriptions topic_name
        @client.execute(
          api_method: @pubsub.subscriptions.list,
          parameters: { query: topic_query(topic_name) }
        )
      end

      protected

      def project_query
        "cloud.googleapis.com/project in (#{project_path})"
      end

      def project_path
        "/projects/#{project}"
      end

      def topic_query topic_name
        "pubsub.googleapis.com/topic in (#{topic_path topic_name})"
      end

      def topic_slug topic_name
        "#{project}/#{topic_name}"
      end

      def topic_path topic_name
        "/topics/#{topic_slug topic_name}"
      end

      def subscription_data topic_name, subscription_name = nil,
                            deadline = nil, endpoint = nil
        data = { "topic" => topic_path(topic_name) }
        data["name"] = subscription_path subscription_name if subscription_name
        data["ackDeadlineSeconds"] = deadline if deadline
        data["pushConfig"] = { "pushEndpoint" => endpoint } if endpoint
        data
      end

      def subscription_slug subscription_name
        "#{project}/#{subscription_name}"
      end

      def subscription_path subscription_name
        "/subscriptions/#{subscription_slug subscription_name}"
      end
    end
  end
end
