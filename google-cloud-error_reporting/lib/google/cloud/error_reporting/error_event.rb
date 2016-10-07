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


require "google/cloud/error_reporting/error_event/service_context"
require "google/cloud/error_reporting/error_event/error_context"

module Google
  module Cloud
    module ErrorReporting
      ##
      # ErrorEvent
      #
      # An individual error event to report
      #
      # Google::Cloud::ErrorReporting::ErrorEvent represents gRPC ReportedErrorEvent
      # object. Each instance is consisted of:
      #   timestamp: The time where event happened.
      #   message: A single string that contains the error message along with
      #            backtrace.
      #   service_context: Represents gRPC ServiceContext class. Contains name and
      #                    version of the GCP service the error event is from.
      #   error_context: Represents gRPC ErrorContext class. Contains metadata for
      #                  the error event.
      #
      # One an error event is reported, the GCP Stackdriver ErrorReporting service
      # is able to parse the message and backtrace, then group the error events by
      # content.
      #
      # @see https://cloud.google.com/error-reporting/reference/rest/v1beta1/projects.events
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #
      #   error_event = error_reporting.error_event "Error Message with Backtrace",
      #                                             timestamp: Time.now,
      #                                             service_name: "my_app_name",
      #                                             service_version: "v8"
      #   error_reporting.report error_event
      #
      class ErrorEvent
        ##
        # Time when the event occurred. If not provided, the time when the event
        # was received by the Error Reporting system will be used.
        #
        # A timestamp in RFC3339 UTC "Zulu" format, accurate to nanoseconds.
        # @example
        #   "2014-10-02T15:01:23.045123456Z"
        attr_accessor :timestamp

        ##
        # A message describing the error. The message can contain an exception
        # stack in one of the supported programming languages and formats. In that
        # case, the message is parsed and detailed exception information is
        # returned when retrieving the error event again.
        attr_accessor :message

        ##
        # The service context in which this error has occurred.
        attr_reader :service_context

        ##
        # A description of the context in which the error occurred.
        attr_reader :error_context

        ##
        # Create a new ErrorEvent instance. The {#service_context} and
        # {#error_context} attributes are initialized to empty ServiceContext
        # and ErrorContext instances.
        #
        # @return [ErrorEvent] A new ErrorEvent instance
        #
        def initialize
          @service_context = ServiceContext.new
          @error_context = ErrorContext.new
          @message = ""
        end

        ##
        # Exports the ErrorEvent to a
        # Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        # object
        #
        # @return [Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   A new
        #   Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        #   object populated from this ErrorEvent object
        #
        def to_grpc
          Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent.new(
            event_time: timestamp_grpc,
            service_context: service_context.to_grpc,
            context: error_context.to_grpc,
            message: message.to_s
          )
        end

        ##
        # Build a new ErrorEvent from a
        # Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        # object
        #
        # @param [Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   grpc A
        #   Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        #   object
        #
        # @return [ErrorEvent] A new ErrorEvent instance derived from given grpc
        #   object
        #
        def self.from_grpc grpc
          return new if grpc.nil?
          new.tap do |e|
            e.timestamp = extract_timestamp(grpc)
            e.message = grpc.message
            e.instance_variable_set "@service_context",
                                    ServiceContext.from_grpc(grpc.service_context)
            e.instance_variable_set "@error_context",
                                    ErrorContext.from_grpc(grpc.context)
          end
        end

        ##
        # Formats the timestamp as a Google::Protobuf::Timestamp object.
        #
        # @return [Google::Protobuf::Timestamp] An Google::Protobuf::Timestamp
        #   object built from {#timestamp}
        #
        def timestamp_grpc
          return nil if timestamp.nil?
          Google::Protobuf::Timestamp.new(
            seconds: timestamp.to_i,
            nanos: timestamp.nsec
          )
        end

        ##
        # Get a Time object from a Google::Protobuf::Timestamp object.
        #
        # @param [Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   grpc A Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        #   object
        #
        # @return [Time] The time object derived from input grpc.event_time
        #
        def self.extract_timestamp grpc
          return nil if grpc.event_time.nil?
          Time.at grpc.event_time.seconds, Rational(grpc.event_time.nanos, 1000)
        end


        ##
        # Build a new ErrorEvent based on a given exception.
        #
        # Extract message (with backtrace), file_path, line_number, and
        # function_name from exception.
        #
        # @param [Exception] exception A ruby Exception
        #
        # @return [ErrorEvent] A new ErrorEvent instance that represent the
        #   given exception
        #
        def self.from_exception exception
          if exception.backtrace.nil? || exception.backtrace.empty?
            message = exception.message
          else
            message = "#{exception.backtrace.first}: #{exception.message} " \
                      "(#{exception.class})\n\t" +
                      exception.backtrace.drop(1).join("\n\t")
            file_path, line_number, function_name =
              exception.backtrace.first.split(":")
            function_name = function_name.to_s[/`(.*)'/, 1]
          end

          ErrorEvent.new.tap do |e|
            e.message = message if message

            ec = e.error_context
            ec.source_location.file_path = file_path if file_path
            ec.source_location.line_number = line_number if line_number
            ec.source_location.function_name = function_name if function_name
          end
        end
      end
    end
  end
end
