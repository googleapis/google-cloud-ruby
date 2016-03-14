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


require "gcloud/pubsub/errors"
require "gcloud/pubsub/subscription/list"
require "gcloud/pubsub/received_message"

module Gcloud
  module Pubsub
    ##
    # # Subscription
    #
    # A named resource representing the stream of messages from a single,
    # specific {Topic}, to be delivered to the subscribing application.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #
    #   sub = pubsub.subscription "my-topic-sub"
    #   msgs = sub.pull
    #   msgs.each { |msg| msg.acknowledge! }
    #
    class Subscription
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The gRPC Service object.
      attr_accessor :service

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private The gRPC Google::Pubsub::V1::Subscription object.
      attr_accessor :grpc

      ##
      # @private Create an empty {Subscription} object.
      def initialize
        @connection = nil
        @gapi = {}
        @service = nil
        @grpc = Google::Pubsub::V1::Subscription.new
        @name = nil
        @exists = nil
      end

      ##
      # @private New lazy {Topic} object without making an HTTP request.
      def self.new_lazy name, conn, service, options = {}
        sub = new.tap do |f|
          f.gapi = nil
          f.grpc = nil
          f.connection = conn
          f.service = service
        end
        sub.instance_eval do
          @name = conn.subscription_path(name, options)
        end
        sub
      end

      ##
      # The name of the subscription.
      def name
        @grpc ? @grpc.name : @name
      end

      ##
      # The {Topic} from which this subscription receives messages.
      #
      # @return [Topic]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.topic.name #=> "projects/my-project/topics/my-topic"
      #
      def topic
        ensure_grpc!
        Topic.new_lazy @grpc.topic, connection, service
      end

      ##
      # This value is the maximum number of seconds after a subscriber receives
      # a message before the subscriber should acknowledge the message.
      def deadline
        ensure_grpc!
        @grpc.ack_deadline_seconds
      end

      ##
      # Returns the URL locating the endpoint to which messages should be
      # pushed.
      def endpoint
        ensure_grpc!
        @grpc.push_config.push_endpoint if @grpc.push_config
      end

      ##
      # Sets the URL locating the endpoint to which messages should be pushed.
      def endpoint= new_endpoint
        ensure_connection!
        resp = connection.modify_push_config name, new_endpoint, {}
        if resp.success?
          @gapi ||= {}
          @gapi["pushConfig"] ||= {}
          @gapi["pushConfig"]["pushEndpoint"] = new_endpoint
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines whether the subscription exists in the Pub/Sub service.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.exists? #=> true
      #
      def exists?
        # Always true if we have a gapi object
        return true unless @grpc.nil?
        # If we have a value, return it
        return @exists unless @exists.nil?
        ensure_grpc!
        @exists = !@grpc.nil?
      rescue Gcloud::NotFoundError
        @exists = false
      end

      ##
      # @private
      # Determines whether the subscription object was created with an
      # HTTP call.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.get_subscription "my-topic-sub"
      #   sub.lazy? #=> false
      #
      def lazy?
        @grpc.nil?
      end

      ##
      # Deletes an existing subscription.
      # All pending messages in the subscription are immediately dropped.
      #
      # @return [Boolean] Returns `true` if the subscription was deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.delete
      #
      def delete
        ensure_service!
        service.delete_subscription name
        return true
      rescue GRPC::BadStatus => e
        raise Error.from_error(e)
      end

      ##
      # Pulls messages from the server. Returns an empty list if there are no
      # messages available in the backlog. Raises an ApiError with status
      # `UNAVAILABLE` if there are too many concurrent pull requests pending
      # for the given subscription.
      #
      # @param [Boolean] immediate When `true` the system will respond
      #   immediately even if it is not able to return messages. When `false`
      #   the system is allowed to wait until it can return least one message.
      #   No messages are returned when a request times out. The default value
      #   is `true`.
      # @param [Integer] max The maximum number of messages to return for this
      #   request. The Pub/Sub system may return fewer than the number
      #   specified. The default value is `100`, the maximum value is `1000`.
      # @param [Boolean] autoack Automatically acknowledge the message as it is
      #   pulled. The default value is `false`.
      #
      # @return [Array<Gcloud::Pubsub::ReceivedMessage>]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # @example A maximum number of messages returned can also be specified:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub", max: 10
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # @example The call can block until messages are available:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   msgs = sub.pull immediate: false
      #   msgs.each { |msg| msg.acknowledge! }
      #
      def pull immediate: true, max: 100, autoack: false
        ensure_service!
        options = { immediate: immediate, max: max }
        list_grpc = service.pull name, options
        messages = Array(list_grpc.received_messages).map do |msg_grpc|
          ReceivedMessage.from_grpc msg_grpc, self
        end
        acknowledge messages if autoack
        messages
      rescue GRPC::BadStatus => e
        raise Error.from_error(e)
      rescue Faraday::TimeoutError
        []
      end

      ##
      # Pulls from the server while waiting for messages to become available.
      # This is the same as:
      #
      #   subscription.pull immediate: false
      #
      # @param [Integer] max The maximum number of messages to return for this
      #   request. The Pub/Sub system may return fewer than the number
      #   specified. The default value is `100`, the maximum value is `1000`.
      # @param [Boolean] autoack Automatically acknowledge the message as it is
      #   pulled. The default value is `false`.
      #
      # @return [Array<Gcloud::Pubsub::ReceivedMessage>]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   msgs = sub.wait_for_messages
      #   msgs.each { |msg| msg.acknowledge! }
      #
      def wait_for_messages max: 100, autoack: false
        pull immediate: false, max: max, autoack: autoack
      end

      ##
      # Poll the backend for new messages. This runs a loop to ping the API,
      # blocking indefinitely, yielding retrieved messages as they are received.
      #
      # @param [Integer] max The maximum number of messages to return for this
      #   request. The Pub/Sub system may return fewer than the number
      #   specified. The default value is `100`, the maximum value is `1000`.
      # @param [Boolean] autoack Automatically acknowledge the message as it is
      #   pulled. The default value is `false`.
      # @param [Number] delay The number of seconds to pause between requests
      #   when the Google Cloud service has no messages to return. The default
      #   value is `1`.
      # @yield [msg] a block for processing new messages
      # @yieldparam [ReceivedMessage] msg the newly received message
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.listen do |msg|
      #     # process msg
      #   end
      #
      # @example Limit the number of messages pulled per batch with `max`:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.listen max: 20 do |msg|
      #     # process msg
      #   end
      #
      # @example Automatically acknowledge messages with `autoack`:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.listen autoack: true do |msg|
      #     # process msg
      #   end
      #
      def listen max: 100, autoack: false, delay: 1
        loop do
          msgs = wait_for_messages max: max, autoack: autoack
          if msgs.any?
            msgs.each { |msg| yield msg }
          else
            sleep delay
          end
        end
      end

      ##
      # Acknowledges receipt of a message. After an ack,
      # the Pub/Sub system can remove the message from the subscription.
      # Acknowledging a message whose ack deadline has expired may succeed,
      # although the message may have been sent again.
      # Acknowledging a message more than once will not result in an error.
      # This is only used for messages received via pull.
      #
      # @param [ReceivedMessage, String] messages One or more {ReceivedMessage}
      #   objects or ack_id values.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   messages = sub.pull
      #   sub.acknowledge messages
      #
      def acknowledge *messages
        ack_ids = coerce_ack_ids messages
        ensure_service!
        service.acknowledge name, *ack_ids
        true
      rescue GRPC::BadStatus => e
        raise Error.from_error(e)
      end
      alias_method :ack, :acknowledge

      ##
      # Modifies the acknowledge deadline for messages.
      #
      # This indicates that more time is needed to process the messages, or to
      # make the messages available for redelivery if the processing was
      # interrupted.
      #
      # @param [Integer] new_deadline The new ack deadline in seconds from the
      #   time this request is sent to the Pub/Sub system. Must be >= 0. For
      #   example, if the value is `10`, the new ack deadline will expire 10
      #   seconds after the call is made. Specifying `0` may immediately make
      #   the message available for another pull request.
      # @param [ReceivedMessage, String] messages One or more {ReceivedMessage}
      #   objects or ack_id values.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   messages = sub.pull
      #   sub.delay 120, messages
      #
      def delay new_deadline, *messages
        ack_ids = coerce_ack_ids messages
        ensure_connection!
        resp = connection.modify_ack_deadline name, ack_ids, new_deadline
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Gets the access control policy.
      #
      # By default, the policy values are memoized to reduce the number of API
      # calls to the Pub/Sub service.
      #
      # @param [Boolean] force Force the latest policy to be retrieved from the
      #   Pub/Sub service when `true`. Otherwise the policy will be memoized to
      #   reduce the number of API calls made to the Pub/Sub service. The
      #   default is `false`.
      #
      # @return [Hash] Returns a hash that conforms to the following structure:
      #
      #   {
      #     "etag"=>"CAE=",
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }]
      #   }
      #
      # @example Policy values are memoized to reduce the number of API calls:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.subscription "my-subscription"
      #   puts subscription.policy["bindings"]
      #   puts subscription.policy["rules"]
      #
      # @example Use `force` to retrieve the latest policy from the service:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.subscription "my-subscription"
      #   policy = subscription.policy force: true
      #
      def policy force: nil
        @policy = nil if force
        @policy ||= begin
          ensure_connection!
          resp = connection.get_subscription_policy name
          fail ApiError.from_response(resp) unless resp.success?
          policy = resp.data
          policy = policy.to_hash if policy.respond_to? :to_hash
          policy
        end
      end

      ##
      # Sets the access control policy.
      #
      # @param [String] new_policy A hash that conforms to the following
      #   structure:
      #
      #     {
      #       "bindings" => [{
      #         "role" => "roles/viewer",
      #         "members" => ["serviceAccount:your-service-account"]
      #       }]
      #     }
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   viewer_policy = {
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }]
      #   }
      #   subscription = pubsub.subscription "my-subscription"
      #   subscription.policy = viewer_policy
      #
      def policy= new_policy
        ensure_connection!
        resp = connection.set_subscription_policy name, new_policy
        if resp.success?
          @policy = resp.data["policy"]
          @policy = @policy.to_hash if @policy.respond_to? :to_hash
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Tests the specified permissions against the [Cloud
      # IAM](https://cloud.google.com/iam/) access control policy.
      #
      # @see https://cloud.google.com/iam/docs/managing-policies Managing
      #   Policies
      #
      # @param [String, Array<String>] permissions The set of permissions to
      #   check access for. Permissions with wildcards (such as `*` or
      #   `storage.*`) are not allowed.
      #
      #   The permissions that can be checked on a subscription are:
      #
      #   * pubsub.subscriptions.consume
      #   * pubsub.subscriptions.get
      #   * pubsub.subscriptions.delete
      #   * pubsub.subscriptions.update
      #   * pubsub.subscriptions.getIamPolicy
      #   * pubsub.subscriptions.setIamPolicy
      #
      # @return [Array<String>] The permissions that have access.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   sub = pubsub.subscription "my-subscription"
      #   perms = sub.test_permissions "pubsub.subscriptions.get",
      #                                "pubsub.subscriptions.consume"
      #   perms.include? "pubsub.subscriptions.get" #=> true
      #   perms.include? "pubsub.subscriptions.consume" #=> false
      #
      def test_permissions *permissions
        permissions = Array(permissions).flatten
        ensure_connection!
        resp = connection.test_subscription_permissions name, permissions
        if resp.success?
          Array(resp.data["permissions"])
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private New {Subscription} from a Google API Client object.
      def self.from_gapi gapi, conn, service
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
          f.service = service
        end
      end

      ##
      # @private New Subscription from a Google::Pubsub::V1::Subscription
      # object.
      def self.from_grpc grpc, connection, service
        new.tap do |f|
          f.grpc = grpc
          f.connection = connection
          f.service = service
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      ##
      # @private Raise an error unless an active connection to the service is
      # available.
      def ensure_service!
        fail "Must have active connection to service" unless service
      end

      ##
      # Ensures a Google API object exists.
      def ensure_gapi!
        ensure_connection!
        return @gapi if @gapi
        resp = connection.get_subscription @name
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Ensures a Google::Pubsub::V1::Subscription object exists.
      def ensure_grpc!
        ensure_service!
        return @grpc if @grpc
        @grpc = service.get_subscription @name
      rescue GRPC::BadStatus => e
        raise Error.from_error(e)
      end

      ##
      # Makes sure the values are the `ack_id`.
      # If given several {ReceivedMessage} objects extract the `ack_id` values.
      def coerce_ack_ids messages
        Array(messages).flatten.map do |msg|
          msg.respond_to?(:ack_id) ? msg.ack_id : msg.to_s
        end
      end
    end
  end
end
