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
# https://github.com/googleapis/googleapis/blob/master/google/monitoring/v3/group_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/monitoring/v3/group_service_pb"
require "google/cloud/monitoring/v3/credentials"

module Google
  module Cloud
    module Monitoring
      module V3
        # The Group API lets you inspect and manage your
        # [groups](https://cloud.google.com#google.monitoring.v3.Group).
        #
        # A group is a named filter that is used to identify
        # a collection of monitored resources. Groups are typically used to
        # mirror the physical and/or logical topology of the environment.
        # Because group membership is computed dynamically, monitored
        # resources that are started in the future are automatically placed
        # in matching groups. By using a group to name monitored resources in,
        # for example, an alert policy, the target of that alert policy is
        # updated automatically as monitored resources are added and removed
        # from the infrastructure.
        #
        # @!attribute [r] group_service_stub
        #   @return [Google::Monitoring::V3::GroupService::Stub]
        class GroupServiceClient
          # @private
          attr_reader :group_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "monitoring.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_groups" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "group"),
            "list_group_members" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "members")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/monitoring.read",
            "https://www.googleapis.com/auth/monitoring.write"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          GROUP_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/groups/{group}"
          )

          private_constant :GROUP_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

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
            require "google/monitoring/v3/group_service_services_pb"

            credentials ||= Google::Cloud::Monitoring::V3::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Monitoring::V3::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-monitoring'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "group_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.monitoring.v3.GroupService",
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
            @group_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Monitoring::V3::GroupService::Stub.method(:new)
            )

            @list_groups = Google::Gax.create_api_call(
              @group_service_stub.method(:list_groups),
              defaults["list_groups"],
              exception_transformer: exception_transformer
            )
            @get_group = Google::Gax.create_api_call(
              @group_service_stub.method(:get_group),
              defaults["get_group"],
              exception_transformer: exception_transformer
            )
            @create_group = Google::Gax.create_api_call(
              @group_service_stub.method(:create_group),
              defaults["create_group"],
              exception_transformer: exception_transformer
            )
            @update_group = Google::Gax.create_api_call(
              @group_service_stub.method(:update_group),
              defaults["update_group"],
              exception_transformer: exception_transformer
            )
            @delete_group = Google::Gax.create_api_call(
              @group_service_stub.method(:delete_group),
              defaults["delete_group"],
              exception_transformer: exception_transformer
            )
            @list_group_members = Google::Gax.create_api_call(
              @group_service_stub.method(:list_group_members),
              defaults["list_group_members"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists the existing groups.
          #
          # @param name [String]
          #   The project whose groups are to be listed. The format is
          #   +"projects/\\{project_id_or_number}"+.
          # @param children_of_group [String]
          #   A group name: +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          #   Returns groups whose +parentName+ field contains the group
          #   name.  If no groups have this parent, the results are empty.
          # @param ancestors_of_group [String]
          #   A group name: +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          #   Returns groups that are ancestors of the specified group.
          #   The groups are returned in order, starting with the immediate parent and
          #   ending with the most distant ancestor.  If the specified group has no
          #   immediate parent, the results are empty.
          # @param descendants_of_group [String]
          #   A group name: +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          #   Returns the descendants of the specified group.  This is a superset of
          #   the results returned by the +childrenOfGroup+ filter, and includes
          #   children-of-children, and so forth.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::Group>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::Group>]
          #   An enumerable of Google::Monitoring::V3::Group instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   group_service_client.list_groups(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   group_service_client.list_groups(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_groups \
              name,
              children_of_group: nil,
              ancestors_of_group: nil,
              descendants_of_group: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              children_of_group: children_of_group,
              ancestors_of_group: ancestors_of_group,
              descendants_of_group: descendants_of_group,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListGroupsRequest)
            @list_groups.call(req, options, &block)
          end

          # Gets a single group.
          #
          # @param name [String]
          #   The group to retrieve. The format is
          #   +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Group]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Group]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")
          #   response = group_service_client.get_group(formatted_name)

          def get_group \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetGroupRequest)
            @get_group.call(req, options, &block)
          end

          # Creates a new group.
          #
          # @param name [String]
          #   The project in which to create the group. The format is
          #   +"projects/\\{project_id_or_number}"+.
          # @param group [Google::Monitoring::V3::Group | Hash]
          #   A group definition. It is an error to define the +name+ field because
          #   the system assigns the name.
          #   A hash of the same form as `Google::Monitoring::V3::Group`
          #   can also be provided.
          # @param validate_only [true, false]
          #   If true, validate this request but do not create the group.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Group]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Group]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +group+:
          #   group = {}
          #   response = group_service_client.create_group(formatted_name, group)

          def create_group \
              name,
              group,
              validate_only: nil,
              options: nil,
              &block
            req = {
              name: name,
              group: group,
              validate_only: validate_only
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateGroupRequest)
            @create_group.call(req, options, &block)
          end

          # Updates an existing group.
          # You can change any group attributes except +name+.
          #
          # @param group [Google::Monitoring::V3::Group | Hash]
          #   The new definition of the group.  All fields of the existing group,
          #   excepting +name+, are replaced with the corresponding fields of this group.
          #   A hash of the same form as `Google::Monitoring::V3::Group`
          #   can also be provided.
          # @param validate_only [true, false]
          #   If true, validate this request but do not update the existing group.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Group]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Group]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #
          #   # TODO: Initialize +group+:
          #   group = {}
          #   response = group_service_client.update_group(group)

          def update_group \
              group,
              validate_only: nil,
              options: nil,
              &block
            req = {
              group: group,
              validate_only: validate_only
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::UpdateGroupRequest)
            @update_group.call(req, options, &block)
          end

          # Deletes an existing group.
          #
          # @param name [String]
          #   The group to delete. The format is
          #   +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")
          #   group_service_client.delete_group(formatted_name)

          def delete_group \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteGroupRequest)
            @delete_group.call(req, options, &block)
            nil
          end

          # Lists the monitored resources that are members of a group.
          #
          # @param name [String]
          #   The group whose members are listed. The format is
          #   +"projects/\\{project_id_or_number}/groups/\\{group_id}"+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param filter [String]
          #   An optional [list filter](https://cloud.google.com/monitoring/api/learn_more#filtering) describing
          #   the members to be returned.  The filter may reference the type, labels, and
          #   metadata of monitored resources that comprise the group.
          #   For example, to return only resources representing Compute Engine VM
          #   instances, use this filter:
          #
          #       resource.type = "gce_instance"
          # @param interval [Google::Monitoring::V3::TimeInterval | Hash]
          #   An optional time interval for which results should be returned. Only
          #   members that were part of the group during the specified interval are
          #   included in the response.  If no interval is provided then the group
          #   membership over the last minute is returned.
          #   A hash of the same form as `Google::Monitoring::V3::TimeInterval`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Api::MonitoredResource>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Api::MonitoredResource>]
          #   An enumerable of Google::Api::MonitoredResource instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   group_service_client = Google::Cloud::Monitoring::Group.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::GroupServiceClient.group_path("[PROJECT]", "[GROUP]")
          #
          #   # Iterate over all results.
          #   group_service_client.list_group_members(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   group_service_client.list_group_members(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_group_members \
              name,
              page_size: nil,
              filter: nil,
              interval: nil,
              options: nil,
              &block
            req = {
              name: name,
              page_size: page_size,
              filter: filter,
              interval: interval
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListGroupMembersRequest)
            @list_group_members.call(req, options, &block)
          end
        end
      end
    end
  end
end
