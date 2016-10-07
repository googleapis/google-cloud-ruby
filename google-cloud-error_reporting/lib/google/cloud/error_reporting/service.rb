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
require "google/cloud/core/grpc_backoff"
require "google/devtools/clouderrorreporting/v1beta1/error_group_service_services"
require "google/devtools/clouderrorreporting/v1beta1/error_stats_service_services"
require "google/devtools/clouderrorreporting/v1beta1/report_errors_service_services"

module Google
  module Cloud
    module ErrorReporting
      ##
      # @private Represents the gRPC Error Reporting service, including all the
      #   API methods.
      class Service
        attr_accessor :project, :credentials, :host, :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials,
                       host: nil, retries: nil, timeout: nil
          @project = project
          @credentials = credentials
          @host = host || "clouderrorreporting.googleapis.com"
          @retries = retries
          @timeout = timeout
        end

        ##
        # Generate gRPC ChannelCredentials
        def creds
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        attr_accessor :mocked_error_reporting
        def error_reporting
          return mocked_error_reporting if mocked_error_reporting
          @error_reporting ||=
            Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorsService::Stub.new(
              host, creds, timeout: timeout
            )
        end

        ##
        # Report an ErrorEvent to Stackdriver ErrorReporting
        #
        # @example
        #   require "google/cloud/error_reporting"
        #
        #   gcloud = Google::Cloud.new
        #   error_reporting = gcloud.error_reporting
        #
        #   error_event = error_reporting.error_event "Error Message with Backtrace",
        #                                             timestamp: Time.now,
        #                                             service_name: "my_app_name",
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
        def report error_event
          if error_event.message.nil? || error_event.message.empty?
            raise ArgumentError, "Cannot report empty message"
          end

          # Stackdriver Error Reporting API requires this extra "projects/" prefix
          formatted_project_name = "projects/" + project

          report_params = {
            project_name: formatted_project_name,
            event: error_event.to_grpc
          }.delete_if { |_, v| v.nil? }

          report_req = Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorEventRequest.new(
            report_params
          )

          execute do
            error_reporting.report_error_event report_req
          end
        end

        def execute
          Google::Cloud::Core::GrpcBackoff.new(retries: retries).execute do
            yield
          end
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
