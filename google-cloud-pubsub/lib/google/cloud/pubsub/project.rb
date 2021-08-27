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
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/topic"
require "google/cloud/pubsub/batch_publisher"
require "google/cloud/pubsub/schema"
require "google/cloud/pubsub/snapshot"

module Google
  module Cloud
    module PubSub
      ##
      # # Project
      #
      # Represents the project that pubsub messages are pushed to and pulled
      # from. {Topic} is a named resource to which messages are sent by
      # publishers. {Subscription} is a named resource representing the stream
      # of messages from a single, specific topic, to be delivered to the
      # subscribing application. {Message} is a combination of data and
      # attributes that a publisher sends to a topic and is eventually delivered
      # to subscribers.
      #
      # See {Google::Cloud#pubsub}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Pub/Sub Project instance.
        def initialize service
          @service = service
        end

        # The Pub/Sub project connected to.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   pubsub.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # Retrieves topic by name.
        #
        # @param [String] topic_name Name of a topic. The value can be a simple
        #   topic ID (relative name), in which case the current project ID will
        #   be supplied, or a fully-qualified topic name in the form
        #   `projects/{project_id}/topics/{topic_id}`.
        # @param [String] project If the topic belongs to a project other than
        #   the one currently connected to, the alternate project ID can be
        #   specified here. Optional. Not used if a fully-qualified topic name
        #   is provided for `topic_name`.
        # @param [Boolean] skip_lookup Optionally create a {Topic} object
        #   without verifying the topic resource exists on the Pub/Sub service.
        #   Calls made on this object will raise errors if the topic resource
        #   does not exist. Default is `false`. Optional.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Topic#publish_async}
        #   is called. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #   * `:max_bytes` (Integer) The maximum size of messages to be collected before the batch is published. Default
        #     is 1,000,000 (1MB).
        #   * `:max_messages` (Integer) The maximum number of messages to be collected before the batch is published.
        #     Default is 100.
        #   * `:interval` (Numeric) The number of seconds to collect messages before the batch is published. Default is
        #     0.01.
        #   * `:threads` (Hash) The number of threads to create to handle concurrent calls by the publisher:
        #     * `:publish` (Integer) The number of threads used to publish messages. Default is 2.
        #     * `:callback` (Integer) The number of threads to handle the published messages' callbacks. Default is 4.
        #   * `:flow_control` (Hash) The client flow control settings for message publishing:
        #     * `:message_limit` (Integer) The maximum number of messages allowed to wait to be published. Default is
        #       `10 * max_messages`.
        #     * `:byte_limit` (Integer) The maximum total size of messages allowed to wait to be published. Default is
        #       `10 * max_bytes`.
        #     * `:limit_exceeded_behavior` (Symbol) The action to take when publish flow control limits are exceeded.
        #       Possible values include: `:ignore` - Flow control is disabled. `:error` - Calls to {Topic#publish_async}
        #       will raise {FlowControlLimitError} when publish flow control limits are exceeded. `:block` - Calls to
        #       {Topic#publish_async} will block until capacity is available when publish flow control limits are
        #       exceeded. The default value is `:ignore`.
        #
        # @return [Google::Cloud::PubSub::Topic, nil] Returns `nil` if topic
        #   does not exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "existing-topic"
        #
        # @example By default `nil` will be returned if topic does not exist.
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "non-existing-topic" # nil
        #
        # @example Create topic in a different project with the `project` flag.
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "another-topic", project: "another-project"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "another-topic", skip_lookup: true
        #
        # @example Configuring AsyncPublisher to increase concurrent callbacks:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "my-topic",
        #                        async: { threads: { callback: 16 } }
        #
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
        def topic topic_name, project: nil, skip_lookup: nil, async: nil
          ensure_service!
          options = { project: project }
          return Topic.from_name topic_name, service, options if skip_lookup
          grpc = service.get_topic topic_name, options
          Topic.from_grpc grpc, service, async: async
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_topic topic
        alias find_topic topic

        ##
        # Creates a new topic.
        #
        # @param [String] topic_name Name of a topic. Required.
        #   The value can be a simple topic ID (relative name), in which
        #   case the current project ID will be supplied, or a fully-qualified
        #   topic name in the form `projects/{project_id}/topics/{topic_id}`.
        #
        #   The topic ID (relative name) must start with a letter, and
        #   contain only letters (`[A-Za-z]`), numbers (`[0-9]`), dashes (`-`),
        #   underscores (`_`), periods (`.`), tildes (`~`), plus (`+`) or percent
        #   signs (`%`). It must be between 3 and 255 characters in length, and
        #   it must not start with `goog`.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the topic. You can use these to organize and group your topics.
        #   Label keys and values can be no longer than 63 characters, can only
        #   contain lowercase letters, numeric characters, underscores and
        #   dashes. International characters are allowed. Label values are
        #   optional. Label keys must start with a letter and each label in the
        #   list must have a different key. See [Creating and Managing
        #   Labels](https://cloud.google.com/pubsub/docs/labels).
        # @param [String] kms_key The Cloud KMS encryption key that will be used
        #   to protect access to messages published on this topic. Optional.
        #   For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
        # @param [Array<String>] persistence_regions The list of GCP region IDs
        #   where messages that are published to the topic may be persisted in
        #   storage. Optional.
        # @param [Hash] async A hash of values to configure the topic's
        #   {AsyncPublisher} that is created when {Topic#publish_async}
        #   is called. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #   * `:max_bytes` (Integer) The maximum size of messages to be collected
        #     before the batch is published. Default is 1,000,000 (1MB).
        #   * `:max_messages` (Integer) The maximum number of messages to be
        #     collected before the batch is published. Default is 100.
        #   * `:interval` (Numeric) The number of seconds to collect messages before
        #     the batch is published. Default is 0.01.
        #   * `:threads` (Hash) The number of threads to create to handle concurrent
        #     calls by the publisher:
        #
        #     * `:publish` (Integer) The number of threads used to publish messages.
        #       Default is 2.
        #     * `:callback` (Integer) The number of threads to handle the published
        #       messages' callbacks. Default is 4.
        #   * `:flow_control` (Hash) The client flow control settings for message publishing:
        #     * `:message_limit` (Integer) The maximum number of messages allowed to wait to be published. Default is
        #       `10 * max_messages`.
        #     * `:byte_limit` (Integer) The maximum total size of messages allowed to wait to be published. Default is
        #       `10 * max_bytes`.
        #     * `:limit_exceeded_behavior` (Symbol) The action to take when publish flow control limits are exceeded.
        #       Possible values include: `:ignore` - Flow control is disabled. `:error` - Calls to {Topic#publish_async}
        #       will raise {FlowControlLimitError} when publish flow control limits are exceeded. `:block` - Calls to
        #       {Topic#publish_async} will block until capacity is available when publish flow control limits are
        #       exceeded. The default value is `:ignore`.
        # @param [String] schema_name The name of the schema that messages
        #   published should be validated against. Optional. The value can be a
        #   simple schema ID (relative name), in which case the current project
        #   ID will be supplied, or a fully-qualified schema name in the form
        #   `projects/{project_id}/schemas/{schema_id}`. If provided,
        #   `message_encoding` must also be provided.
        # @param [String, Symbol] message_encoding The encoding of messages validated
        #   against the schema identified by `schema_name`. Optional. Values include:
        #
        #   * `JSON` - JSON encoding.
        #   * `BINARY` - Binary encoding, as defined by the schema type. For some
        #     schema types, binary encoding may not be available.
        # @param [Numeric] retention Indicates the minimum number of seconds to retain a message
        #   after it is published to the topic. If this field is set, messages published
        #   to the topic within the `retention` number of seconds are always available to
        #   subscribers. For instance, it allows any attached subscription to [seek to a
        #   timestamp](https://cloud.google.com/pubsub/docs/replay-overview#seek_to_a_time)
        #   that is up to `retention` number of seconds in the past. If this field is
        #   not set, message retention is controlled by settings on individual
        #   subscriptions. Cannot be less than 600 (10 minutes) or more than 604,800 (7 days).
        #
        # @return [Google::Cloud::PubSub::Topic]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.create_topic "my-topic"
        #
        def create_topic topic_name,
                         labels: nil,
                         kms_key: nil,
                         persistence_regions: nil,
                         async: nil,
                         schema_name: nil,
                         message_encoding: nil,
                         retention: nil
          ensure_service!
          grpc = service.create_topic topic_name,
                                      labels:              labels,
                                      kms_key_name:        kms_key,
                                      persistence_regions: persistence_regions,
                                      schema_name:         schema_name,
                                      message_encoding:    message_encoding,
                                      retention:           retention
          Topic.from_grpc grpc, service, async: async
        end
        alias new_topic create_topic

        ##
        # Retrieves a list of topics for the given project.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `topics`; indicates that this is a continuation of a call, and that
        #   the system should return the next page of data.
        # @param [Integer] max Maximum number of topics to return.
        #
        # @return [Array<Google::Cloud::PubSub::Topic>] (See
        #   {Google::Cloud::PubSub::Topic::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topics = pubsub.topics
        #   topics.each do |topic|
        #     puts topic.name
        #   end
        #
        # @example Retrieve all topics: (See {Topic::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   topics = pubsub.topics
        #   topics.all do |topic|
        #     puts topic.name
        #   end
        #
        def topics token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_topics options
          Topic::List.from_grpc grpc, service, max
        end
        alias find_topics topics
        alias list_topics topics

        ##
        # Retrieves subscription by name.
        #
        # @param [String] subscription_name Name of a subscription. The value can
        #   be a simple subscription ID, in which case the current project ID
        #   will be supplied, or a fully-qualified subscription name in the form
        #   `projects/{project_id}/subscriptions/{subscription_id}`.
        # @param [String] project If the subscription belongs to a project other
        #   than the one currently connected to, the alternate project ID can be
        #   specified here. Not used if a fully-qualified subscription name is
        #   provided for `subscription_name`.
        # @param [Boolean] skip_lookup Optionally create a {Subscription} object
        #   without verifying the subscription resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::PubSub::Subscription, nil] Returns `nil` if
        #   the subscription does not exist
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.subscription "my-sub"
        #   sub.name #=> "projects/my-project/subscriptions/my-sub"
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   # No API call is made to retrieve the subscription information.
        #   sub = pubsub.subscription "my-sub", skip_lookup: true
        #   sub.name #=> "projects/my-project/subscriptions/my-sub"
        #
        def subscription subscription_name, project: nil, skip_lookup: nil
          ensure_service!
          options = { project: project }
          return Subscription.from_name subscription_name, service, options if skip_lookup
          grpc = service.get_subscription subscription_name, options
          Subscription.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_subscription subscription
        alias find_subscription subscription

        ##
        # Retrieves a list of subscriptions for the given project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of subscriptions to return.
        #
        # @return [Array<Google::Cloud::PubSub::Subscription>] (See
        #   {Google::Cloud::PubSub::Subscription::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subs = pubsub.subscriptions
        #   subs.each do |sub|
        #     puts sub.name
        #   end
        #
        # @example Retrieve all subscriptions: (See {Subscription::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subs = pubsub.subscriptions
        #   subs.all do |sub|
        #     puts sub.name
        #   end
        #
        def subscriptions token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_subscriptions options
          Subscription::List.from_grpc grpc, service, max
        end
        alias find_subscriptions subscriptions
        alias list_subscriptions subscriptions


        ##
        # Retrieves a list of snapshots for the given project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of snapshots to return.
        #
        # @return [Array<Google::Cloud::PubSub::Snapshot>] (See
        #   {Google::Cloud::PubSub::Snapshot::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   snapshots = pubsub.snapshots
        #   snapshots.each do |snapshot|
        #     puts snapshot.name
        #   end
        #
        # @example Retrieve all snapshots: (See {Snapshot::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   snapshots = pubsub.snapshots
        #   snapshots.all do |snapshot|
        #     puts snapshot.name
        #   end
        #
        def snapshots token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          grpc = service.list_snapshots options
          Snapshot::List.from_grpc grpc, service, max
        end
        alias find_snapshots snapshots
        alias list_snapshots snapshots

        ##
        # Retrieves schema by name.
        #
        # @param [String] schema_name Name of a schema. The value can
        #   be a simple schema ID, in which case the current project ID
        #   will be supplied, or a fully-qualified schema name in the form
        #   `projects/{project_id}/schemas/{schema_id}`.
        # @param view [Symbol, String, nil] Possible values:
        #   * `BASIC` - Include the `name` and `type` of the schema, but not the `definition`.
        #   * `FULL` - Include all Schema object fields.
        #
        #   The default value is `FULL`.
        # @param [String] project If the schema belongs to a project other
        #   than the one currently connected to, the alternate project ID can be
        #   specified here. Not used if a fully-qualified schema name is
        #   provided for `schema_name`.
        # @param [Boolean] skip_lookup Optionally create a {Schema} object
        #   without verifying the schema resource exists on the Pub/Sub
        #   service. Calls made on this object will raise errors if the service
        #   resource does not exist. Default is `false`.
        #
        # @return [Google::Cloud::PubSub::Schema, nil] Returns `nil` if
        #   the schema does not exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema"
        #   schema.name #=> "projects/my-project/schemas/my-schema"
        #   schema.type #=> :PROTOCOL_BUFFER
        #   schema.definition # The schema definition
        #
        # @example Skip the lookup against the service with `skip_lookup`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   # No API call is made to retrieve the schema information.
        #   # The default project is used in the name.
        #   schema = pubsub.schema "my-schema", skip_lookup: true
        #   schema.name #=> "projects/my-project/schemas/my-schema"
        #   schema.type #=> nil
        #   schema.definition #=> nil
        #
        # @example Omit the schema definition with `view: :basic`:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema", view: :basic
        #   schema.name #=> "projects/my-project/schemas/my-schema"
        #   schema.type #=> :PROTOCOL_BUFFER
        #   schema.definition #=> nil
        #
        def schema schema_name, view: nil, project: nil, skip_lookup: nil
          ensure_service!
          options = { project: project }
          return Schema.from_name schema_name, view, service, options if skip_lookup
          view ||= :FULL
          grpc = service.get_schema schema_name, view, options
          Schema.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_schema schema
        alias find_schema schema

        ##
        # Creates a new schema.
        #
        # @param [String] schema_id The ID to use for the schema, which will
        #   become the final component of the schema's resource name. Required.
        #
        #   The schema ID (relative name) must start with a letter, and
        #   contain only letters (`[A-Za-z]`), numbers (`[0-9]`), dashes (`-`),
        #   underscores (`_`), periods (`.`), tildes (`~`), plus (`+`) or percent
        #   signs (`%`). It must be between 3 and 255 characters in length, and
        #   it must not start with `goog`.
        # @param [String, Symbol] type The type of the schema. Required. Possible
        #   values are case-insensitive and include:
        #
        #     * `PROTOCOL_BUFFER` - A Protocol Buffer schema definition.
        #     * `AVRO` - An Avro schema definition.
        # @param [String] definition  The definition of the schema. Required. This
        #   should be a string representing the full definition of the schema that
        #   is a valid schema definition of the type specified in `type`.
        # @param [String] project If the schema belongs to a project other
        #   than the one currently connected to, the alternate project ID can be
        #   specified here. Optional.
        #
        # @return [Google::Cloud::PubSub::Schema]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   definition = "..."
        #   schema = pubsub.create_schema "my-schema", :avro, definition
        #   schema.name #=> "projects/my-project/schemas/my-schema"
        #
        def create_schema schema_id, type, definition, project: nil
          ensure_service!
          type = type.to_s.upcase
          grpc = service.create_schema schema_id, type, definition, project: project
          Schema.from_grpc grpc, service
        end
        alias new_schema create_schema

        ##
        # Retrieves a list of schemas for the given project.
        #
        # @param view [String, Symbol, nil] The set of fields to return in the response. Possible values:
        #
        #     * `BASIC` - Include the `name` and `type` of the schema, but not the `definition`.
        #     * `FULL` - Include all Schema object fields.
        #
        #   The default value is `FULL`.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of schemas to return.
        #
        # @return [Array<Google::Cloud::PubSub::Schema>] (See
        #   {Google::Cloud::PubSub::Schema::List})
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schemas = pubsub.schemas
        #   schemas.each do |schema|
        #     puts schema.name
        #   end
        #
        # @example Retrieve all schemas: (See {Schema::List#all})
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schemas = pubsub.schemas
        #   schemas.all do |schema|
        #     puts schema.name
        #   end
        #
        def schemas view: nil, token: nil, max: nil
          ensure_service!
          view ||= :FULL
          options = { token: token, max: max }
          grpc = service.list_schemas view, options
          Schema::List.from_grpc grpc, service, view, max
        end
        alias find_schemas schemas
        alias list_schemas schemas

        ##
        # Validates a schema type and definition.
        #
        # @param [String, Symbol] type The type of the schema. Required. Possible
        #   values are case-insensitive and include:
        #
        #     * `PROTOCOL_BUFFER` - A Protocol Buffer schema definition.
        #     * `AVRO` - An Avro schema definition.
        # @param [String] definition  The definition of the schema. Required. This
        #   should be a string representing the full definition of the schema that
        #   is a valid schema definition of the type specified in `type`.
        # @param [String] project If the schema belongs to a project other
        #   than the one currently connected to, the alternate project ID can be
        #   specified here. Optional.
        #
        # @return [Boolean] `true` if the schema is valid, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   definition = "..."
        #   pubsub.validate_schema :avro, definition #=> true
        #
        def valid_schema? type, definition, project: nil
          ensure_service!
          type = type.to_s.upcase
          service.validate_schema type, definition, project: project # return type is empty
          true
        rescue Google::Cloud::InvalidArgumentError
          false
        end
        alias validate_schema valid_schema?

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # Call the publish API with arrays of data data and attrs.
        def publish_batch_messages topic_name, batch
          grpc = service.publish topic_name, batch.messages
          batch.to_gcloud_messages Array(grpc.message_ids)
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
