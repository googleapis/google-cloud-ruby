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

require "json"
require "gcloud/pubsub/errors"
require "gcloud/pubsub/topic/list"
require "gcloud/pubsub/subscription"

module Gcloud
  module Pubsub
    ##
    # # Topic
    #
    # A named resource to which messages are published.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    class Topic
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty {Topic} object.
      def initialize
        @connection = nil
        @gapi = {}
        @name = nil
        @exists = nil
      end

      ##
      # @private New lazy {Topic} object without making an HTTP request.
      def self.new_lazy name, conn, options = {}
        new.tap do |t|
          t.gapi = nil
          t.connection = conn
          t.instance_eval do
            @name = conn.topic_path(name, options)
          end
        end
      end

      ##
      # The name of the topic in the form of
      # "/projects/project-identifier/topics/topic-name".
      def name
        @gapi ? @gapi["name"] : @name
      end

      ##
      # Permanently deletes the topic.
      #
      # @return [Boolean] Returns `true` if the topic was deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_topic name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new {Subscription} object on the current Topic.
      #
      # @param [String] subscription_name Name of the new subscription. Must
      #   start with a letter, and contain only letters ([A-Za-z]), numbers
      #   ([0-9], dashes (-), underscores (_), periods (.), tildes (~), plus (+)
      #   or percent signs (%). It must be between 3 and 255 characters in
      #   length, and it must not start with "goog".
      # @param [Integer] deadline The maximum number of seconds after a
      #   subscriber receives a message before the subscriber should acknowledge
      #   the message.
      # @param [String] endpoint A URL locating the endpoint to which messages
      #   should be pushed.
      #
      # @return [Gcloud::Pubsub::Subscription]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub"
      #   puts sub.name # => "my-topic-sub"
      #
      # @example The name is optional, and will be generated if not given:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub"
      #   puts sub.name # => "generated-sub-name"
      #
      # @example Wait 2 minutes for acknowledgement and push all to an endpoint:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub",
      #                         deadline: 120,
      #                         endpoint: "https://example.com/push"
      #
      def subscribe subscription_name, deadline: nil, endpoint: nil
        ensure_connection!
        options = { deadline: deadline, endpoint: endpoint }
        resp = connection.create_subscription name, subscription_name, options
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :create_subscription, :subscribe
      alias_method :new_subscription, :subscribe

      ##
      # Retrieves subscription by name.
      #
      # @param [String] subscription_name Name of a subscription.
      # @param [Boolean] skip_lookup Optionally create a {Subscription} object
      #   without verifying the subscription resource exists on the Pub/Sub
      #   service. Calls made on this object will raise errors if the service
      #   resource does not exist. Default is `false`.
      #
      # @return [Gcloud::Pubsub::Subscription, nil] Returns `nil` if
      #   the subscription does not exist.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   subscription = topic.subscription "my-topic-subscription"
      #   puts subscription.name
      #
      # @example Skip the lookup against the service with `skip_lookup`:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   # No API call is made to retrieve the subscription information.
      #   subscription = pubsub.subscription "my-sub", skip_lookup: true
      #   puts subscription.name
      #
      def subscription subscription_name, skip_lookup: nil
        ensure_connection!
        if skip_lookup
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
      # Retrieves a list of subscription names for the given project.
      #
      # @param [String] token The `token` value returned by the last call to
      #   `subscriptions`; indicates that this is a continuation of a call, and
      #   that the system should return the next page of data.
      # @param [Integer] max Maximum number of subscriptions to return.
      #
      # @return [Array<Subscription>] (See {Subscription::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   subscription = topic.subscriptions
      #   subscriptions.each do |subscription|
      #     puts subscription.name
      #   end
      #
      # @example With pagination: (See {Subscription::List#token})
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   all_subs = []
      #   tmp_subs = topic.subscriptions
      #   while tmp_subs.any? do
      #     tmp_subs.each do |subscription|
      #       all_subs << subscription
      #     end
      #     # break loop if no more subscriptions available
      #     break if tmp_subs.token.nil?
      #     # get the next group of subscriptions
      #     tmp_subs = topic.subscriptions token: tmp_subs.token
      #   end
      #
      def subscriptions token: nil, max: nil
        ensure_connection!
        options = { token: token, max: max }
        resp = connection.list_topics_subscriptions name, options
        if resp.success?
          Subscription::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_subscriptions, :subscriptions
      alias_method :list_subscriptions, :subscriptions

      ##
      # Publishes one or more messages to the topic.
      #
      # @param [String] data The message data.
      # @param [Hash] attributes Optional attributes for the message.
      #
      # @return [Message, Array<Message>] Returns the published message when
      #   called without a block, or an array of messages when called with a
      #   block.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish "new-message"
      #
      # @example Additionally, a message can be published with attributes:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish "new-message",
      #                       foo: :bar,
      #                       this: :that
      #
      # @example Multiple messages can be sent at the same time using a block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msgs = topic.publish do |batch|
      #     batch.publish "new-message-1", foo: :bar
      #     batch.publish "new-message-2", foo: :baz
      #     batch.publish "new-message-3", foo: :bif
      #   end
      #
      def publish data = nil, attributes = {}
        ensure_connection!
        batch = Batch.new data, attributes
        yield batch if block_given?
        return nil if batch.messages.count.zero?
        publish_batch_messages batch
      end

      ##
      # Gets the access control policy.
      #
      # @param [Boolean] force Force the latest policy to be retrieved from the
      #   Pub/Sub service when +true. Otherwise the policy will be memoized to
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
      #   topic = pubsub.topic "my-topic"
      #   puts topic.policy["bindings"]
      #   puts topic.policy["rules"]
      #
      # @example Use `force` to retrieve the latest policy from the service:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   policy = topic.policy force: true
      #
      def policy force: nil
        @policy = nil if force
        @policy ||= begin
          ensure_connection!
          resp = connection.get_topic_policy name
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
      #   topic = pubsub.topic "my-topic"
      #   topic.policy = viewer_policy
      #
      def policy= new_policy
        ensure_connection!
        resp = connection.set_topic_policy name, new_policy
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
      # @param [String, Array<String>] *permissions The set of permissions to
      #   check access for. Permissions with wildcards (such as `*` or
      #   `storage.*`) are not allowed.
      #
      # @return [Array<Strings>] The permissions that have access.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #   topic = pubsub.topic "my-topic"
      #   perms = topic.test_permissions "projects.topic.list",
      #                                  "projects.topic.publish"
      #   perms.include? "projects.topic.list" #=> true
      #   perms.include? "projects.topic.publish" #=> false
      #
      def test_permissions *permissions
        permissions = Array(permissions).flatten
        ensure_connection!
        resp = connection.test_topic_permissions name, permissions
        if resp.success?
          Array(resp.data["permissions"])
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines whether the topic exists in the Pub/Sub service.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.exists? #=> true
      #
      def exists?
        # Always true if we have a gapi object
        return true unless @gapi.nil?
        # If we have a value, return it
        return @exists unless @exists.nil?
        ensure_gapi!
        @exists = !@gapi.nil?
      end

      ##
      # @private
      # Determines whether the topic object was created with an HTTP call.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.lazy? #=> false
      #
      def lazy?
        @gapi.nil?
      end

      ##
      # @private New {Topic} from a Google API Client object.
      def self.from_gapi gapi, conn
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      ##
      # Ensures a Google API object exists.
      def ensure_gapi!
        ensure_connection!
        return @gapi if @gapi
        resp = connection.get_topic @name
        @gapi = resp.data if resp.success?
      end

      ##
      # Call the publish API with arrays of data data and attrs.
      def publish_batch_messages batch
        resp = connection.publish name, batch.messages
        if resp.success?
          batch.to_gcloud_messages resp.data["messageIds"]
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Batch object used to publish multiple messages at once.
      class Batch
        ##
        # @private The messages to publish
        attr_reader :messages

        ##
        # @private Create a new instance of the object.
        def initialize data = nil, attributes = {}
          @messages = []
          @mode = :batch
          return if data.nil?
          @mode = :single
          publish data, attributes
        end

        ##
        # Add multiple messages to the topic.
        # All messages added will be published at once.
        # See {Gcloud::Pubsub::Topic#publish}
        def publish data, attributes = {}
          @messages << [data, attributes]
        end

        ##
        # @private Create Message objects with message ids.
        def to_gcloud_messages message_ids
          msgs = @messages.zip(Array(message_ids)).map do |arr, id|
            Message.from_gapi "data"       => arr[0],
                              "attributes" => jsonify_hash(arr[1]),
                              "messageId"  => id
          end
          # Return just one Message if a single publish,
          # otherwise return the array of Messages.
          if @mode == :single && msgs.count <= 1
            msgs.first
          else
            msgs
          end
        end

        protected

        ##
        # Make the hash look like it was returned from the Cloud API.
        def jsonify_hash hash
          hash = (hash || {}).to_h
          return hash if hash.empty?
          JSON.parse(JSON.dump(hash))
        end
      end
    end
  end
end
