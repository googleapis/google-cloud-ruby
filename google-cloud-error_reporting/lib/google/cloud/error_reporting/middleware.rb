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


require "google/cloud/core/environment"
require "google/cloud/error_reporting/v1beta1"
require "rack"
require "rack/request"

module Google
  module Cloud
    module ErrorReporting
      ##
      # Middleware
      #
      # Google::Cloud::ErrorReporting::Middleware defines a Rack Middleware
      # that can automatically catch upstream exceptions and report them
      # to Stackdriver Error Reporting.
      #
      class Middleware
        attr_reader :error_reporting, :ignore_classes, :project_id,
                    :service_name, :service_version

        ##
        # Construct a new instance of Middleware
        #
        # @param [Rack Application] app The Rack application
        # @param [Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceClient
        #   ] error_reporting A ErrorReporting::V1beta1::ReportErrorsServiceClient
        #   object to for reporting exceptions
        # @param [String] project_id Name of GCP project. Default to
        #   ENV["ERROR_REPORTING_PROJECT"] then ENV["GOOGLE_CLOUD_PROJECT"].
        #   Automatically discovered if on GAE
        # @param [String] service_name Name of the service. Default to
        #   ENV["ERROR_REPORTING_SERVICE"] then "ruby". Automatically discovered
        #   if on GAE
        # @param [String] service_version Version of the service. Optional.
        #   ENV["ERROR_REPORTING_VERSION"]. Automatically discovered if on GAE
        # @param [Array<Class>] ignore_classes A single or an array of Exception
        #   classes to ignore
        #
        # @return [Google::Cloud::ErrorReporting::Middleware] A new instance of
        #   Middleware
        #
        def initialize app,
                       error_reporting: V1beta1::ReportErrorsServiceClient.new,
                       project_id: nil,
                       service_name: nil,
                       service_version: nil,
                       ignore_classes: nil
          @app = app
          @error_reporting = error_reporting
          @service_name = service_name ||
                          ENV["ERROR_REPORTING_SERVICE"] ||
                          Google::Cloud::Core::Environment.gae_module_id ||
                          "ruby"
          @service_version = service_version ||
                             ENV["ERROR_REPORTING_VERSION"] ||
                             Google::Cloud::Core::Environment.gae_module_version
          @ignore_classes = Array(ignore_classes)
          @project_id = project_id ||
                        ENV["ERROR_REPORTING_PROJECT"] ||
                        ENV["GOOGLE_CLOUD_PROJECT"] ||
                        Google::Cloud::Core::Environment.project_id

          fail ArgumentError, "project_id is required" if @project_id.nil?
        end

        ##
        # Implements the mandatory Rack Middleware call method.
        #
        # Catch all Exceptions from upstream and report them to Stackdriver
        # Error Reporting. Unless the exception's class is defined to be ignored
        # by this Middleware.
        #
        # @param [Hash] env Rack environment hash
        #
        def call env
          response = @app.call env

          # sinatra doesn't always raise the Exception, but it saves it in
          # env['sinatra.error']
          if env["sinatra.error"].is_a? Exception
            report_exception env, env["sinatra.error"]
          end

          response
        rescue Exception => exception
          report_exception env, exception

          # Always raise exception backup
          raise exception
        end

        ##
        # Report an given exception to Stackdriver Error Reporting.
        #
        # While it reports most of the exceptions. Certain Rails exceptions that
        # maps to a HTTP status code less than 500 will be treated as not the
        # app fault and ignored.
        #
        # @param [Hash] env Rack environment hash
        # @param [Exception] exception The Ruby exception to report.
        #
        def report_exception env, exception
          # Do not any exceptions that's specified by the ignore_classes list.
          return if ignore_classes.include? exception.class

          error_event_grpc = build_error_event_from_exception env, exception

          # If this exception maps to a HTTP status code less than 500, do
          # not report it.
          status_code =
            error_event_grpc.context.http_request.response_status_code.to_i
          return if status_code > 0 && status_code < 500

          error_reporting.report_error_event full_project_id, error_event_grpc
        end

        ##
        # Creates a GRPC ErrorEvent based on the exception. Fill in the
        # HttpRequestContext section of the ErrorEvent based on the HTTP Request
        # headers.
        #
        # When used in Rails environment. It replies on
        # ActionDispatch::ExceptionWrapper class to derive a HTTP status code
        # based on the exception's class.
        #
        # @param [Hash] env Rack environment hash
        # @param [Exception] exception Exception to convert from
        #
        # @return [
        #   Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   The gRPC ReportedErrorEvent object that's based
        #   on given exception
        #
        def build_error_event_from_exception env, exception
          error_event = ErrorEvent.from_exception exception

          # Inject service_context info into error_event object
          error_event[:service_context] = {
            service: service_name,
            version: service_version
          }.delete_if { |_, v| v.nil? }

          # Inject http_request_context info into error_event object
          rack_request = Rack::Request.new env
          error_event[:context][:http_request] = {
            method: rack_request.request_method,
            url: rack_request.url,
            user_agent: rack_request.user_agent,
            referrer: rack_request.referrer,
            response_status_code: get_http_status(exception),
            remote_ip: rack_request.ip
          }.delete_if { |_, v| v.nil? }

          error_event.to_grpc
        end

        ##
        # Build full ReportErrorsServiceClient project_path from project_id, which
        # is in "projects/#{project_id}" format.
        #
        # @return [String] fully qualified project id in
        #   "projects/#{project_id}" format
        def full_project_id
          V1beta1::ReportErrorsServiceClient.project_path project_id
        end

        private

        ##
        # Helper method to derive HTTP status code base on exception class in
        # Rails. Returns nil if not in Rails environment
        #
        # @param [Exception] exception An Ruby exception
        #
        # @return [Integer] A number that represents HTTP status code or nil if
        #   status code can't be determined
        #
        def get_http_status exception
          http_status = nil
          if defined?(ActionDispatch::ExceptionWrapper) &&
             ActionDispatch::ExceptionWrapper.respond_to?(
               :status_code_for_exception
             )
            http_status =
              ActionDispatch::ExceptionWrapper.status_code_for_exception(
                exception.class.name
              )
          end

          http_status
        end

        ##
        # This class implements a hash representation of
        # Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
        class ErrorEvent
          # Internal data structure mirroring gRPC ReportedErrorEvent structure
          attr_reader :hash

          ##
          # Construct a new ErrorEvent object
          #
          # @return [ErrorEvent] A new ErrorEvent object
          def initialize
            @hash = {}
          end

          ##
          # Construct an ErrorEvent object based on a given exception
          #
          # @param [Exception] A Ruby exception
          #
          # @return [ErrorEvent] An ErrorEvent object containing information
          #   from the given exception
          def self.from_exception exception
            exception_data = extract_exception exception

            # Build error_context hash
            error_context = {
              user: ENV["USER"],
              report_location: {
                file_path: exception_data[:file_path],
                function_name: exception_data[:function_name],
                line_number: exception_data[:line_number].to_i
              }.delete_if { |_, v| v.nil? }
            }.delete_if { |_, v| v.nil? }

            # Build error_event hash
            error_event = ErrorEvent.new
            t = Time.now
            error_event.hash.merge!({
              event_time: {
                seconds: t.to_i,
                nanos: t.nsec
              },
              message: exception_data[:message],
              context: error_context
            }.delete_if { |_, v| v.nil? })

            error_event
          end

          ##
          # Helper method extract data from exception
          #
          # @param [Exception] A Ruby Exception
          #
          # @return [Hash] A hash containing formatted error message with
          # backtrace, file_path, line_number, and function_name
          def self.extract_exception exception
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

            {
              message: message,
              file_path: file_path,
              line_number: line_number,
              function_name: function_name
            }
          end
          private_class_method :extract_exception

          ##
          # Get the value of the given key from internal hash
          def [] key
            hash[key]
          end

          ##
          # Write new value with the key in internal hash
          def []= key, value
            hash[key] = value
          end

          ##
          # Convert ErrorEvent object to gRPC struct
          #
          # @return [Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
          #   gRPC struct that represent an ErrorEvent
          def to_grpc
            grpc_module =
              Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
            grpc_module.decode_json hash.to_json
          end
        end

        private_constant :ErrorEvent
      end
    end
  end
end
