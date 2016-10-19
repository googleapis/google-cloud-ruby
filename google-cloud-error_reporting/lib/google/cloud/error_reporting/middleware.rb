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
        # @param [Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceApi]
        #   error_reporting A ErrorReporting::V1beta1::ReportErrorsServiceApi
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
        # @return A new instance of Middleware
        #
        def initialize app, error_reporting: nil, project_id: nil,
                       service_name: nil, service_version: nil,
                       ignore_classes: nil
          @app = app
          @error_reporting = error_reporting ||
            Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceApi.new

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

          raise ArgumentError, "project_id is required" if @project_id.nil?
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

          error_event = build_error_event_from_exception env,
                                                         exception

          # If this exception maps to a HTTP status code less than 500, do
          # not report it.
          return if
            error_event.context.http_request.response_status_code.to_i < 500

          error_reporting.report_error_event full_project_id, error_event
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
        # @return [Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
        #   The gRPC ReportedErrorEvent object that's based on given exception
        #
        def build_error_event_from_exception env, exception
          # Build service_context hash
          service_context = {
                              service: service_name,
                              version: service_version
                            }.delete_if { |k,v| v.nil? }

          # Build error message and source_location hash
          if exception.backtrace.nil? || exception.backtrace.empty?
            message = exception.message
            report_location = nil
          else
            message = "#{exception.backtrace.first}: #{exception.message} " \
                      "(#{exception.class})\n\t" +
                      exception.backtrace.drop(1).join("\n\t")
            file_path, line_number, function_name =
              exception.backtrace.first.split(":")
            function_name = function_name.to_s[/`(.*)'/, 1]
            report_location = {
                                file_path: file_path,
                                function_name: function_name,
                                line_number: line_number.to_i
                              }.delete_if { |k,v| v.nil? }
          end

          # Build http_request_context hash
          rack_request = Rack::Request.new env
          http_method = rack_request.request_method
          http_url = rack_request.url
          http_user_agent = rack_request.user_agent
          http_referrer = rack_request.referrer
          http_status = get_http_status exception
          http_remote_ip = rack_request.ip
          http_request_context = {
                                   method: http_method,
                                   url: http_url,
                                   user_agent: http_user_agent,
                                   referrer: http_referrer,
                                   response_status_code: http_status,
                                   remote_ip: http_remote_ip
                                 }.delete_if { |k,v| v.nil? }

          # Build error_context hash
          error_context = {
                            http_request: http_request_context,
                            user: ENV["USER"],
                            report_location: report_location,
                          }.delete_if { |k,v| v.nil? }

          # Build error_event hash
          t = Time.now
          error_event = {
            event_time: {
              seconds: t.to_i,
              nanos: t.nsec
            },
            service_context: service_context,
            message: message,
            context: error_context
          }.delete_if { |k,v| v.nil? }

          # Finally build and return GRPC ErrorEvent
          Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent.decode_json \
            error_event.to_json
        end

        ##
        # Build full ReportErrorsServiceApi project_path from project_id, which
        # is in "projects/#{project_id}" format.
        def full_project_id
          Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceApi.project_path project_id
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
      end
    end
  end
end
