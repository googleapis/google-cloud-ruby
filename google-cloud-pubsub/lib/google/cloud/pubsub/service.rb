# Copyright 2016 Google LLC
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
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/convert"
require "google/cloud/pubsub/version"
require "google/cloud/pubsub/v1"
require "securerandom"

module Google
  module Cloud
    module PubSub
      ##
      # @private Represents the Pub/Sub service API, including IAM mixins.
      class Service
        attr_accessor :project
        attr_accessor :credentials
        attr_accessor :host
        attr_accessor :timeout
        ###
        # The same client_id is used across all streaming pull connections that are created by this client. This is
        # intentional, as it indicates to the server that any guarantees, such as message ordering, made for a stream
        # that is disconnected will be made for the stream that is created to replace it. The attr_accessor allows the
        # value to be replaced for unit testing.
        attr_accessor :client_id

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil
          @project = project
          @credentials = credentials
          @host = host
          @timeout = timeout
          @client_id = SecureRandom.uuid.freeze
        end

        def subscriber
          return mocked_subscriber if mocked_subscriber
          @subscriber ||= V1::Subscriber::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_subscriber

        def publisher
          return mocked_publisher if mocked_publisher
          @publisher ||= V1::Publisher::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_publisher

        def iam
          return mocked_iam if mocked_iam
          @iam ||= V1::IAMPolicy::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_iam

        def schemas
          return mocked_schemas if mocked_schemas
          @schemas ||= V1::SchemaService::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_schemas

        ##
        # Gets the configuration of a topic.
        # Since the topic only has the name attribute,
        # this method is only useful to check the existence of a topic.
        # If other attributes are added in the future,
        # they will be returned here.
        def get_topic topic_name, options = {}
          publisher.get_topic topic: topic_path(topic_name, options)
        end

        ##
        # Lists matching topics.
        def list_topics options = {}
          paged_enum = publisher.list_topics project:    project_path(options),
                                             page_size:  options[:max],
                                             page_token: options[:token]

          paged_enum.response
        end

        ##
        # Creates the given topic with the given name.
        def create_topic topic_name,
                         labels: nil,
                         kms_key_name: nil,
                         persistence_regions: nil,
                         schema_name: nil,
                         message_encoding: nil,
                         retention: nil,
                         options: {}
          if persistence_regions
            message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new(
              allowed_persistence_regions: Array(persistence_regions)
            )
          end

          if schema_name || message_encoding
            unless schema_name && message_encoding
              raise ArgumentError, "Schema settings must include both schema_name and message_encoding."
            end
            schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new(
              schema:   schema_path(schema_name),
              encoding: message_encoding.to_s.upcase
            )
          end

          publisher.create_topic \
            name:                       topic_path(topic_name, options),
            labels:                     labels,
            kms_key_name:               kms_key_name,
            message_storage_policy:     message_storage_policy,
            schema_settings:            schema_settings,
            message_retention_duration: Convert.number_to_duration(retention)
        end

        def update_topic topic_obj, *fields
          mask = Google::Protobuf::FieldMask.new paths: fields.map(&:to_s)
          publisher.update_topic topic: topic_obj, update_mask: mask
        end

        ##
        # Deletes the topic with the given name. All subscriptions to this topic
        # are also deleted. Raises GRPC status code 5 if the topic does not
        # exist. After a topic is deleted, a new topic may be created with the
        # same name.
        def delete_topic topic_name
          publisher.delete_topic topic: topic_path(topic_name)
        end

        ##
        # Adds one or more messages to the topic.
        # Raises GRPC status code 5 if the topic does not exist.
        # The messages parameter is an array of arrays.
        # The first element is the data, second is attributes hash.
        def publish topic, messages
          publisher.publish topic: topic_path(topic), messages: messages
        end

        ##
        # Gets the details of a subscription.
        def get_subscription subscription_name, options = {}
          subscriber.get_subscription subscription: subscription_path(subscription_name, options)
        end

        ##
        # Lists matching subscriptions by project and topic.
        def list_topics_subscriptions topic, options = {}
          publisher.list_topic_subscriptions topic:      topic_path(topic, options),
                                             page_size:  options[:max],
                                             page_token: options[:token]
        end

        ##
        # Lists matching subscriptions by project.
        def list_subscriptions options = {}
          paged_enum = subscriber.list_subscriptions project:    project_path(options),
                                                     page_size:  options[:max],
                                                     page_token: options[:token]

          paged_enum.response
        end

        ##
        # Creates a subscription on a given topic for a given subscriber.
        def create_subscription topic, subscription_name, options = {}
          subscriber.create_subscription \
            name:                       subscription_path(subscription_name, options),
            topic:                      topic_path(topic),
            push_config:                options[:push_config],
            ack_deadline_seconds:       options[:deadline],
            retain_acked_messages:      options[:retain_acked],
            message_retention_duration: Convert.number_to_duration(options[:retention]),
            labels:                     options[:labels],
            enable_message_ordering:    options[:message_ordering],
            filter:                     options[:filter],
            dead_letter_policy:         dead_letter_policy(options),
            retry_policy:               options[:retry_policy]
        end

        def update_subscription subscription_obj, *fields
          mask = Google::Protobuf::FieldMask.new paths: fields.map(&:to_s)
          subscriber.update_subscription subscription: subscription_obj, update_mask: mask
        end

        ##
        # Deletes an existing subscription. All pending messages in the subscription are immediately dropped.
        def delete_subscription subscription
          subscriber.delete_subscription subscription: subscription_path(subscription)
        end

        ##
        # Detaches a subscription from its topic. All messages retained in the subscription are dropped. Subsequent
        # `Pull` and `StreamingPull` requests will raise `FAILED_PRECONDITION`. If the subscription is a push
        # subscription, pushes to the endpoint will stop.
        def detach_subscription subscription
          publisher.detach_subscription subscription: subscription_path(subscription)
        end

        ##
        # Pulls a single message from the server.
        def pull subscription, options = {}
          max_messages = options.fetch(:max, 100).to_i
          return_immediately = !(!options.fetch(:immediate, true))

          subscriber.pull subscription:       subscription_path(subscription, options),
                          max_messages:       max_messages,
                          return_immediately: return_immediately
        end

        def streaming_pull request_enum
          subscriber.streaming_pull request_enum
        end

        ##
        # Acknowledges receipt of a message.
        def acknowledge subscription, *ack_ids
          subscriber.acknowledge subscription: subscription_path(subscription), ack_ids: ack_ids
        end

        ##
        # Modifies the PushConfig for a specified subscription.
        def modify_push_config subscription, endpoint, attributes
          # Convert attributes to strings to match the protobuf definition
          attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]
          push_config = Google::Cloud::PubSub::V1::PushConfig.new(
            push_endpoint: endpoint,
            attributes:    attributes
          )

          subscriber.modify_push_config subscription: subscription_path(subscription),
                                        push_config:  push_config
        end

        ##
        # Modifies the ack deadline for a specific message.
        def modify_ack_deadline subscription, ids, deadline
          subscriber.modify_ack_deadline subscription:         subscription_path(subscription),
                                         ack_ids:              Array(ids),
                                         ack_deadline_seconds: deadline
        end

        ##
        # Lists snapshots by project.
        def list_snapshots options = {}
          paged_enum = subscriber.list_snapshots project:    project_path(options),
                                                 page_size:  options[:max],
                                                 page_token: options[:token]

          paged_enum.response
        end

        ##
        # Creates a snapshot on a given subscription.
        def create_snapshot subscription, snapshot_name, labels: nil
          subscriber.create_snapshot name:         snapshot_path(snapshot_name),
                                     subscription: subscription_path(subscription),
                                     labels:       labels
        end

        def update_snapshot snapshot_obj, *fields
          mask = Google::Protobuf::FieldMask.new paths: fields.map(&:to_s)
          subscriber.update_snapshot snapshot: snapshot_obj, update_mask: mask
        end

        ##
        # Deletes an existing snapshot.
        # All pending messages in the snapshot are immediately dropped.
        def delete_snapshot snapshot
          subscriber.delete_snapshot snapshot: snapshot_path(snapshot)
        end

        ##
        # Adjusts the given subscription to a time or snapshot.
        def seek subscription, time_or_snapshot
          if a_time? time_or_snapshot
            time = Convert.time_to_timestamp time_or_snapshot
            subscriber.seek subscription: subscription, time: time
          else
            time_or_snapshot = time_or_snapshot.name if time_or_snapshot.is_a? Snapshot
            subscriber.seek subscription: subscription_path(subscription),
                            snapshot:     snapshot_path(time_or_snapshot)
          end
        end

        ##
        # Lists schemas in the current (or given) project.
        # @param view [String, Symbol, nil] Possible values:
        #   * `BASIC` - Include the name and type of the schema, but not the definition.
        #   * `FULL` - Include all Schema object fields.
        #
        def list_schemas view, options = {}
          schema_view = Google::Cloud::PubSub::V1::SchemaView.const_get view.to_s.upcase
          paged_enum = schemas.list_schemas parent:     project_path(options),
                                            view:       schema_view,
                                            page_size:  options[:max],
                                            page_token: options[:token]

          paged_enum.response
        end

        ##
        # Creates a schema in the current (or given) project.
        def create_schema schema_id, type, definition, options = {}
          schema = Google::Cloud::PubSub::V1::Schema.new(
            type:       type,
            definition: definition
          )
          schemas.create_schema parent:    project_path(options),
                                schema:    schema,
                                schema_id: schema_id
        end

        ##
        # Gets the details of a schema.
        # @param view [String, Symbol, nil] The set of fields to return in the response. Possible values:
        #   * `BASIC` - Include the name and type of the schema, but not the definition.
        #   * `FULL` - Include all Schema object fields.
        #
        def get_schema schema_name, view, options = {}
          schema_view = Google::Cloud::PubSub::V1::SchemaView.const_get view.to_s.upcase
          schemas.get_schema name: schema_path(schema_name, options),
                             view: schema_view
        end

        ##
        # Delete a schema.
        def delete_schema schema_name
          schemas.delete_schema name: schema_path(schema_name)
        end

        ##
        # Validate the definition string intended for a schema.
        def validate_schema type, definition, options = {}
          schema = Google::Cloud::PubSub::V1::Schema.new(
            type:       type,
            definition: definition
          )
          schemas.validate_schema parent: project_path(options),
                                  schema: schema
        end

        ##
        # Validates a message against a schema.
        #
        # @param message_data [String] Message to validate against the provided `schema_spec`.
        # @param message_encoding [Google::Cloud::PubSub::V1::Encoding] The encoding expected for messages.
        # @param schema_name [String] Name of the schema against which to validate.
        # @param project [String] Name of the project if not the default project.
        # @param type [String] Ad-hoc schema type against which to validate.
        # @param definition [String] Ad-hoc schema definition against which to validate.
        #
        def validate_message message_data, message_encoding, schema_name: nil, project: nil, type: nil, definition: nil
          if type && definition
            schema = Google::Cloud::PubSub::V1::Schema.new(
              type:       type,
              definition: definition
            )
          end
          schemas.validate_message parent:   project_path(project: project),
                                   name:     schema_path(schema_name),
                                   schema:   schema,
                                   message:  message_data,
                                   encoding: message_encoding
        end

        # Helper methods

        def get_topic_policy topic_name, options = {}
          iam.get_iam_policy resource: topic_path(topic_name, options)
        end

        def set_topic_policy topic_name, new_policy, options = {}
          iam.set_iam_policy resource: topic_path(topic_name, options), policy: new_policy
        end

        def test_topic_permissions topic_name, permissions, options = {}
          iam.test_iam_permissions resource: topic_path(topic_name, options), permissions: permissions
        end

        def get_subscription_policy subscription_name, options = {}
          iam.get_iam_policy resource: subscription_path(subscription_name, options)
        end

        def set_subscription_policy subscription_name, new_policy, options = {}
          iam.set_iam_policy resource: subscription_path(subscription_name, options), policy: new_policy
        end

        def test_subscription_permissions subscription_name, permissions, options = {}
          iam.test_iam_permissions resource: subscription_path(subscription_name, options), permissions: permissions
        end

        def project_path options = {}
          project_name = options[:project] || project
          "projects/#{project_name}"
        end

        def topic_path topic_name, options = {}
          return topic_name if topic_name.to_s.include? "/"
          "#{project_path options}/topics/#{topic_name}"
        end

        def subscription_path subscription_name, options = {}
          return subscription_name if subscription_name.to_s.include? "/"
          "#{project_path options}/subscriptions/#{subscription_name}"
        end

        def snapshot_path snapshot_name, options = {}
          return snapshot_name if snapshot_name.nil? || snapshot_name.to_s.include?("/")
          "#{project_path options}/snapshots/#{snapshot_name}"
        end

        def schema_path schema_name, options = {}
          return schema_name if schema_name.nil? || schema_name.to_s.include?("/")
          "#{project_path options}/schemas/#{schema_name}"
        end

        def inspect
          "#<#{self.class.name} (#{@project})>"
        end

        protected

        def a_time? obj
          return false unless obj.respond_to? :to_time
          # Rails' String#to_time returns nil if the string doesn't parse.
          return false if obj.to_time.nil?
          true
        end

        def dead_letter_policy options
          return nil unless options[:dead_letter_topic_name]
          policy = Google::Cloud::PubSub::V1::DeadLetterPolicy.new dead_letter_topic: options[:dead_letter_topic_name]
          if options[:dead_letter_max_delivery_attempts]
            policy.max_delivery_attempts = options[:dead_letter_max_delivery_attempts]
          end
          policy
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
