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
require "google/cloud/pubsub/async_publisher"
require "google/cloud/pubsub/batch_publisher"

module Google
  module Cloud
    module PubSub
      ##
      # # Publisher
      #
      # A {Publisher} is the primary interface for data plane operations on a
      # topic, including publishing messages, batching messages for higher
      # throughput, and managing ordering keys.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   publisher = pubsub.publisher "my-topic-only"
      #
      #   publisher.publish "task completed"
      #
      class Publisher
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google::Cloud::PubSub::V1::Topic object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Topic} object.
        def initialize
          @service = nil
          @grpc = nil
          @resource_name = nil
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
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   publisher.publish_async "task completed" do |result|
        #     if result.succeeded?
        #       log_publish_success result.data
        #     else
        #       log_publish_failure result.data, result.error
        #     end
        #   end
        #
        #   publisher.async_publisher.stop!
        #
        def async_publisher
          @async_publisher
        end

        ##
        # The name of the publisher.
        #
        # @return [String] A fully-qualified topic name in the form
        #   `projects/{project_id}/topics/{topic_id}`.
        #
        def name
          @grpc.name
        end

        ##
        # Publishes one or more messages to the publisher.
        #
        # The message payload must not be empty; it must contain either a
        # non-empty data field, or at least one attribute.
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
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
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   msg = publisher.publish "task completed"
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   msg = publisher.publish file
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   msg = publisher.publish "task completed",
        #                       foo: :bar,
        #                       this: :that
        #
        # @example Multiple messages can be sent at the same time using a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #
        #   msgs = publisher.publish do |p|
        #     p.publish "task 1 completed", foo: :bar
        #     p.publish "task 2 completed", foo: :baz
        #     p.publish "task 3 completed", foo: :bif
        #   end
        #
        # @example Ordered messages are supported using ordering_key:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-ordered-topic"
        #
        #   # Ensure that message ordering is enabled.
        #   publisher.enable_message_ordering!
        #
        #   # Publish an ordered message with an ordering key.
        #   publisher.publish "task completed",
        #                 ordering_key: "task-key"
        #
        def publish data = nil, attributes = nil, ordering_key: nil, compress: nil, compression_bytes_threshold: nil,
                    **extra_attrs, &block
          ensure_service!
          batch = BatchPublisher.new data,
                                     attributes,
                                     ordering_key,
                                     extra_attrs,
                                     compress: compress,
                                     compression_bytes_threshold: compression_bytes_threshold

          block&.call batch
          return nil if batch.messages.count.zero?
          batch.publish_batch_messages name, service
        end

        ##
        # Publishes a message asynchronously to the topic using
        # {#async_publisher}.
        #
        # The message payload must not be empty; it must contain either a
        # non-empty data field, or at least one attribute.
        #
        # Google Cloud Pub/Sub ordering keys provide the ability to ensure
        # related messages are sent to subscribers in the order in which they
        # were published. Messages can be tagged with an ordering key, a string
        # that identifies related messages for which publish order should be
        # respected. The service guarantees that, for a given ordering key and
        # publisher, messages are sent to subscribers in the order in which they
        # were published. Ordering does not require sacrificing high throughput
        # or scalability, as the service automatically distributes messages for
        # different ordering keys across subscribers.
        #
        # To use ordering keys, specify `ordering_key`. Before specifying
        # `ordering_key` on a message a call to `#enable_message_ordering!` must
        # be made or an error will be raised.
        #
        # @note At the time of this release, ordering keys are not yet publicly
        #   enabled and requires special project enablements.
        #
        # Publisher flow control limits the number of outstanding messages that
        # are allowed to wait to be published.
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
        # @yield [result] the callback for when the message has been published
        # @yieldparam [PublishResult] result the result of the asynchronous
        #   publish
        # @raise [Google::Cloud::PubSub::AsyncPublisherStopped] when the
        #   publisher is stopped. (See {AsyncPublisher#stop} and
        #   {AsyncPublisher#stopped?}.)
        # @raise [Google::Cloud::PubSub::OrderedMessagesDisabled] when
        #   publishing a message with an `ordering_key` but ordered messages are
        #   not enabled. (See {#message_ordering?} and
        #   {#enable_message_ordering!}.)
        # @raise [Google::Cloud::PubSub::OrderingKeyError] when publishing a
        #   message with an `ordering_key` that has already failed when
        #   publishing. Use {#resume_publish} to allow this `ordering_key` to be
        #   published again.
        # @raise [Google::Cloud::PubSub::FlowControlLimitError] when publish flow
        #   control limits are exceeded, and the `async` parameter key
        #   `flow_control.limit_exceeded_behavior` is set to `:error` or `:block`.
        #   If `flow_control.limit_exceeded_behavior` is set to `:block`, this error
        #   will be raised only when a limit would be exceeded by a single message.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   publisher.publish_async "task completed" do |result|
        #     if result.succeeded?
        #       log_publish_success result.data
        #     else
        #       log_publish_failure result.data, result.error
        #     end
        #   end
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   publisher.async_publisher.stop!
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   publisher.publish_async file
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   publisher.async_publisher.stop!
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   publisher.publish_async "task completed",
        #                       foo: :bar, this: :that
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   publisher.async_publisher.stop!
        #
        # @example Ordered messages are supported using ordering_key:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-ordered-topic"
        #
        #   # Ensure that message ordering is enabled.
        #   publisher.enable_message_ordering!
        #
        #   # Publish an ordered message with an ordering key.
        #   publisher.publish_async "task completed",
        #                       ordering_key: "task-key"
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   publisher.async_publisher.stop!
        #
        def publish_async data = nil, attributes = nil, ordering_key: nil, **extra_attrs, &callback
          ensure_service!

          @async_publisher ||= AsyncPublisher.new name, service, **@async_opts
          @async_publisher.publish data, attributes, ordering_key: ordering_key, **extra_attrs, &callback
        end

        ##
        # Enables message ordering for messages with ordering keys on the
        # {#async_publisher}. When enabled, messages published with the same
        # `ordering_key` will be delivered in the order they were published.
        #
        # @note At the time of this release, ordering keys are not yet publicly
        #   enabled and requires special project enablements.
        #
        # See {#message_ordering?}.  See {#publish_async},
        # {Subscriber#listen}, and {Message#ordering_key}.
        #
        def enable_message_ordering!
          @async_publisher ||= AsyncPublisher.new name, service, **@async_opts
          @async_publisher.enable_message_ordering!
        end

        ##
        # Whether message ordering for messages with ordering keys has been
        # enabled on the {#async_publisher}. When enabled, messages published
        # with the same `ordering_key` will be delivered in the order they were
        # published. When disabled, messages may be delivered in any order.
        #
        # See {#enable_message_ordering!}. See {#publish_async},
        # {Subscriber#listen}, and {Message#ordering_key}.
        #
        # @return [Boolean]
        #
        def message_ordering?
          @async_publisher ||= AsyncPublisher.new name, service, **@async_opts
          @async_publisher.message_ordering?
        end

        ##
        # Resume publishing ordered messages for the provided ordering key.
        #
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
        #
        # @return [boolean] `true` when resumed, `false` otherwise.
        #
        def resume_publish ordering_key
          @async_publisher ||= AsyncPublisher.new name, service, **@async_opts
          @async_publisher.resume_publish ordering_key
        end

        ##
        # @private New Publisher from a Google::Cloud::PubSub::V1::Topic object.
        def self.from_grpc grpc, service, async: nil
          new.tap do |t|
            t.grpc = grpc
            t.service = service
            t.instance_variable_set :@async_opts, async if async
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
        # Ensures a Google::Cloud::PubSub::V1::Topic object exists.
        def ensure_grpc!
          ensure_service!
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
