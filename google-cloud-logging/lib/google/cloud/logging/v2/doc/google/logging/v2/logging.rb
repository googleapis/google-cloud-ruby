# Copyright 2017 Google LLC
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

module Google
  module Logging
    ##
    # # Stackdriver Logging API Contents
    #
    # | Class | Description |
    # | ----- | ----------- |
    # | [LoggingServiceV2Client][] | Writes log entries and manages your Stackdriver Logging configuration. |
    # | [ConfigServiceV2Client][] | Writes log entries and manages your Stackdriver Logging configuration. |
    # | [MetricsServiceV2Client][] | Writes log entries and manages your Stackdriver Logging configuration. |
    # | [Data Types][] | Data types for Google::Cloud::Logging::V2 |
    #
    # [LoggingServiceV2Client]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/logging/v2/loggingservicev2client
    # [ConfigServiceV2Client]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/logging/v2/configservicev2client
    # [MetricsServiceV2Client]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/logging/v2/metricsservicev2client
    # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/logging/v2/datatypes
    #
    module V2
      # The parameters to DeleteLog.
      # @!attribute [rw] log_name
      #   @return [String]
      #     Required. The resource name of the log to delete:
      #
      #         "projects/[PROJECT_ID]/logs/[LOG_ID]"
      #         "organizations/[ORGANIZATION_ID]/logs/[LOG_ID]"
      #         "billingAccounts/[BILLING_ACCOUNT_ID]/logs/[LOG_ID]"
      #         "folders/[FOLDER_ID]/logs/[LOG_ID]"
      #
      #     +[LOG_ID]+ must be URL-encoded. For example,
      #     +"projects/my-project-id/logs/syslog"+,
      #     +"organizations/1234567890/logs/cloudresourcemanager.googleapis.com%2Factivity"+.
      #     For more information about log names, see
      #     {Google::Logging::V2::LogEntry LogEntry}.
      class DeleteLogRequest; end

      # The parameters to WriteLogEntries.
      # @!attribute [rw] log_name
      #   @return [String]
      #     Optional. A default log resource name that is assigned to all log entries
      #     in +entries+ that do not specify a value for +log_name+:
      #
      #         "projects/[PROJECT_ID]/logs/[LOG_ID]"
      #         "organizations/[ORGANIZATION_ID]/logs/[LOG_ID]"
      #         "billingAccounts/[BILLING_ACCOUNT_ID]/logs/[LOG_ID]"
      #         "folders/[FOLDER_ID]/logs/[LOG_ID]"
      #
      #     +[LOG_ID]+ must be URL-encoded. For example,
      #     +"projects/my-project-id/logs/syslog"+ or
      #     +"organizations/1234567890/logs/cloudresourcemanager.googleapis.com%2Factivity"+.
      #     For more information about log names, see
      #     {Google::Logging::V2::LogEntry LogEntry}.
      # @!attribute [rw] resource
      #   @return [Google::Api::MonitoredResource]
      #     Optional. A default monitored resource object that is assigned to all log
      #     entries in +entries+ that do not specify a value for +resource+. Example:
      #
      #         { "type": "gce_instance",
      #           "labels": {
      #             "zone": "us-central1-a", "instance_id": "00000000000000000000" }}
      #
      #     See {Google::Logging::V2::LogEntry LogEntry}.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     Optional. Default labels that are added to the +labels+ field of all log
      #     entries in +entries+. If a log entry already has a label with the same key
      #     as a label in this parameter, then the log entry's label is not changed.
      #     See {Google::Logging::V2::LogEntry LogEntry}.
      # @!attribute [rw] entries
      #   @return [Array<Google::Logging::V2::LogEntry>]
      #     Required. The log entries to send to Stackdriver Logging. The order of log
      #     entries in this list does not matter. Values supplied in this method's
      #     +log_name+, +resource+, and +labels+ fields are copied into those log
      #     entries in this list that do not include values for their corresponding
      #     fields. For more information, see the {Google::Logging::V2::LogEntry LogEntry} type.
      #
      #     If the +timestamp+ or +insert_id+ fields are missing in log entries, then
      #     this method supplies the current time or a unique identifier, respectively.
      #     The supplied values are chosen so that, among the log entries that did not
      #     supply their own values, the entries earlier in the list will sort before
      #     the entries later in the list. See the +entries.list+ method.
      #
      #     Log entries with timestamps that are more than the
      #     [logs retention period](https://cloud.google.com/logging/quota-policy) in the past or more than
      #     24 hours in the future might be discarded. Discarding does not return
      #     an error.
      #
      #     To improve throughput and to avoid exceeding the
      #     [quota limit](https://cloud.google.com/logging/quota-policy) for calls to +entries.write+,
      #     you should try to include several log entries in this list,
      #     rather than calling this method for each individual log entry.
      # @!attribute [rw] partial_success
      #   @return [true, false]
      #     Optional. Whether valid entries should be written even if some other
      #     entries fail due to INVALID_ARGUMENT or PERMISSION_DENIED errors. If any
      #     entry is not written, then the response status is the error associated
      #     with one of the failed entries and the response includes error details
      #     keyed by the entries' zero-based index in the +entries.write+ method.
      class WriteLogEntriesRequest; end

      # Result returned from WriteLogEntries.
      # empty
      class WriteLogEntriesResponse; end

      # Error details for WriteLogEntries with partial success.
      # @!attribute [rw] log_entry_errors
      #   @return [Hash{Integer => Google::Rpc::Status}]
      #     When +WriteLogEntriesRequest.partial_success+ is true, records the error
      #     status for entries that were not written due to a permanent error, keyed
      #     by the entry's zero-based index in +WriteLogEntriesRequest.entries+.
      #
      #     Failed requests for which no entries are written will not include
      #     per-entry errors.
      class WriteLogEntriesPartialErrors; end

      # The parameters to +ListLogEntries+.
      # @!attribute [rw] project_ids
      #   @return [Array<String>]
      #     Deprecated. Use +resource_names+ instead.  One or more project identifiers
      #     or project numbers from which to retrieve log entries.  Example:
      #     +"my-project-1A"+. If present, these project identifiers are converted to
      #     resource name format and added to the list of resources in
      #     +resource_names+.
      # @!attribute [rw] resource_names
      #   @return [Array<String>]
      #     Required. Names of one or more parent resources from which to
      #     retrieve log entries:
      #
      #         "projects/[PROJECT_ID]"
      #         "organizations/[ORGANIZATION_ID]"
      #         "billingAccounts/[BILLING_ACCOUNT_ID]"
      #         "folders/[FOLDER_ID]"
      #
      #     Projects listed in the +project_ids+ field are added to this list.
      # @!attribute [rw] filter
      #   @return [String]
      #     Optional. A filter that chooses which log entries to return.  See [Advanced
      #     Logs Filters](/logging/docs/view/advanced_filters).  Only log entries that
      #     match the filter are returned.  An empty filter matches all log entries in
      #     the resources listed in +resource_names+. Referencing a parent resource
      #     that is not listed in +resource_names+ will cause the filter to return no
      #     results.
      #     The maximum length of the filter is 20000 characters.
      # @!attribute [rw] order_by
      #   @return [String]
      #     Optional. How the results should be sorted.  Presently, the only permitted
      #     values are +"timestamp asc"+ (default) and +"timestamp desc"+. The first
      #     option returns entries in order of increasing values of
      #     +LogEntry.timestamp+ (oldest first), and the second option returns entries
      #     in order of decreasing timestamps (newest first).  Entries with equal
      #     timestamps are returned in order of their +insert_id+ values.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Optional. The maximum number of results to return from this request.
      #     Non-positive values are ignored.  The presence of +next_page_token+ in the
      #     response indicates that more results might be available.
      # @!attribute [rw] page_token
      #   @return [String]
      #     Optional. If present, then retrieve the next batch of results from the
      #     preceding call to this method.  +page_token+ must be the value of
      #     +next_page_token+ from the previous response.  The values of other method
      #     parameters should be identical to those in the previous call.
      class ListLogEntriesRequest; end

      # Result returned from +ListLogEntries+.
      # @!attribute [rw] entries
      #   @return [Array<Google::Logging::V2::LogEntry>]
      #     A list of log entries.  If +entries+ is empty, +nextPageToken+ may still be
      #     returned, indicating that more entries may exist.  See +nextPageToken+ for
      #     more information.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than those appearing in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
      #
      #     If a value for +next_page_token+ appears and the +entries+ field is empty,
      #     it means that the search found no log entries so far but it did not have
      #     time to search all the possible log entries.  Retry the method with this
      #     value for +page_token+ to continue the search.  Alternatively, consider
      #     speeding up the search by changing your filter to specify a single log name
      #     or resource type, or to narrow the time range of the search.
      class ListLogEntriesResponse; end

      # The parameters to ListMonitoredResourceDescriptors
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Optional. The maximum number of results to return from this request.
      #     Non-positive values are ignored.  The presence of +nextPageToken+ in the
      #     response indicates that more results might be available.
      # @!attribute [rw] page_token
      #   @return [String]
      #     Optional. If present, then retrieve the next batch of results from the
      #     preceding call to this method.  +pageToken+ must be the value of
      #     +nextPageToken+ from the previous response.  The values of other method
      #     parameters should be identical to those in the previous call.
      class ListMonitoredResourceDescriptorsRequest; end

      # Result returned from ListMonitoredResourceDescriptors.
      # @!attribute [rw] resource_descriptors
      #   @return [Array<Google::Api::MonitoredResourceDescriptor>]
      #     A list of resource descriptors.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than those appearing in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
      class ListMonitoredResourceDescriptorsResponse; end

      # The parameters to ListLogs.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. The resource name that owns the logs:
      #
      #         "projects/[PROJECT_ID]"
      #         "organizations/[ORGANIZATION_ID]"
      #         "billingAccounts/[BILLING_ACCOUNT_ID]"
      #         "folders/[FOLDER_ID]"
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Optional. The maximum number of results to return from this request.
      #     Non-positive values are ignored.  The presence of +nextPageToken+ in the
      #     response indicates that more results might be available.
      # @!attribute [rw] page_token
      #   @return [String]
      #     Optional. If present, then retrieve the next batch of results from the
      #     preceding call to this method.  +pageToken+ must be the value of
      #     +nextPageToken+ from the previous response.  The values of other method
      #     parameters should be identical to those in the previous call.
      class ListLogsRequest; end

      # Result returned from ListLogs.
      # @!attribute [rw] log_names
      #   @return [Array<String>]
      #     A list of log names. For example,
      #     +"projects/my-project/syslog"+ or
      #     +"organizations/123/cloudresourcemanager.googleapis.com%2Factivity"+.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than those appearing in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
      class ListLogsResponse; end
    end
  end
end