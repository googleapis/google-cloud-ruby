# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/logging/resource"
require "gcloud/logging/entry/http_request"
require "gcloud/logging/entry/operation"
require "gcloud/logging/entry/list"

module Gcloud
  module Logging
    ##
    # # Entry
    #
    # An individual entry in a log.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   entry = logging.entries.first
    #
    class Entry
      ##
      # Create an empty Entry object.
      def initialize
        @labels = {}
        @resource = Resource.new
        @http_request = HttpRequest.new
        @operation = Operation.new
        @severity = :DEFAULT
      end

      ##
      # The resource name of the log to which this log entry belongs. The format
      # of the name is `projects/<project-id>/logs/<log-id>`. e.g.
      # `projects/my-projectid/logs/syslog` and
      # `projects/1234567890/logs/library.googleapis.com%2Fbook_log`
      #
      # The log ID part of resource name must be less than 512 characters long
      # and can only include the following characters: upper and lower case
      # alphanumeric characters: `[A-Za-z0-9]`; and punctuation characters:
      # forward-slash (`/`), underscore (`_`), hyphen (`-`), and period (`.`).
      # Forward-slash (`/`) characters in the log ID must be URL-encoded.
      attr_accessor :log_name

      ##
      # The monitored resource associated with this log entry. Example: a log
      # entry that reports a database error would be associated with the
      # monitored resource designating the particular database that reported the
      # error.
      attr_reader :resource

      ##
      # The time the event described by the log entry occurred. If omitted,
      # Cloud Logging will use the time the log entry is written.
      attr_accessor :timestamp

      ##
      # The severity of the log entry. The default value is `DEFAULT`.
      attr_accessor :severity

      ##
      # Helper method to determine if the severity is `DEFAULT`
      def default?
        severity == :DEFAULT
      end

      ##
      # Helper method to determine if the severity is `DEBUG`
      def debug?
        severity == :DEBUG
      end

      ##
      # Helper method to determine if the severity is `INFO`
      def info?
        severity == :INFO
      end

      ##
      # Helper method to determine if the severity is `NOTICE`
      def notice?
        severity == :NOTICE
      end

      ##
      # Helper method to determine if the severity is `WARNING`
      def warning?
        severity == :WARNING
      end

      ##
      # Helper method to determine if the severity is `ERROR`
      def error?
        severity == :ERROR
      end

      ##
      # Helper method to determine if the severity is `CRITICAL`
      def critical?
        severity == :CRITICAL
      end

      ##
      # Helper method to determine if the severity is `ALERT`
      def alert?
        severity == :ALERT
      end

      ##
      # Helper method to determine if the severity is `EMERGENCY`
      def emergency?
        severity == :EMERGENCY
      end

      ##
      # A unique ID for the log entry. If you provide this field, the logging
      # service considers other log entries in the same log with the same ID as
      # duplicates which can be removed. If omitted, Cloud Logging will generate
      # a unique ID for this log entry.
      attr_accessor :insert_id

      ##
      # A set of user-defined data that provides additional information about
      # the log entry.
      attr_accessor :labels

      ##
      # The log entry payload, represented as either a string, a hash (JSON), or
      # a hash (protocol buffer).
      attr_accessor :payload

      ##
      # Information about the HTTP request associated with this log entry, if
      # applicable.
      attr_reader :http_request

      ##
      # Information about an operation associated with the log entry, if
      # applicable.
      attr_reader :operation

      ##
      # @private Determines if the Entry has any data.
      def empty?
        log_name.nil? &&
          timestamp.nil? &&
          insert_id.nil? &&
          (labels.nil? || labels.empty?) &&
          payload.nil? &&
          resource.empty? &&
          http_request.empty? &&
          operation.empty?
      end

      ##
      # @private Exports the Entry to a Google::Logging::V2::LogEntry object.
      def to_grpc
        grpc = Google::Logging::V2::LogEntry.new(
          log_name: log_name.to_s,
          timestamp: timestamp_grpc,
          # TODO: verify severity is the correct type?
          severity: severity,
          insert_id: insert_id.to_s,
          labels: labels_grpc,
          resource: resource.to_grpc,
          http_request: http_request.to_grpc,
          operation: operation.to_grpc
        )
        # Add payload
        append_payload grpc
        grpc
      end

      ##
      # @private New Entry from a Google::Logging::V2::LogEntry object.
      def self.from_grpc grpc
        return new if grpc.nil?
        new.tap do |e|
          e.log_name = grpc.log_name
          e.timestamp = extract_timestamp(grpc)
          e.severity = grpc.severity
          e.insert_id = grpc.insert_id
          e.labels = hashify(grpc.labels)
          e.payload = extract_payload(grpc)
          e.instance_eval do
            @resource = Resource.from_grpc grpc.resource
            @http_request = HttpRequest.from_grpc grpc.http_request
            @operation = Operation.from_grpc grpc.operation
          end
        end
      end

      ##
      # @private Convert to a hash, used for labels.
      def self.hashify h
        # TODO: Is this really neccessary anymore? Doesn't GRPC do the right
        # thing?
        h = h.to_hash if h.respond_to? :to_hash
        h = h.to_h    if h.respond_to? :to_h
        h
      end

      ##
      # @private Formats the timestamp as a Google::Protobuf::Timestamp object.
      def timestamp_grpc
        return nil if timestamp.nil?
        # TODO: ArgumentError if timestamp is not a Time object?
        Google::Protobuf::Timestamp.new(
          seconds: timestamp.to_i,
          nanos: timestamp.nsec
        )
      end

      ##
      # @private Formats the labels so they can be saved to a
      # Google::Logging::V2::LogEntry object.
      def labels_grpc
        # Coerce symbols to strings
        Hash[labels.map do |k, v|
          v = String(v) if v.is_a? Symbol
          [String(k), v]
        end]
      end

      ##
      # @private Adds the payload data to a Google::Logging::V2::LogEntry
      # object.
      def append_payload grpc
        # TODO: This is not correct. We need to convert a hash to the
        # json_payload's Google::Protobuf::Struct object. And however we
        # identify a proto_payload to a Google::Protobuf::Any object. There is
        # more work to do.
        grpc.proto_payload = nil
        grpc.json_payload  = nil
        grpc.text_payload  = nil

        if payload.respond_to? :to_proto
          grpc.proto_payload = payload.to_proto
        elsif payload.respond_to? :to_hash
          grpc.json_payload = payload.to_hash
        else
          grpc.text_payload = payload.to_s
        end
      end

      ##
      # @private Extract payload data from Google API Client object.
      def self.extract_payload grpc
        # TODO: This is not correct. We need to convert the json_payload
        # Google::Protobuf::Struct object to a hash. And the proto_payload
        # Google::Protobuf::Any object to something as well. It is more
        # complicated than this.
        grpc.proto_payload || grpc.json_payload || grpc.text_payload
      end

      ##
      # @private Get a Time object from a Google::Protobuf::Timestamp object.
      def self.extract_timestamp grpc
        return nil if grpc.timestamp.nil?
        Time.at grpc.timestamp.seconds, grpc.timestamp.nanos/1000.0
      end
    end
  end
end
