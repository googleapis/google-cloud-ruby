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

module Google
  module Logging
    module V2
      # The parameters to DeleteLog.
      # @!attribute [rw] log_name
      #   @return [String]
      #     Required. The resource name of the log to delete.  Example:
      #     +"projects/my-project/logs/syslog"+.
      class DeleteLogRequest; end

      # The parameters to WriteLogEntries.
      # @!attribute [rw] log_name
      #   @return [String]
      #     Optional. A default log resource name that is assigned to all log entries
      #     in +entries+ that do not specify a value for +log_name+.  Example:
      #     +"projects/my-project/logs/syslog"+.  See
      #     LogEntry.
      # @!attribute [rw] resource
      #   @return [Google::Api::MonitoredResource]
      #     Optional. A default monitored resource object that is assigned to all log
      #     entries in +entries+ that do not specify a value for +resource+. Example:
      #
      #         { "type": "gce_instance",
      #           "labels": {
      #             "zone": "us-central1-a", "instance_id": "00000000000000000000" }}
      #
      #     See LogEntry.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     Optional. Default labels that are added to the +labels+ field of all log
      #     entries in +entries+. If a log entry already has a label with the same key
      #     as a label in this parameter, then the log entry's label is not changed.
      #     See LogEntry.
      # @!attribute [rw] entries
      #   @return [Array<Google::Logging::V2::LogEntry>]
      #     Required. The log entries to write. Values supplied for the fields
      #     +log_name+, +resource+, and +labels+ in this +entries.write+ request are
      #     added to those log entries that do not provide their own values for the
      #     fields.
      #
      #     To improve throughput and to avoid exceeding the
      #     {quota limit}[https://cloud.google.com/logging/quota-policy] for calls to +entries.write+,
      #     you should write multiple log entries at once rather than
      #     calling this method for each individual log entry.
      # @!attribute [rw] partial_success
      #   @return [true, false]
      #     Optional. Whether valid entries should be written even if some other
      #     entries fail due to INVALID_ARGUMENT or PERMISSION_DENIED errors. If any
      #     entry is not written, the response status will be the error associated
      #     with one of the failed entries and include error details in the form of
      #     WriteLogEntriesPartialErrors.
      class WriteLogEntriesRequest; end

      # Result returned from WriteLogEntries.
      # empty
      class WriteLogEntriesResponse; end

      # The parameters to +ListLogEntries+.
      # @!attribute [rw] project_ids
      #   @return [Array<String>]
      #     Deprecated. One or more project identifiers or project numbers from which
      #     to retrieve log entries.  Examples: +"my-project-1A"+, +"1234567890"+. If
      #     present, these project identifiers are converted to resource format and
      #     added to the list of resources in +resourceNames+. Callers should use
      #     +resourceNames+ rather than this parameter.
      # @!attribute [rw] resource_names
      #   @return [Array<String>]
      #     Optional. One or more cloud resources from which to retrieve log entries.
      #     Example: +"projects/my-project-1A"+, +"projects/1234567890"+.  Projects
      #     listed in +projectIds+ are added to this list.
      # @!attribute [rw] filter
      #   @return [String]
      #     Optional. A filter that chooses which log entries to return.  See {Advanced
      #     Logs Filters}[https://cloud.google.com/logging/docs/view/advanced_filters].  Only log entries that
      #     match the filter are returned.  An empty filter matches all log entries.
      # @!attribute [rw] order_by
      #   @return [String]
      #     Optional. How the results should be sorted.  Presently, the only permitted
      #     values are +"timestamp asc"+ (default) and +"timestamp desc"+. The first
      #     option returns entries in order of increasing values of
      #     +LogEntry.timestamp+ (oldest first), and the second option returns entries
      #     in order of decreasing timestamps (newest first).  Entries with equal
      #     timestamps are returned in order of +LogEntry.insertId+.
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
      class ListLogEntriesRequest; end

      # Result returned from +ListLogEntries+.
      # @!attribute [rw] entries
      #   @return [Array<Google::Logging::V2::LogEntry>]
      #     A list of log entries.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than appear in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
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
      #     If there might be more results than appear in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
      class ListMonitoredResourceDescriptorsResponse; end
    end
  end
end