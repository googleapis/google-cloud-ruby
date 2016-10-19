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
      # An individual entry in a log.
      # @!attribute [rw] log_name
      #   @return [String]
      #     Required. The resource name of the log to which this log entry
      #     belongs. The format of the name is
      #     +"projects/<project-id>/logs/<log-id>"+.  Examples:
      #     +"projects/my-projectid/logs/syslog"+,
      #     +"projects/my-projectid/logs/library.googleapis.com%2Fbook_log"+.
      #
      #     The log ID part of resource name must be less than 512 characters
      #     long and can only include the following characters: upper and
      #     lower case alphanumeric characters: [A-Za-z0-9]; and punctuation
      #     characters: forward-slash, underscore, hyphen, and period.
      #     Forward-slash (+/+) characters in the log ID must be URL-encoded.
      # @!attribute [rw] resource
      #   @return [Google::Api::MonitoredResource]
      #     Required. The monitored resource associated with this log entry.
      #     Example: a log entry that reports a database error would be
      #     associated with the monitored resource designating the particular
      #     database that reported the error.
      # @!attribute [rw] proto_payload
      #   @return [Google::Protobuf::Any]
      #     The log entry payload, represented as a protocol buffer.  Some
      #     Google Cloud Platform services use this field for their log
      #     entry payloads.
      # @!attribute [rw] text_payload
      #   @return [String]
      #     The log entry payload, represented as a Unicode string (UTF-8).
      # @!attribute [rw] json_payload
      #   @return [Google::Protobuf::Struct]
      #     The log entry payload, represented as a structure that
      #     is expressed as a JSON object.
      # @!attribute [rw] timestamp
      #   @return [Google::Protobuf::Timestamp]
      #     Optional. The time the event described by the log entry occurred.  If
      #     omitted, Stackdriver Logging will use the time the log entry is received.
      # @!attribute [rw] severity
      #   @return [Google::Logging::Type::LogSeverity]
      #     Optional. The severity of the log entry. The default value is
      #     +LogSeverity.DEFAULT+.
      # @!attribute [rw] insert_id
      #   @return [String]
      #     Optional. A unique ID for the log entry. If you provide this
      #     field, the logging service considers other log entries in the
      #     same project with the same ID as duplicates which can be removed.  If
      #     omitted, Stackdriver Logging will generate a unique ID for this
      #     log entry.
      # @!attribute [rw] http_request
      #   @return [Google::Logging::Type::HttpRequest]
      #     Optional. Information about the HTTP request associated with this
      #     log entry, if applicable.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     Optional. A set of user-defined (key, value) data that provides additional
      #     information about the log entry.
      # @!attribute [rw] operation
      #   @return [Google::Logging::V2::LogEntryOperation]
      #     Optional. Information about an operation associated with the log entry, if
      #     applicable.
      class LogEntry; end

      # Additional information about a potentially long-running operation with which
      # a log entry is associated.
      # @!attribute [rw] id
      #   @return [String]
      #     Optional. An arbitrary operation identifier. Log entries with the
      #     same identifier are assumed to be part of the same operation.
      # @!attribute [rw] producer
      #   @return [String]
      #     Optional. An arbitrary producer identifier. The combination of
      #     +id+ and +producer+ must be globally unique.  Examples for +producer+:
      #     +"MyDivision.MyBigCompany.com"+, +"github.com/MyProject/MyApplication"+.
      # @!attribute [rw] first
      #   @return [true, false]
      #     Optional. Set this to True if this is the first log entry in the operation.
      # @!attribute [rw] last
      #   @return [true, false]
      #     Optional. Set this to True if this is the last log entry in the operation.
      class LogEntryOperation; end
    end
  end
end