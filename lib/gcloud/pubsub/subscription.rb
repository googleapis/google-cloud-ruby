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

require "gcloud/pubsub/errors"
require "gcloud/pubsub/subscription/list"
require "gcloud/pubsub/event"

module Gcloud
  module Pubsub
    ##
    # = Subscription
    #
    # Represents a Pub/Sub subscription, contains the stream of messages from a
    # single, specific Topic, to be delivered to the subscribing application.
    #
    #   require "glcoud/pubsub"
    #
    #   pubsub = Gcloud.pubsub
    #
    #   sub = pubsub.subscription "my-topic-sub"
    #   msgs = sub.pull
    #   msgs.each { |msg| msg.acknowledge! }
    #
    class Subscription
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Subscription object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
        @name = nil
        @exists = nil
      end

      ##
      # New lazy Topic object without making an HTTP request.
      def self.new_lazy name, conn #:nodoc:
        sub = new.tap do |f|
          f.gapi = nil
          f.connection = conn
        end
        sub.instance_eval do
          @name = conn.subscription_path(name)
        end
        sub
      end

      ##
      # The name of the subscription.
      def name
        @gapi ? @gapi["name"] : @name
      end

      ##
      # The Topic from which this subscription is receiving messages.
      #
      # === Returns
      #
      # Topic
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.topic.name "projects/my-project/topics/my-topic"
      #
      def topic
        ensure_gapi!
        # Always disable autocreate, we don't want to recreate a topic that
        # was intentionally deleted.
        Topic.new_lazy @gapi["topic"], connection, false
      end

      ##
      # The maximum number of seconds after a subscriber receives a message
      # before the subscriber should acknowledge or nack the message.
      # If the ack deadline for a message passes without an ack or a nack,
      # the Pub/Sub system will eventually redeliver the message.
      # If a subscriber acknowledges after the deadline,
      # the Pub/Sub system may accept the ack,
      # but but the message may already have been sent again.
      # Multiple acks to the message are allowed.
      def deadline
        ensure_gapi!
        @gapi["ackDeadlineSeconds"]
      end

      ##
      # A URL locating the endpoint that messages are pushed.
      def endpoint
        ensure_gapi!
        @gapi["pushConfig"]["pushEndpoint"] if @gapi["pushConfig"]
      end

      ##
      # A URL locating the endpoint that messages are pushed.
      def endpoint= new_endpoint
        ensure_connection!
        resp = connection.modify_push_config name, new_endpoint, {}
        if resp.success?
          @gapi["pushConfig"]["pushEndpoint"] = new_endpoint if @gapi
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines whether the subscription exists in the Pub/Sub service.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.exists? #=> true
      #
      def exists?
        # Always true if we have a gapi object
        return true unless @gapi.nil?
        # If we have a value, return it
        return @exists unless @exists.nil?
        ensure_gapi!
        @exists = !@gapi.nil?
      rescue NotFoundError
        @exists = false
      end

      ##
      # Determines whether the subscription object was created with an
      # HTTP call.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.get_subscription "my-topic-sub"
      #   sub.lazy? #=> false
      #
      def lazy? #:nodoc:
        @gapi.nil?
      end

      ##
      # Deletes an existing subscription.
      # All pending messages in the subscription are immediately dropped.
      #
      # === Returns
      #
      # +true+ if the subscription was deleted.
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_subscription name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Pulls messages from the server. Returns an empty list if there are no
      # messages available in the backlog. The server may return UNAVAILABLE if
      # there are too many concurrent pull requests pending for the given
      # subscription.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:immediate]+::
      #   When +true+, the system will respond immediately, either with a
      #   message if available or +nil+ if no message is available.
      #   When not specified, or when +false+, the call will block until a
      #   message is available, or may return UNAVAILABLE if no messages become
      #   available within a reasonable amount of time. (+Boolean+)
      #   When +true+ the system will respond immediately even if it is not
      #   able to return a message. Otherwise the system is allowed to wait
      #   until at least one message is available.
      # +options [:max]+::
      #   The maximum number of messages to return for this request.
      #   The Pub/Sub system may return fewer than the number specified.
      #   (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Pubsub::Event
      #
      # === Examples
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # Results can be returned immediately with the +:immediate+ option:
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub", immediate: true
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # A maximum number of messages returned can also be speified:
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub", max: 10
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      def pull options = {}
        ensure_connection!
        resp = connection.pull name, options
        if resp.success?
          Array(resp.data["receivedMessages"]).map do |gapi|
            Event.from_gapi gapi, self
          end
        else
          fail ApiError.from_response(resp)
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
      # === Parameters
      #
      # +ack_ids+::
      #   One or more ack_id values. (+Event#ack_id+)
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   ack_ids = sub.pull.map { |msg| msg.ack_id }
      #   sub.acknowledge *ack_ids
      #
      def acknowledge *ack_ids
        ensure_connection!
        resp = connection.acknowledge name, *ack_ids
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :ack, :acknowledge

      ##
      # Modifies the acknowledge deadline for messages.
      #
      # This indicates that more time is needed to process the messages, or to
      # make the messages available for redelivery if the processing was
      # interrupted.
      #
      # === Parameters
      #
      # +new_deadline+::
      #   The new ack deadline in seconds from the time this request is sent
      #   to the Pub/Sub system. Must be >= 0. For example, if the value is 10,
      #   the new ack deadline will expire 10 seconds after the call is made.
      #   Specifying zero may immediately make the messages available for
      #   another pull request. (+Integer+)
      # +ack_ids+::
      #   One or more ack_id values. (+Event#ack_id+)
      #
      # === Example
      #
      #   require "glcoud/pubsub"
      #
      #   pubsub = Gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   events = sub.pull
      #   ack_ids = events.map { |msg| msg.ack_id }
      #   sub.delay 120, *ack_ids
      #
      def delay new_deadline, *ack_ids
        ensure_connection!
        resp = connection.modify_ack_deadline name, ack_ids, new_deadline
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Subscription from a Google API Client object.
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
    end
  end
end
