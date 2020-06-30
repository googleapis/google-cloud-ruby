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


require "google/cloud/errors"
require "google/cloud/error_reporting/version"
require "google/cloud/error_reporting/v1beta1"
require "uri"

module Google
  module Cloud
    module ErrorReporting
      ##
      # @private Represents the gRPC Error Reporting service, including all the
      #   API methods.
      class Service
        attr_accessor :project, :credentials, :timeout, :client_config, :host

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, client_config: nil,
                       host: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @client_config = client_config || {}
          @host = host
        end

        def error_reporting
          return mocked_error_reporting if mocked_error_reporting
          @error_reporting ||= \
            V1beta1::ReportErrorsService::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::ErrorReporting::VERSION
            end
        end
        attr_accessor :mocked_error_reporting

        ##
        # Report a {Google::Cloud::ErrorReporting::ErrorEvent} to Stackdriver
        # Error Reporting service.
        #
        # @example
        #   require "google/cloud/error_reporting"
        #
        #   error_reporting = Google::Cloud::ErrorReporting.new
        #
        #   error_event =
        #     error_reporting.error_event "Error Message with Backtrace",
        #                                 event_time: Time.now,
        #                                 service_name: "my_app_name",
        #                                 service_version: "v8",
        #                                 user: "johndoh",
        #                                 file_path: "MyController.rb",
        #                                 line_number: 123,
        #                                 function_name: "index"
        #   error_reporting.report error_event
        #
        def report error_event
          if error_event.message.nil? || error_event.message.empty?
            raise ArgumentError, "Cannot report empty message"
          end

          error_event_grpc = error_event.to_grpc

          error_reporting.report_error_event project_name: project_path, event: error_event_grpc
        end

        protected

        def service_address
          return nil if host.nil?
          URI.parse("//#{host}").host
        end

        def service_port
          return nil if host.nil?
          URI.parse("//#{host}").port
        end

        def project_path
          V1beta1::ReportErrorsService::Paths.project_path project: project
        end
      end
    end
  end
end
