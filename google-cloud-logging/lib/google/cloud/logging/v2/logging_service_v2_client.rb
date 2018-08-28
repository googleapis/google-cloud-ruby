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
# https://github.com/googleapis/googleapis/blob/master/google/logging/v2/logging.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/logging/v2/logging_pb"
require "google/cloud/logging/v2/credentials"

module Google
  module Cloud
    module Logging
      module V2
        # Service for ingesting and querying logs.
        #
        # @!attribute [r] logging_service_v2_stub
        #   @return [Google::Logging::V2::LoggingServiceV2::Stub]
        class LoggingServiceV2Client
          # @private
          attr_reader :logging_service_v2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "logging.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_log_entries" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "entries"),
            "list_monitored_resource_descriptors" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "resource_descriptors"),
            "list_logs" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "log_names")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          BUNDLE_DESCRIPTORS = {
            "write_log_entries" => Google::Gax::BundleDescriptor.new(
              "entries",
              [
                "logName",
                "resource",
                "labels"
              ])
          }.freeze

          private_constant :BUNDLE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-platform.read-only",
            "https://www.googleapis.com/auth/logging.admin",
            "https://www.googleapis.com/auth/logging.read",
            "https://www.googleapis.com/auth/logging.write"
          ].freeze


          LOG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/logs/{log}"
          )

          private_constant :LOG_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified log resource name string.
          # @param project [String]
          # @param log [String]
          # @return [String]
          def self.log_path project, log
            LOG_PATH_TEMPLATE.render(
              :"project" => project,
              :"log" => log
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
            require "google/logging/v2/logging_services_pb"

            credentials ||= Google::Cloud::Logging::V2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Logging::V2::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-logging'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "logging_service_v2_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.logging.v2.LoggingServiceV2",
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
            @logging_service_v2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Logging::V2::LoggingServiceV2::Stub.method(:new)
            )

            @delete_log = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:delete_log),
              defaults["delete_log"],
              exception_transformer: exception_transformer
            )
            @write_log_entries = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:write_log_entries),
              defaults["write_log_entries"],
              exception_transformer: exception_transformer
            )
            @list_log_entries = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_log_entries),
              defaults["list_log_entries"],
              exception_transformer: exception_transformer
            )
            @list_monitored_resource_descriptors = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_monitored_resource_descriptors),
              defaults["list_monitored_resource_descriptors"],
              exception_transformer: exception_transformer
            )
            @list_logs = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_logs),
              defaults["list_logs"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Deletes all the log entries in a log.
          # The log reappears if it receives new entries.
          # Log entries written shortly before the delete operation might not be
          # deleted.
          #
          # @param log_name [String]
          #   Required. The resource name of the log to delete:
          #
          #       "projects/[PROJECT_ID]/logs/[LOG_ID]"
          #       "organizations/[ORGANIZATION_ID]/logs/[LOG_ID]"
          #       "billingAccounts/[BILLING_ACCOUNT_ID]/logs/[LOG_ID]"
          #       "folders/[FOLDER_ID]/logs/[LOG_ID]"
          #
          #   +[LOG_ID]+ must be URL-encoded. For example,
          #   +"projects/my-project-id/logs/syslog"+,
          #   +"organizations/1234567890/logs/cloudresourcemanager.googleapis.com%2Factivity"+.
          #   For more information about log names, see
          #   {Google::Logging::V2::LogEntry LogEntry}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   logging_service_v2_client = Google::Cloud::Logging::V2::LoggingServiceV2Client.new
          #   formatted_log_name = Google::Cloud::Logging::V2::LoggingServiceV2Client.log_path("[PROJECT]", "[LOG]")
          #   logging_service_v2_client.delete_log(formatted_log_name)

          def delete_log \
              log_name,
              options: nil,
              &block
            req = {
              log_name: log_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::DeleteLogRequest)
            @delete_log.call(req, options, &block)
            nil
          end

          # Writes log entries to Stackdriver Logging. This API method is the
          # only way to send log entries to Stackdriver Logging. This method
          # is used, directly or indirectly, by the Stackdriver Logging agent
          # (fluentd) and all logging libraries configured to use Stackdriver
          # Logging.
          # A single request may contain log entries for a maximum of 1000
          # different resources (projects, organizations, billing accounts or
          # folders)
          #
          # @param entries [Array<Google::Logging::V2::LogEntry | Hash>]
          #   Required. The log entries to send to Stackdriver Logging. The order of log
          #   entries in this list does not matter. Values supplied in this method's
          #   +log_name+, +resource+, and +labels+ fields are copied into those log
          #   entries in this list that do not include values for their corresponding
          #   fields. For more information, see the
          #   {Google::Logging::V2::LogEntry LogEntry} type.
          #
          #   If the +timestamp+ or +insert_id+ fields are missing in log entries, then
          #   this method supplies the current time or a unique identifier, respectively.
          #   The supplied values are chosen so that, among the log entries that did not
          #   supply their own values, the entries earlier in the list will sort before
          #   the entries later in the list. See the +entries.list+ method.
          #
          #   Log entries with timestamps that are more than the
          #   [logs retention period](https://cloud.google.com/logging/quota-policy) in the past or more than
          #   24 hours in the future will not be available when calling +entries.list+.
          #   However, those log entries can still be exported with
          #   [LogSinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs).
          #
          #   To improve throughput and to avoid exceeding the
          #   [quota limit](https://cloud.google.com/logging/quota-policy) for calls to +entries.write+,
          #   you should try to include several log entries in this list,
          #   rather than calling this method for each individual log entry.
          #   A hash of the same form as `Google::Logging::V2::LogEntry`
          #   can also be provided.
          # @param log_name [String]
          #   Optional. A default log resource name that is assigned to all log entries
          #   in +entries+ that do not specify a value for +log_name+:
          #
          #       "projects/[PROJECT_ID]/logs/[LOG_ID]"
          #       "organizations/[ORGANIZATION_ID]/logs/[LOG_ID]"
          #       "billingAccounts/[BILLING_ACCOUNT_ID]/logs/[LOG_ID]"
          #       "folders/[FOLDER_ID]/logs/[LOG_ID]"
          #
          #   +[LOG_ID]+ must be URL-encoded. For example,
          #   +"projects/my-project-id/logs/syslog"+ or
          #   +"organizations/1234567890/logs/cloudresourcemanager.googleapis.com%2Factivity"+.
          #   For more information about log names, see
          #   {Google::Logging::V2::LogEntry LogEntry}.
          # @param resource [Google::Api::MonitoredResource | Hash]
          #   Optional. A default monitored resource object that is assigned to all log
          #   entries in +entries+ that do not specify a value for +resource+. Example:
          #
          #       { "type": "gce_instance",
          #         "labels": {
          #           "zone": "us-central1-a", "instance_id": "00000000000000000000" }}
          #
          #   See {Google::Logging::V2::LogEntry LogEntry}.
          #   A hash of the same form as `Google::Api::MonitoredResource`
          #   can also be provided.
          # @param labels [Hash{String => String}]
          #   Optional. Default labels that are added to the +labels+ field of all log
          #   entries in +entries+. If a log entry already has a label with the same key
          #   as a label in this parameter, then the log entry's label is not changed.
          #   See {Google::Logging::V2::LogEntry LogEntry}.
          # @param partial_success [true, false]
          #   Optional. Whether valid entries should be written even if some other
          #   entries fail due to INVALID_ARGUMENT or PERMISSION_DENIED errors. If any
          #   entry is not written, then the response status is the error associated
          #   with one of the failed entries and the response includes error details
          #   keyed by the entries' zero-based index in the +entries.write+ method.
          # @param dry_run [true, false]
          #   Optional. If true, the request should expect normal response, but the
          #   entries won't be persisted nor exported. Useful for checking whether the
          #   logging API endpoints are working properly before sending valuable data.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Logging::V2::WriteLogEntriesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Logging::V2::WriteLogEntriesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   logging_service_v2_client = Google::Cloud::Logging::V2::LoggingServiceV2Client.new
          #
          #   # TODO: Initialize +entries+:
          #   entries = []
          #   response = logging_service_v2_client.write_log_entries(entries)

          def write_log_entries \
              entries,
              log_name: nil,
              resource: nil,
              labels: nil,
              partial_success: nil,
              dry_run: nil,
              options: nil,
              &block
            req = {
              entries: entries,
              log_name: log_name,
              resource: resource,
              labels: labels,
              partial_success: partial_success,
              dry_run: dry_run
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::WriteLogEntriesRequest)
            @write_log_entries.call(req, options, &block)
          end

          # Lists log entries.  Use this method to retrieve log entries from
          # Stackdriver Logging.  For ways to export log entries, see
          # [Exporting Logs](https://cloud.google.com/logging/docs/export).
          #
          # @param resource_names [Array<String>]
          #   Required. Names of one or more parent resources from which to
          #   retrieve log entries:
          #
          #       "projects/[PROJECT_ID]"
          #       "organizations/[ORGANIZATION_ID]"
          #       "billingAccounts/[BILLING_ACCOUNT_ID]"
          #       "folders/[FOLDER_ID]"
          #
          #   Projects listed in the +project_ids+ field are added to this list.
          # @param project_ids [Array<String>]
          #   Deprecated. Use +resource_names+ instead.  One or more project identifiers
          #   or project numbers from which to retrieve log entries.  Example:
          #   +"my-project-1A"+. If present, these project identifiers are converted to
          #   resource name format and added to the list of resources in
          #   +resource_names+.
          # @param filter [String]
          #   Optional. A filter that chooses which log entries to return.  See [Advanced
          #   Logs Filters](/logging/docs/view/advanced_filters).  Only log entries that
          #   match the filter are returned.  An empty filter matches all log entries in
          #   the resources listed in +resource_names+. Referencing a parent resource
          #   that is not listed in +resource_names+ will cause the filter to return no
          #   results.
          #   The maximum length of the filter is 20000 characters.
          # @param order_by [String]
          #   Optional. How the results should be sorted.  Presently, the only permitted
          #   values are +"timestamp asc"+ (default) and +"timestamp desc"+. The first
          #   option returns entries in order of increasing values of
          #   +LogEntry.timestamp+ (oldest first), and the second option returns entries
          #   in order of decreasing timestamps (newest first).  Entries with equal
          #   timestamps are returned in order of their +insert_id+ values.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Logging::V2::LogEntry>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Logging::V2::LogEntry>]
          #   An enumerable of Google::Logging::V2::LogEntry instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   logging_service_v2_client = Google::Cloud::Logging::V2::LoggingServiceV2Client.new
          #
          #   # TODO: Initialize +formatted_resource_names+:
          #   formatted_resource_names = []
          #
          #   # Iterate over all results.
          #   logging_service_v2_client.list_log_entries(formatted_resource_names).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_client.list_log_entries(formatted_resource_names).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_log_entries \
              resource_names,
              project_ids: nil,
              filter: nil,
              order_by: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              resource_names: resource_names,
              project_ids: project_ids,
              filter: filter,
              order_by: order_by,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::ListLogEntriesRequest)
            @list_log_entries.call(req, options, &block)
          end

          # Lists the descriptors for monitored resource types used by Stackdriver
          # Logging.
          #
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Api::MonitoredResourceDescriptor>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Api::MonitoredResourceDescriptor>]
          #   An enumerable of Google::Api::MonitoredResourceDescriptor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   logging_service_v2_client = Google::Cloud::Logging::V2::LoggingServiceV2Client.new
          #
          #   # Iterate over all results.
          #   logging_service_v2_client.list_monitored_resource_descriptors.each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_client.list_monitored_resource_descriptors.each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_monitored_resource_descriptors \
              page_size: nil,
              options: nil,
              &block
            req = {
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::ListMonitoredResourceDescriptorsRequest)
            @list_monitored_resource_descriptors.call(req, options, &block)
          end

          # Lists the logs in projects, organizations, folders, or billing accounts.
          # Only logs that have entries are listed.
          #
          # @param parent [String]
          #   Required. The resource name that owns the logs:
          #
          #       "projects/[PROJECT_ID]"
          #       "organizations/[ORGANIZATION_ID]"
          #       "billingAccounts/[BILLING_ACCOUNT_ID]"
          #       "folders/[FOLDER_ID]"
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
          #   require "google/cloud/logging/v2"
          #
          #   logging_service_v2_client = Google::Cloud::Logging::V2::LoggingServiceV2Client.new
          #   formatted_parent = Google::Cloud::Logging::V2::LoggingServiceV2Client.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   logging_service_v2_client.list_logs(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_client.list_logs(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_logs \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::ListLogsRequest)
            @list_logs.call(req, options, &block)
          end
        end
      end
    end
  end
end
