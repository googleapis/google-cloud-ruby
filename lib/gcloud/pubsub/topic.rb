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
    # A named resource to which messages are published.
    #
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
        @name = nil
        @exists = nil
      end

      ##
      # New lazy Topic object without making an HTTP request.
      def self.new_lazy name, conn, options = {} #:nodoc:
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
      # === Returns
      #
      # +true+ if the topic was deleted.
      #
      # === Example
      #
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
      # Creates a new Subscription object on the current Topic.
      #
      # === Parameters
      #
      # +subscription_name+::
      #   Name of the new subscription. Must start with a letter, and contain
      #   only letters ([A-Za-z]), numbers ([0-9], dashes (-), underscores (_),
      #   periods (.), tildes (~), plus (+) or percent signs (%). It must be
      #   between 3 and 255 characters in length, and it must not start with
      #   "goog". (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:deadline]</code>::
      #   The maximum number of seconds after a subscriber receives a message
      #   before the subscriber should acknowledge the message. (+Integer+)
      # <code>options[:endpoint]</code>::
      #   A URL locating the endpoint to which messages should be pushed.
      #   e.g. "https://example.com/push" (+String+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub"
      #   puts sub.name # => "my-topic-sub"
      #
      # The name is optional, and will be generated if not given.
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
      # The subscription can be created that waits two minutes for
      # acknowledgement and pushed all messages to an endpoint
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
      def subscribe subscription_name, options = {}
        ensure_connection!
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
      # === Parameters
      #
      # +subscription_name+::
      #   Name of a subscription. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:skip_lookup]</code>::
      #   Optionally create a Subscription object without verifying the
      #   subscription resource exists on the Pub/Sub service. Calls made on
      #   this object will raise errors if the service resource does not exist.
      #   Default is +false+. (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Pubsub::Subscription or nil if subscription does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   subscription = topic.subscription "my-topic-subscription"
      #   puts subscription.name
      #
      # The lookup against the Pub/Sub service can be skipped using the
      # +skip_lookup+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   # No API call is made to retrieve the subscription information.
      #   subscription = pubsub.subscription "my-sub", skip_lookup: true
      #   puts subscription.name
      #
      def subscription subscription_name, options = {}
        ensure_connection!
        if options[:skip_lookup]
          return Subscription.new_lazy(subscription_name, connection, options)
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
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   The +token+ value returned by the last call to +subscriptions+;
      #   indicates that this is a continuation of a call, and that the system
      #   should return the next page of data. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of subscriptions to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Subscription objects (See Subscription::List)
      #
      # === Examples
      #
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
      # If you have a significant number of subscriptions, you may need to
      # paginate through them: (See Subscription::List#token)
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
      def subscriptions options = {}
        ensure_connection!
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
      # === Parameters
      #
      # +data+::
      #   The message data. (+String+)
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   msg = topic.publish "new-message"
      #
      # Additionally, a message can be published with attributes:
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
      # Multiple messages can be published at the same time by passing a block:
      #
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
      #     "etag"=>"CAE=",
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }]
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
      #   topic = pubsub.topic "my-topic"
      #   puts topic.policy["bindings"]
      #   puts topic.policy["rules"]
      #
      # To retrieve the latest policy from the Pub/Sub service, use the +force+
      # flag.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   policy = topic.policy force: true
      #
      def policy options = {}
        @policy = nil if options[:force]
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
      # === Parameters
      #
      # +new_policy+::
      #   A hash that conforms to the following structure:
      #
      #     {
      #       "bindings" => [{
      #         "role" => "roles/viewer",
      #         "members" => ["serviceAccount:your-service-account"]
      #       }]
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
      # Tests the specified permissions against the {Cloud
      # IAM}[https://cloud.google.com/iam/] access control policy. See
      # {Managing Policies}[https://cloud.google.com/iam/docs/managing-policies]
      # for more information.
      #
      # === Parameters
      #
      # +permissions+::
      #   The set of permissions to check access for. Permissions with wildcards
      #   (such as +*+ or +storage.*+) are not allowed.
      #   (String or Array of Strings)
      #
      # === Returns
      #
      # The permissions that have access. (Array of Strings)
      #
      # === Example
      #
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
      # === Example
      #
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
      # Determines whether the topic object was created with an HTTP call.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.lazy? #=> false
      #
      def lazy? #:nodoc:
        @gapi.nil?
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
        # The messages to publish
        attr_reader :messages #:nodoc:

        ##
        # Create a new instance of the object.
        def initialize data = nil, attributes = {} #:nodoc:
          @messages = []
          @mode = :batch
          return if data.nil?
          @mode = :single
          publish data, attributes
        end

        ##
        # Add multiple messages to the topic.
        # All messages added will be published at once.
        # See Gcloud::Pubsub::Topic#publish
        def publish data, attributes = {}
          @messages << [data, attributes]
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
