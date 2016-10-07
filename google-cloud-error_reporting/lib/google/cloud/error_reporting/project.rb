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


require "google/cloud/errors"
require "google/cloud/core/gce"
require "google/cloud/error_reporting/service"
require "google/cloud/error_reporting/credentials"
require "google/cloud/error_reporting/error_event"

module Google
  module Cloud
    module ErrorReporting
      ##
      # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they control access
      # to Stackdriver ErrorReporting. Each project has a friendly name and a
      # unique ID. Projects can be created only in the [Google Developers
      # Console](https://console.developers.google.com). See
      # {Google::Cloud#error_reporting}.
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #   error_event = error_reporting.error_event "Error Message with Backtrace",
      #                                             timestamp: Time.now
      #                                             service_name: "my_app_name"
      #   error_reporting.report error_event
      #
      # @see Google::Cloud::ErrorReporting.new
      #
      class Project
        ##
        # Find default project_id from ERROR_REPORTING_RPOJECT,
        # GOOGLE_CLOUD_PROJECT, GCLOUD_PROJECT environment varaibles, or query
        # from GCE meta service
        #
        # @return [String] default valid GCP project_id
        #
        def self.default_project
          ENV["ERROR_REPORTING_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            Google::Cloud::Core::GCE.project_id
        end

        ##
        # Find default service_name from ERROR_REPORTING_SERVICE,
        # GAE_MODULE_NAME environment varaibles or just "ruby"
        #
        # @return [String] default GCP service_name
        #
        def self.default_service_name
          ENV["ERROR_REPORTING_SERVICE"] ||
            ENV["GAE_MODULE_NAME"] ||
            "ruby"
        end

        ##
        # Find default service_version from ERROR_REPORTING_VERSION or
        # GAE_MODULE_VERSION environment varaibles
        #
        # @return [String] default GCP service_version
        #
        def self.default_service_version
          ENV["ERROR_REPORTING_VERSION"] ||
            ENV["GAE_MODULE_VERSION"]
        end

        ##
        # The gRPC Service object
        attr_accessor :service

        ##
        # Create a new Project instance
        #
        # @param [Google::Cloud::ErrorReporting::Service] service The underneath
        #   gRPC Service object
        #
        # @return A new Project instance
        #
        def initialize service
          @service = service
        end

        ##
        # Get the name of current project_id from underneath gRPC Service object
        #
        # @return The current project_id
        #
        def project
          service.project
        end

        ##
        # Wrapper for {Service#report}
        #
        def report *args, &block
          service.report *args, &block
        end

        ##
        # Create an ErrorEvent from the given exception, and report this
        # ErrorEvent to Stackdriver Error Reporting
        #
        # @param [Exception] exception A Ruby exception
        # @param [String] service_name The service's name.
        #   Default to {default_service_name}
        # @param [String] service_version The service's version.
        #   Default to {default_service_version}
        #
        # @example
        #   require "google/cloud/error_reporting"
        #
        #   error_reporting = Google::Cloud::ErrorReporting.new
        #
        #   begin
        #     fail StandardError, "A serious problem"
        #   rescue StandardError => exception
        #     error_reporting.report_exception, service_name: "my_app_name",
        #                                       service_version: "v8"
        #   end
        #
        def report_exception exception, service_name: nil, service_version: nil
          error_event = ErrorEvent.from_exception exception

          error_event.service_context.service =
            service_name || self.class.default_service_name
          error_event.service_context.version =
            service_version || self.class.default_service_version

          yield error_event if block_given?

          report error_event
        end

        ##
        #
        # Create a new ErrorEvent instance
        #
        # @param [String] message The error message along with backtrace
        # @param [String] service_name The service's name.
        #   Default to {default_service_name}
        # @param [String] service_version The service's version.
        #   Default to {default_service_version}
        # @param [Time] timestamp Time when the event occurred. If not provided,
        #   the time when the event was received by the Error Reporting system
        #    will be used.
        # @param [String] user The user who caused or was affected by the crash.
        #   This can be a user ID, an email address, or an arbitrary token that
        #   uniquely identifies the user. When sending an error report, leave
        #   this field empty if the user was not logged in. In this case the
        #   Error Reporting system will use other data, such as remote IP
        #   address, to distinguish affected users
        # @param [String] http_method The type of HTTP request, such as GET,
        #   POST, etc.
        # @param [String] http_url The URL of the request.
        # @param [String] http_user_agent The user agent information that is
        #   provided with the request.
        # @param [String] http_referrer The referrer information that is
        #   provided with the request.
        # @param [Number] http_status The HTTP response status code for the
        #   request.
        # @param [String] http_remote_ip The IP address from which the request
        #   originated. This can be IPv4, IPv6, or a token which is derived from
        #   the IP address, depending on the data that has been provided in the
        #   error report.
        # @param [String] file_path The source code filename, which can include
        #   a truncated relative path, or a full path from a production machine.
        # @param [Number] line_number 1-based. 0 indicates that the line number
        #   is unknown.
        # @param [String] function_name Human-readable name of a function or
        #   method. The value can include optional context like the class or
        #   package name. For example, my.package.MyClass.method in case of
        #   Java.
        #
        # @return [ErrorEvent] A new ErrorEvent instance
        #
        # @example
        #   require "google/cloud/error_reporting"
        #
        #   error_reporting = Google::Cloud::ErrorReporting.new
        #
        #   error_event = error_reporting.error_event "Error Message with Backtrace",
        #                                             timestamp: Time.now,
        #                                             service_name: "my_app",
        #                                             service_version: "v8",
        #                                             user: "johndoh",
        #                                             http_method: "GET",
        #                                             http_url: "http://mysite.com/index.html",
        #                                             http_status: 500,
        #                                             http_remote_ip: "127.0.0.1",
        #                                             file_path: "app/controllers/MyController.rb",
        #                                             line_number: 123,
        #                                             function_name: "index"
        #   error_reporting.report error_event
        #
        def error_event message = nil, service_name: nil, service_version: nil,
                        timestamp: nil, user: nil, http_method: nil,
                        http_url: nil, http_user_agent: nil, http_referrer: nil,
                        http_status: nil, http_remote_ip: nil, file_path: nil,
                        line_number: nil, function_name: nil
          ErrorEvent.new.tap do |e|
            e.message = message if message
            e.timestamp = timestamp if timestamp

            e.service_context.service =
              service_name || self.class.default_service_name
            e.service_context.version =
              service_version || self.class.default_service_version

            ec = e.error_context
            ec.user = user if user

            ec.http_request_context.method = http_method if http_method
            ec.http_request_context.url = http_url if http_url
            ec.http_request_context.user_agent = http_user_agent if http_user_agent
            ec.http_request_context.referrer = http_referrer if http_referrer
            ec.http_request_context.status = http_status if http_status
            ec.http_request_context.remote_ip = http_remote_ip if http_remote_ip

            ec.source_location.file_path = file_path if file_path
            ec.source_location.line_number = line_number if line_number
            ec.source_location.function_name = function_name if function_name
          end
        end
      end
    end
  end
end
