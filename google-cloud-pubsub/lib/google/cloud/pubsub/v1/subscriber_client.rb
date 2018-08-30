# Copyright 2018 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/pubsub/v1/pubsub.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/iam/v1/iam_policy_pb"
require "google/pubsub/v1/pubsub_pb"
require "google/cloud/pubsub/v1/credentials"

module Google
  module Cloud
    module Pubsub
      module V1
        # The service that an application uses to manipulate subscriptions and to
        # consume messages from a subscription via the +Pull+ method or by
        # establishing a bi-directional stream using the +StreamingPull+ method.
        #
        # @!attribute [r] iam_policy_stub
        #   @return [Google::Iam::V1::IAMPolicy::Stub]
        # @!attribute [r] subscriber_stub
        #   @return [Google::Pubsub::V1::Subscriber::Stub]
        class SubscriberClient
          # @private
          attr_reader :iam_policy_stub, :subscriber_stub

          # The default address of the service.
          SERVICE_ADDRESS = "pubsub.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_subscriptions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "subscriptions"),
            "list_snapshots" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "snapshots")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/pubsub"
          ].freeze


          SUBSCRIPTION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/subscriptions/{subscription}"
          )

          private_constant :SUBSCRIPTION_PATH_TEMPLATE

          TOPIC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/topics/{topic}"
          )

          private_constant :TOPIC_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          SNAPSHOT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/snapshots/{snapshot}"
          )

          private_constant :SNAPSHOT_PATH_TEMPLATE

          # Returns a fully-qualified subscription resource name string.
          # @param project [String]
          # @param subscription [String]
          # @return [String]
          def self.subscription_path project, subscription
            SUBSCRIPTION_PATH_TEMPLATE.render(
              :"project" => project,
              :"subscription" => subscription
            )
          end

          # Returns a fully-qualified topic resource name string.
          # @param project [String]
          # @param topic [String]
          # @return [String]
          def self.topic_path project, topic
            TOPIC_PATH_TEMPLATE.render(
              :"project" => project,
              :"topic" => topic
            )
          end

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified snapshot resource name string.
          # @param project [String]
          # @param snapshot [String]
          # @return [String]
          def self.snapshot_path project, snapshot
            SNAPSHOT_PATH_TEMPLATE.render(
              :"project" => project,
              :"snapshot" => snapshot
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/iam/v1/iam_policy_services_pb"
            require "google/pubsub/v1/pubsub_services_pb"

            credentials ||= Google::Cloud::Pubsub::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Pubsub::V1::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-pubsub'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "subscriber_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.pubsub.v1.Subscriber",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @iam_policy_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Iam::V1::IAMPolicy::Stub.method(:new)
            )
            @subscriber_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Pubsub::V1::Subscriber::Stub.method(:new)
            )

            @create_subscription = Google::Gax.create_api_call(
              @subscriber_stub.method(:create_subscription),
              defaults["create_subscription"],
              exception_transformer: exception_transformer
            )
            @get_subscription = Google::Gax.create_api_call(
              @subscriber_stub.method(:get_subscription),
              defaults["get_subscription"],
              exception_transformer: exception_transformer
            )
            @update_subscription = Google::Gax.create_api_call(
              @subscriber_stub.method(:update_subscription),
              defaults["update_subscription"],
              exception_transformer: exception_transformer
            )
            @list_subscriptions = Google::Gax.create_api_call(
              @subscriber_stub.method(:list_subscriptions),
              defaults["list_subscriptions"],
              exception_transformer: exception_transformer
            )
            @delete_subscription = Google::Gax.create_api_call(
              @subscriber_stub.method(:delete_subscription),
              defaults["delete_subscription"],
              exception_transformer: exception_transformer
            )
            @modify_ack_deadline = Google::Gax.create_api_call(
              @subscriber_stub.method(:modify_ack_deadline),
              defaults["modify_ack_deadline"],
              exception_transformer: exception_transformer
            )
            @acknowledge = Google::Gax.create_api_call(
              @subscriber_stub.method(:acknowledge),
              defaults["acknowledge"],
              exception_transformer: exception_transformer
            )
            @pull = Google::Gax.create_api_call(
              @subscriber_stub.method(:pull),
              defaults["pull"],
              exception_transformer: exception_transformer
            )
            @streaming_pull = Google::Gax.create_api_call(
              @subscriber_stub.method(:streaming_pull),
              defaults["streaming_pull"],
              exception_transformer: exception_transformer
            )
            @modify_push_config = Google::Gax.create_api_call(
              @subscriber_stub.method(:modify_push_config),
              defaults["modify_push_config"],
              exception_transformer: exception_transformer
            )
            @list_snapshots = Google::Gax.create_api_call(
              @subscriber_stub.method(:list_snapshots),
              defaults["list_snapshots"],
              exception_transformer: exception_transformer
            )
            @create_snapshot = Google::Gax.create_api_call(
              @subscriber_stub.method(:create_snapshot),
              defaults["create_snapshot"],
              exception_transformer: exception_transformer
            )
            @update_snapshot = Google::Gax.create_api_call(
              @subscriber_stub.method(:update_snapshot),
              defaults["update_snapshot"],
              exception_transformer: exception_transformer
            )
            @delete_snapshot = Google::Gax.create_api_call(
              @subscriber_stub.method(:delete_snapshot),
              defaults["delete_snapshot"],
              exception_transformer: exception_transformer
            )
            @seek = Google::Gax.create_api_call(
              @subscriber_stub.method(:seek),
              defaults["seek"],
              exception_transformer: exception_transformer
            )
            @set_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:set_iam_policy),
              defaults["set_iam_policy"],
              exception_transformer: exception_transformer
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:get_iam_policy),
              defaults["get_iam_policy"],
              exception_transformer: exception_transformer
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @iam_policy_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Creates a subscription to a given topic. See the
          # <a href="/pubsub/docs/admin#resource_names"> resource name rules</a>.
          # If the subscription already exists, returns +ALREADY_EXISTS+.
          # If the corresponding topic doesn't exist, returns +NOT_FOUND+.
          #
          # If the name is not provided in the request, the server will assign a random
          # name for this subscription on the same project as the topic, conforming
          # to the
          # [resource name format](https://cloud.google.com/pubsub/docs/overview#names).
          # The generated name is populated in the returned Subscription object.
          # Note that for REST API requests, you must specify a name in the request.
          #
          # @param name [String]
          #   The name of the subscription. It must have the format
          #   +"projects/\\{project}/subscriptions/\\{subscription}"+. +\\{subscription}+ must
          #   start with a letter, and contain only letters (+[A-Za-z]+), numbers
          #   (+[0-9]+), dashes (+-+), underscores (+_+), periods (+.+), tildes (+~+),
          #   plus (+++) or percent signs (+%+). It must be between 3 and 255 characters
          #   in length, and it must not start with +"goog"+
          # @param topic [String]
          #   The name of the topic from which this subscription is receiving messages.
          #   Format is +projects/\\{project}/topics/\\{topic}+.
          #   The value of this field will be +_deleted-topic_+ if the topic has been
          #   deleted.
          # @param push_config [Google::Pubsub::V1::PushConfig | Hash]
          #   If push delivery is used with this subscription, this field is
          #   used to configure it. An empty +pushConfig+ signifies that the subscriber
          #   will pull and ack messages using API methods.
          #   A hash of the same form as `Google::Pubsub::V1::PushConfig`
          #   can also be provided.
          # @param ack_deadline_seconds [Integer]
          #   This value is the maximum time after a subscriber receives a message
          #   before the subscriber should acknowledge the message. After message
          #   delivery but before the ack deadline expires and before the message is
          #   acknowledged, it is an outstanding message and will not be delivered
          #   again during that time (on a best-effort basis).
          #
          #   For pull subscriptions, this value is used as the initial value for the ack
          #   deadline. To override this value for a given message, call
          #   +ModifyAckDeadline+ with the corresponding +ack_id+ if using
          #   non-streaming pull or send the +ack_id+ in a
          #   +StreamingModifyAckDeadlineRequest+ if using streaming pull.
          #   The minimum custom deadline you can specify is 10 seconds.
          #   The maximum custom deadline you can specify is 600 seconds (10 minutes).
          #   If this parameter is 0, a default value of 10 seconds is used.
          #
          #   For push delivery, this value is also used to set the request timeout for
          #   the call to the push endpoint.
          #
          #   If the subscriber never acknowledges the message, the Pub/Sub
          #   system will eventually redeliver the message.
          # @param retain_acked_messages [true, false]
          #   Indicates whether to retain acknowledged messages. If true, then
          #   messages are not expunged from the subscription's backlog, even if they are
          #   acknowledged, until they fall out of the +message_retention_duration+
          #   window.<br><br>
          #   <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          #   changed in backward-incompatible ways and is not recommended for production
          #   use. It is not subject to any SLA or deprecation policy.
          # @param message_retention_duration [Google::Protobuf::Duration | Hash]
          #   How long to retain unacknowledged messages in the subscription's backlog,
          #   from the moment a message is published.
          #   If +retain_acked_messages+ is true, then this also configures the retention
          #   of acknowledged messages, and thus configures how far back in time a +Seek+
          #   can be done. Defaults to 7 days. Cannot be more than 7 days or less than 10
          #   minutes.<br><br>
          #   <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          #   changed in backward-incompatible ways and is not recommended for production
          #   use. It is not subject to any SLA or deprecation policy.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param labels [Hash{String => String}]
          #   User labels.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Subscription]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_name = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   formatted_topic = Google::Cloud::Pubsub::V1::SubscriberClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = subscriber_client.create_subscription(formatted_name, formatted_topic)

          def create_subscription \
              name,
              topic,
              push_config: nil,
              ack_deadline_seconds: nil,
              retain_acked_messages: nil,
              message_retention_duration: nil,
              labels: nil,
              options: nil,
              &block
            req = {
              name: name,
              topic: topic,
              push_config: push_config,
              ack_deadline_seconds: ack_deadline_seconds,
              retain_acked_messages: retain_acked_messages,
              message_retention_duration: message_retention_duration,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::Subscription)
            @create_subscription.call(req, options, &block)
          end

          # Gets the configuration details of a subscription.
          #
          # @param subscription [String]
          #   The name of the subscription to get.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Subscription]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   response = subscriber_client.get_subscription(formatted_subscription)

          def get_subscription \
              subscription,
              options: nil,
              &block
            req = {
              subscription: subscription
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::GetSubscriptionRequest)
            @get_subscription.call(req, options, &block)
          end

          # Updates an existing subscription. Note that certain properties of a
          # subscription, such as its topic, are not modifiable.
          #
          # @param subscription [Google::Pubsub::V1::Subscription | Hash]
          #   The updated subscription object.
          #   A hash of the same form as `Google::Pubsub::V1::Subscription`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Indicates which fields in the provided subscription to update.
          #   Must be specified and non-empty.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Subscription]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   ack_deadline_seconds = 42
          #   subscription = { ack_deadline_seconds: ack_deadline_seconds }
          #   paths_element = "ack_deadline_seconds"
          #   paths = [paths_element]
          #   update_mask = { paths: paths }
          #   response = subscriber_client.update_subscription(subscription, update_mask)

          def update_subscription \
              subscription,
              update_mask,
              options: nil,
              &block
            req = {
              subscription: subscription,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::UpdateSubscriptionRequest)
            @update_subscription.call(req, options, &block)
          end

          # Lists matching subscriptions.
          #
          # @param project [String]
          #   The name of the cloud project that subscriptions belong to.
          #   Format is +projects/\\{project}+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Subscription>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Subscription>]
          #   An enumerable of Google::Pubsub::V1::Subscription instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_project = Google::Cloud::Pubsub::V1::SubscriberClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   subscriber_client.list_subscriptions(formatted_project).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   subscriber_client.list_subscriptions(formatted_project).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_subscriptions \
              project,
              page_size: nil,
              options: nil,
              &block
            req = {
              project: project,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ListSubscriptionsRequest)
            @list_subscriptions.call(req, options, &block)
          end

          # Deletes an existing subscription. All messages retained in the subscription
          # are immediately dropped. Calls to +Pull+ after deletion will return
          # +NOT_FOUND+. After a subscription is deleted, a new one may be created with
          # the same name, but the new one has no association with the old
          # subscription or its topic unless the same topic is specified.
          #
          # @param subscription [String]
          #   The subscription to delete.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   subscriber_client.delete_subscription(formatted_subscription)

          def delete_subscription \
              subscription,
              options: nil,
              &block
            req = {
              subscription: subscription
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::DeleteSubscriptionRequest)
            @delete_subscription.call(req, options, &block)
            nil
          end

          # Modifies the ack deadline for a specific message. This method is useful
          # to indicate that more time is needed to process a message by the
          # subscriber, or to make the message available for redelivery if the
          # processing was interrupted. Note that this does not modify the
          # subscription-level +ackDeadlineSeconds+ used for subsequent messages.
          #
          # @param subscription [String]
          #   The name of the subscription.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param ack_ids [Array<String>]
          #   List of acknowledgment IDs.
          # @param ack_deadline_seconds [Integer]
          #   The new ack deadline with respect to the time this request was sent to
          #   the Pub/Sub system. For example, if the value is 10, the new
          #   ack deadline will expire 10 seconds after the +ModifyAckDeadline+ call
          #   was made. Specifying zero may immediately make the message available for
          #   another pull request.
          #   The minimum deadline you can specify is 0 seconds.
          #   The maximum deadline you can specify is 600 seconds (10 minutes).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +ack_ids+:
          #   ack_ids = []
          #
          #   # TODO: Initialize +ack_deadline_seconds+:
          #   ack_deadline_seconds = 0
          #   subscriber_client.modify_ack_deadline(formatted_subscription, ack_ids, ack_deadline_seconds)

          def modify_ack_deadline \
              subscription,
              ack_ids,
              ack_deadline_seconds,
              options: nil,
              &block
            req = {
              subscription: subscription,
              ack_ids: ack_ids,
              ack_deadline_seconds: ack_deadline_seconds
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ModifyAckDeadlineRequest)
            @modify_ack_deadline.call(req, options, &block)
            nil
          end

          # Acknowledges the messages associated with the +ack_ids+ in the
          # +AcknowledgeRequest+. The Pub/Sub system can remove the relevant messages
          # from the subscription.
          #
          # Acknowledging a message whose ack deadline has expired may succeed,
          # but such a message may be redelivered later. Acknowledging a message more
          # than once will not result in an error.
          #
          # @param subscription [String]
          #   The subscription whose message is being acknowledged.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param ack_ids [Array<String>]
          #   The acknowledgment ID for the messages being acknowledged that was returned
          #   by the Pub/Sub system in the +Pull+ response. Must not be empty.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +ack_ids+:
          #   ack_ids = []
          #   subscriber_client.acknowledge(formatted_subscription, ack_ids)

          def acknowledge \
              subscription,
              ack_ids,
              options: nil,
              &block
            req = {
              subscription: subscription,
              ack_ids: ack_ids
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::AcknowledgeRequest)
            @acknowledge.call(req, options, &block)
            nil
          end

          # Pulls messages from the server. Returns an empty list if there are no
          # messages available in the backlog. The server may return +UNAVAILABLE+ if
          # there are too many concurrent pull requests pending for the given
          # subscription.
          #
          # @param subscription [String]
          #   The subscription from which messages should be pulled.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param max_messages [Integer]
          #   The maximum number of messages returned for this request. The Pub/Sub
          #   system may return fewer than the number specified.
          # @param return_immediately [true, false]
          #   If this field set to true, the system will respond immediately even if
          #   it there are no messages available to return in the +Pull+ response.
          #   Otherwise, the system may wait (for a bounded amount of time) until at
          #   least one message is available, rather than returning no messages. The
          #   client may cancel the request if it does not wish to wait any longer for
          #   the response.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::PullResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::PullResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +max_messages+:
          #   max_messages = 0
          #   response = subscriber_client.pull(formatted_subscription, max_messages)

          def pull \
              subscription,
              max_messages,
              return_immediately: nil,
              options: nil,
              &block
            req = {
              subscription: subscription,
              max_messages: max_messages,
              return_immediately: return_immediately
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::PullRequest)
            @pull.call(req, options, &block)
          end

          # Establishes a stream with the server, which sends messages down to the
          # client. The client streams acknowledgements and ack deadline modifications
          # back to the server. The server will close the stream and return the status
          # on any error. The server may close the stream with status +UNAVAILABLE+ to
          # reassign server-side resources, in which case, the client should
          # re-establish the stream. Flow control can be achieved by configuring the
          # underlying RPC channel.
          #
          # @param reqs [Enumerable<Google::Pubsub::V1::StreamingPullRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Pubsub::V1::StreamingPullResponse>]
          #   An enumerable of Google::Pubsub::V1::StreamingPullResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +stream_ack_deadline_seconds+:
          #   stream_ack_deadline_seconds = 0
          #   request = { subscription: formatted_subscription, stream_ack_deadline_seconds: stream_ack_deadline_seconds }
          #   requests = [request]
          #   subscriber_client.streaming_pull(requests).each do |element|
          #     # Process element.
          #   end

          def streaming_pull reqs, options: nil
            request_protos = reqs.lazy.map do |req|
              Google::Gax::to_proto(req, Google::Pubsub::V1::StreamingPullRequest)
            end
            @streaming_pull.call(request_protos, options)
          end

          # Modifies the +PushConfig+ for a specified subscription.
          #
          # This may be used to change a push subscription to a pull one (signified by
          # an empty +PushConfig+) or vice versa, or change the endpoint URL and other
          # attributes of a push subscription. Messages will accumulate for delivery
          # continuously through the call regardless of changes to the +PushConfig+.
          #
          # @param subscription [String]
          #   The name of the subscription.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param push_config [Google::Pubsub::V1::PushConfig | Hash]
          #   The push configuration for future deliveries.
          #
          #   An empty +pushConfig+ indicates that the Pub/Sub system should
          #   stop pushing messages from the given subscription and allow
          #   messages to be pulled and acknowledged - effectively pausing
          #   the subscription if +Pull+ or +StreamingPull+ is not called.
          #   A hash of the same form as `Google::Pubsub::V1::PushConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +push_config+:
          #   push_config = {}
          #   subscriber_client.modify_push_config(formatted_subscription, push_config)

          def modify_push_config \
              subscription,
              push_config,
              options: nil,
              &block
            req = {
              subscription: subscription,
              push_config: push_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ModifyPushConfigRequest)
            @modify_push_config.call(req, options, &block)
            nil
          end

          # Lists the existing snapshots.<br><br>
          # <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          # changed in backward-incompatible ways and is not recommended for production
          # use. It is not subject to any SLA or deprecation policy.
          #
          # @param project [String]
          #   The name of the cloud project that snapshots belong to.
          #   Format is +projects/\\{project}+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Snapshot>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Snapshot>]
          #   An enumerable of Google::Pubsub::V1::Snapshot instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_project = Google::Cloud::Pubsub::V1::SubscriberClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   subscriber_client.list_snapshots(formatted_project).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   subscriber_client.list_snapshots(formatted_project).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_snapshots \
              project,
              page_size: nil,
              options: nil,
              &block
            req = {
              project: project,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ListSnapshotsRequest)
            @list_snapshots.call(req, options, &block)
          end

          # Creates a snapshot from the requested subscription.<br><br>
          # <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          # changed in backward-incompatible ways and is not recommended for production
          # use. It is not subject to any SLA or deprecation policy.
          # If the snapshot already exists, returns +ALREADY_EXISTS+.
          # If the requested subscription doesn't exist, returns +NOT_FOUND+.
          # If the backlog in the subscription is too old -- and the resulting snapshot
          # would expire in less than 1 hour -- then +FAILED_PRECONDITION+ is returned.
          # See also the +Snapshot.expire_time+ field. If the name is not provided in
          # the request, the server will assign a random
          # name for this snapshot on the same project as the subscription, conforming
          # to the [resource name format](https://cloud.google.com/pubsub/docs/overview#names).
          # The generated
          # name is populated in the returned Snapshot object. Note that for REST API
          # requests, you must specify a name in the request.
          #
          # @param name [String]
          #   Optional user-provided name for this snapshot.
          #   If the name is not provided in the request, the server will assign a random
          #   name for this snapshot on the same project as the subscription.
          #   Note that for REST API requests, you must specify a name.
          #   Format is +projects/\\{project}/snapshots/\\{snap}+.
          # @param subscription [String]
          #   The subscription whose backlog the snapshot retains.
          #   Specifically, the created snapshot is guaranteed to retain:
          #    (a) The existing backlog on the subscription. More precisely, this is
          #        defined as the messages in the subscription's backlog that are
          #        unacknowledged upon the successful completion of the
          #        +CreateSnapshot+ request; as well as:
          #    (b) Any messages published to the subscription's topic following the
          #        successful completion of the CreateSnapshot request.
          #   Format is +projects/\\{project}/subscriptions/\\{sub}+.
          # @param labels [Hash{String => String}]
          #   User labels.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Snapshot]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Snapshot]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_name = Google::Cloud::Pubsub::V1::SubscriberClient.snapshot_path("[PROJECT]", "[SNAPSHOT]")
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   response = subscriber_client.create_snapshot(formatted_name, formatted_subscription)

          def create_snapshot \
              name,
              subscription,
              labels: nil,
              options: nil,
              &block
            req = {
              name: name,
              subscription: subscription,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::CreateSnapshotRequest)
            @create_snapshot.call(req, options, &block)
          end

          # Updates an existing snapshot.<br><br>
          # <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          # changed in backward-incompatible ways and is not recommended for production
          # use. It is not subject to any SLA or deprecation policy.
          # Note that certain properties of a snapshot are not modifiable.
          #
          # @param snapshot [Google::Pubsub::V1::Snapshot | Hash]
          #   The updated snapshot object.
          #   A hash of the same form as `Google::Pubsub::V1::Snapshot`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Indicates which fields in the provided snapshot to update.
          #   Must be specified and non-empty.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Snapshot]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Snapshot]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   seconds = 123456
          #   expire_time = { seconds: seconds }
          #   snapshot = { expire_time: expire_time }
          #   paths_element = "expire_time"
          #   paths = [paths_element]
          #   update_mask = { paths: paths }
          #   response = subscriber_client.update_snapshot(snapshot, update_mask)

          def update_snapshot \
              snapshot,
              update_mask,
              options: nil,
              &block
            req = {
              snapshot: snapshot,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::UpdateSnapshotRequest)
            @update_snapshot.call(req, options, &block)
          end

          # Removes an existing snapshot. <br><br>
          # <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          # changed in backward-incompatible ways and is not recommended for production
          # use. It is not subject to any SLA or deprecation policy.
          # When the snapshot is deleted, all messages retained in the snapshot
          # are immediately dropped. After a snapshot is deleted, a new one may be
          # created with the same name, but the new one has no association with the old
          # snapshot or its subscription, unless the same subscription is specified.
          #
          # @param snapshot [String]
          #   The name of the snapshot to delete.
          #   Format is +projects/\\{project}/snapshots/\\{snap}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_snapshot = Google::Cloud::Pubsub::V1::SubscriberClient.snapshot_path("[PROJECT]", "[SNAPSHOT]")
          #   subscriber_client.delete_snapshot(formatted_snapshot)

          def delete_snapshot \
              snapshot,
              options: nil,
              &block
            req = {
              snapshot: snapshot
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::DeleteSnapshotRequest)
            @delete_snapshot.call(req, options, &block)
            nil
          end

          # Seeks an existing subscription to a point in time or to a given snapshot,
          # whichever is provided in the request.<br><br>
          # <b>ALPHA:</b> This feature is part of an alpha release. This API might be
          # changed in backward-incompatible ways and is not recommended for production
          # use. It is not subject to any SLA or deprecation policy.
          #
          # @param subscription [String]
          #   The subscription to affect.
          # @param time [Google::Protobuf::Timestamp | Hash]
          #   The time to seek to.
          #   Messages retained in the subscription that were published before this
          #   time are marked as acknowledged, and messages retained in the
          #   subscription that were published after this time are marked as
          #   unacknowledged. Note that this operation affects only those messages
          #   retained in the subscription (configured by the combination of
          #   +message_retention_duration+ and +retain_acked_messages+). For example,
          #   if +time+ corresponds to a point before the message retention
          #   window (or to a point before the system's notion of the subscription
          #   creation time), only retained messages will be marked as unacknowledged,
          #   and already-expunged messages will not be restored.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param snapshot [String]
          #   The snapshot to seek to. The snapshot's topic must be the same as that of
          #   the provided subscription.
          #   Format is +projects/\\{project}/snapshots/\\{snap}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::SeekResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::SeekResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_subscription = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   response = subscriber_client.seek(formatted_subscription)

          def seek \
              subscription,
              time: nil,
              snapshot: nil,
              options: nil,
              &block
            req = {
              subscription: subscription,
              time: time,
              snapshot: snapshot
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::SeekRequest)
            @seek.call(req, options, &block)
          end

          # Sets the access control policy on the specified resource. Replaces any
          # existing policy.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the +resource+. The size of
          #   the policy is limited to a few 10s of KB. An empty policy is a
          #   valid policy but certain Cloud Platform services (such as Projects)
          #   might reject them.
          #   A hash of the same form as `Google::Iam::V1::Policy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +policy+:
          #   policy = {}
          #   response = subscriber_client.set_iam_policy(formatted_resource, policy)

          def set_iam_policy \
              resource,
              policy,
              options: nil,
              &block
            req = {
              resource: resource,
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
            @set_iam_policy.call(req, options, &block)
          end

          # Gets the access control policy for a resource.
          # Returns an empty policy if the resource exists and does not have a policy
          # set.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #   response = subscriber_client.get_iam_policy(formatted_resource)

          def get_iam_policy \
              resource,
              options: nil,
              &block
            req = {
              resource: resource
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
            @get_iam_policy.call(req, options, &block)
          end

          # Returns permissions that a caller has on the specified resource.
          # If the resource does not exist, this will return an empty set of
          # permissions, not a NOT_FOUND error.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the +resource+. Permissions with
          #   wildcards (such as '*' or 'storage.*') are not allowed. For more
          #   information see
          #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::TestIamPermissionsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::TestIamPermissionsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   subscriber_client = Google::Cloud::Pubsub::Subscriber.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::SubscriberClient.subscription_path("[PROJECT]", "[SUBSCRIPTION]")
          #
          #   # TODO: Initialize +permissions+:
          #   permissions = []
          #   response = subscriber_client.test_iam_permissions(formatted_resource, permissions)

          def test_iam_permissions \
              resource,
              permissions,
              options: nil,
              &block
            req = {
              resource: resource,
              permissions: permissions
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
            @test_iam_permissions.call(req, options, &block)
          end
        end
      end
    end
  end
end
