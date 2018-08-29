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
# https://github.com/googleapis/googleapis/blob/master/google/monitoring/v3/notification_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/monitoring/v3/notification_service_pb"
require "google/cloud/monitoring/v3/credentials"

module Google
  module Cloud
    module Monitoring
      module V3
        # The Notification Channel API provides access to configuration that
        # controls how messages related to incidents are sent.
        #
        # @!attribute [r] notification_channel_service_stub
        #   @return [Google::Monitoring::V3::NotificationChannelService::Stub]
        class NotificationChannelServiceClient
          # @private
          attr_reader :notification_channel_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "monitoring.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_notification_channel_descriptors" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "channel_descriptors"),
            "list_notification_channels" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "notification_channels")
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

          NOTIFICATION_CHANNEL_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/notificationChannels/{notification_channel}"
          )

          private_constant :NOTIFICATION_CHANNEL_PATH_TEMPLATE

          NOTIFICATION_CHANNEL_DESCRIPTOR_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/notificationChannelDescriptors/{channel_descriptor}"
          )

          private_constant :NOTIFICATION_CHANNEL_DESCRIPTOR_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified notification_channel resource name string.
          # @param project [String]
          # @param notification_channel [String]
          # @return [String]
          def self.notification_channel_path project, notification_channel
            NOTIFICATION_CHANNEL_PATH_TEMPLATE.render(
              :"project" => project,
              :"notification_channel" => notification_channel
            )
          end

          # Returns a fully-qualified notification_channel_descriptor resource name string.
          # @param project [String]
          # @param channel_descriptor [String]
          # @return [String]
          def self.notification_channel_descriptor_path project, channel_descriptor
            NOTIFICATION_CHANNEL_DESCRIPTOR_PATH_TEMPLATE.render(
              :"project" => project,
              :"channel_descriptor" => channel_descriptor
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
            require "google/monitoring/v3/notification_service_services_pb"

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
              "notification_channel_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.monitoring.v3.NotificationChannelService",
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
            @notification_channel_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Monitoring::V3::NotificationChannelService::Stub.method(:new)
            )

            @list_notification_channel_descriptors = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:list_notification_channel_descriptors),
              defaults["list_notification_channel_descriptors"],
              exception_transformer: exception_transformer
            )
            @get_notification_channel_descriptor = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:get_notification_channel_descriptor),
              defaults["get_notification_channel_descriptor"],
              exception_transformer: exception_transformer
            )
            @list_notification_channels = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:list_notification_channels),
              defaults["list_notification_channels"],
              exception_transformer: exception_transformer
            )
            @get_notification_channel = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:get_notification_channel),
              defaults["get_notification_channel"],
              exception_transformer: exception_transformer
            )
            @create_notification_channel = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:create_notification_channel),
              defaults["create_notification_channel"],
              exception_transformer: exception_transformer
            )
            @update_notification_channel = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:update_notification_channel),
              defaults["update_notification_channel"],
              exception_transformer: exception_transformer
            )
            @delete_notification_channel = Google::Gax.create_api_call(
              @notification_channel_service_stub.method(:delete_notification_channel),
              defaults["delete_notification_channel"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists the descriptors for supported channel types. The use of descriptors
          # makes it possible for new channel types to be dynamically added.
          #
          # @param name [String]
          #   The REST resource name of the parent from which to retrieve
          #   the notification channel descriptors. The expected syntax is:
          #
          #       projects/[PROJECT_ID]
          #
          #   Note that this names the parent container in which to look for the
          #   descriptors; to retrieve a single descriptor by name, use the
          #   {Google::Monitoring::V3::NotificationChannelService::GetNotificationChannelDescriptor GetNotificationChannelDescriptor}
          #   operation, instead.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::NotificationChannelDescriptor>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::NotificationChannelDescriptor>]
          #   An enumerable of Google::Monitoring::V3::NotificationChannelDescriptor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   notification_channel_service_client.list_notification_channel_descriptors(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   notification_channel_service_client.list_notification_channel_descriptors(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_notification_channel_descriptors \
              name,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListNotificationChannelDescriptorsRequest)
            @list_notification_channel_descriptors.call(req, options, &block)
          end

          # Gets a single channel descriptor. The descriptor indicates which fields
          # are expected / permitted for a notification channel of the given type.
          #
          # @param name [String]
          #   The channel type for which to execute the request. The format is
          #   +projects/[PROJECT_ID]/notificationChannelDescriptors/\\{channel_type}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::NotificationChannelDescriptor]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::NotificationChannelDescriptor]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_descriptor_path("[PROJECT]", "[CHANNEL_DESCRIPTOR]")
          #   response = notification_channel_service_client.get_notification_channel_descriptor(formatted_name)

          def get_notification_channel_descriptor \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetNotificationChannelDescriptorRequest)
            @get_notification_channel_descriptor.call(req, options, &block)
          end

          # Lists the notification channels that have been created for the project.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   +projects/[PROJECT_ID]+. That is, this names the container
          #   in which to look for the notification channels; it does not name a
          #   specific channel. To query a specific channel by REST resource name, use
          #   the
          #   {Google::Monitoring::V3::NotificationChannelService::GetNotificationChannel +GetNotificationChannel+} operation.
          # @param filter [String]
          #   If provided, this field specifies the criteria that must be met by
          #   notification channels to be included in the response.
          #
          #   For more details, see [sorting and
          #   filtering](/monitoring/api/v3/sorting-and-filtering).
          # @param order_by [String]
          #   A comma-separated list of fields by which to sort the result. Supports
          #   the same set of fields as in +filter+. Entries can be prefixed with
          #   a minus sign to sort in descending rather than ascending order.
          #
          #   For more details, see [sorting and
          #   filtering](/monitoring/api/v3/sorting-and-filtering).
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::NotificationChannel>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::NotificationChannel>]
          #   An enumerable of Google::Monitoring::V3::NotificationChannel instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   notification_channel_service_client.list_notification_channels(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   notification_channel_service_client.list_notification_channels(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_notification_channels \
              name,
              filter: nil,
              order_by: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              filter: filter,
              order_by: order_by,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListNotificationChannelsRequest)
            @list_notification_channels.call(req, options, &block)
          end

          # Gets a single notification channel. The channel includes the relevant
          # configuration details with which the channel was created. However, the
          # response may truncate or omit passwords, API keys, or other private key
          # matter and thus the response may not be 100% identical to the information
          # that was supplied in the call to the create method.
          #
          # @param name [String]
          #   The channel for which to execute the request. The format is
          #   +projects/[PROJECT_ID]/notificationChannels/[CHANNEL_ID]+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::NotificationChannel]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::NotificationChannel]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")
          #   response = notification_channel_service_client.get_notification_channel(formatted_name)

          def get_notification_channel \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetNotificationChannelRequest)
            @get_notification_channel.call(req, options, &block)
          end

          # Creates a new notification channel, representing a single notification
          # endpoint such as an email address, SMS number, or pagerduty service.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is:
          #
          #       projects/[PROJECT_ID]
          #
          #   Note that this names the container into which the channel will be
          #   written. This does not name the newly created channel. The resulting
          #   channel's name will have a normalized version of this field as a prefix,
          #   but will add +/notificationChannels/[CHANNEL_ID]+ to identify the channel.
          # @param notification_channel [Google::Monitoring::V3::NotificationChannel | Hash]
          #   The definition of the +NotificationChannel+ to create.
          #   A hash of the same form as `Google::Monitoring::V3::NotificationChannel`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::NotificationChannel]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::NotificationChannel]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +notification_channel+:
          #   notification_channel = {}
          #   response = notification_channel_service_client.create_notification_channel(formatted_name, notification_channel)

          def create_notification_channel \
              name,
              notification_channel,
              options: nil,
              &block
            req = {
              name: name,
              notification_channel: notification_channel
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateNotificationChannelRequest)
            @create_notification_channel.call(req, options, &block)
          end

          # Updates a notification channel. Fields not specified in the field mask
          # remain unchanged.
          #
          # @param notification_channel [Google::Monitoring::V3::NotificationChannel | Hash]
          #   A description of the changes to be applied to the specified
          #   notification channel. The description must provide a definition for
          #   fields to be updated; the names of these fields should also be
          #   included in the +update_mask+.
          #   A hash of the same form as `Google::Monitoring::V3::NotificationChannel`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The fields to update.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::NotificationChannel]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::NotificationChannel]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #
          #   # TODO: Initialize +notification_channel+:
          #   notification_channel = {}
          #   response = notification_channel_service_client.update_notification_channel(notification_channel)

          def update_notification_channel \
              notification_channel,
              update_mask: nil,
              options: nil,
              &block
            req = {
              notification_channel: notification_channel,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::UpdateNotificationChannelRequest)
            @update_notification_channel.call(req, options, &block)
          end

          # Deletes a notification channel.
          #
          # @param name [String]
          #   The channel for which to execute the request. The format is
          #   +projects/[PROJECT_ID]/notificationChannels/[CHANNEL_ID]+.
          # @param force [true, false]
          #   If true, the notification channel will be deleted regardless of its
          #   use in alert policies (the policies will be updated to remove the
          #   channel). If false, channels that are still referenced by an existing
          #   alerting policy will fail to be deleted in a delete operation.
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
          #   notification_channel_service_client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")
          #   notification_channel_service_client.delete_notification_channel(formatted_name)

          def delete_notification_channel \
              name,
              force: nil,
              options: nil,
              &block
            req = {
              name: name,
              force: force
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteNotificationChannelRequest)
            @delete_notification_channel.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
