# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0oud
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/cloud/error_reporting/version"
require "google/cloud/error_reporting/v1beta1"
require "google/gax/errors"

module Google
  module Cloud
    module ErrorReporting
      ##
      # @private Represents the gRPC Error Reporting service, including all the
      #   API methods.
      class Service
        attr_accessor :project, :credentials, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, client_config: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @client_config = client_config || {}
        end

        def error_reporting
          return mocked_error_reporting if mocked_error_reporting
          @error_reporting ||= \
            V1beta1::ReportErrorsServiceClient.new(
              credentials: credentials,
              timeout: timeout,
              client_config: client_config,
              lib_name: "gccl",
              lib_version: Google::Cloud::ErrorReporting::VERSION
            )
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
            fail ArgumentError, "Cannot report empty message"
          end

          error_event_grpc = error_event.to_grpc

          execute do
            error_reporting.report_error_event project_path, error_event_grpc
          end
        end

        protected

        def project_path
          V1beta1::ReportErrorsServiceClient.project_path project
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        end
      end
    end
  end
end
