# Copyright 2016 Google LLC
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


require "google/cloud/logging/convert"
require "google/cloud/logging/resource"
require "google/cloud/logging/entry/http_request"
require "google/cloud/logging/entry/operation"
require "google/cloud/logging/entry/source_location"
require "google/cloud/logging/entry/list"

module Google
  module Cloud
    module Logging
      ##
      # # Entry
      #
      # An individual entry in a log.
      #
      # Each log entry is composed of metadata and a payload. The metadata
      # includes standard information used by Stackdriver Logging, such as when
      # the entry was created and where it came from. The payload is the event
      # record. Traditionally this is a message string, but in Stackdriver
      # Logging it can also be a JSON or protocol buffer object. A single log
      # can have entries with different payload types.
      #
      # A log is a named collection of entries. Logs can be produced by Google
      # Cloud Platform services, by third-party services, or by your
      # applications. For example, the log `compute.googleapis.com/activity_log`
      # is produced by Google Compute Engine. Logs are simply referenced by name
      # in google-cloud. There is no `Log` type in google-cloud or `Log`
      # resource in the Stackdriver Logging API.
      #
      # @see https://cloud.google.com/logging/docs/view/logs_index List of Log
      #   Types
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   entry = logging.entry payload: "Job started.", log_name: "my_app_log"
      #   entry.resource.type = "gae_app"
      #   entry.resource.labels[:module_id] = "1"
      #   entry.resource.labels[:version_id] = "20150925t173233"
      #
      #   logging.write_entries entry
      #
      # @example Provide a hash to write a JSON payload to the log:
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   payload = { "stats" => { "a" => 8, "b" => 12.5} }
      #   entry = logging.entry payload: payload, log_name: "my_app_log"
      #   entry.resource.type = "gae_app"
      #   entry.resource.labels[:module_id] = "1"
      #   entry.resource.labels[:version_id] = "20150925t173233"
      #
      #   logging.write_entries entry
      #
      class Entry
        ##
        # Create a new Entry instance. The {#resource} attribute is
        # pre-populated with a new {Google::Cloud::Logging::Resource} instance.
        # See also {Google::Cloud::Logging::Project#entry}.
        def initialize
          @labels = {}
          @resource = Resource.new
          @http_request = HttpRequest.new
          @operation = Operation.new
          @severity = :DEFAULT
          @source_location = SourceLocation.new
        end

        ##
        # The resource name of the log to which this log entry belongs. The
        # format of the name is `projects/<project-id>/logs/<log-id>`. e.g.
        # `projects/my-projectid/logs/my_app_log` and
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
        # monitored resource designating the particular database that reported
        # the error.
        # @return [Google::Cloud::Logging::Resource]
        attr_accessor :resource

        ##
        # The time the event described by the log entry occurred. If omitted,
        # Stackdriver Logging will use the time the log entry is written.
        # @return [Time]
        attr_accessor :timestamp

        ##
        # The severity level of the log entry. The default value is `:DEFAULT`.
        # @return [Symbol]
        attr_accessor :severity

        ##
        # Returns `true` if the severity level is `:DEFAULT`.
        def default?
          severity == :DEFAULT
        end

        ##
        # Sets the severity level to `:DEFAULT`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity = :DEBUG
        #   entry.default!
        #   entry.default? #=> true
        #   entry.severity #=> :DEFAULT
        #
        def default!
          self.severity = :DEFAULT
        end

        ##
        # Returns `true` if the severity level is `:DEBUG`.
        def debug?
          severity == :DEBUG
        end

        ##
        # Sets the severity level to `:DEBUG`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.debug!
        #   entry.debug? #=> true
        #   entry.severity #=> :DEBUG
        #
        def debug!
          self.severity = :DEBUG
        end

        ##
        # Returns `true` if the severity level is `:INFO`.
        def info?
          severity == :INFO
        end

        ##
        # Sets the severity level to `:INFO`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.info!
        #   entry.info? #=> true
        #   entry.severity #=> :INFO
        #
        def info!
          self.severity = :INFO
        end

        ##
        # Returns `true` if the severity level is `:NOTICE`.
        def notice?
          severity == :NOTICE
        end

        ##
        # Sets the severity level to `:NOTICE`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.notice!
        #   entry.notice? #=> true
        #   entry.severity #=> :NOTICE
        #
        def notice!
          self.severity = :NOTICE
        end

        ##
        # Returns `true` if the severity level is `:WARNING`.
        def warning?
          severity == :WARNING
        end

        ##
        # Sets the severity level to `:WARNING`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.warning!
        #   entry.warning? #=> true
        #   entry.severity #=> :WARNING
        #
        def warning!
          self.severity = :WARNING
        end

        ##
        # Returns `true` if the severity level is `:ERROR`.
        def error?
          severity == :ERROR
        end

        ##
        # Sets the severity level to `:ERROR`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.error!
        #   entry.error? #=> true
        #   entry.severity #=> :ERROR
        #
        def error!
          self.severity = :ERROR
        end

        ##
        # Returns `true` if the severity level is `:CRITICAL`.
        def critical?
          severity == :CRITICAL
        end

        ##
        # Sets the severity level to `:CRITICAL`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.critical!
        #   entry.critical? #=> true
        #   entry.severity #=> :CRITICAL
        #
        def critical!
          self.severity = :CRITICAL
        end

        ##
        # Returns `true` if the severity level is `:ALERT`.
        def alert?
          severity == :ALERT
        end

        ##
        # Sets the severity level to `:ALERT`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.alert!
        #   entry.alert? #=> true
        #   entry.severity #=> :ALERT
        #
        def alert!
          self.severity = :ALERT
        end

        ##
        # Returns `true` if the severity level is `:EMERGENCY`.
        def emergency?
          severity == :EMERGENCY
        end

        ##
        # Sets the severity level to `:EMERGENCY`.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry
        #   entry.severity #=> :DEFAULT
        #   entry.emergency!
        #   entry.emergency? #=> true
        #   entry.severity #=> :EMERGENCY
        #
        def emergency!
          self.severity = :EMERGENCY
        end

        ##
        # A unique ID for the log entry. If you provide this field, the logging
        # service considers other log entries in the same log with the same ID
        # as duplicates which can be removed. If omitted, Stackdriver Logging
        # will generate a unique ID for this log entry.
        # @return [String]
        attr_accessor :insert_id

        ##
        # A set of user-defined data that provides additional information about
        # the log entry.
        # @return [Hash]
        attr_accessor :labels

        ##
        # The log entry payload, represented as either a string, a hash (JSON),
        # or a hash (protocol buffer).
        # @return [String, Hash]
        attr_accessor :payload

        ##
        # Information about the HTTP request associated with this log entry, if
        # applicable.
        # @return [Google::Cloud::Logging::Entry::HttpRequest]
        attr_reader :http_request

        ##
        # Information about an operation associated with the log entry, if
        # applicable.
        # @return [Google::Cloud::Logging::Entry::Operation]
        attr_reader :operation

        ##
        # Resource name of the trace associated with the log entry, if any. If
        # it contains a relative resource name, the name is assumed to be
        # relative to `//tracing.googleapis.com`. Example:
        # `projects/my-projectid/traces/06796866738c859f2f19b7cfb3214824`
        # Optional.
        # @return [String]
        attr_accessor :trace

        ##
        # Source code location information associated with the log entry, if
        # any.
        # @return [Google::Cloud::Logging::Entry::SourceLocation]
        attr_reader :source_location

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
            operation.empty? &&
            trace.nil? &&
            source_location.empty?
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
            operation: operation.to_grpc,
            trace: trace.to_s,
            source_location: source_location.to_grpc
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
            e.labels = Convert.map_to_hash(grpc.labels)
            e.payload = extract_payload(grpc)
            e.instance_variable_set "@resource",
                                    Resource.from_grpc(grpc.resource)
            e.instance_variable_set "@http_request",
                                    HttpRequest.from_grpc(grpc.http_request)
            e.instance_variable_set "@operation",
                                    Operation.from_grpc(grpc.operation)
            e.trace = grpc.trace
            e.instance_variable_set "@source_location",
                                    SourceLocation.from_grpc(
                                      grpc.source_location
                                    )
          end
        end

        ##
        # @private Formats the timestamp as a Google::Protobuf::Timestamp
        # object.
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
          grpc.proto_payload = nil
          grpc.json_payload  = nil
          grpc.text_payload  = nil

          if payload.is_a? Google::Protobuf::Any
            grpc.proto_payload = payload
          elsif payload.respond_to? :to_hash
            grpc.json_payload = Convert.hash_to_struct payload.to_hash
          else
            grpc.text_payload = payload.to_s
          end
        end

        ##
        # @private Extract payload data from Google API Client object.
        def self.extract_payload grpc
          grpc.proto_payload || grpc.json_payload || grpc.text_payload
        end

        ##
        # @private Get a Time object from a Google::Protobuf::Timestamp object.
        def self.extract_timestamp grpc
          return nil if grpc.timestamp.nil?
          Time.at grpc.timestamp.seconds, Rational(grpc.timestamp.nanos, 1000)
        end
      end
    end
  end
end
