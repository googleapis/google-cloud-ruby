# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/iam/v1/iam_policy_pb"
require "google/pubsub/v1/pubsub_pb"

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
          attr_reader :iam_policy_stub, :publisher_stub

          # The default address of the service.
          SERVICE_ADDRESS = "pubsub.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

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

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          TOPIC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/topics/{topic}"
          )

          private_constant :TOPIC_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
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

          # Parses the project from a project resource.
          # @param project_name [String]
          # @return [String]
          def self.match_project_from_project_name project_name
            PROJECT_PATH_TEMPLATE.match(project_name)["project"]
          end

          # Parses the project from a topic resource.
          # @param topic_name [String]
          # @return [String]
          def self.match_project_from_topic_name topic_name
            TOPIC_PATH_TEMPLATE.match(topic_name)["project"]
          end

          # Parses the topic from a topic resource.
          # @param topic_name [String]
          # @return [String]
          def self.match_topic_from_topic_name topic_name
            TOPIC_PATH_TEMPLATE.match(topic_name)["topic"]
          end

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: nil,
              app_version: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/iam/v1/iam_policy_services_pb"
            require "google/pubsub/v1/pubsub_services_pb"


            if app_name || app_version
              warn "`app_name` and `app_version` are no longer being used in the request headers."
            end

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
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
                kwargs: headers
              )
            end
            @iam_policy_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Iam::V1::IAMPolicy::Stub.method(:new)
            )
            @publisher_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Pubsub::V1::Publisher::Stub.method(:new)
            )

            @set_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:set_iam_policy),
              defaults["set_iam_policy"]
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:get_iam_policy),
              defaults["get_iam_policy"]
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @iam_policy_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"]
            )
            @create_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:create_topic),
              defaults["create_topic"]
            )
            @publish = Google::Gax.create_api_call(
              @publisher_stub.method(:publish),
              defaults["publish"]
            )
            @get_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:get_topic),
              defaults["get_topic"]
            )
            @list_topics = Google::Gax.create_api_call(
              @publisher_stub.method(:list_topics),
              defaults["list_topics"]
            )
            @list_topic_subscriptions = Google::Gax.create_api_call(
              @publisher_stub.method(:list_topic_subscriptions),
              defaults["list_topic_subscriptions"]
            )
            @delete_topic = Google::Gax.create_api_call(
              @publisher_stub.method(:delete_topic),
              defaults["delete_topic"]
            )
          end

          # Service calls

          # Creates the given topic with the given name.
          #
          # @param name [String]
          #   The name of the topic. It must have the format
          #   +"projects/{project}/topics/{topic}"+. +{topic}+ must start with a letter,
          #   and contain only letters (+[A-Za-z]+), numbers (+[0-9]+), dashes (+-+),
          #   underscores (+_+), periods (+.+), tildes (+~+), plus (+++) or percent
          #   signs (+%+). It must be between 3 and 255 characters in length, and it
          #   must not start with +"goog"+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_name = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.create_topic(formatted_name)

          def create_topic \
              name,
              options: nil
            req = Google::Pubsub::V1::Topic.new({
              name: name
            }.delete_if { |_, v| v.nil? })
            @create_topic.call(req, options)
          end

          # Adds one or more messages to the topic. Returns +NOT_FOUND+ if the topic
          # does not exist. The message payload must not be empty; it must contain
          #  either a non-empty data field, or at least one attribute.
          #
          # @param topic [String]
          #   The messages in the request will be published on this topic.
          #   Format is +projects/{project}/topics/{topic}+.
          # @param messages [Array<Google::Pubsub::V1::PubsubMessage>]
          #   The messages to publish.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::PublishResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #   PubsubMessage = Google::Pubsub::V1::PubsubMessage
          #
          #   publisher_client = PublisherClient.new
          #   formatted_topic = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   data = ''
          #   messages_element = PubsubMessage.new
          #   messages_element.data = data
          #   messages = [messages_element]
          #   response = publisher_client.publish(formatted_topic, messages)

          def publish \
              topic,
              messages,
              options: nil
            req = Google::Pubsub::V1::PublishRequest.new({
              topic: topic,
              messages: messages
            }.delete_if { |_, v| v.nil? })
            @publish.call(req, options)
          end

          # Gets the configuration of a topic.
          #
          # @param topic [String]
          #   The name of the topic to get.
          #   Format is +projects/{project}/topics/{topic}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_topic = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.get_topic(formatted_topic)

          def get_topic \
              topic,
              options: nil
            req = Google::Pubsub::V1::GetTopicRequest.new({
              topic: topic
            }.delete_if { |_, v| v.nil? })
            @get_topic.call(req, options)
          end

          # Lists matching topics.
          #
          # @param project [String]
          #   The name of the cloud project that topics belong to.
          #   Format is +projects/{project}+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Pubsub::V1::Topic>]
          #   An enumerable of Google::Pubsub::V1::Topic instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_project = PublisherClient.project_path("[PROJECT]")
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
              options: nil
            req = Google::Pubsub::V1::ListTopicsRequest.new({
              project: project,
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_topics.call(req, options)
          end

          # Lists the name of the subscriptions for this topic.
          #
          # @param topic [String]
          #   The name of the topic that subscriptions are attached to.
          #   Format is +projects/{project}/topics/{topic}+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<String>]
          #   An enumerable of String instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_topic = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
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
              options: nil
            req = Google::Pubsub::V1::ListTopicSubscriptionsRequest.new({
              topic: topic,
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_topic_subscriptions.call(req, options)
          end

          # Deletes the topic with the given name. Returns +NOT_FOUND+ if the topic
          # does not exist. After a topic is deleted, a new topic may be created with
          # the same name; this is an entirely new topic with none of the old
          # configuration or subscriptions. Existing subscriptions to this topic are
          # not deleted, but their +topic+ field is set to +_deleted-topic_+.
          #
          # @param topic [String]
          #   Name of the topic to delete.
          #   Format is +projects/{project}/topics/{topic}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_topic = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   publisher_client.delete_topic(formatted_topic)

          def delete_topic \
              topic,
              options: nil
            req = Google::Pubsub::V1::DeleteTopicRequest.new({
              topic: topic
            }.delete_if { |_, v| v.nil? })
            @delete_topic.call(req, options)
            nil
          end

          # Sets the access control policy on the specified resource. Replaces any
          # existing policy.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param policy [Google::Iam::V1::Policy]
          #   REQUIRED: The complete policy to be applied to the +resource+. The size of
          #   the policy is limited to a few 10s of KB. An empty policy is a
          #   valid policy but certain Cloud Platform services (such as Projects)
          #   might reject them.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   Policy = Google::Iam::V1::Policy
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_resource = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   policy = Policy.new
          #   response = publisher_client.set_iam_policy(formatted_resource, policy)

          def set_iam_policy \
              resource,
              policy,
              options: nil
            req = Google::Iam::V1::SetIamPolicyRequest.new({
              resource: resource,
              policy: policy
            }.delete_if { |_, v| v.nil? })
            @set_iam_policy.call(req, options)
          end

          # Gets the access control policy for a resource.
          # Returns an empty policy if the resource exists and does not have a policy
          # set.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_resource = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_client.get_iam_policy(formatted_resource)

          def get_iam_policy \
              resource,
              options: nil
            req = Google::Iam::V1::GetIamPolicyRequest.new({
              resource: resource
            }.delete_if { |_, v| v.nil? })
            @get_iam_policy.call(req, options)
          end

          # Returns permissions that a caller has on the specified resource.
          # If the resource does not exist, this will return an empty set of
          # permissions, not a NOT_FOUND error.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the +resource+. Permissions with
          #   wildcards (such as '*' or 'storage.*') are not allowed. For more
          #   information see
          #   {IAM Overview}[https://cloud.google.com/iam/docs/overview#permissions].
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Iam::V1::TestIamPermissionsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_client"
          #
          #   PublisherClient = Google::Cloud::Pubsub::V1::PublisherClient
          #
          #   publisher_client = PublisherClient.new
          #   formatted_resource = PublisherClient.topic_path("[PROJECT]", "[TOPIC]")
          #   permissions = []
          #   response = publisher_client.test_iam_permissions(formatted_resource, permissions)

          def test_iam_permissions \
              resource,
              permissions,
              options: nil
            req = Google::Iam::V1::TestIamPermissionsRequest.new({
              resource: resource,
              permissions: permissions
            }.delete_if { |_, v| v.nil? })
            @test_iam_permissions.call(req, options)
          end
        end
      end
    end
  end
end
