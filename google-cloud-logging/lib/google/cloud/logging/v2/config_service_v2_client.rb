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
# https://github.com/googleapis/googleapis/blob/master/google/logging/v2/logging_config.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/logging/v2/logging_config_pb"

module Google
  module Cloud
    module Logging
      module V2
        # Service for configuring sinks used to export log entries outside of
        # Stackdriver Logging.
        #
        # @!attribute [r] config_service_v2_stub
        #   @return [Google::Logging::V2::ConfigServiceV2::Stub]
        class ConfigServiceV2Client
          attr_reader :config_service_v2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "logging.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_sinks" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "sinks")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-platform.read-only",
            "https://www.googleapis.com/auth/logging.admin",
            "https://www.googleapis.com/auth/logging.read",
            "https://www.googleapis.com/auth/logging.write"
          ].freeze

          PARENT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PARENT_PATH_TEMPLATE

          SINK_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/sinks/{sink}"
          )

          private_constant :SINK_PATH_TEMPLATE

          # Returns a fully-qualified parent resource name string.
          # @param project [String]
          # @return [String]
          def self.parent_path project
            PARENT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified sink resource name string.
          # @param project [String]
          # @param sink [String]
          # @return [String]
          def self.sink_path project, sink
            SINK_PATH_TEMPLATE.render(
              :"project" => project,
              :"sink" => sink
            )
          end

          # Parses the project from a parent resource.
          # @param parent_name [String]
          # @return [String]
          def self.match_project_from_parent_name parent_name
            PARENT_PATH_TEMPLATE.match(parent_name)["project"]
          end

          # Parses the project from a sink resource.
          # @param sink_name [String]
          # @return [String]
          def self.match_project_from_sink_name sink_name
            SINK_PATH_TEMPLATE.match(sink_name)["project"]
          end

          # Parses the sink from a sink resource.
          # @param sink_name [String]
          # @return [String]
          def self.match_sink_from_sink_name sink_name
            SINK_PATH_TEMPLATE.match(sink_name)["sink"]
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
            require "google/logging/v2/logging_config_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
              "ruby/#{RUBY_VERSION}".freeze
            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "config_service_v2_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.logging.v2.ConfigServiceV2",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @config_service_v2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Logging::V2::ConfigServiceV2::Stub.method(:new)
            )

            @list_sinks = Google::Gax.create_api_call(
              @config_service_v2_stub.method(:list_sinks),
              defaults["list_sinks"]
            )
            @get_sink = Google::Gax.create_api_call(
              @config_service_v2_stub.method(:get_sink),
              defaults["get_sink"]
            )
            @create_sink = Google::Gax.create_api_call(
              @config_service_v2_stub.method(:create_sink),
              defaults["create_sink"]
            )
            @update_sink = Google::Gax.create_api_call(
              @config_service_v2_stub.method(:update_sink),
              defaults["update_sink"]
            )
            @delete_sink = Google::Gax.create_api_call(
              @config_service_v2_stub.method(:delete_sink),
              defaults["delete_sink"]
            )
          end

          # Service calls

          # Lists sinks.
          #
          # @param parent [String]
          #   Required. The resource name where this sink was created:
          #
          #       "projects/[PROJECT_ID]"
          #       "organizations/[ORGANIZATION_ID]"
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Logging::V2::LogSink>]
          #   An enumerable of Google::Logging::V2::LogSink instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/config_service_v2_client"
          #
          #   ConfigServiceV2Client = Google::Cloud::Logging::V2::ConfigServiceV2Client
          #
          #   config_service_v2_client = ConfigServiceV2Client.new
          #   formatted_parent = ConfigServiceV2Client.parent_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   config_service_v2_client.list_sinks(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   config_service_v2_client.list_sinks(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_sinks \
              parent,
              page_size: nil,
              options: nil
            req = Google::Logging::V2::ListSinksRequest.new({
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_sinks.call(req, options)
          end

          # Gets a sink.
          #
          # @param sink_name [String]
          #   Required. The resource name of the sink to return:
          #
          #       "projects/[PROJECT_ID]/sinks/[SINK_ID]"
          #       "organizations/[ORGANIZATION_ID]/sinks/[SINK_ID]"
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogSink]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/config_service_v2_client"
          #
          #   ConfigServiceV2Client = Google::Cloud::Logging::V2::ConfigServiceV2Client
          #
          #   config_service_v2_client = ConfigServiceV2Client.new
          #   formatted_sink_name = ConfigServiceV2Client.sink_path("[PROJECT]", "[SINK]")
          #   response = config_service_v2_client.get_sink(formatted_sink_name)

          def get_sink \
              sink_name,
              options: nil
            req = Google::Logging::V2::GetSinkRequest.new({
              sink_name: sink_name
            }.delete_if { |_, v| v.nil? })
            @get_sink.call(req, options)
          end

          # Creates a sink.
          #
          # @param parent [String]
          #   Required. The resource in which to create the sink:
          #
          #       "projects/[PROJECT_ID]"
          #       "organizations/[ORGANIZATION_ID]"
          # @param sink [Google::Logging::V2::LogSink]
          #   Required. The new sink, whose +name+ parameter is a sink identifier that
          #   is not already in use.
          # @param unique_writer_identity [true, false]
          #   Optional. Whether the sink will have a dedicated service account returned
          #   in the sink's writer_identity. Set this field to be true to export
          #   logs from one project to a different project. This field is ignored for
          #   non-project sinks (e.g. organization sinks) because those sinks are
          #   required to have dedicated service accounts.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogSink]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/config_service_v2_client"
          #
          #   ConfigServiceV2Client = Google::Cloud::Logging::V2::ConfigServiceV2Client
          #   LogSink = Google::Logging::V2::LogSink
          #
          #   config_service_v2_client = ConfigServiceV2Client.new
          #   formatted_parent = ConfigServiceV2Client.parent_path("[PROJECT]")
          #   sink = LogSink.new
          #   response = config_service_v2_client.create_sink(formatted_parent, sink)

          def create_sink \
              parent,
              sink,
              unique_writer_identity: nil,
              options: nil
            req = Google::Logging::V2::CreateSinkRequest.new({
              parent: parent,
              sink: sink,
              unique_writer_identity: unique_writer_identity
            }.delete_if { |_, v| v.nil? })
            @create_sink.call(req, options)
          end

          # Updates or creates a sink.
          #
          # @param sink_name [String]
          #   Required. The resource name of the sink to update, including the parent
          #   resource and the sink identifier:
          #
          #       "projects/[PROJECT_ID]/sinks/[SINK_ID]"
          #       "organizations/[ORGANIZATION_ID]/sinks/[SINK_ID]"
          #
          #   Example: +"projects/my-project-id/sinks/my-sink-id"+.
          # @param sink [Google::Logging::V2::LogSink]
          #   Required. The updated sink, whose name is the same identifier that appears
          #   as part of +sinkName+.  If +sinkName+ does not exist, then
          #   this method creates a new sink.
          # @param unique_writer_identity [true, false]
          #   Optional. Whether the sink will have a dedicated service account returned
          #   in the sink's writer_identity. Set this field to be true to export
          #   logs from one project to a different project. This field is ignored for
          #   non-project sinks (e.g. organization sinks) because those sinks are
          #   required to have dedicated service accounts.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogSink]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/config_service_v2_client"
          #
          #   ConfigServiceV2Client = Google::Cloud::Logging::V2::ConfigServiceV2Client
          #   LogSink = Google::Logging::V2::LogSink
          #
          #   config_service_v2_client = ConfigServiceV2Client.new
          #   formatted_sink_name = ConfigServiceV2Client.sink_path("[PROJECT]", "[SINK]")
          #   sink = LogSink.new
          #   response = config_service_v2_client.update_sink(formatted_sink_name, sink)

          def update_sink \
              sink_name,
              sink,
              unique_writer_identity: nil,
              options: nil
            req = Google::Logging::V2::UpdateSinkRequest.new({
              sink_name: sink_name,
              sink: sink,
              unique_writer_identity: unique_writer_identity
            }.delete_if { |_, v| v.nil? })
            @update_sink.call(req, options)
          end

          # Deletes a sink.
          #
          # @param sink_name [String]
          #   Required. The resource name of the sink to delete, including the parent
          #   resource and the sink identifier:
          #
          #       "projects/[PROJECT_ID]/sinks/[SINK_ID]"
          #       "organizations/[ORGANIZATION_ID]/sinks/[SINK_ID]"
          #
          #   It is an error if the sink does not exist.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/config_service_v2_client"
          #
          #   ConfigServiceV2Client = Google::Cloud::Logging::V2::ConfigServiceV2Client
          #
          #   config_service_v2_client = ConfigServiceV2Client.new
          #   formatted_sink_name = ConfigServiceV2Client.sink_path("[PROJECT]", "[SINK]")
          #   config_service_v2_client.delete_sink(formatted_sink_name)

          def delete_sink \
              sink_name,
              options: nil
            req = Google::Logging::V2::DeleteSinkRequest.new({
              sink_name: sink_name
            }.delete_if { |_, v| v.nil? })
            @delete_sink.call(req, options)
            nil
          end
        end
      end
    end
  end
end
