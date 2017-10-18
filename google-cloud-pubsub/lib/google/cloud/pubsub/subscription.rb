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


require "google/cloud/pubsub/convert"
require "google/cloud/errors"
require "google/cloud/pubsub/subscription/list"
require "google/cloud/pubsub/received_message"
require "google/cloud/pubsub/snapshot"
require "google/cloud/pubsub/subscriber"

module Google
  module Cloud
    module Pubsub
      ##
      # # Subscription
      #
      # A named resource representing the stream of messages from a single,
      # specific {Topic}, to be delivered to the subscribing application.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   subscriber = sub.listen do |msg|
      #     # process msg
      #     msg.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   subscriber.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   subscriber.stop.wait!
      #
      class Subscription
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The gRPC Google::Pubsub::V1::Subscription object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Subscription} object.
        def initialize
          @service = nil
          @grpc = nil
          @lazy = nil
          @exists = nil
        end

        ##
        # The name of the subscription.
        def name
          @grpc.name
        end

        ##
        # The {Topic} from which this subscription receives messages.
        #
        # @return [Topic]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.topic.name #=> "projects/my-project/topics/my-topic"
        #
        def topic
          ensure_grpc!
          Topic.new_lazy @grpc.topic, service
        end

        ##
        # This value is the maximum number of seconds after a subscriber
        # receives a message before the subscriber should acknowledge the
        # message.
        def deadline
          ensure_grpc!
          @grpc.ack_deadline_seconds
        end

        def deadline= new_deadline
          update_grpc = @grpc.dup
          update_grpc.ack_deadline_seconds = new_deadline
          @grpc = service.update_subscription update_grpc,
                                              :ack_deadline_seconds
          @lazy = nil
          self
        end

        ##
        # Indicates whether to retain acknowledged messages. If `true`, then
        # messages are not expunged from the subscription's backlog, even if
        # they are acknowledged, until they fall out of the
        # {#retention_duration} window. Default is `false`.
        #
        # @return [Boolean] Returns `true` if acknowledged messages are
        #   retained.
        #
        def retain_acked
          ensure_grpc!
          @grpc.retain_acked_messages
        end

        def retain_acked= new_retain_acked
          update_grpc = @grpc.dup
          update_grpc.retain_acked_messages = !(!new_retain_acked)
          @grpc = service.update_subscription update_grpc,
                                              :retain_acked_messages
          @lazy = nil
          self
        end

        ##
        # How long to retain unacknowledged messages in the subscription's
        # backlog, from the moment a message is published. If
        # {#retain_acked} is `true`, then this also configures the retention of
        # acknowledged messages, and thus configures how far back in time a
        # {#seek} can be done. Cannot be more than 604,800 seconds (7 days) or
        # less than 600 seconds (10 minutes). Default is 604,800 seconds (7
        # days).
        #
        # @return [Numeric] The message retention duration in seconds.
        #
        def retention
          ensure_grpc!
          Convert.duration_to_number @grpc.message_retention_duration
        end

        def retention= new_retention
          update_grpc = @grpc.dup
          update_grpc.message_retention_duration = \
            Convert.number_to_duration new_retention
          @grpc = service.update_subscription update_grpc,
                                              :message_retention_duration
          @lazy = nil
          self
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
          ensure_service!
          service.modify_push_config name, new_endpoint, {}
          @grpc.push_config = Google::Pubsub::V1::PushConfig.new(
            push_endpoint: new_endpoint,
            attributes: {}
          ) if @grpc
        end

        ##
        # Determines whether the subscription exists in the Pub/Sub service.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.exists? #=> true
        #
        def exists?
          # Always true if the object is not set as lazy
          return true unless lazy?
          # If we have a value, return it
          return @exists unless @exists.nil?
          ensure_grpc!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # @private
        # Determines whether the subscription object was created with an
        # HTTP call.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.get_subscription "my-topic-sub"
        #   sub.lazy? #=> nil
        #
        def lazy?
          @lazy
        end

        ##
        # Deletes an existing subscription.
        # All pending messages in the subscription are immediately dropped.
        #
        # @return [Boolean] Returns `true` if the subscription was deleted.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.delete
        #
        def delete
          ensure_service!
          service.delete_subscription name
          true
        end

        ##
        # Pulls messages from the server. Returns an empty list if there are no
        # messages available in the backlog. Raises an ApiError with status
        # `UNAVAILABLE` if there are too many concurrent pull requests pending
        # for the given subscription.
        #
        # See also {#listen} for the preferred way to process messages as they
        # become available.
        #
        # @param [Boolean] immediate When `true` the system will respond
        #   immediately even if it is not able to return messages. When `false`
        #   the system is allowed to wait until it can return least one message.
        #   No messages are returned when a request times out. The default value
        #   is `true`.
        #
        #   See also {#listen} for the preferred way to process messages as they
        #   become available.
        # @param [Integer] max The maximum number of messages to return for this
        #   request. The Pub/Sub system may return fewer than the number
        #   specified. The default value is `100`, the maximum value is `1000`.
        #
        # @return [Array<Google::Cloud::Pubsub::ReceivedMessage>]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.pull.each { |msg| msg.acknowledge! }
        #
        # @example A maximum number of messages returned can also be specified:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.pull(max: 10).each { |msg| msg.acknowledge! }
        #
        # @example The call can block until messages are available:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   msgs = sub.pull immediate: false
        #   msgs.each { |msg| msg.acknowledge! }
        #
        def pull immediate: true, max: 100
          ensure_service!
          options = { immediate: immediate, max: max }
          list_grpc = service.pull name, options
          Array(list_grpc.received_messages).map do |msg_grpc|
            ReceivedMessage.from_grpc msg_grpc, self
          end
        rescue Google::Cloud::DeadlineExceededError
          []
        end

        ##
        # Pulls from the server while waiting for messages to become available.
        # This is the same as:
        #
        #   subscription.pull immediate: false
        #
        # See also {#listen} for the preferred way to process messages as they
        # become available.
        #
        # @param [Integer] max The maximum number of messages to return for this
        #   request. The Pub/Sub system may return fewer than the number
        #   specified. The default value is `100`, the maximum value is `1000`.
        #
        # @return [Array<Google::Cloud::Pubsub::ReceivedMessage>]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   msgs = sub.wait_for_messages
        #   msgs.each { |msg| msg.acknowledge! }
        #
        def wait_for_messages max: 100
          pull immediate: false, max: max
        end

        ##
        # Create a {Subscriber} object that receives  and processes messages
        # using the code provided in the callback.
        #
        # @param [Numeric] deadline The default number of seconds the stream
        #   will hold received messages before modifying the message's ack
        #   deadline. The minimum is 10, the maximum is 600. Default is
        #   {#deadline}. Optional.
        # @param [Integer] streams The number of concurrent streams to open to
        #   pull messages from the subscription. Default is 4. Optional.
        # @param [Integer] inventory The number of received messages to be
        #   collected by subscriber. Default is 1,000. Optional.
        # @param [Hash] threads The number of threads to create to handle
        #   concurrent calls by each stream opened by the subscriber. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #     * `:callback` (Integer) The number of threads used to handle the
        #       received messages. Default is 8.
        #     * `:push` (Integer) The number of threads to handle
        #       acknowledgement ({ReceivedMessage#ack!}) and delay messages
        #       ({ReceivedMessage#nack!}, {ReceivedMessage#delay!}). Default is
        #       4.
        #
        # @yield [msg] a block for processing new messages
        # @yieldparam [ReceivedMessage] msg the newly received message
        #
        # @return [Subscriber]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #
        #   subscriber = sub.listen do |msg|
        #     # process msg
        #     msg.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   subscriber.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop.wait!
        #
        # @example Configuring to increase concurrent callbacks:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #
        #   subscriber = sub.listen threads: { callback: 16 } do |msg|
        #     # store the message somewhere before acknowledging
        #     store_in_backend msg.data # takes a few seconds
        #     msg.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   subscriber.start
        #
        def listen deadline: nil, streams: nil, inventory: nil, threads: {},
                   &block
          ensure_service!
          deadline ||= self.deadline

          Subscriber.new name, block, deadline: deadline, streams: streams,
                                      inventory: inventory, threads: threads,
                                      service: service
        end

        ##
        # Acknowledges receipt of a message. After an ack,
        # the Pub/Sub system can remove the message from the subscription.
        # Acknowledging a message whose ack deadline has expired may succeed,
        # although the message may have been sent again.
        # Acknowledging a message more than once will not result in an error.
        # This is only used for messages received via pull.
        #
        # See also {ReceivedMessage#acknowledge!}.
        #
        # @param [ReceivedMessage, String] messages One or more
        #   {ReceivedMessage} objects or ack_id values.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   messages = sub.pull
        #   sub.acknowledge messages
        #
        def acknowledge *messages
          ack_ids = coerce_ack_ids messages
          return true if ack_ids.empty?
          ensure_service!
          service.acknowledge name, *ack_ids
          true
        end
        alias_method :ack, :acknowledge

        ##
        # Modifies the acknowledge deadline for messages.
        #
        # This indicates that more time is needed to process the messages, or to
        # make the messages available for redelivery if the processing was
        # interrupted.
        #
        # See also {ReceivedMessage#delay!}.
        #
        # @param [Integer] new_deadline The new ack deadline in seconds from the
        #   time this request is sent to the Pub/Sub system. Must be >= 0. For
        #   example, if the value is `10`, the new ack deadline will expire 10
        #   seconds after the call is made. Specifying `0` may immediately make
        #   the message available for another pull request.
        # @param [ReceivedMessage, String] messages One or more
        #   {ReceivedMessage} objects or ack_id values.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   messages = sub.pull
        #   sub.delay 120, messages
        #
        def delay new_deadline, *messages
          ack_ids = coerce_ack_ids messages
          ensure_service!
          service.modify_ack_deadline name, ack_ids, new_deadline
          true
        end
        alias_method :modify_ack_deadline, :delay

        ##
        # Creates a new {Snapshot} from the subscription. The created snapshot
        # is guaranteed to retain:
        #
        # * The existing backlog on the subscription. More precisely, this is
        #   defined as the messages in the subscription's backlog that are
        #   unacknowledged upon the successful completion of the
        #   `create_snapshot` operation; as well as:
        # * Any messages published to the subscription's topic following the
        #   successful completion of the `create_snapshot` operation.
        #
        # @param [String, nil] snapshot_name Name of the new snapshot. If the
        #   name is not provided, the server will assign a random name
        #   for this snapshot on the same project as the subscription. The
        #   format is `projects/{project}/snapshots/{snap}`. The name must start
        #   with a letter, and contain only letters ([A-Za-z]), numbers
        #   ([0-9], dashes (-), underscores (_), periods (.), tildes (~), plus
        #   (+) or percent signs (%). It must be between 3 and 255 characters in
        #   length, and it must not start with "goog". Optional.
        #
        # @return [Google::Cloud::Pubsub::Snapshot]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   snapshot = sub.create_snapshot "my-snapshot"
        #   snapshot.name #=> "projects/my-project/snapshots/my-snapshot"
        #
        # @example Without providing a name:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   snapshot = sub.create_snapshot
        #   snapshot.name #=> "projects/my-project/snapshots/gcr-analysis-..."
        #
        def create_snapshot snapshot_name = nil
          ensure_service!
          grpc = service.create_snapshot name, snapshot_name
          Snapshot.from_grpc grpc, service
        end
        alias_method :new_snapshot, :create_snapshot

        ##
        # Resets the subscription's backlog to a given {Snapshot} or to a point
        # in time, whichever is provided in the request.
        #
        # @param [Snapshot, String, Time] snapshot The `Snapshot` instance,
        #   snapshot name, or time to which to perform the seek.
        #   If the argument is a snapshot, the snapshot's topic must be the
        #   same as that of the subscription. If it is a time, messages retained
        #   in the subscription that were published before this time are marked
        #   as acknowledged, and messages retained in the subscription that were
        #   published after this time are marked as unacknowledged. Note that
        #   this operation affects only those messages retained in the
        #   subscription. For example, if the time corresponds to a point before
        #   the message retention window (or to a point before the system's
        #   notion of the subscription creation time), only retained messages
        #   will be marked as unacknowledged, and already-expunged messages will
        #   not be restored.
        #
        # @return [Boolean] Returns `true` if the seek was successful.
        #
        # @example Using a snapshot
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   snapshot = sub.create_snapshot
        #
        #   messages = sub.pull
        #   sub.acknowledge messages
        #
        #   sub.seek snapshot
        #
        # @example Using a time:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   time = Time.now
        #
        #   messages = sub.pull
        #   sub.acknowledge messages
        #
        #   sub.seek time
        #
        def seek snapshot
          ensure_service!
          service.seek name, snapshot
          true
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this subscription.
        #
        # @see https://cloud.google.com/pubsub/docs/reference/rpc/google.iam.v1#iampolicy
        #   google.iam.v1.IAMPolicy
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Pub/Sub service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   subscription
        #
        # @return [Policy] the current Cloud IAM Policy for this subscription
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-subscription"
        #
        #   policy = sub.policy
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-subscription"
        #
        #   sub.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end
        #
        def policy
          ensure_service!
          grpc = service.get_subscription_policy name
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          self.policy = policy
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this subscription. The policy should be read from
        # {#policy}. See {Google::Cloud::Pubsub::Policy} for an explanation of
        # the policy `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @see https://cloud.google.com/pubsub/docs/reference/rpc/google.iam.v1#iampolicy
        #   google.iam.v1.IAMPolicy
        #
        # @param [Policy] new_policy a new or modified Cloud IAM Policy for this
        #   subscription
        #
        # @return [Policy] the policy returned by the API update operation
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-subscription"
        #
        #   policy = sub.policy # API call
        #
        #   policy.add "roles/owner", "user:owner@example.com"
        #
        #   sub.policy = policy # API call
        #
        def policy= new_policy
          ensure_service!
          grpc = service.set_subscription_policy name, new_policy.to_grpc
          Policy.from_grpc grpc
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
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-subscription"
        #   perms = sub.test_permissions "pubsub.subscriptions.get",
        #                                "pubsub.subscriptions.consume"
        #   perms.include? "pubsub.subscriptions.get" #=> true
        #   perms.include? "pubsub.subscriptions.consume" #=> false
        #
        def test_permissions *permissions
          permissions = Array(permissions).flatten
          ensure_service!
          grpc = service.test_subscription_permissions name, permissions
          grpc.permissions
        end

        ##
        # @private New Subscription from a Google::Pubsub::V1::Subscription
        # object.
        def self.from_grpc grpc, service
          new.tap do |f|
            f.grpc = grpc
            f.service = service
          end
        end

        ##
        # @private New lazy {Topic} object without making an HTTP request.
        def self.new_lazy name, service, options = {}
          lazy_grpc = Google::Pubsub::V1::Subscription.new \
            name: service.subscription_path(name, options)
          from_grpc(lazy_grpc, service).tap do |s|
            s.instance_variable_set :@lazy, true
          end
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end

        ##
        # Ensures a Google::Pubsub::V1::Subscription object exists.
        def ensure_grpc!
          ensure_service!
          @grpc = service.get_subscription name if lazy?
          @lazy = nil
        end

        ##
        # Makes sure the values are the `ack_id`. If given several
        # {ReceivedMessage} objects extract the `ack_id` values.
        def coerce_ack_ids messages
          Array(messages).flatten.map do |msg|
            msg.respond_to?(:ack_id) ? msg.ack_id : msg.to_s
          end
        end
      end
    end
  end
end
