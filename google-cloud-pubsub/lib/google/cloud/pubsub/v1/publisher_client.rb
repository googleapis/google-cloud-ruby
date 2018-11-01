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
        # The service that an application uses to manipulate topics, and to send
        # messages to a topic.
        #
        # @!attribute [r] iam_policy_stub
        #   @return [Google::Iam::V1::IAMPolicy::Stub]
        # @!attribute [r] publisher_stub
        #   @return [Google::Pubsub::V1::Publisher::Stub]
        class PublisherClient
          # @private
          attr_reader :iam_policy_stub, :publisher_stub

          # The default address of the service.
          SERVICE_ADDRESS = "pubsub.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_topics" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "topics"),
            "list_topic_subscriptions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "subscriptions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          BUNDLE_DESCRIPTORS = {
            "publish" => Google::Gax::BundleDescriptor.new(
              "messages",
              [
                "topic"
              ],
              subresponse_field: "message_ids")
          }.freeze

          private_constant :BUNDLE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/pubsub"
          ].freeze


          TOPIC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/topics/{topic}"
          )

          private_constant :TOPIC_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

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
              "publisher_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.pubsub.v1.Publisher",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                bundle_descriptors: BUNDLE_DESCRIPTORS,
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
            @publisher_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Pubsub::V1::Publisher::Stub.method(:new)
            )

            @create_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:create_topic),
              defaults["create_topic"],
              exception_transformer: exception_transformer
            )
            @update_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:update_topic),
              defaults["update_topic"],
              exception_transformer: exception_transformer
            )
            @publish = Google::Gax.create_api_call(
              @publisher_stub.method(:publish),
              defaults["publish"],
              exception_transformer: exception_transformer
            )
            @get_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:get_topic),
              defaults["get_topic"],
              exception_transformer: exception_transformer
            )
            @list_topics = Google::Gax.create_api_call(
              @publisher_stub.method(:list_topics),
              defaults["list_topics"],
              exception_transformer: exception_transformer
            )
            @list_topic_subscriptions = Google::Gax.create_api_call(
              @publisher_stub.method(:list_topic_subscriptions),
              defaults["list_topic_subscriptions"],
              exception_transformer: exception_transformer
            )
            @delete_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:delete_topic),
              defaults["delete_topic"],
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

          # Creates the given topic with the given name. See the
          # <a href="/pubsub/docs/admin#resource_names"> resource name rules</a>.
          #
          # @param name [String]
          #   The name of the topic. It must have the format
          #   `"projects/{project}/topics/{topic}"`. `{topic}` must start with a letter,
          #   and contain only letters (`[A-Za-z]`), numbers (`[0-9]`), dashes (`-`),
          #   underscores (`_`), periods (`.`), tildes (`~`), plus (`+`) or percent
          #   signs (`%`). It must be between 3 and 255 characters in length, and it
          #   must not start with `"goog"`.
          # @param labels [Hash{String => String}]
          #   See <a href="/pubsub/docs/labels"> Creating and managing labels</a>.
          # @param message_storage_policy [Google::Pubsub::V1::MessageStoragePolicy | Hash]
          #   Policy constraining how messages published to the topic may be stored. It
          #   is determined when the topic is created based on the policy configured at
          #   the project level. It must not be set by the caller in the request to
          #   CreateTopic or to UpdateTopic. This field will be populated in the
          #   responses for GetTopic, CreateTopic, and UpdateTopic: if not present in the
          #   response, then no constraints are in effect.
          #   A hash of the same form as `Google::Pubsub::V1::MessageStoragePolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Topic]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_name = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.create_topic(formatted_name)

          def create_topic \
              name,
              labels: nil,
              message_storage_policy: nil,
              options: nil,
              &block
            req = {
              name: name,
              labels: labels,
              message_storage_policy: message_storage_policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::Topic)
            @create_topic.call(req, options, &block)
          end

          # Updates an existing topic. Note that certain properties of a
          # topic are not modifiable.
          #
          # @param topic [Google::Pubsub::V1::Topic | Hash]
          #   The updated topic object.
          #   A hash of the same form as `Google::Pubsub::V1::Topic`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Indicates which fields in the provided topic to update. Must be specified
          #   and non-empty. Note that if `update_mask` contains
          #   "message_storage_policy" then the new value will be determined based on the
          #   policy configured at the project or organization level. The
          #   `message_storage_policy` must not be set in the `topic` provided above.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Topic]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #
          #   # TODO: Initialize `topic`:
          #   topic = {}
          #
          #   # TODO: Initialize `update_mask`:
          #   update_mask = {}
          #   response = publisher_client.update_topic(topic, update_mask)

          def update_topic \
              topic,
              update_mask,
              options: nil,
              &block
            req = {
              topic: topic,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::UpdateTopicRequest)
            @update_topic.call(req, options, &block)
          end

          # Adds one or more messages to the topic. Returns `NOT_FOUND` if the topic
          # does not exist.
          #
          # @param topic [String]
          #   The messages in the request will be published on this topic.
          #   Format is `projects/{project}/topics/{topic}`.
          # @param messages [Array<Google::Pubsub::V1::PubsubMessage | Hash>]
          #   The messages to publish.
          #   A hash of the same form as `Google::Pubsub::V1::PubsubMessage`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::PublishResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::PublishResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_topic = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   data = ''
          #   messages_element = { data: data }
          #   messages = [messages_element]
          #   response = publisher_client.publish(formatted_topic, messages)

          def publish \
              topic,
              messages,
              options: nil,
              &block
            req = {
              topic: topic,
              messages: messages
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::PublishRequest)
            @publish.call(req, options, &block)
          end

          # Gets the configuration of a topic.
          #
          # @param topic [String]
          #   The name of the topic to get.
          #   Format is `projects/{project}/topics/{topic}`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Pubsub::V1::Topic]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_topic = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.get_topic(formatted_topic)

          def get_topic \
              topic,
              options: nil,
              &block
            req = {
              topic: topic
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::GetTopicRequest)
            @get_topic.call(req, options, &block)
          end

          # Lists matching topics.
          #
          # @param project [String]
          #   The name of the project in which to list topics.
          #   Format is `projects/{project-id}`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Topic>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Topic>]
          #   An enumerable of Google::Pubsub::V1::Topic instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_project = Google::Cloud::Pubsub::V1::PublisherClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   publisher_client.list_topics(formatted_project).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   publisher_client.list_topics(formatted_project).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_topics \
              project,
              page_size: nil,
              options: nil,
              &block
            req = {
              project: project,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ListTopicsRequest)
            @list_topics.call(req, options, &block)
          end

          # Lists the names of the subscriptions on this topic.
          #
          # @param topic [String]
          #   The name of the topic that subscriptions are attached to.
          #   Format is `projects/{project}/topics/{topic}`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<String>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<String>]
          #   An enumerable of String instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub"
          #
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_topic = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #
          #   # Iterate over all results.
          #   publisher_client.list_topic_subscriptions(formatted_topic).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   publisher_client.list_topic_subscriptions(formatted_topic).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_topic_subscriptions \
              topic,
              page_size: nil,
              options: nil,
              &block
            req = {
              topic: topic,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::ListTopicSubscriptionsRequest)
            @list_topic_subscriptions.call(req, options, &block)
          end

          # Deletes the topic with the given name. Returns `NOT_FOUND` if the topic
          # does not exist. After a topic is deleted, a new topic may be created with
          # the same name; this is an entirely new topic with none of the old
          # configuration or subscriptions. Existing subscriptions to this topic are
          # not deleted, but their `topic` field is set to `_deleted-topic_`.
          #
          # @param topic [String]
          #   Name of the topic to delete.
          #   Format is `projects/{project}/topics/{topic}`.
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
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_topic = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   publisher_client.delete_topic(formatted_topic)

          def delete_topic \
              topic,
              options: nil,
              &block
            req = {
              topic: topic
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Pubsub::V1::DeleteTopicRequest)
            @delete_topic.call(req, options, &block)
            nil
          end

          # Sets the access control policy on the specified resource. Replaces any
          # existing policy.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   `resource` is usually specified as a path. For example, a Project
          #   resource is specified as `projects/{project}`.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the `resource`. The size of
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
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #
          #   # TODO: Initialize `policy`:
          #   policy = {}
          #   response = publisher_client.set_iam_policy(formatted_resource, policy)

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
          #   `resource` is usually specified as a path. For example, a Project
          #   resource is specified as `projects/{project}`.
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
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.get_iam_policy(formatted_resource)

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
          #   `resource` is usually specified as a path. For example, a Project
          #   resource is specified as `projects/{project}`.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the `resource`. Permissions with
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
          #   publisher_client = Google::Cloud::Pubsub::Publisher.new(version: :v1)
          #   formatted_resource = Google::Cloud::Pubsub::V1::PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #
          #   # TODO: Initialize `permissions`:
          #   permissions = []
          #   response = publisher_client.test_iam_permissions(formatted_resource, permissions)

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
