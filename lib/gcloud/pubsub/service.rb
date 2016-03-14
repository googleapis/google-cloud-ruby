# Copyright 2016 Google Inc. All rights reserved.
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


require "google/pubsub/v1/pubsub_services"
require "gcloud/grpc_utils"

module Gcloud
  module Pubsub
    ##
    # @private Represents the gRPC Pub/Sub service, including all the API
    # methods.
    class Service
      attr_accessor :project, :credentials, :host

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @host = "pubsub.googleapis.com"
      end

      def creds
        GRPC::Core::ChannelCredentials.new.compose \
          GRPC::Core::CallCredentials.new credentials.client.updater_proc
      end

      def subscriber
        return mocked_subscriber if mocked_subscriber
        @subscriber ||= Google::Pubsub::V1::Subscriber::Stub.new host, creds
      end
      attr_accessor :mocked_subscriber

      def publisher
        return mocked_publisher if mocked_publisher
        @publisher ||= Google::Pubsub::V1::Publisher::Stub.new host, creds
      end
      attr_accessor :mocked_publisher

      ##
      # Gets the configuration of a topic.
      # Since the topic only has the name attribute,
      # this method is only useful to check the existence of a topic.
      # If other attributes are added in the future,
      # they will be returned here.
      def get_topic topic_name, options = {}
        topic_req = Google::Pubsub::V1::GetTopicRequest.new.tap do |r|
          r.topic = topic_path(topic_name, options)
        end

        publisher.get_topic topic_req
      end

      ##
      # Lists matching topics.
      def list_topics options = {}
        topics_req = Google::Pubsub::V1::ListTopicsRequest.new.tap do |r|
          r.project = project_path(options)
          r.page_token = options[:token] if options[:token]
          r.page_size = options[:max] if options[:max]
        end

        publisher.list_topics topics_req
      end

      ##
      # Creates the given topic with the given name.
      def create_topic topic_name, options = {}
        topic_req = Google::Pubsub::V1::Topic.new.tap do |r|
          r.name = topic_path(topic_name, options)
        end

        publisher.create_topic topic_req
      end

      ##
      # Deletes the topic with the given name.
      # All subscriptions to this topic are also deleted.
      # Raises GRPC status code 5 if the topic does not exist.
      # After a topic is deleted, a new topic may be created with the same name.
      def delete_topic topic_name
        topic_req = Google::Pubsub::V1::DeleteTopicRequest.new.tap do |r|
          r.topic = topic_path(topic_name)
        end

        publisher.delete_topic topic_req
      end

      ##
      # Adds one or more messages to the topic.
      # Raises GRPC status code 5 if the topic does not exist.
      # The messages parameter is an array of arrays.
      # The first element is the data, second is attributes hash.
      def publish topic, messages
        publish_req = Google::Pubsub::V1::PublishRequest.new(
          topic: topic_path(topic),
          messages: messages.map do |data, attributes|
            Google::Pubsub::V1::PubsubMessage.new(
              data: [data].pack("m").encode("ASCII-8BIT"),
              attributes: attributes
            )
          end
        )

        publisher.publish publish_req
      end

      ##
      # Gets the details of a subscription.
      def get_subscription subscription_name, options = {}
        sub_req = Google::Pubsub::V1::GetSubscriptionRequest.new(
          subscription: subscription_path(subscription_name, options)
        )

        subscriber.get_subscription sub_req
      end

      ##
      # Lists matching subscriptions by project and topic.
      def list_topics_subscriptions topic, options = {}
        list_params = { topic:     topic_path(topic, options),
                        page_token: options[:token],
                        page_size:  options[:max] }.delete_if { |_, v| v.nil? }
        list_req = Google::Pubsub::V1::ListTopicSubscriptionsRequest.new \
          list_params

        publisher.list_topic_subscriptions list_req
      end

      ##
      # Lists matching subscriptions by project.
      def list_subscriptions options = {}
        list_params = { project:    project_path(options),
                        page_token: options[:token],
                        page_size:  options[:max] }.delete_if { |_, v| v.nil? }
        list_req = Google::Pubsub::V1::ListSubscriptionsRequest.new list_params

        subscriber.list_subscriptions list_req
      end

      ##
      # Creates a subscription on a given topic for a given subscriber.
      def create_subscription topic, subscription_name, options = {}
        sub_params = { name: subscription_path(subscription_name, options),
                       topic: topic_path(topic),
                       ack_deadline_seconds: options[:deadline]
                     }.delete_if { |_, v| v.nil? }
        sub_req = Google::Pubsub::V1::Subscription.new sub_params
        if options[:endpoint]
          sub_req.push_config = Google::Pubsub::V1::PushConfig.new(
            push_endpoint: options[:endpoint],
            attributes: (options[:attributes] || {}).to_h)
        end

        subscriber.create_subscription sub_req
      end

      ##
      # Deletes an existing subscription.
      # All pending messages in the subscription are immediately dropped.
      def delete_subscription subscription
        del_req = Google::Pubsub::V1::DeleteSubscriptionRequest.new(
          subscription: subscription_path(subscription)
        )

        subscriber.delete_subscription del_req
      end

      ##
      # Pulls a single message from the server.
      def pull subscription, options = {}
        pull_req = Google::Pubsub::V1::PullRequest.new(
          subscription: subscription_path(subscription, options),
          return_immediately: !(!options.fetch(:immediate, true)),
          max_messages: options.fetch(:max, 100).to_i
        )

        subscriber.pull pull_req
      end

      ##
      # Acknowledges receipt of a message.
      def acknowledge subscription, *ack_ids
        ack_req = Google::Pubsub::V1::AcknowledgeRequest.new(
          subscription: subscription_path(subscription),
          ack_ids: ack_ids
        )

        subscriber.acknowledge ack_req
      end

      ##
      # Modifies the PushConfig for a specified subscription.
      def modify_push_config subscription, endpoint, attributes
        # Convert attributes to strings to match the protobuf definition
        attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

        mpc_req = Google::Pubsub::V1::ModifyPushConfigRequest.new(
          subscription: subscription_path(subscription),
          push_config: Google::Pubsub::V1::PushConfig.new(
            push_endpoint: endpoint,
            attributes: attributes
          )
        )

        subscriber.modify_push_config mpc_req
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
    end
  end
end
