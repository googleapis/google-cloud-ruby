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

module Google
  module Cloud
    module Logging
      module V2
        # Service for ingesting and querying logs.
        #
        # @!attribute [r] stub
        #   @return [Google::Logging::V2::LoggingServiceV2::Stub]
        class LoggingServiceV2Api
          attr_reader :stub

          # The default address of the service.
          SERVICE_ADDRESS = "logging.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_log_entries" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "entries"),
            "list_monitored_resource_descriptors" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "resource_descriptors")
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

          LOG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/logs/{log}"
          )

          private_constant :LOG_PATH_TEMPLATE

          # Returns a fully-qualified parent resource name string.
          # @param project [String]
          # @return [String]
          def self.parent_path project
            PARENT_PATH_TEMPLATE.render(
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

          # Parses the project from a parent resource.
          # @param parent_name [String]
          # @return [String]
          def self.match_project_from_parent_name parent_name
            PARENT_PATH_TEMPLATE.match(parent_name)["project"]
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
            require "google/logging/v2/logging_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
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
              &Google::Logging::V2::LoggingServiceV2::Stub.method(:new)
            )

            @delete_log = Google::Gax.create_api_call(
              @stub.method(:delete_log),
              defaults["delete_log"]
            )
            @write_log_entries = Google::Gax.create_api_call(
              @stub.method(:write_log_entries),
              defaults["write_log_entries"]
            )
            @list_log_entries = Google::Gax.create_api_call(
              @stub.method(:list_log_entries),
              defaults["list_log_entries"]
            )
            @list_monitored_resource_descriptors = Google::Gax.create_api_call(
              @stub.method(:list_monitored_resource_descriptors),
              defaults["list_monitored_resource_descriptors"]
            )
          end

          # Service calls

          # Deletes a log and all its log entries.
          # The log will reappear if it receives new entries.
          #
          # @param log_name [String]
          #   Required. The resource name of the log to delete.  Example:
          #   +"projects/my-project/logs/syslog"+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_api"
          #
          #   LoggingServiceV2Api = Google::Cloud::Logging::V2::LoggingServiceV2Api
          #
          #   logging_service_v2_api = LoggingServiceV2Api.new
          #   formatted_log_name = LoggingServiceV2Api.log_path("[PROJECT]", "[LOG]")
          #   logging_service_v2_api.delete_log(formatted_log_name)

          def delete_log \
              log_name,
              options: nil
            req = Google::Logging::V2::DeleteLogRequest.new(
              log_name: log_name
            )
            @delete_log.call(req, options)
          end

          # Writes log entries to Stackdriver Logging.  All log entries are
          # written by this method.
          #
          # @param log_name [String]
          #   Optional. A default log resource name for those log entries in +entries+
          #   that do not specify their own +logName+.  Example:
          #   +"projects/my-project/logs/syslog"+.  See
          #   LogEntry.
          # @param resource [Google::Api::MonitoredResource]
          #   Optional. A default monitored resource for those log entries in +entries+
          #   that do not specify their own +resource+.
          # @param labels [Hash{String => String}]
          #   Optional. User-defined +key:value+ items that are added to
          #   the +labels+ field of each log entry in +entries+, except when a log
          #   entry specifies its own +key:value+ item with the same key.
          #   Example: +{ "size": "large", "color":"red" }+
          # @param entries [Array<Google::Logging::V2::LogEntry>]
          #   Required. The log entries to write. The log entries must have values for
          #   all required fields.
          #
          #   To improve throughput and to avoid exceeding the quota limit for calls
          #   to +entries.write+, use this field to write multiple log entries at once
          #   rather than  // calling this method for each log entry.
          # @param partial_success [true, false]
          #   Optional. Whether valid entries should be written even if some other
          #   entries fail due to INVALID_ARGUMENT or PERMISSION_DENIED errors. If any
          #   entry is not written, the response status will be the error associated
          #   with one of the failed entries and include error details in the form of
          #   WriteLogEntriesPartialErrors.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::WriteLogEntriesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2/logging_service_v2_api"
          #
          #   LoggingServiceV2Api = Google::Cloud::Logging::V2::LoggingServiceV2Api
          #
          #   logging_service_v2_api = LoggingServiceV2Api.new
          #   entries = []
          #   response = logging_service_v2_api.write_log_entries(entries)

          def write_log_entries \
              entries,
              log_name: nil,
              resource: nil,
              labels: nil,
              partial_success: nil,
              options: nil
            req = Google::Logging::V2::WriteLogEntriesRequest.new(
              entries: entries
            )
            req.log_name = log_name unless log_name.nil?
            req.resource = resource unless resource.nil?
            req.labels = labels unless labels.nil?
            req.partial_success = partial_success unless partial_success.nil?
            @write_log_entries.call(req, options)
          end

          # Lists log entries.  Use this method to retrieve log entries from Cloud
          # Logging.  For ways to export log entries, see
          # {Exporting Logs}[https://cloud.google.com/logging/docs/export].
          #
          # @param project_ids [Array<String>]
          #   Required. One or more project IDs or project numbers from which to retrieve
          #   log entries.  Examples of a project ID: +"my-project-1A"+, +"1234567890"+.
          # @param filter [String]
          #   Optional. An {advanced logs filter}[https://cloud.google.com/logging/docs/view/advanced_filters].
          #   The filter is compared against all log entries in the projects specified by
          #   +projectIds+.  Only entries that match the filter are retrieved.  An empty
          #   filter matches all log entries.
          # @param order_by [String]
          #   Optional. How the results should be sorted.  Presently, the only permitted
          #   values are +"timestamp asc"+ (default) and +"timestamp desc"+. The first
          #   option returns entries in order of increasing values of
          #   +LogEntry.timestamp+ (oldest first), and the second option returns entries
          #   in order of decreasing timestamps (newest first).  Entries with equal
          #   timestamps are returned in order of +LogEntry.insertId+.
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
          #   require "google/cloud/logging/v2/logging_service_v2_api"
          #
          #   LoggingServiceV2Api = Google::Cloud::Logging::V2::LoggingServiceV2Api
          #
          #   logging_service_v2_api = LoggingServiceV2Api.new
          #   project_ids = []
          #
          #   # Iterate over all results.
          #   logging_service_v2_api.list_log_entries(project_ids).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_api.list_log_entries(project_ids).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_log_entries \
              project_ids,
              filter: nil,
              order_by: nil,
              page_size: nil,
              options: nil
            req = Google::Logging::V2::ListLogEntriesRequest.new(
              project_ids: project_ids
            )
            req.filter = filter unless filter.nil?
            req.order_by = order_by unless order_by.nil?
            req.page_size = page_size unless page_size.nil?
            @list_log_entries.call(req, options)
          end

          # Lists the monitored resource descriptors used by Stackdriver Logging.
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
          #   require "google/cloud/logging/v2/logging_service_v2_api"
          #
          #   LoggingServiceV2Api = Google::Cloud::Logging::V2::LoggingServiceV2Api
          #
          #   logging_service_v2_api = LoggingServiceV2Api.new
          #
          #   # Iterate over all results.
          #   logging_service_v2_api.list_monitored_resource_descriptors.each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   logging_service_v2_api.list_monitored_resource_descriptors.each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_monitored_resource_descriptors \
              page_size: nil,
              options: nil
            req = Google::Logging::V2::ListMonitoredResourceDescriptorsRequest.new
            req.page_size = page_size unless page_size.nil?
            @list_monitored_resource_descriptors.call(req, options)
          end
        end
      end
    end
  end
end
