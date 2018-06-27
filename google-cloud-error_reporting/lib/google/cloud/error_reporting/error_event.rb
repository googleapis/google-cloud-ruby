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
  module Cloud
    module ErrorReporting
      ##
      # # ErrorEvent
      #
      # An individual error event to report to Stackdriver Error Reporting
      # service.
      #
      # Google::Cloud::ErrorReporting::ErrorEvent is able to be transformed
      # into
      # {Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent}
      # gRPC structure. Once an error event is reported, the GCP
      # Stackdriver ErrorReporting service is able to parse the message and
      # backtrace, then group the error events by content.
      #
      # @see https://cloud.google.com/error-reporting/reference/rest/v1beta1/projects.events
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #
      #   error_event = error_reporting.error_event "Error with Backtrace",
      #                                             event_time: Time.now,
      #                                             service_name: "my_app_name",
      #                                             service_version: "v8"
      #   error_reporting.report error_event
      #
      class ErrorEvent
        ##
        # Time when the event occurred. If not provided, the time when the event
        # was received by the Error Reporting system will be used.
        attr_accessor :event_time

        ##
        # A message describing the error. The message can contain an exception
        # stack in one of the supported programming languages and formats. In
        # that case, the message is parsed and detailed exception information is
        # returned when retrieving the error event again.
        attr_accessor :message

        ##
        # An identifier of the service, such as the name of the executable, job,
        # or Google App Engine service name. This field is expected to have a
        # low number of values that are relatively stable over time, as opposed
        # to version, which can be changed whenever new code is deployed.
        attr_accessor :service_name

        ##
        # Represents the source code version that the developer provided, which
        # could represent a version label or a Git SHA-1 hash, for example.
        attr_accessor :service_version

        ##
        # The type of HTTP request, such as GET, POST, etc.
        attr_accessor :http_method

        ##
        # The URL of the request.
        attr_accessor :http_url

        ##
        # The user agent information that is provided with the request.
        attr_accessor :http_user_agent

        ##
        # The referrer information that is provided with the request.
        attr_accessor :http_referrer

        ##
        # The HTTP response status code for the request.
        attr_accessor :http_status

        ##
        # The IP address from which the request originated. This can be IPv4,
        # IPv6, or a token which is derived from the IP address, depending on
        # the data that has been provided in the error report.
        attr_accessor :http_remote_ip

        ##
        # The user who caused or was affected by the crash. This can be a user
        # ID, an email address, or an arbitrary token that uniquely identifies
        # the user. When sending an error report, leave this field empty if the
        # user was not logged in. In this case the Error Reporting system will
        # use other data, such as remote IP address, to distinguish affected
        # users. See affectedUsersCount in ErrorGroupStats.
        attr_accessor :user

        ##
        # The source code filename, which can include a truncated relative path,
        # or a full path from a production machine.
        attr_accessor :file_path

        ##
        # 1-based. 0 indicates that the line number is unknown.
        attr_accessor :line_number

        ##
        # Human-readable name of a function or method. The value can include
        # optional context like the class or package name. For example,
        # my.package.MyClass.method in case of Java.
        attr_accessor :function_name

        ##
        # Build a new ErrorEvent from a
        # Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        # object.
        #
        # @param [
        #   Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   grpc A
        #   Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        #   object
        #
        # @return [ErrorEvent] A new ErrorEvent instance derived from given grpc
        #   object
        #
        def self.from_grpc grpc
          return new if grpc.nil?
          new.tap do |event|
            event.event_time = extract_timestamp grpc.event_time
            event.message = grpc.message

            extract_service_context event, grpc.service_context
            extract_error_context event, grpc.context
          end
        end

        ##
        # @private Get a Time object from a Google::Protobuf::Timestamp object.
        #
        # @param [Google::Protobuf::Timestamp] timestamp_grpc A protobuf
        #   Timestamp object
        #
        # @return [Time] The time object derived from input grpc timestamp
        #
        def self.extract_timestamp timestamp_grpc
          return nil if timestamp_grpc.nil?
          Time.at timestamp_grpc.seconds, Rational(timestamp_grpc.nanos, 1000)
        end

        ##
        # @private Extract service context info from gRPC into an ErrorEvent.
        def self.extract_service_context error_event, service_context_grpc
          return nil if service_context_grpc.nil?

          error_event.service_name = service_context_grpc.service
          error_event.service_version = service_context_grpc.version
        end

        ##
        # @private Extract error context info from gRPC into an ErrorEvent.
        def self.extract_error_context error_event, error_context_grpc
          return nil if error_context_grpc.nil?

          error_event.user = error_context_grpc.user
          extract_http_request error_event, error_context_grpc.http_request
          extract_source_location error_event,
                                  error_context_grpc.report_location
        end

        ##
        # @private Extract http request info from gRPC into an ErrorEvent.
        def self.extract_http_request error_event, http_request_grpc
          return nil if http_request_grpc.nil?

          error_event.http_method = http_request_grpc["method"]
          error_event.http_url = http_request_grpc.url
          error_event.http_user_agent = http_request_grpc.user_agent
          error_event.http_referrer = http_request_grpc.referrer
          error_event.http_status = http_request_grpc.response_status_code
          error_event.http_remote_ip = http_request_grpc.remote_ip
        end

        ##
        # @private Extract source location info from gRPC into an ErrorEvent.
        def self.extract_source_location error_event, source_location_grpc
          return nil if source_location_grpc.nil?

          error_event.file_path = source_location_grpc.file_path
          error_event.line_number = source_location_grpc.line_number
          error_event.function_name = source_location_grpc.function_name
        end

        private_class_method :extract_timestamp,
                             :extract_service_context,
                             :extract_error_context,
                             :extract_http_request,
                             :extract_source_location

        ##
        # Construct an ErrorEvent object based on a given exception.
        #
        # @param [Exception] exception A Ruby exception.
        #
        # @return [ErrorEvent] An ErrorEvent object containing information
        #   from the given exception.
        def self.from_exception exception
          backtrace = exception.backtrace
          message = exception.message

          unless backtrace.nil?
            error_location = String backtrace.first

            message = "#{error_location}: #{message} (#{exception.class})\n\t" +
                      backtrace.drop(1).join("\n\t")
            file_path, line_number, function_name = error_location.split(":")
            function_name = function_name.to_s[/`(.*)'/, 1]
          end

          new.tap do |e|
            e.message = message
            e.file_path = file_path
            e.line_number = line_number.to_i
            e.function_name = function_name
          end
        end

        ##
        # Convert ErrorEvent object to gRPC struct.
        #
        # @return [Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   gRPC struct that represent an ErrorEvent.
        def to_grpc
          error_event_hash = {
            event_time: event_time_hash,
            message: message,
            service_context: service_context_hash,
            context: error_context_hash
          }.delete_if { |_, v| v.nil? }

          grpc_class =
            Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
          grpc_class.decode_json error_event_hash.to_json
        end

        private

        ##
        # @private Formats the event_time as the hash representation of
        # Google::Protobuf::Timestamp struct.
        #
        def event_time_hash
          return nil if event_time.nil?
          {
            seconds: event_time.to_i,
            nanos: event_time.nsec
          }
        end

        ##
        # @private Formats the service_name and service_version as the hash
        # representation of
        # Google::Devtools::Clouderrorreporting::V1beta1::SourceContext struct.
        #
        def service_context_hash
          return nil if !service_name && !service_version
          {
            service: service_name,
            version: service_version
          }.delete_if { |_, v| v.nil? }
        end

        ##
        # @private Formats the error context info as the hash
        # representation of
        # Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext struct.
        #
        def error_context_hash
          http_request_hash = {
            method: http_method,
            url: http_url,
            user_agent: http_user_agent,
            referrer: http_referrer,
            response_status_code: http_status,
            remote_ip: http_remote_ip
          }.delete_if { |_, v| v.nil? }

          source_location_hash = {
            file_path: file_path,
            line_number: line_number,
            function_name: function_name
          }.delete_if { |_, v| v.nil? }

          result = {
            http_request: http_request_hash.empty? ? nil : http_request_hash,
            user: user,
            report_location:
              source_location_hash.empty? ? nil : source_location_hash
          }.delete_if { |_, v| v.nil? }

          result.empty? ? nil : result
        end
      end
    end
  end
end
