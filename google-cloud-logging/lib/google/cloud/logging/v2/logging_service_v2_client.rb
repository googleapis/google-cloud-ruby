# Copyright 2017, Google Inc. All rights reserved.
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
# https://github.com/googleapis/googleapis/blob/master/google/logging/v2/logging.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/logging/v2/logging_pb"

module Google
  module Cloud
    module Logging
      module V2
        # Service for ingesting and querying logs.
        #
        # @!attribute [r] logging_service_v2_stub
        #   @return [Google::Logging::V2::LoggingServiceV2::Stub]
        class LoggingServiceV2Client
          attr_reader :logging_service_v2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "logging.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

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
                "labels",
                "partialSuccess"
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

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          LOG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/logs/{log}"
          )

          private_constant :LOG_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

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

          # Parses the project from a project resource.
          # @param project_name [String]
          # @return [String]
          def self.match_project_from_project_name project_name
            PROJECT_PATH_TEMPLATE.match(project_name)["project"]
          end

          # Parses the project from a log resource.
          # @param log_name [String]
          # @return [String]
          def self.match_project_from_log_name log_name
            LOG_PATH_TEMPLATE.match(log_name)["project"]
          end

          # Parses the log from a log resource.
          # @param log_name [String]
          # @return [String]
          def self.match_log_from_log_name log_name
            LOG_PATH_TEMPLATE.match(log_name)["log"]
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
            require "google/logging/v2/logging_services_pb"


            if app_name || app_version
              warn "`app_name` and `app_version` are no longer being used in the request headers."
            end

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.6.8 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
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
                kwargs: headers
              )
            end
            @logging_service_v2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Logging::V2::LoggingServiceV2::Stub.method(:new)
            )

            @delete_log = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:delete_log),
              defaults["delete_log"]
            )
            @write_log_entries = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:write_log_entries),
              defaults["write_log_entries"]
            )
            @list_log_entries = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_log_entries),
              defaults["list_log_entries"]
            )
            @list_monitored_resource_descriptors = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_monitored_resource_descriptors),
              defaults["list_monitored_resource_descriptors"]
            )
            @list_logs = Google::Gax.create_api_call(
              @logging_service_v2_stub.method(:list_logs),
              defaults["list_logs"]
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
          #   LogEntry.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_client"
          #
          #   LoggingServiceV2Client = Google::Cloud::Logging::V2::LoggingServiceV2Client
          #
          #   logging_service_v2_client = LoggingServiceV2Client.new
          #   formatted_log_name = LoggingServiceV2Client.log_path("[PROJECT]", "[LOG]")
          #   logging_service_v2_client.delete_log(formatted_log_name)

          def delete_log \
              log_name,
              options: nil
            req = Google::Logging::V2::DeleteLogRequest.new({
              log_name: log_name
            }.delete_if { |_, v| v.nil? })
            @delete_log.call(req, options)
            nil
          end

          # Writes log entries to Stackdriver Logging.
          #
          # @param entries [Array<Google::Logging::V2::LogEntry>]
          #   Required.  The log entries to write. Values supplied for the fields
          #   +log_name+, +resource+, and +labels+ in this +entries.write+ request are
          #   inserted into those log entries in this list that do not provide their own
          #   values.
          #
          #   Stackdriver Logging also creates and inserts values for +timestamp+ and
          #   +insert_id+ if the entries do not provide them. The created +insert_id+ for
          #   the N'th entry in this list will be greater than earlier entries and less
          #   than later entries.  Otherwise, the order of log entries in this list does
          #   not matter.
          #
          #   To improve throughput and to avoid exceeding the
          #   {quota limit}[https://cloud.google.com/logging/quota-policy] for calls to +entries.write+,
          #   you should write multiple log entries at once rather than
          #   calling this method for each individual log entry.
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
          #   LogEntry.
          # @param resource [Google::Api::MonitoredResource]
          #   Optional. A default monitored resource object that is assigned to all log
          #   entries in +entries+ that do not specify a value for +resource+. Example:
          #
          #       { "type": "gce_instance",
          #         "labels": {
          #           "zone": "us-central1-a", "instance_id": "00000000000000000000" }}
          #
          #   See LogEntry.
          # @param labels [Hash{String => String}]
          #   Optional. Default labels that are added to the +labels+ field of all log
          #   entries in +entries+. If a log entry already has a label with the same key
          #   as a label in this parameter, then the log entry's label is not changed.
          #   See LogEntry.
          # @param partial_success [true, false]
          #   Optional. Whether valid entries should be written even if some other
          #   entries fail due to INVALID_ARGUMENT or PERMISSION_DENIED errors. If any
          #   entry is not written, then the response status is the error associated
          #   with one of the failed entries and the response includes error details
          #   keyed by the entries' zero-based index in the +entries.write+ method.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::WriteLogEntriesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_client"
          #
          #   LoggingServiceV2Client = Google::Cloud::Logging::V2::LoggingServiceV2Client
          #
          #   logging_service_v2_client = LoggingServiceV2Client.new
          #   entries = []
          #   response = logging_service_v2_client.write_log_entries(entries)

          def write_log_entries \
              entries,
              log_name: nil,
              resource: nil,
              labels: nil,
              partial_success: nil,
              options: nil
            req = Google::Logging::V2::WriteLogEntriesRequest.new({
              entries: entries,
              log_name: log_name,
              resource: resource,
              labels: labels,
              partial_success: partial_success
            }.delete_if { |_, v| v.nil? })
            @write_log_entries.call(req, options)
          end

          # Lists log entries.  Use this method to retrieve log entries from
          # Stackdriver Logging.  For ways to export log entries, see
          # {Exporting Logs}[https://cloud.google.com/logging/docs/export].
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
          #   Optional. A filter that chooses which log entries to return.  See {Advanced
          #   Logs Filters}[https://cloud.google.com/logging/docs/view/advanced_filters].  Only log entries that
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
          # @return [Google::Gax::PagedEnumerable<Google::Logging::V2::LogEntry>]
          #   An enumerable of Google::Logging::V2::LogEntry instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_client"
          #
          #   LoggingServiceV2Client = Google::Cloud::Logging::V2::LoggingServiceV2Client
          #
          #   logging_service_v2_client = LoggingServiceV2Client.new
          #   resource_names = []
          #
          #   # Iterate over all results.
          #   logging_service_v2_client.list_log_entries(resource_names).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_client.list_log_entries(resource_names).each_page do |page|
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
              options: nil
            req = Google::Logging::V2::ListLogEntriesRequest.new({
              resource_names: resource_names,
              project_ids: project_ids,
              filter: filter,
              order_by: order_by,
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_log_entries.call(req, options)
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
          # @return [Google::Gax::PagedEnumerable<Google::Api::MonitoredResourceDescriptor>]
          #   An enumerable of Google::Api::MonitoredResourceDescriptor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_client"
          #
          #   LoggingServiceV2Client = Google::Cloud::Logging::V2::LoggingServiceV2Client
          #
          #   logging_service_v2_client = LoggingServiceV2Client.new
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
              options: nil
            req = Google::Logging::V2::ListMonitoredResourceDescriptorsRequest.new({
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_monitored_resource_descriptors.call(req, options)
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
          # @return [Google::Gax::PagedEnumerable<String>]
          #   An enumerable of String instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_client"
          #
          #   LoggingServiceV2Client = Google::Cloud::Logging::V2::LoggingServiceV2Client
          #
          #   logging_service_v2_client = LoggingServiceV2Client.new
          #   formatted_parent = LoggingServiceV2Client.project_path("[PROJECT]")
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
              options: nil
            req = Google::Logging::V2::ListLogsRequest.new({
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? })
            @list_logs.call(req, options)
          end
        end
      end
    end
  end
end
