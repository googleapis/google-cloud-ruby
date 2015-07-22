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
require "gcloud/pubsub/received_message"

module Gcloud
  module Pubsub
    ##
    # = Subscription
    #
    # A named resource representing the stream of messages from a single,
    # specific topic, to be delivered to the subscribing application.
    #
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
      def self.new_lazy name, conn, options = {} #:nodoc:
        sub = new.tap do |f|
          f.gapi = nil
          f.connection = conn
        end
        sub.instance_eval do
          @name = conn.subscription_path(name, options)
        end
        sub
      end

      ##
      # The name of the subscription.
      def name
        @gapi ? @gapi["name"] : @name
      end

      ##
      # The Topic from which this subscription receives messages.
      #
      # === Returns
      #
      # Topic
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.topic.name #=> "projects/my-project/topics/my-topic"
      #
      def topic
        ensure_gapi!
        # Always disable autocreate, we don't want to recreate a topic that
        # was intentionally deleted.
        Topic.new_lazy @gapi["topic"], connection, autocreate: false
      end

      ##
      # This value is the maximum number of seconds after a subscriber receives
      # a message before the subscriber should acknowledge the message.
      def deadline
        ensure_gapi!
        @gapi["ackDeadlineSeconds"]
      end

      ##
      # Returns the URL locating the endpoint to which messages should be
      # pushed.
      def endpoint
        ensure_gapi!
        @gapi["pushConfig"]["pushEndpoint"] if @gapi["pushConfig"]
      end

      ##
      # Sets the URL locating the endpoint to which messages should be pushed.
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
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

      # rubocop:disable Metrics/MethodLength
      # Disabled rubocop because these lines are needed.

      ##
      # Pulls messages from the server. Returns an empty list if there are no
      # messages available in the backlog. Raises an ApiError with status
      # +UNAVAILABLE+ if there are too many concurrent pull requests pending
      # for the given subscription.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:immediate]</code>::
      #   When +true+ the system will respond immediately even if it is not able
      #   to return messages. When +false+ the system is allowed to wait until
      #   it can return least one message. No messages are returned when a
      #   request times out. The default value is +true+. (+Boolean+)
      # <code>options[:max]</code>::
      #   The maximum number of messages to return for this request. The Pub/Sub
      #   system may return fewer than the number specified. The default value
      #   is +100+, the maximum value is +1000+. (+Integer+)
      # <code>options[:autoack]</code>::
      #   Automatically acknowledge the message as it is pulled. The default
      #   value is +false+. (+Boolean+)
      #
      # === Returns
      #
      # Array of Gcloud::Pubsub::ReceivedMessage
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # A maximum number of messages returned can also be specified:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub", max: 10
      #   sub.pull.each { |msg| msg.acknowledge! }
      #
      # The call can block until messages are available by setting the
      # +:immediate+ option to +false+:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   msgs = sub.pull immediate: false
      #   msgs.each { |msg| msg.acknowledge! }
      #
      def pull options = {}
        ensure_connection!
        resp = connection.pull name, options
        if resp.success?
          messages = Array(resp.data["receivedMessages"]).map do |gapi|
            ReceivedMessage.from_gapi gapi, self
          end
          acknowledge messages if options[:autoack]
          messages
        else
          fail ApiError.from_response(resp)
        end
      rescue Faraday::TimeoutError
        []
      end

      # rubocop:enable Metrics/MethodLength

      ##
      # Pulls from the server while waiting for messages to become available.
      # This is the same as:
      #
      #   subscription.pull immediate: false
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:max]</code>::
      #   The maximum number of messages to return for this request. The Pub/Sub
      #   system may return fewer than the number specified. The default value
      #   is +100+, the maximum value is +1000+. (+Integer+)
      # <code>options[:autoack]</code>::
      #   Automatically acknowledge the message as it is pulled. The default
      #   value is +false+. (+Boolean+)
      #
      # === Returns
      #
      # Array of Gcloud::Pubsub::ReceivedMessage
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   msgs = sub.wait_for_messages
      #   msgs.each { |msg| msg.acknowledge! }
      #
      def wait_for_messages options = {}
        pull options.merge(immediate: false)
      end

      ##
      # Poll the backend for new messages. This runs a loop to ping the API,
      # blocking indefinitely, yielding retrieved messages as they are received.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:max]</code>::
      #   The maximum number of messages to return for this request. The Pub/Sub
      #   system may return fewer than the number specified. The default value
      #   is +100+, the maximum value is +1000+. (+Integer+)
      # <code>options[:autoack]</code>::
      #   Automatically acknowledge the message as it is pulled. The default
      #   value is +false+. (+Boolean+)
      # <code>options[:delay]</code>::
      #   The number of seconds to pause between requests when the Google Cloud
      #   service has no messages to return. The default value is +1+.
      #   (+Number+)
      #
      # === Examples
      #
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
      # The number of messages pulled per batch can be set with the +max+
      # option:
      #
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
      # Messages can be automatically acknowledged as they are pulled with the
      # +autoack+ option:
      #
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
      def listen options = {}
        delay = options.fetch(:delay, 1)
        loop do
          msgs = wait_for_messages options
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
      # === Parameters
      #
      # +messages+::
      #   One or more ReceivedMessage objects or ack_id values.
      #   (+ReceivedMessage+ or +ack_id+)
      #
      # === Example
      #
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
      #   to the Pub/Sub system. Must be >= 0. For example, if the value is
      #   +10+, the new ack deadline will expire 10 seconds after the call is
      #   made. Specifying +0+ may immediately make the messages available for
      #   another pull request. (+Integer+)
      # +messages+::
      #   One or more ReceivedMessage objects or ack_id values.
      #   (+ReceivedMessage+ or +ack_id+)
      #
      # === Example
      #
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
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:force]</code>::
      #   Force the latest policy to be retrieved from the Pub/Sub service when
      #   +true. Otherwise the policy will be memoized to reduce the number of
      #   API calls made to the Pub/Sub service. The default is +false+.
      #   (+Boolean+)
      #
      # === Returns
      #
      # A hash that conforms to the following structure:
      #
      #   {
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }],
      #     "rules" => []
      #   }
      #
      # === Examples
      #
      # By default, the policy values are memoized to reduce the number of API
      # calls to the Pub/Sub service.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.subscription "my-subscription"
      #   puts subscription.policy["bindings"]
      #   puts subscription.policy["rules"]
      #
      # To retrieve the latest policy from the Pub/Sub service, use the +force+
      # flag.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   subscription = pubsub.subscription "my-subscription"
      #   policy = subscription.policy force: true
      #
      def policy options = {}
        @policy = nil if options[:force]
        @policy ||= begin
          ensure_connection!
          resp = connection.get_subscription_policy name
          policy = resp.data["policy"]
          policy = policy.to_hash if policy.respond_to? :to_hash
          policy
        end
      end

      ##
      # Sets the access control policy.
      #
      # === Parameters
      #
      # +new_policy+::
      #   A hash that conforms to the following structure:
      #
      #     {
      #       "bindings" => [{
      #         "role" => "roles/viewer",
      #         "members" => ["serviceAccount:your-service-account"]
      #       }],
      #       "rules" => []
      #     }
      #
      # === Example
      #
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

      ##
      # Makes sure the values are the +ack_id+.
      # If given several ReceivedMessage objects extract the +ack_id+ values.
      def coerce_ack_ids messages
        Array(messages).flatten.map do |msg|
          msg.respond_to?(:ack_id) ? msg.ack_id : msg.to_s
        end
      end
    end
  end
end
