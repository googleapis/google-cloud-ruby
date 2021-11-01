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
require "google/cloud/pubsub/retry_policy"

module Google
  module Cloud
    module PubSub
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
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      class Topic
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   topic.async_publisher.stop!
        #
        def async_publisher
          @async_publisher
        end

        ##
        # The name of the topic.
        #
        # @return [String] A fully-qualified topic name in the form
        #   `projects/{project_id}/topics/{topic_id}`.
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
        # Makes an API call to retrieve the labels values when called on a
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
          update_grpc = Google::Cloud::PubSub::V1::Topic.new name: name, labels: new_labels
          @grpc = service.update_topic update_grpc, :labels
          @resource_name = nil
        end

        ##
        # The Cloud KMS encryption key that will be used to protect access
        # to messages published on this topic.
        # For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
        # The default value is `nil`, which means default encryption is used.
        #
        # Makes an API call to retrieve the KMS encryption key when called on a
        # reference object. See {#reference?}.
        #
        # @return [String]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.kms_key #=> "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #
        def kms_key
          ensure_grpc!
          @grpc.kms_key_name
        end

        ##
        # Set the Cloud KMS encryption key that will be used to protect access
        # to messages published on this topic.
        # For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
        # The default value is `nil`, which means default encryption is used.
        #
        # @param [String] new_kms_key_name New Cloud KMS key name
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   topic.kms_key = key_name
        #
        def kms_key= new_kms_key_name
          update_grpc = Google::Cloud::PubSub::V1::Topic.new name: name, kms_key_name: new_kms_key_name
          @grpc = service.update_topic update_grpc, :kms_key_name
          @resource_name = nil
        end

        ##
        # The list of GCP region IDs where messages that are published to the
        # topic may be persisted in storage.
        #
        # Messages published by publishers running in non-allowed GCP regions
        # (or running outside of GCP altogether) will be routed for storage in
        # one of the allowed regions. An empty list indicates a misconfiguration
        # at the project or organization level, which will result in all publish
        # operations failing.
        #
        # Makes an API call to retrieve the list of GCP region IDs values when
        # called on a reference object. See {#reference?}.
        #
        # @return [Array<String>]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.persistence_regions #=> ["us-central1", "us-central2"]
        #
        def persistence_regions
          ensure_grpc!
          return [] if @grpc.message_storage_policy.nil?
          Array @grpc.message_storage_policy.allowed_persistence_regions
        end

        ##
        # Sets the list of GCP region IDs where messages that are published to
        # the topic may be persisted in storage.
        #
        # @param [Array<String>] new_persistence_regions
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.persistence_regions = ["us-central1", "us-central2"]
        #
        def persistence_regions= new_persistence_regions
          update_grpc = Google::Cloud::PubSub::V1::Topic.new \
            name: name, message_storage_policy: { allowed_persistence_regions: Array(new_persistence_regions) }
          @grpc = service.update_topic update_grpc, :message_storage_policy
          @resource_name = nil
        end

        ##
        # The name of the schema that messages published should be validated against, if schema settings are configured
        # for the topic. The value is a fully-qualified schema name in the form
        # `projects/{project_id}/schemas/{schema_id}`. If present, {#message_encoding} should also be present. The value
        # of this field will be `_deleted-schema_` if the schema has been deleted.
        #
        # Makes an API call to retrieve the schema settings when called on a reference object. See {#reference?}.
        #
        # @return [String, nil] The schema name, or `nil` if schema settings are not configured for the topic.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.schema_name #=> "projects/my-project/schemas/my-schema"
        #
        def schema_name
          ensure_grpc!
          @grpc.schema_settings&.schema
        end

        ##
        # The encoding of messages validated against the schema identified by {#schema_name}. If present, {#schema_name}
        # should also be present. Values include:
        #
        # * `JSON` - JSON encoding.
        # * `BINARY` - Binary encoding, as defined by the schema type. For some schema types, binary encoding may not be
        #   available.
        #
        # Makes an API call to retrieve the schema settings when called on a reference object. See {#reference?}.
        #
        # @return [Symbol, nil] The schema encoding, or `nil` if schema settings are not configured for the topic.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   topic.message_encoding #=> :JSON
        #
        def message_encoding
          ensure_grpc!
          @grpc.schema_settings&.encoding
        end

        ##
        # Checks if the encoding of messages in the schema settings is `BINARY`. See {#message_encoding}.
        #
        # Makes an API call to retrieve the schema settings when called on a reference object. See {#reference?}.
        #
        # @return [Boolean] `true` when `BINARY`, `false` if not `BINARY` or schema settings is not set.
        #
        def message_encoding_binary?
          message_encoding.to_s.upcase == "BINARY"
        end

        ##
        # Checks if the encoding of messages in the schema settings is `JSON`. See {#message_encoding}.
        #
        # Makes an API call to retrieve the schema settings when called on a reference object. See {#reference?}.
        #
        # @return [Boolean] `true` when `JSON`, `false` if not `JSON` or schema settings is not set.
        #
        def message_encoding_json?
          message_encoding.to_s.upcase == "JSON"
        end

        ##
        # Indicates the minimum number of seconds to retain a message after it is
        # published to the topic. If this field is set, messages published to the topic
        # within the `retention` number of seconds are always available to subscribers.
        # For instance, it allows any attached subscription to [seek to a
        # timestamp](https://cloud.google.com/pubsub/docs/replay-overview#seek_to_a_time)
        # that is up to `retention` number of seconds in the past. If this field is
        # not set, message retention is controlled by settings on individual
        # subscriptions. Cannot be less than 600 (10 minutes) or more than 604,800 (7 days).
        # See {#retention=}.
        #
        # Makes an API call to retrieve the retention value when called on a
        # reference object. See {#reference?}.
        #
        # @return [Numeric, nil] The message retention duration in seconds, or `nil` if not set.
        #
        def retention
          ensure_grpc!
          Convert.duration_to_number @grpc.message_retention_duration
        end

        ##
        # Sets the message retention duration in seconds. If set to a positive duration
        # between 600 (10 minutes) and 604,800 (7 days), inclusive, the message retention
        # duration is changed. If set to `nil`, this clears message retention duration
        # from the topic. See {#retention}.
        #
        # @param [Numeric, nil] new_retention The new message retention duration value.
        #
        def retention= new_retention
          new_retention_duration = Convert.number_to_duration new_retention
          update_grpc = Google::Cloud::PubSub::V1::Topic.new name: name,
                                                             message_retention_duration: new_retention_duration
          @grpc = service.update_topic update_grpc, :message_retention_duration
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
        #   pubsub = Google::Cloud::PubSub.new
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
        # @param [String] subscription_name Name of the new subscription. Required.
        #   The value can be a simple subscription ID (relative name), in which
        #   case the current project ID will be supplied, or a fully-qualified
        #   subscription name in the form
        #   `projects/{project_id}/subscriptions/{subscription_id}`.
        #
        #   The subscription ID (relative name) must start with a letter, and
        #   contain only letters (`[A-Za-z]`), numbers (`[0-9]`), dashes (`-`),
        #   underscores (`_`), periods (`.`), tildes (`~`), plus (`+`) or percent
        #   signs (`%`). It must be between 3 and 255 characters in length, and
        #   it must not start with `goog`.
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
        #   should be pushed. The parameters `push_config` and `endpoint` should not both be provided.
        # @param [Google::Cloud::PubSub::Subscription::PushConfig] push_config The configuration for a push delivery
        #   endpoint that should contain the endpoint, and can contain authentication data (OIDC token authentication).
        #   The parameters `push_config` and `endpoint` should not both be provided.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the subscription. You can use these to organize and group your
        #   subscriptions. Label keys and values can be no longer than 63
        #   characters, can only contain lowercase letters, numeric characters,
        #   underscores and dashes. International characters are allowed. Label
        #   values are optional. Label keys must start with a letter and each
        #   label in the list must have a different key. See [Creating and
        #   Managing Labels](https://cloud.google.com/pubsub/docs/labels).
        # @param [Boolean] message_ordering Whether to enable message ordering
        #   on the subscription.
        # @param [String] filter An expression written in the Cloud Pub/Sub filter language. If non-empty, then only
        #   {Message} instances whose `attributes` field matches the filter are delivered on this subscription. If
        #   empty, then no messages are filtered out. Optional.
        # @param [Topic] dead_letter_topic The {Topic} to which dead letter messages for the subscription should be
        #   published. Dead lettering is done on a best effort basis. The same message might be dead lettered multiple
        #   times. The Cloud Pub/Sub service account associated with the enclosing subscription's parent project (i.e.,
        #   `service-{project_number}@gcp-sa-pubsub.iam.gserviceaccount.com`) must have permission to Publish() to
        #   this topic.
        #
        #   The operation will fail if the topic does not exist. Users should ensure that there is a subscription
        #   attached to this topic since messages published to a topic with no subscriptions are lost.
        # @param [Integer] dead_letter_max_delivery_attempts The maximum number of delivery attempts for any message in
        #   the subscription's dead letter policy. Dead lettering is done on a best effort basis. The same message might
        #   be dead lettered multiple times. The value must be between 5 and 100. If this parameter is 0, a default
        #   value of 5 is used. The `dead_letter_topic` must also be set.
        # @param [RetryPolicy] retry_policy A policy that specifies how Cloud Pub/Sub retries message delivery for
        #   this subscription. If not set, the default retry policy is applied. This generally implies that messages
        #   will be retried as soon as possible for healthy subscribers. Retry Policy will be triggered on NACKs or
        #   acknowledgement deadline exceeded events for a given message.
        #
        # @return [Google::Cloud::PubSub::Subscription]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   sub = topic.subscribe "my-topic-sub"
        #   sub.name # => "my-topic-sub"
        #
        # @example Wait 2 minutes for acknowledgement:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   sub = topic.subscribe "my-topic-sub",
        #                         deadline: 120
        #
        # @example Configure a push endpoint:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   push_config = Google::Cloud::PubSub::Subscription::PushConfig.new endpoint: "http://example.net/callback"
        #   push_config.set_oidc_token "service-account@example.net", "audience-header-value"
        #
        #   sub = topic.subscribe "my-subscription", push_config: push_config
        #
        # @example Configure a Dead Letter Queues policy:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   # Dead Letter Queue (DLQ) testing requires IAM bindings to the Cloud Pub/Sub service account that is
        #   # automatically created and managed by the service team in a private project.
        #   my_project_number = "000000000000"
        #   service_account_email = "serviceAccount:service-#{my_project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
        #
        #   dead_letter_topic = pubsub.topic "my-dead-letter-topic"
        #   dead_letter_subscription = dead_letter_topic.subscribe "my-dead-letter-sub"
        #
        #   dead_letter_topic.policy { |p| p.add "roles/pubsub.publisher", service_account_email }
        #   dead_letter_subscription.policy { |p| p.add "roles/pubsub.subscriber", service_account_email }
        #
        #   topic = pubsub.topic "my-topic"
        #   sub = topic.subscribe "my-topic-sub",
        #                         dead_letter_topic: dead_letter_topic,
        #                         dead_letter_max_delivery_attempts: 10
        #
        # @example Configure a Retry Policy:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   retry_policy = Google::Cloud::PubSub::RetryPolicy.new minimum_backoff: 5, maximum_backoff: 300
        #   sub = topic.subscribe "my-topic-sub", retry_policy: retry_policy
        #
        def subscribe subscription_name,
                      deadline: nil,
                      retain_acked: false,
                      retention: nil,
                      endpoint: nil,
                      push_config: nil,
                      labels: nil,
                      message_ordering: nil,
                      filter: nil,
                      dead_letter_topic: nil,
                      dead_letter_max_delivery_attempts: nil,
                      retry_policy: nil
          ensure_service!
          if push_config && endpoint
            raise ArgumentError, "endpoint and push_config were both provided. Please provide only one."
          end
          push_config = Google::Cloud::PubSub::Subscription::PushConfig.new endpoint: endpoint if endpoint

          options = {
            deadline:                          deadline,
            retain_acked:                      retain_acked,
            retention:                         retention,
            labels:                            labels,
            message_ordering:                  message_ordering,
            filter:                            filter,
            dead_letter_max_delivery_attempts: dead_letter_max_delivery_attempts
          }

          options[:dead_letter_topic_name] = dead_letter_topic.name if dead_letter_topic
          if options[:dead_letter_max_delivery_attempts] && !options[:dead_letter_topic_name]
            # Service error message "3:Invalid resource name given (name=)." does not identify param.
            raise ArgumentError, "dead_letter_topic is required with dead_letter_max_delivery_attempts"
          end
          options[:push_config] = push_config.to_grpc if push_config
          options[:retry_policy] = retry_policy.to_grpc if retry_policy
          grpc = service.create_subscription name, subscription_name, options
          Subscription.from_grpc grpc, service
        end
        alias create_subscription subscribe
        alias new_subscription subscribe

        ##
        # Retrieves subscription by name.
        #
        # @param [String] subscription_name Name of a subscription. The value
        #   can be a simple subscription ID (relative name), in which case the
        #   current project ID will be supplied, or a fully-qualified
        #   subscription name in the form
        #   `projects/{project_id}/subscriptions/{subscription_id}`.
        # @param [Boolean] skip_lookup Optionally create a {Subscription} object
        #   without verifying the subscription resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::PubSub::Subscription, nil] Returns `nil` if
        #   the subscription does not exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   sub = topic.subscription "my-topic-sub"
        #   sub.name #=> "projects/my-project/subscriptions/my-topic-sub"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #
        #   # No API call is made to retrieve the subscription information.
        #   sub = topic.subscription "my-topic-sub", skip_lookup: true
        #   sub.name #=> "projects/my-project/subscriptions/my-topic-sub"
        #
        def subscription subscription_name, skip_lookup: nil
          ensure_service!
          return Subscription.from_name subscription_name, service if skip_lookup
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   topic = pubsub.topic "my-topic"
        #   msg = topic.publish "task completed"
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   msg = topic.publish file
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msg = topic.publish "task completed",
        #                       foo: :bar,
        #                       this: :that
        #
        # @example Multiple messages can be sent at the same time using a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msgs = topic.publish do |t|
        #     t.publish "task 1 completed", foo: :bar
        #     t.publish "task 2 completed", foo: :baz
        #     t.publish "task 3 completed", foo: :bif
        #   end
        #
        # @example Ordered messages are supported using ordering_key:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-ordered-topic"
        #
        #   # Ensure that message ordering is enabled.
        #   topic.enable_message_ordering!
        #
        #   # Publish an ordered message with an ordering key.
        #   topic.publish "task completed",
        #                 ordering_key: "task-key"
        #
        def publish data = nil, attributes = nil, ordering_key: nil, **extra_attrs, &block
          ensure_service!
          batch = BatchPublisher.new data, attributes, ordering_key, extra_attrs
          block&.call batch
          return nil if batch.messages.count.zero?
          publish_batch_messages batch
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
        # are allowed to wait to be published. See the `flow_control` key in the
        # `async` parameter in {Project#topic} for more information about publisher
        # flow control settings.
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
        #   See the `async` parameter in {Project#topic} for more information about
        #   `flow_control` settings.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
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
        #   # Shut down the publisher when ready to stop publishing messages.
        #   topic.async_publisher.stop!
        #
        # @example A message can be published using a File object:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   file = File.open "message.txt", mode: "rb"
        #   topic.publish_async file
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   topic.async_publisher.stop!
        #
        # @example Additionally, a message can be published with attributes:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.publish_async "task completed",
        #                       foo: :bar, this: :that
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   topic.async_publisher.stop!
        #
        # @example Ordered messages are supported using ordering_key:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-ordered-topic"
        #
        #   # Ensure that message ordering is enabled.
        #   topic.enable_message_ordering!
        #
        #   # Publish an ordered message with an ordering key.
        #   topic.publish_async "task completed",
        #                       ordering_key: "task-key"
        #
        #   # Shut down the publisher when ready to stop publishing messages.
        #   topic.async_publisher.stop!
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
        # {Subscription#listen}, and {Message#ordering_key}.
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
        # {Subscription#listen}, and {Message#ordering_key}.
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
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   policy = topic.policy
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
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
        # {Google::Cloud::PubSub::Policy} for an explanation of the policy
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   pubsub = Google::Cloud::PubSub.new
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
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.resource? #=> true
        #
        def resource?
          !@grpc.nil?
        end

        ##
        # Reloads the topic with current data from the Pub/Sub service.
        #
        # @return [Google::Cloud::PubSub::Topic] Returns the reloaded topic
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   topic.reload!
        #
        def reload!
          ensure_service!
          @grpc = service.get_topic name
          @resource_name = nil
          self
        end
        alias refresh! reload!

        ##
        # @private New Topic from a Google::Cloud::PubSub::V1::Topic object.
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
        # Ensures a Google::Cloud::PubSub::V1::Topic object exists.
        def ensure_grpc!
          ensure_service!
          reload! if reference?
        end

        ##
        # Call the publish API with arrays of data data and attrs.
        def publish_batch_messages batch
          grpc = service.publish name, batch.messages
          batch.to_gcloud_messages Array(grpc.message_ids)
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
