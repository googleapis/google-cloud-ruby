# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/devtools/clouderrorreporting/v1beta1/error_stats_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/devtools/clouderrorreporting/v1beta1/error_stats_service_pb"
require "google/cloud/error_reporting/credentials"

module Google
  module Cloud
    module ErrorReporting
      module V1beta1
        # An API for retrieving and managing error statistics as well as data for
        # individual events.
        #
        # @!attribute [r] error_stats_service_stub
        #   @return [Google::Devtools::Clouderrorreporting::V1beta1::ErrorStatsService::Stub]
        class ErrorStatsServiceClient
          attr_reader :error_stats_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "clouderrorreporting.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_group_stats" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "error_group_stats"),
            "list_events" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "error_events")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

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
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/devtools/clouderrorreporting/v1beta1/error_stats_service_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
              warn "`service_path` and `port` parameters are deprecated and will be removed"
            end

            credentials ||= Google::Cloud::ErrorReporting::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::ErrorReporting::Credentials.new(credentials).updater_proc
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

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "error_stats_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.clouderrorreporting.v1beta1.ErrorStatsService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @error_stats_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Devtools::Clouderrorreporting::V1beta1::ErrorStatsService::Stub.method(:new)
            )

            @list_group_stats = Google::Gax.create_api_call(
              @error_stats_service_stub.method(:list_group_stats),
              defaults["list_group_stats"]
            )
            @list_events = Google::Gax.create_api_call(
              @error_stats_service_stub.method(:list_events),
              defaults["list_events"]
            )
            @delete_events = Google::Gax.create_api_call(
              @error_stats_service_stub.method(:delete_events),
              defaults["delete_events"]
            )
          end

          # Service calls

          # Lists the specified groups.
          #
          # @param project_name [String]
          #   [Required] The resource name of the Google Cloud Platform project. Written
          #   as <code>projects/</code> plus the
          #   <a href="https://support.google.com/cloud/answer/6158840">Google Cloud
          #   Platform project ID</a>.
          #
          #   Example: <code>projects/my-project-123</code>.
          # @param time_range [Google::Devtools::Clouderrorreporting::V1beta1::QueryTimeRange | Hash]
          #   [Optional] List data for the given time range.
          #   If not set a default time range is used. The field time_range_begin
          #   in the response will specify the beginning of this time range.
          #   Only <code>ErrorGroupStats</code> with a non-zero count in the given time
          #   range are returned, unless the request contains an explicit group_id list.
          #   If a group_id list is given, also <code>ErrorGroupStats</code> with zero
          #   occurrences are returned.
          #   A hash of the same form as `Google::Devtools::Clouderrorreporting::V1beta1::QueryTimeRange`
          #   can also be provided.
          # @param group_id [Array<String>]
          #   [Optional] List all <code>ErrorGroupStats</code> with these IDs.
          # @param service_filter [Google::Devtools::Clouderrorreporting::V1beta1::ServiceContextFilter | Hash]
          #   [Optional] List only <code>ErrorGroupStats</code> which belong to a service
          #   context that matches the filter.
          #   Data for all service contexts is returned if this field is not specified.
          #   A hash of the same form as `Google::Devtools::Clouderrorreporting::V1beta1::ServiceContextFilter`
          #   can also be provided.
          # @param timed_count_duration [Google::Protobuf::Duration | Hash]
          #   [Optional] The preferred duration for a single returned +TimedCount+.
          #   If not set, no timed counts are returned.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param alignment [Google::Devtools::Clouderrorreporting::V1beta1::TimedCountAlignment]
          #   [Optional] The alignment of the timed counts to be returned.
          #   Default is +ALIGNMENT_EQUAL_AT_END+.
          # @param alignment_time [Google::Protobuf::Timestamp | Hash]
          #   [Optional] Time where the timed counts shall be aligned if rounded
          #   alignment is chosen. Default is 00:00 UTC.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param order [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroupOrder]
          #   [Optional] The sort order in which the results are returned.
          #   Default is +COUNT_DESC+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroupStats>]
          #   An enumerable of Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroupStats instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1"
          #
          #   error_stats_service_client = Google::Cloud::ErrorReporting::V1beta1::ErrorStats.new
          #   formatted_project_name = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient.project_path("[PROJECT]")
          #   time_range = {}
          #
          #   # Iterate over all results.
          #   error_stats_service_client.list_group_stats(formatted_project_name, time_range).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   error_stats_service_client.list_group_stats(formatted_project_name, time_range).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_group_stats \
              project_name,
              time_range,
              group_id: nil,
              service_filter: nil,
              timed_count_duration: nil,
              alignment: nil,
              alignment_time: nil,
              order: nil,
              page_size: nil,
              options: nil
            req = {
              project_name: project_name,
              time_range: time_range,
              group_id: group_id,
              service_filter: service_filter,
              timed_count_duration: timed_count_duration,
              alignment: alignment,
              alignment_time: alignment_time,
              order: order,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouderrorreporting::V1beta1::ListGroupStatsRequest)
            @list_group_stats.call(req, options)
          end

          # Lists the specified events.
          #
          # @param project_name [String]
          #   [Required] The resource name of the Google Cloud Platform project. Written
          #   as +projects/+ plus the
          #   [Google Cloud Platform project
          #   ID](https://support.google.com/cloud/answer/6158840).
          #   Example: +projects/my-project-123+.
          # @param group_id [String]
          #   [Required] The group for which events shall be returned.
          # @param service_filter [Google::Devtools::Clouderrorreporting::V1beta1::ServiceContextFilter | Hash]
          #   [Optional] List only ErrorGroups which belong to a service context that
          #   matches the filter.
          #   Data for all service contexts is returned if this field is not specified.
          #   A hash of the same form as `Google::Devtools::Clouderrorreporting::V1beta1::ServiceContextFilter`
          #   can also be provided.
          # @param time_range [Google::Devtools::Clouderrorreporting::V1beta1::QueryTimeRange | Hash]
          #   [Optional] List only data for the given time range.
          #   If not set a default time range is used. The field time_range_begin
          #   in the response will specify the beginning of this time range.
          #   A hash of the same form as `Google::Devtools::Clouderrorreporting::V1beta1::QueryTimeRange`
          #   can also be provided.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Devtools::Clouderrorreporting::V1beta1::ErrorEvent>]
          #   An enumerable of Google::Devtools::Clouderrorreporting::V1beta1::ErrorEvent instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1"
          #
          #   error_stats_service_client = Google::Cloud::ErrorReporting::V1beta1::ErrorStats.new
          #   formatted_project_name = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient.project_path("[PROJECT]")
          #   group_id = ''
          #
          #   # Iterate over all results.
          #   error_stats_service_client.list_events(formatted_project_name, group_id).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   error_stats_service_client.list_events(formatted_project_name, group_id).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_events \
              project_name,
              group_id,
              service_filter: nil,
              time_range: nil,
              page_size: nil,
              options: nil
            req = {
              project_name: project_name,
              group_id: group_id,
              service_filter: service_filter,
              time_range: time_range,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouderrorreporting::V1beta1::ListEventsRequest)
            @list_events.call(req, options)
          end

          # Deletes all error events of a given project.
          #
          # @param project_name [String]
          #   [Required] The resource name of the Google Cloud Platform project. Written
          #   as +projects/+ plus the
          #   [Google Cloud Platform project
          #   ID](https://support.google.com/cloud/answer/6158840).
          #   Example: +projects/my-project-123+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouderrorreporting::V1beta1::DeleteEventsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1"
          #
          #   error_stats_service_client = Google::Cloud::ErrorReporting::V1beta1::ErrorStats.new
          #   formatted_project_name = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient.project_path("[PROJECT]")
          #   response = error_stats_service_client.delete_events(formatted_project_name)

          def delete_events \
              project_name,
              options: nil
            req = {
              project_name: project_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouderrorreporting::V1beta1::DeleteEventsRequest)
            @delete_events.call(req, options)
          end
        end
      end
    end
  end
end
