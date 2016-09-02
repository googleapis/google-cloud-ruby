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

module Google
  module Cloud
    module Pubsub
      module V1
        # The service that an application uses to manipulate topics, and to send
        # messages to a topic.
        #
        # @!attribute [r] stub
        #   @return [Google::Pubsub::V1::Publisher::Stub]
        class PublisherApi
          attr_reader :stub

          # The default address of the service.
          SERVICE_ADDRESS = "pubsub.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

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
          # @param app_name [String]
          #   The codename of the calling service.
          # @param app_version [String]
          #   The version of the calling service.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: "gax",
              app_version: Google::Gax::VERSION
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/pubsub/v1/pubsub_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
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
            @stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Pubsub::V1::Publisher::Stub.method(:new)
            )

            @create_topic = Google::Gax.create_api_call(
              @stub.method(:create_topic),
              defaults["create_topic"]
            )
            @publish = Google::Gax.create_api_call(
              @stub.method(:publish),
              defaults["publish"]
            )
            @get_topic = Google::Gax.create_api_call(
              @stub.method(:get_topic),
              defaults["get_topic"]
            )
            @list_topics = Google::Gax.create_api_call(
              @stub.method(:list_topics),
              defaults["list_topics"]
            )
            @list_topic_subscriptions = Google::Gax.create_api_call(
              @stub.method(:list_topic_subscriptions),
              defaults["list_topic_subscriptions"]
            )
            @delete_topic = Google::Gax.create_api_call(
              @stub.method(:delete_topic),
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
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #
          #   publisher_api = PublisherApi.new
          #   formatted_name = PublisherApi.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_api.create_topic(formatted_name)

          def create_topic \
              name,
              options: nil
            req = Google::Pubsub::V1::Topic.new(
              name: name
            )
            @create_topic.call(req, options)
          end

          # Adds one or more messages to the topic. Returns +NOT_FOUND+ if the topic
          # does not exist. The message payload must not be empty; it must contain
          #  either a non-empty data field, or at least one attribute.
          #
          # @param topic [String]
          #   The messages in the request will be published on this topic.
          # @param messages [Array<Google::Pubsub::V1::PubsubMessage>]
          #   The messages to publish.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::PublishResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #   PubsubMessage = Google::Pubsub::V1::PubsubMessage
          #
          #   publisher_api = PublisherApi.new
          #   formatted_topic = PublisherApi.topic_path("[PROJECT]", "[TOPIC]")
          #   data = ''
          #   messages_element = PubsubMessage.new
          #   messages_element.data = data
          #   messages = [messages_element]
          #   response = publisher_api.publish(formatted_topic, messages)

          def publish \
              topic,
              messages,
              options: nil
            req = Google::Pubsub::V1::PublishRequest.new(
              topic: topic,
              messages: messages
            )
            @publish.call(req, options)
          end

          # Gets the configuration of a topic.
          #
          # @param topic [String]
          #   The name of the topic to get.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Pubsub::V1::Topic]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #
          #   publisher_api = PublisherApi.new
          #   formatted_topic = PublisherApi.topic_path("[PROJECT]", "[TOPIC]")
          #   response = publisher_api.get_topic(formatted_topic)

          def get_topic \
              topic,
              options: nil
            req = Google::Pubsub::V1::GetTopicRequest.new(
              topic: topic
            )
            @get_topic.call(req, options)
          end

          # Lists matching topics.
          #
          # @param project [String]
          #   The name of the cloud project that topics belong to.
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
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #
          #   publisher_api = PublisherApi.new
          #   formatted_project = PublisherApi.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   publisher_api.list_topics(formatted_project).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   publisher_api.list_topics(formatted_project).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_topics \
              project,
              page_size: nil,
              options: nil
            req = Google::Pubsub::V1::ListTopicsRequest.new(
              project: project
            )
            req.page_size = page_size unless page_size.nil?
            @list_topics.call(req, options)
          end

          # Lists the name of the subscriptions for this topic.
          #
          # @param topic [String]
          #   The name of the topic that subscriptions are attached to.
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
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #
          #   publisher_api = PublisherApi.new
          #   formatted_topic = PublisherApi.topic_path("[PROJECT]", "[TOPIC]")
          #
          #   # Iterate over all results.
          #   publisher_api.list_topic_subscriptions(formatted_topic).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   publisher_api.list_topic_subscriptions(formatted_topic).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_topic_subscriptions \
              topic,
              page_size: nil,
              options: nil
            req = Google::Pubsub::V1::ListTopicSubscriptionsRequest.new(
              topic: topic
            )
            req.page_size = page_size unless page_size.nil?
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
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/pubsub/v1/publisher_api"
          #
          #   PublisherApi = Google::Cloud::Pubsub::V1::PublisherApi
          #
          #   publisher_api = PublisherApi.new
          #   formatted_topic = PublisherApi.topic_path("[PROJECT]", "[TOPIC]")
          #   publisher_api.delete_topic(formatted_topic)

          def delete_topic \
              topic,
              options: nil
            req = Google::Pubsub::V1::DeleteTopicRequest.new(
              topic: topic
            )
            @delete_topic.call(req, options)
          end
        end
      end
    end
  end
end
