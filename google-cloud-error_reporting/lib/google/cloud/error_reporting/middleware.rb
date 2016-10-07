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
        attr_reader :error_reporting, :service_name,
                    :service_version, :ignore_classes

        ##
        # Construct a new instance of Middleware
        #
        # @param [Rack Application] app The Rack application
        # @param [Google::Cloud::ErrorReporting::Project] error_reporting A
        #   ErrorReporting::Project object to for reporting exceptions
        # @param [String] service_name Name of the service. Default to "ruby"
        # @param [String] service_version Optional. Version of the service.
        # @param [Array<Class>] ignore A single or an array of Exception classes
        #   to ignore
        #
        # @return A new instance of Middleware
        #
        def initialize app, error_reporting: nil, service_name: nil,
                       service_version: nil, ignore: nil
          @app = app
          @error_reporting = error_reporting || Google::Cloud.error_reporting
          @service_name = service_name
          @service_version = service_version
          @ignore_classes = Array(ignore) || []
        end

        ##
        # Implements the mandatory Rack Middleware call method.
        #
        # Catch all Exceptions from upstream and report them to Stackdriver
        # Error Reporting. Unless the exception's class is defined to be ignored
        # by this Middleware.
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
        # Creates an ErrorEvent based on the exception. Fill in the
        # HttpRequestContext section of the ErrorEvent based on the HTTP Request
        # headers.
        #
        # When used in Rails environment. It replies on
        # ActionDispatch::ExceptionWrapper class to derive a HTTP status code
        # based on the exception's class. Default to 500.
        #
        # While it reports most of the exceptions. Certain Rails exceptions that
        # maps to a HTTP status code less than 500 will be treated as not the
        # app fault and ignored.
        #
        # @param [Hash] env Rack environment
        # @param [Exception] exception The Ruby exception to report.
        #
        def report_exception env, exception
          # Do not any exceptions that's specified by the ignore_classes list.
          return if ignore_classes.include? exception.class

          error_event = ErrorEvent.from_exception exception
          request = Rack::Request.new env

          error_event.service_context.service =
            service_name ||
            Google::Cloud::ErrorReporting::Project.default_service_name
          error_event.service_context.version =
            service_version ||
            Google::Cloud::ErrorReporting::Project.default_service_version

          ec = error_event.error_context
          ec.user = ENV["USER"]

          ec.http_request_context.method =
            ensure_encoding request.request_method
          ec.http_request_context.url = ensure_encoding request.url
          ec.http_request_context.user_agent =
            ensure_encoding request.user_agent
          ec.http_request_context.referrer = ensure_encoding request.referrer
          ec.http_request_context.status = self.class.get_http_status exception
          ec.http_request_context.remote_ip = ensure_encoding request.ip

          # If this exception maps to a HTTP status code less than 500, do
          # not report it.
          return if ec.http_request_context.status &&
                    ec.http_request_context.status < 500

          error_reporting.report error_event
        end

        ##
        # Helper method to derive HTTP status code base on exception class in
        # Rails. Returns nil if not in Rails environment
        #
        # @param [Exception] exception An Ruby exception
        #
        # @return [Integer] A number that represents HTTP status code or nil if
        #   status code can't be determined
        #
        def self.get_http_status exception
          http_status = nil
          if defined?(::ActionDispatch::ExceptionWrapper) &&
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

        private

        ##
        # Helper function to ensure String values are encoded correctly
        def ensure_encoding value
          return nil if value.nil?

          vdup = value.dup

          # Change encoding to UTF-8 if input value is a binary string
          vdup.force_encoding("UTF-8") if vdup.is_a?(::String) &&
                                          vdup.encoding.name == "ASCII-8BIT"

          # Return the valid UTF-8 string. Otherwise just return nil.
          vdup.is_a?(::String) && !vdup.valid_encoding? ? nil : vdup
        end
      end
    end
  end
end
