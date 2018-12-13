# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/cloud/pubsub/topic/list"
require "google/cloud/pubsub/async_publisher"
require "google/cloud/pubsub/batch_publisher"
require "google/cloud/pubsub/subscription"
require "google/cloud/pubsub/policy"

module Google
  module Cloud
    module Pubsub
      ##
      # # Topic
      #
      # A named resource to which messages are published.
      #
      # See {Project#create_topic} and {Project#topic}.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      class Topic
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google::Pubsub::V1::Topic object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Topic} object.
        def initialize
          @service = nil
          @grpc = nil
          @resource_name = nil
          @exists = nil
          @async_opts = {}
        end

        ##
        # AsyncPublisher object used to publish multiple messages in batches.
        #
        # @return [AsyncPublisher] Returns publisher object if calls to
        #   {#publish_async} have been made, returns `nil` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.publish_async "task completed" do |result|
        #     if result.succeeded?
        #       log_publish_success result.data
        #     else
        #       log_publish_failure result.data, result.error
        #     end
        #   end
        #
        #   topic.async_publisher.stop.wait!
        #
        def async_publisher
          @async_publisher
        end

        ##
        # The name of the topic in the form of
        # "/projects/project-identifier/topics/topic-name".
        #
        # @return [String]
        #
        def name
          return @resource_name if reference?
          @grpc.name
        end

        ##
        # A hash of user-provided labels associated with this topic. Labels can
        # be used to organize and group topics. See [Creating and Managing
        # Labels](https://cloud.google.com/pubsub/docs/labels).
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to update the labels for this topic.
        #
        # Makes an API call to retrieve the endpoint value when called on a
        # reference object. See {#reference?}.
        #
        # @return [Hash] The frozen labels hash.
        #
        def labels
          ensure_grpc!
          @grpc.labels.to_h.freeze
        end

        ##
        # Sets the hash of user-provided labels associated with this
        # topic. Labels can be used to organize and group topics.
        # Label keys and values can be no longer than 63 characters, can only
        # contain lowercase letters, numeric characters, underscores and dashes.
        # International characters are allowed. Label values are optional. Label
        # keys must start with a letter and each label in the list must have a
        # different key. See [Creating and Managing
        # Labels](https://cloud.google.com/pubsub/docs/labels).
        #
        # @param [Hash] new_labels The new labels hash.
        #
        def labels= new_labels
          raise ArgumentError, "Value must be a Hash" if new_labels.nil?
          update_grpc = Google::Pubsub::V1::Topic.new \
            name: name, labels: new_labels
          @grpc = service.update_topic update_grpc, :labels
          @resource_name = nil
        end

        ##
        # Permanently deletes the topic.
        #
        # @return [Boolean] Returns `true` if the topic was deleted.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.delete
        #
        def delete
          ensure_service!
          service.delete_topic name
          true
        end

        ##
        # Creates a new {Subscription} object on the current Topic.
        #
        # @param [String] subscription_name Name of the new subscription. Must
        #   start with a letter, and contain only letters ([A-Za-z]), numbers
        #   ([0-9], dashes (-), underscores (_), periods (.), tildes (~), plus
        #   (+) or percent signs (%). It must be between 3 and 255 characters in
        #   length, and it must not start with "goog". Required.
        # @param [Integer] deadline The maximum number of seconds after a
        #   subscriber receives a message before the subscriber should
        #   acknowledge the message.
        # @param [Boolean] retain_acked Indicates whether to retain acknowledged
        #   messages. If `true`, then messages are not expunged from the
        #   subscription's backlog, even if they are acknowledged, until they
        #   fall out of the `retention` window. Default is `false`.
        # @param [Numeric] retention How long to retain unacknowledged messages
        #   in the subscription's backlog, from the moment a message is
        #   published. If `retain_acked` is `true`, then this also configures
        #   the retention of acknowledged messages, and thus configures how far
        #   back in time a {Subscription#seek} can be done. Cannot be more than
        #   604,800 seconds (7 days) or less than 600 seconds (10 minutes).
        #   Default is 604,800 seconds (7 days).
        # @param [String] endpoint A URL locating the endpoint to which messages
        #   should be pushed.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the subscription. You can use these to organize and group your
        #   subscriptions. Label keys and values can be no longer than 63
        #   characters, can only contain lowercase letters, numeric characters,
        #   underscores and dashes. International characters are allowed. Label
        #   values are optional. Label keys must start with a letter and each
        #   label in the list must have a different key. See [Creating and
        #   Managing Labels](https://cloud.google.com/pubsub/docs/labels).
        #
        # @return [Google::Cloud::Pubsub::Subscription]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   sub = topic.subscribe "my-topic-sub"
        #   sub.name # => "my-topic-sub"
        #
        # @example Wait 2 minutes for acknowledgement and push all to endpoint:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   sub = topic.subscribe "my-topic-sub",
        #                         deadline: 120,
        #                         endpoint: "https://example.com/push"
        #
        def subscribe subscription_name, deadline: nil, retain_acked: false,
                      retention: nil, endpoint: nil, labels: nil
          ensure_service!
          options = { deadline: deadline, retain_acked: retain_acked,
                      retention: retention, endpoint: endpoint, labels: labels }
          grpc = service.create_subscription name, subscription_name, options
          Subscription.from_grpc grpc, service
        end
        alias create_subscription subscribe
        alias new_subscription subscribe

        ##
        # Retrieves subscription by name.
        #
        # @param [String] subscription_name Name of a subscription.
        # @param [Boolean] skip_lookup Optionally create a {Subscription} object
        #   without verifying the subscription resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::Pubsub::Subscription, nil] Returns `nil` if
        #   the subscription does not exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   sub = topic.subscription "my-topic-sub"
        #   sub.name #=> "projects/my-project/subscriptions/my-topic-sub"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   # No API call is made to retrieve the subscription information.
        #   sub = topic.subscription "my-topic-sub", skip_lookup: true
        #   sub.name #=> "projects/my-project/subscriptions/my-topic-sub"
        #
        def subscription subscription_name, skip_lookup: nil
          ensure_service!
          if skip_lookup
            return Subscription.from_name subscription_name, service
          end
          grpc = service.get_subscription subscription_name
          Subscription.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_subscription subscription
        alias find_subscription subscription

        ##
        # Retrieves a list of subscription names for the given project.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `subscriptions`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @param [Integer] max Maximum number of subscriptions to return.
        #
        # @return [Array<Subscription>] (See {Subscription::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   subscriptions = topic.subscriptions
        #   subscriptions.each do |subscription|
        #     puts subscription.name
        #   end
        #
        # @example Retrieve all subscriptions: (See {Subscription::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   subscriptions = topic.subscriptions
        #   subscriptions.all do |subscription|
        #     puts subscription.name
        #   end
        #
        def subscriptions token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_topics_subscriptions name, options
          Subscription::List.from_topic_grpc grpc, service, name, max
        end
        alias find_subscriptions subscriptions
        alias list_subscriptions subscriptions

        ##
        # Publishes one or more messages to the topic.
        #
        # The message payload must not be empty; it must contain either a
        # non-empty data field, or at least one attribute.
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @yield [batch] a block for publishing multiple messages in one
        #   request
        # @yieldparam [BatchPublisher] batch the topic batch publisher
        #   object
        #
        # @return [Message, Array<Message>] Returns the published message when
        #   called without a block, or an array of messages when called with a
        #   block.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msg = topic.publish "task completed"
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   msg = topic.publish file
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msg = topic.publish "task completed",
        #                       foo: :bar,
        #                       this: :that
        #
        # @example Multiple messages can be sent at the same time using a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msgs = topic.publish do |t|
        #     t.publish "task 1 completed", foo: :bar
        #     t.publish "task 2 completed", foo: :baz
        #     t.publish "task 3 completed", foo: :bif
        #   end
        #
        def publish data = nil, attributes = {}
          ensure_service!
          batch = BatchPublisher.new data, attributes
          yield batch if block_given?
          return nil if batch.messages.count.zero?
          publish_batch_messages batch
        end

        ##
        # Publishes a message asynchronously to the topic.
        #
        # The message payload must not be empty; it must contain either a
        # non-empty data field, or at least one attribute.
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @yield [result] the callback for when the message has been published
        # @yieldparam [PublishResult] result the result of the asynchronous
        #   publish
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.publish_async "task completed" do |result|
        #     if result.succeeded?
        #       log_publish_success result.data
        #     else
        #       log_publish_failure result.data, result.error
        #     end
        #   end
        #
        #   topic.async_publisher.stop.wait!
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   topic.publish_async file
        #
        #   topic.async_publisher.stop.wait!
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.publish_async "task completed",
        #                       foo: :bar, this: :that
        #
        #   topic.async_publisher.stop.wait!
        #
        def publish_async data = nil, attributes = {}, &block
          ensure_service!

          @async_publisher ||= AsyncPublisher.new(name, service, @async_opts)
          @async_publisher.publish data, attributes, &block
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this topic.
        #
        # @see https://cloud.google.com/pubsub/docs/reference/rpc/google.iam.v1#iampolicy
        #   google.iam.v1.IAMPolicy
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Pub/Sub service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   topic
        #
        # @return [Policy] the current Cloud IAM Policy for this topic
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   policy = topic.policy
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end
        #
        def policy
          ensure_service!
          grpc = service.get_topic_policy name
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          update_policy policy
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this topic. The policy should be read from {#policy}. See
        # {Google::Cloud::Pubsub::Policy} for an explanation of the policy
        # `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @see https://cloud.google.com/pubsub/docs/reference/rpc/google.iam.v1#iampolicy
        #   google.iam.v1.IAMPolicy
        #
        # @param [Policy] new_policy a new or modified Cloud IAM Policy for this
        #   topic
        #
        # @return [Policy] the policy returned by the API update operation
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   policy = topic.policy # API call
        #
        #   policy.add "roles/owner", "user:owner@example.com"
        #
        #   topic.update_policy policy # API call
        #
        def update_policy new_policy
          ensure_service!
          grpc = service.set_topic_policy name, new_policy.to_grpc
          @policy = Policy.from_grpc grpc
        end
        alias policy= update_policy

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
        #   The permissions that can be checked on a topic are:
        #
        #   * pubsub.topics.publish
        #   * pubsub.topics.attachSubscription
        #   * pubsub.topics.get
        #   * pubsub.topics.delete
        #   * pubsub.topics.update
        #   * pubsub.topics.getIamPolicy
        #   * pubsub.topics.setIamPolicy
        #
        # @return [Array<Strings>] The permissions that have access.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   topic = pubsub.topic "my-topic"
        #   perms = topic.test_permissions "pubsub.topics.get",
        #                                  "pubsub.topics.publish"
        #   perms.include? "pubsub.topics.get" #=> true
        #   perms.include? "pubsub.topics.publish" #=> false
        #
        def test_permissions *permissions
          permissions = Array(permissions).flatten
          permissions = Array(permissions).flatten
          ensure_service!
          grpc = service.test_topic_permissions name, permissions
          grpc.permissions
        end

        ##
        # Determines whether the topic exists in the Pub/Sub service.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.exists? #=> true
        #
        def exists?
          # Always true if the object is not set as reference
          return true unless reference?
          # If we have a value, return it
          return @exists unless @exists.nil?
          ensure_grpc!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # Determines whether the topic object was created without retrieving the
        # resource representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the topic was created without a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic", skip_lookup: true
        #   topic.reference? #=> true
        #
        def reference?
          @grpc.nil?
        end

        ##
        # Determines whether the topic object was created with a resource
        # representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the topic was created with a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.resource? #=> true
        #
        def resource?
          !@grpc.nil?
        end

        ##
        # @private New Topic from a Google::Pubsub::V1::Topic object.
        def self.from_grpc grpc, service, async: nil
          new.tap do |t|
            t.grpc = grpc
            t.service = service
            t.instance_variable_set :@async_opts, async if async
          end
        end

        ##
        # @private New reference {Topic} object without making an HTTP request.
        def self.from_name name, service, options = {}
          name = service.topic_path name, options
          from_grpc(nil, service).tap do |t|
            t.instance_variable_set :@resource_name, name
          end
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # Ensures a Google::Pubsub::V1::Topic object exists.
        def ensure_grpc!
          ensure_service!
          @grpc = service.get_topic name if reference?
          @resource_name = nil
        end

        ##
        # Call the publish API with arrays of data data and attrs.
        def publish_batch_messages batch
          grpc = service.publish name, batch.messages
          batch.to_gcloud_messages Array(grpc.message_ids)
        end
      end
    end
  end
end
