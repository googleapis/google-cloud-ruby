# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/pubsub/v1/pubsub.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/pubsub/v1/pubsub_services_pb"

module Google
  module Cloud
    module Pubsub
      module V1
        # The service that an application uses to manipulate subscriptions and to
        # consume messages from a subscription via the +Pull+ method.
        #
        # @!attribute [r] stub
        #   @return [Google::Pubsub::V1::Subscriber::Stub]
        class SubscriberApi
          attr_reader :stub

          # The default address of the service.
          SERVICE_ADDRESS = "pubsub.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_subscriptions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "subscriptions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/pubsub"
          ].freeze

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          SUBSCRIPTION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/subscriptions/{subscription}"
          )

          private_constant :SUBSCRIPTION_PATH_TEMPLATE

          TOPIC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/topics/{topic}"
          )

          private_constant :TOPIC_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified subscription resource name string.
          # @param project [String]
          # @param subscription [String]
          # @return [String]
          def self.subscription_path project, subscription
            SUBSCRIPTION_PATH_TEMPLATE.render(
              :"project" => project,
              :"subscription" => subscription
            )
          end

          # Returns a fully-qualified topic resource name string.
          # @param project [String]
          # @param topic [String]
          # @return [String]
          def self.topic_path project, topic
            TOPIC_PATH_TEMPLATE.render(
              :"project" => project,
              :"topic" => topic
            )
          end

          # Parses the project from a project resource.
          # @param project_name [String]
          # @return [String]
          def self.match_project_from_project_name project_name
            PROJECT_PATH_TEMPLATE.match(project_name)["project"]
          end

          # Parses the project from a subscription resource.
          # @param subscription_name [String]
          # @return [String]
          def self.match_project_from_subscription_name subscription_name
            SUBSCRIPTION_PATH_TEMPLATE.match(subscription_name)["project"]
          end

          # Parses the subscription from a subscription resource.
          # @param subscription_name [String]
          # @return [String]
          def self.match_subscription_from_subscription_name subscription_name
            SUBSCRIPTION_PATH_TEMPLATE.match(subscription_name)["subscription"]
          end

          # Parses the project from a topic resource.
          # @param topic_name [String]
          # @return [String]
          def self.match_project_from_topic_name topic_name
            TOPIC_PATH_TEMPLATE.match(topic_name)["project"]
          end

          # Parses the topic from a topic resource.
          # @param topic_name [String]
          # @return [String]
          def self.match_topic_from_topic_name topic_name
            TOPIC_PATH_TEMPLATE.match(topic_name)["topic"]
          end

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param app_name [String]
          #   The codename of the calling service.
          # @param app_version [String]
          #   The version of the calling service.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: "gax",
              app_version: Google::Gax::VERSION
            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "subscriber_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.pubsub.v1.Subscriber",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Pubsub::V1::Subscriber::Stub.method(:new)
            )

            @create_subscription = Google::Gax.create_api_call(
              @stub.method(:create_subscription),
              defaults["create_subscription"]
            )
            @get_subscription = Google::Gax.create_api_call(
              @stub.method(:get_subscription),
              defaults["get_subscription"]
            )
            @list_subscriptions = Google::Gax.create_api_call(
              @stub.method(:list_subscriptions),
              defaults["list_subscriptions"]
            )
            @delete_subscription = Google::Gax.create_api_call(
              @stub.method(:delete_subscription),
              defaults["delete_subscription"]
            )
            @modify_ack_deadline = Google::Gax.create_api_call(
              @stub.method(:modify_ack_deadline),
              defaults["modify_ack_deadline"]
            )
            @acknowledge = Google::Gax.create_api_call(
              @stub.method(:acknowledge),
              defaults["acknowledge"]
            )
            @pull = Google::Gax.create_api_call(
              @stub.method(:pull),
              defaults["pull"]
            )
            @modify_push_config = Google::Gax.create_api_call(
              @stub.method(:modify_push_config),
              defaults["modify_push_config"]
            )
          end

          # Service calls

          # Creates a subscription to a given topic for a given subscriber.
          # If the subscription already exists, returns +ALREADY_EXISTS+.
          # If the corresponding topic doesn't exist, returns +NOT_FOUND+.
          #
          # If the name is not provided in the request, the server will assign a random
          # name for this subscription on the same project as the topic.
          #
          # @param name [String]
          #   The name of the subscription. It must have the format
          #   +"projects/{project}/subscriptions/{subscription}"+. +{subscription}+ must
          #   start with a letter, and contain only letters (+[A-Za-z]+), numbers
          #   (+[0-9]+), dashes (+-+), underscores (+_+), periods (+.+), tildes (+~+),
          #   plus (+++) or percent signs (+%+). It must be between 3 and 255 characters
          #   in length, and it must not start with +"goog"+.
          # @param topic [String]
          #   The name of the topic from which this subscription is receiving messages.
          #   The value of this field will be +_deleted-topic_+ if the topic has been
          #   deleted.
          # @param push_config [Google::Pubsub::V1::PushConfig]
          #   If push delivery is used with this subscription, this field is
          #   used to configure it. An empty +pushConfig+ signifies that the subscriber
          #   will pull and ack messages using API methods.
          # @param ack_deadline_seconds [Integer]
          #   This value is the maximum time after a subscriber receives a message
          #   before the subscriber should acknowledge the message. After message
          #   delivery but before the ack deadline expires and before the message is
          #   acknowledged, it is an outstanding message and will not be delivered
          #   again during that time (on a best-effort basis).
          #
          #   For pull subscriptions, this value is used as the initial value for the ack
          #   deadline. To override this value for a given message, call
          #   +ModifyAckDeadline+ with the corresponding +ack_id+ if using
          #   pull.
          #
          #   For push delivery, this value is also used to set the request timeout for
          #   the call to the push endpoint.
          #
          #   If the subscriber never acknowledges the message, the Pub/Sub
          #   system will eventually redeliver the message.
          #
          #   If this parameter is not set, the default value of 10 seconds is used.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def create_subscription \
              name,
              topic,
              push_config: nil,
              ack_deadline_seconds: nil,
              options: nil
            req = Google::Pubsub::V1::Subscription.new(
              name: name,
              topic: topic
            )
            req.push_config = push_config unless push_config.nil?
            req.ack_deadline_seconds = ack_deadline_seconds unless ack_deadline_seconds.nil?
            @create_subscription.call(req, options)
          end

          # Gets the configuration details of a subscription.
          #
          # @param subscription [String]
          #   The name of the subscription to get.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def get_subscription \
              subscription,
              options: nil
            req = Google::Pubsub::V1::GetSubscriptionRequest.new(
              subscription: subscription
            )
            @get_subscription.call(req, options)
          end

          # Lists matching subscriptions.
          #
          # @param project [String]
          #   The name of the cloud project that subscriptions belong to.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Subscription>]
          #   An enumerable of Google::Pubsub::V1::Subscription instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def list_subscriptions \
              project,
              page_size: nil,
              options: nil
            req = Google::Pubsub::V1::ListSubscriptionsRequest.new(
              project: project
            )
            req.page_size = page_size unless page_size.nil?
            @list_subscriptions.call(req, options)
          end

          # Deletes an existing subscription. All pending messages in the subscription
          # are immediately dropped. Calls to +Pull+ after deletion will return
          # +NOT_FOUND+. After a subscription is deleted, a new one may be created with
          # the same name, but the new one has no association with the old
          # subscription, or its topic unless the same topic is specified.
          #
          # @param subscription [String]
          #   The subscription to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def delete_subscription \
              subscription,
              options: nil
            req = Google::Pubsub::V1::DeleteSubscriptionRequest.new(
              subscription: subscription
            )
            @delete_subscription.call(req, options)
          end

          # Modifies the ack deadline for a specific message. This method is useful
          # to indicate that more time is needed to process a message by the
          # subscriber, or to make the message available for redelivery if the
          # processing was interrupted.
          #
          # @param subscription [String]
          #   The name of the subscription.
          # @param ack_ids [Array<String>]
          #   List of acknowledgment IDs.
          # @param ack_deadline_seconds [Integer]
          #   The new ack deadline with respect to the time this request was sent to
          #   the Pub/Sub system. Must be >= 0. For example, if the value is 10, the new
          #   ack deadline will expire 10 seconds after the +ModifyAckDeadline+ call
          #   was made. Specifying zero may immediately make the message available for
          #   another pull request.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def modify_ack_deadline \
              subscription,
              ack_ids,
              ack_deadline_seconds,
              options: nil
            req = Google::Pubsub::V1::ModifyAckDeadlineRequest.new(
              subscription: subscription,
              ack_ids: ack_ids,
              ack_deadline_seconds: ack_deadline_seconds
            )
            @modify_ack_deadline.call(req, options)
          end

          # Acknowledges the messages associated with the +ack_ids+ in the
          # +AcknowledgeRequest+. The Pub/Sub system can remove the relevant messages
          # from the subscription.
          #
          # Acknowledging a message whose ack deadline has expired may succeed,
          # but such a message may be redelivered later. Acknowledging a message more
          # than once will not result in an error.
          #
          # @param subscription [String]
          #   The subscription whose message is being acknowledged.
          # @param ack_ids [Array<String>]
          #   The acknowledgment ID for the messages being acknowledged that was returned
          #   by the Pub/Sub system in the +Pull+ response. Must not be empty.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def acknowledge \
              subscription,
              ack_ids,
              options: nil
            req = Google::Pubsub::V1::AcknowledgeRequest.new(
              subscription: subscription,
              ack_ids: ack_ids
            )
            @acknowledge.call(req, options)
          end

          # Pulls messages from the server. Returns an empty list if there are no
          # messages available in the backlog. The server may return +UNAVAILABLE+ if
          # there are too many concurrent pull requests pending for the given
          # subscription.
          #
          # @param subscription [String]
          #   The subscription from which messages should be pulled.
          # @param return_immediately [true, false]
          #   If this is specified as true the system will respond immediately even if
          #   it is not able to return a message in the +Pull+ response. Otherwise the
          #   system is allowed to wait until at least one message is available rather
          #   than returning no messages. The client may cancel the request if it does
          #   not wish to wait any longer for the response.
          # @param max_messages [Integer]
          #   The maximum number of messages returned for this request. The Pub/Sub
          #   system may return fewer than the number specified.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::PullResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def pull \
              subscription,
              max_messages,
              return_immediately: nil,
              options: nil
            req = Google::Pubsub::V1::PullRequest.new(
              subscription: subscription,
              max_messages: max_messages
            )
            req.return_immediately = return_immediately unless return_immediately.nil?
            @pull.call(req, options)
          end

          # Modifies the +PushConfig+ for a specified subscription.
          #
          # This may be used to change a push subscription to a pull one (signified by
          # an empty +PushConfig+) or vice versa, or change the endpoint URL and other
          # attributes of a push subscription. Messages will accumulate for delivery
          # continuously through the call regardless of changes to the +PushConfig+.
          #
          # @param subscription [String]
          #   The name of the subscription.
          # @param push_config [Google::Pubsub::V1::PushConfig]
          #   The push configuration for future deliveries.
          #
          #   An empty +pushConfig+ indicates that the Pub/Sub system should
          #   stop pushing messages from the given subscription and allow
          #   messages to be pulled and acknowledged - effectively pausing
          #   the subscription if +Pull+ is not called.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def modify_push_config \
              subscription,
              push_config,
              options: nil
            req = Google::Pubsub::V1::ModifyPushConfigRequest.new(
              subscription: subscription,
              push_config: push_config
            )
            @modify_push_config.call(req, options)
          end
        end
      end
    end
  end
end
