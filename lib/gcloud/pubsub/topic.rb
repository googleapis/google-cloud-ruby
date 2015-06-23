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
    # = Topic
    #
    # Represents a Pubsub topic. Belongs to a Project and creates Subscription
    # and publishes messages.
    #
    #   require "glcoud/pubsub"
    #
    #   pubsub = Gcloud.pubsub
    #
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    class Topic
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Topic object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The name of the topic in the form of
      # "/projects/project-identifier/topics/topic-name".
      def name
        @gapi["name"]
      end

      ##
      # Permenently deletes the topic.
      # The topic must be empty.
      #
      # === Returns
      #
      # +true+ if the topic was deleted.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
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
          ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new Subscription object on the current Topic.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. If the name is not provided in the request,
      #   the server will assign a random name for this subscription on the same
      #   project as the topic. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:deadline]+::
      #   The maximum number of seconds after a subscriber receives a message
      #   before the subscriber should acknowledge the message. (+Integer+)
      # +options [:endpoint]+::
      #   A URL locating the endpoint to which messages should be pushed.
      #   e.g. "https://example.com/push" (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription
      #
      # === Examples
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub"
      #   puts sub.name # => "my-topic-sub"
      #
      # The name is optional, and will be generated if not given.
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub"
      #   puts sub.name # => "generated-sub-name"
      #
      # The subscription can be created that waits two minutes for
      # acknowledgement and pushed all messages to an endpoint
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub",
      #                         deadline: 120,
      #                         endpoint: "https://example.com/push"
      #
      def subscribe subscription_name = nil, options = {}
        ensure_connection!
        resp = connection.create_subscription name, subscription_name, options
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          # TODO: Handle ALREADY_EXISTS and NOT_FOUND
          fail ApiError.from_response(resp)
        end
      end
      alias_method :create_subscription, :subscribe
      alias_method :new_subscription, :subscribe

      ##
      # Retrieves a subscription by name.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription or nil if subscription does not exist
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   subscription = topic.subscription "my-topic-subscription"
      #   puts subscription.name
      #
      def subscription subscription_name
        ensure_connection!
        resp = connection.get_subscription subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          nil
        end
      end
      alias_method :find_subscription, :subscription
      alias_method :get_subscription, :subscription

      ##
      # Retrieves a list of subscription names for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:token]+::
      #   The +token+ value returned by the last call to +subscriptions+;
      #   indicates that this is a continuation of a call, and that the system
      #   should return the next page of data. (+String+)
      # +options [:max]+::
      #   Maximum number of subscriptions to return. (+Integer+)
      #
      # === Returns
      #
      # Array of subscription name strings, not Subscription objects
      #
      # === Examples
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   subscription = topic.subscriptions
      #   subscriptions.each do |subscription|
      #     puts subscription.name
      #   end
      #
      # If you have a significant number of subscriptions, you may need to
      # paginate through them: (See Subscription::List#token)
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
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
      def subscriptions options = {}
        ensure_connection!
        resp = connection.list_topics_subscriptions name, options
        if resp.success?
          Subscription::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_subscriptions, :subscriptions
      alias_method :list_subscriptions, :subscriptions

      ##
      # Publishes one or more messages to the topic.
      #
      # === Parameters
      #
      # +message+::
      #   The message payload. (+String+)
      # +attributes+::
      #   Optional attributes for the message. (+Hash+)
      #
      # === Returns
      #
      # Message object when called without a block,
      # Array of Message objects when called with a block
      #
      # === Examples
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish "new-message"
      #
      # Additionally, a message can be published with attributes:
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish "new-message",
      #                       foo: :bar,
      #                       this: :that
      #
      # Multiple messages can be published at the same time by passing a block:
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish do |batch|
      #     batch.publish "new-message-1", foo: :bar
      #     batch.publish "new-message-2", foo: :baz
      #     batch.publish "new-message-3", foo: :bif
      #   end
      #
      def publish message = nil, attributes = {}
        ensure_connection!
        batch = Batch.new message, attributes
        yield batch if block_given?
        return nil if batch.messages.count.zero?
        publish_batch_messages batch
      end

      ##
      # Determines whether the topic exists in the Pub/Sub service.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.exists? #=> true
      #
      def exists?
        true
      end

      ##
      # Determines whether the topic object was created with an HTTP call.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.lazy? #=> false
      #
      def lazy? #:nodoc:
        false
      end

      ##
      # Determines whether the lazy topic object should create a topic on the
      # Pub/Sub service.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.autocreate? #=> true
      #
      def autocreate? #:nodoc:
        false
      end

      ##
      # New Topic from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
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
      # Call the publish API with arrays of message data and attrs.
      def publish_batch_messages batch
        resp = connection.publish name, batch.messages
        if resp.success?
          batch.to_gcloud_messages resp.data["messageIds"]
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # Batch object used to publish multiple messages at once.
      class Batch
        ##
        # The messages to publish
        attr_reader :messages #:nodoc:

        ##
        # Create a new instance of the object.
        def initialize message = nil, attributes = {} #:nodoc:
          @messages = []
          @mode = :batch
          return if message.nil?
          @mode = :single
          publish message, attributes
        end

        ##
        # Add multiple messages to the topic.
        # All messages added will be published at once.
        # See Gcloud::Pubsub::Topic#publish
        def publish message, attributes = {}
          @messages << [message, attributes]
        end

        ##
        # Create Message objects with message ids.
        def to_gcloud_messages message_ids #:nodoc:
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
          if hash.respond_to? :to_h
            hash = hash.to_h
          else
            hash = Hash.try_convert(hash) || {}
          end
          return hash if hash.empty?
          JSON.parse(JSON.dump(hash))
        end
      end
    end
  end
end
