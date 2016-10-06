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
# https://github.com/googleapis/googleapis/blob/master/google/devtools/clouderrorreporting/v1beta1/error_group_service.proto,
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
    module ErrorReporting
      module V1beta1
        # Service for retrieving and updating individual error groups.
        #
        # @!attribute [r] error_group_service_stub
        #   @return [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroupService::Stub]
        class ErrorGroupServiceApi
          attr_reader :error_group_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "clouderrorreporting.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          GROUP_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/groups/{group}"
          )

          private_constant :GROUP_PATH_TEMPLATE

          # Returns a fully-qualified group resource name string.
          # @param project [String]
          # @param group [String]
          # @return [String]
          def self.group_path project, group
            GROUP_PATH_TEMPLATE.render(
              :"project" => project,
              :"group" => group
            )
          end

          # Parses the project from a group resource.
          # @param group_name [String]
          # @return [String]
          def self.match_project_from_group_name group_name
            GROUP_PATH_TEMPLATE.match(group_name)["project"]
          end

          # Parses the group from a group resource.
          # @param group_name [String]
          # @return [String]
          def self.match_group_from_group_name group_name
            GROUP_PATH_TEMPLATE.match(group_name)["group"]
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
            require "google/devtools/clouderrorreporting/v1beta1/error_group_service_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
              "ruby/#{RUBY_VERSION}".freeze
            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "error_group_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.clouderrorreporting.v1beta1.ErrorGroupService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @error_group_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroupService::Stub.method(:new)
            )

            @get_group = Google::Gax.create_api_call(
              @error_group_service_stub.method(:get_group),
              defaults["get_group"]
            )
            @update_group = Google::Gax.create_api_call(
              @error_group_service_stub.method(:update_group),
              defaults["update_group"]
            )
          end

          # Service calls

          # Get the specified group.
          #
          # @param group_name [String]
          #   [Required] The group resource name. Written as
          #   <code>projects/<var>projectID</var>/groups/<var>group_name</var></code>.
          #   Call
          #   <a href="/error-reporting/reference/rest/v1beta1/projects.groupStats/list">
          #   <code>groupStats.list</code></a> to return a list of groups belonging to
          #   this project.
          #
          #   Example: <code>projects/my-project-123/groups/my-group</code>
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroup]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1/error_group_service_api"
          #
          #   ErrorGroupServiceApi = Google::Cloud::ErrorReporting::V1beta1::ErrorGroupServiceApi
          #
          #   error_group_service_api = ErrorGroupServiceApi.new
          #   formatted_group_name = ErrorGroupServiceApi.group_path("[PROJECT]", "[GROUP]")
          #   response = error_group_service_api.get_group(formatted_group_name)

          def get_group \
              group_name,
              options: nil
            req = Google::Devtools::Clouderrorreporting::V1beta1::GetGroupRequest.new(
              group_name: group_name
            )
            @get_group.call(req, options)
          end

          # Replace the data for the specified group.
          # Fails if the group does not exist.
          #
          # @param group [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroup]
          #   [Required] The group which replaces the resource on the server.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroup]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1/error_group_service_api"
          #
          #   ErrorGroup = Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroup
          #   ErrorGroupServiceApi = Google::Cloud::ErrorReporting::V1beta1::ErrorGroupServiceApi
          #
          #   error_group_service_api = ErrorGroupServiceApi.new
          #   group = ErrorGroup.new
          #   response = error_group_service_api.update_group(group)

          def update_group \
              group,
              options: nil
            req = Google::Devtools::Clouderrorreporting::V1beta1::UpdateGroupRequest.new(
              group: group
            )
            @update_group.call(req, options)
          end
        end
      end
    end
  end
end
