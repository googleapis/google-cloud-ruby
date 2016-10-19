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
      # Describes a sink used to export log entries outside Stackdriver Logging.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The client-assigned sink identifier, unique within the
      #     project. Example: +"my-syslog-errors-to-pubsub"+.  Sink identifiers are
      #     limited to 1000 characters and can include only the following characters:
      #     +A-Z+, +a-z+, +0-9+, and the special characters +_-.+.  The maximum length
      #     of the name is 100 characters.
      # @!attribute [rw] destination
      #   @return [String]
      #     Required. The export destination. See
      #     {Exporting Logs With Sinks}[https://cloud.google.com/logging/docs/api/tasks/exporting-logs].
      #     Examples:
      #
      #         "storage.googleapis.com/my-gcs-bucket"
      #         "bigquery.googleapis.com/projects/my-project-id/datasets/my-dataset"
      #         "pubsub.googleapis.com/projects/my-project/topics/my-topic"
      # @!attribute [rw] filter
      #   @return [String]
      #     Optional. An {advanced logs filter}[https://cloud.google.com/logging/docs/view/advanced_filters].
      #     Only log entries matching the filter are exported. The filter
      #     must be consistent with the log entry format specified by the
      #     +outputVersionFormat+ parameter, regardless of the format of the
      #     log entry that was originally written to Stackdriver Logging.
      #     Example filter (V2 format):
      #
      #         logName=projects/my-projectid/logs/syslog AND severity>=ERROR
      # @!attribute [rw] output_version_format
      #   @return [Google::Logging::V2::LogSink::VersionFormat]
      #     Optional. The log entry version to use for this sink's exported log
      #     entries.  This version does not have to correspond to the version of the
      #     log entry that was written to Stackdriver Logging. If omitted, the
      #     v2 format is used.
      # @!attribute [rw] writer_identity
      #   @return [String]
      #     Output only. The iam identity to which the destination needs to grant write
      #     access.  This may be a service account or a group.
      #     Examples (Do not assume these specific values):
      #        "serviceAccount:cloud-logs@system.gserviceaccount.com"
      #        "group:cloud-logs@google.com"
      #
      #       For GCS destinations, the role "roles/owner" is required on the bucket
      #       For Cloud Pubsub destinations, the role "roles/pubsub.publisher" is
      #         required on the topic
      #       For BigQuery, the role "roles/editor" is required on the dataset
      class LogSink
        # Available log entry formats. Log entries can be written to Cloud
        # Logging in either format and can be exported in either format.
        # Version 2 is the preferred format.
        module VersionFormat
          # An unspecified version format will default to V2.
          VERSION_FORMAT_UNSPECIFIED = 0

          # +LogEntry+ version 2 format.
          V2 = 1

          # +LogEntry+ version 1 format.
          V1 = 2
        end
      end

      # The parameters to +ListSinks+.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. The cloud resource containing the sinks.
      #     Example: +"projects/my-logging-project"+.
      # @!attribute [rw] page_token
      #   @return [String]
      #     Optional. If present, then retrieve the next batch of results from the
      #     preceding call to this method.  +pageToken+ must be the value of
      #     +nextPageToken+ from the previous response.  The values of other method
      #     parameters should be identical to those in the previous call.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Optional. The maximum number of results to return from this request.
      #     Non-positive values are ignored.  The presence of +nextPageToken+ in the
      #     response indicates that more results might be available.
      class ListSinksRequest; end

      # Result returned from +ListSinks+.
      # @!attribute [rw] sinks
      #   @return [Array<Google::Logging::V2::LogSink>]
      #     A list of sinks.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than appear in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call the same
      #     method again using the value of +nextPageToken+ as +pageToken+.
      class ListSinksResponse; end

      # The parameters to +GetSink+.
      # @!attribute [rw] sink_name
      #   @return [String]
      #     Required. The resource name of the sink to return.
      #     Example: +"projects/my-project-id/sinks/my-sink-id"+.
      class GetSinkRequest; end

      # The parameters to +CreateSink+.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. The resource in which to create the sink.
      #     Example: +"projects/my-project-id"+.
      #     The new sink must be provided in the request.
      # @!attribute [rw] sink
      #   @return [Google::Logging::V2::LogSink]
      #     Required. The new sink, whose +name+ parameter is a sink identifier that
      #     is not already in use.
      class CreateSinkRequest; end

      # The parameters to +UpdateSink+.
      # @!attribute [rw] sink_name
      #   @return [String]
      #     Required. The resource name of the sink to update, including the parent
      #     resource and the sink identifier.  If the sink does not exist, this method
      #     creates the sink.  Example: +"projects/my-project-id/sinks/my-sink-id"+.
      # @!attribute [rw] sink
      #   @return [Google::Logging::V2::LogSink]
      #     Required. The updated sink, whose name is the same identifier that appears
      #     as part of +sinkName+.  If +sinkName+ does not exist, then
      #     this method creates a new sink.
      class UpdateSinkRequest; end

      # The parameters to +DeleteSink+.
      # @!attribute [rw] sink_name
      #   @return [String]
      #     Required. The resource name of the sink to delete, including the parent
      #     resource and the sink identifier.  Example:
      #     +"projects/my-project-id/sinks/my-sink-id"+.  It is an error if the sink
      #     does not exist.
      class DeleteSinkRequest; end
    end
  end
end