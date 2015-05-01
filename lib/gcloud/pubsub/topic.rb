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
    # Represents a Topic.
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
      #   topic.delete
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
      # Creates a subscription on a given topic for a given subscriber.
      #
      # If the name is not provided in the request, the server will assign a
      # random name for this subscription on the same project as the topic.
      def create_subscription subscription_name = nil
        ensure_connection!
        resp = connection.create_subscription name, subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          # TODO: Handle ALREADY_EXISTS and NOT_FOUND
          fail ApiError.from_response(resp)
        end
      end
      alias_method :subscribe, :create_subscription

      ##
      # Retrieves a subscription by name.
      def subscription subscription_name
        ensure_connection!
        resp = connection.get_subscription subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Retrieves a list of subscriptions names on the topic.
      # The values returned are strings, not Subscription objects.
      def subscriptions options = {}
        ensure_connection!
        resp = connection.list_topics_subscriptions name, options
        if resp.success?
          Subscription::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Adds one or more messages to the topic.
      # Returns NOT_FOUND if the topic does not exist.
      def publish message = nil, attributes = {}
        ensure_connection!
        batch = Batch.new message, attributes
        yield batch if block_given?
        return nil if batch.messages.count.zero?
        publish_batch_messages batch
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
          hash = hash.to_h
          return hash if hash.empty?
          JSON.parse(JSON.dump(hash))
        end
      end
    end
  end
end
