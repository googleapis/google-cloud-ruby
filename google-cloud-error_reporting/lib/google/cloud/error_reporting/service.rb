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
        attr_accessor :project
        attr_accessor :credentials
        attr_accessor :timeout
        attr_accessor :host
        attr_accessor :quota_project

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, host: nil,
                       quota_project: nil, universe_domain: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @host = host
          @quota_project = quota_project
          @quota_project ||= credentials.quota_project_id if credentials.respond_to? :quota_project_id
          @universe_domain = universe_domain
        end

        def universe_domain
          @error_reporting&.universe_domain ||
            @universe_domain ||
            V1beta1::ReportErrorsService::Client.configure.universe_domain ||
            configured_universe_domain ||
            ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] ||
            "googleapis.com"
        end

        def error_reporting
          return mocked_error_reporting if mocked_error_reporting
          @error_reporting ||=
            V1beta1::ReportErrorsService::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.quota_project = quota_project if quota_project
              effective_universe = @universe_domain || config.universe_domain || configured_universe_domain
              config.universe_domain = effective_universe if effective_universe
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::ErrorReporting::VERSION
            end
        end
        attr_accessor :mocked_error_reporting

        ##
        # Report a {Google::Cloud::ErrorReporting::ErrorEvent} to
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

        def project_path
          V1beta1::ReportErrorsService::Paths.project_path project: project
        end

        def configured_universe_domain
          return unless Google::Cloud.respond_to?(:configure) &&
                        Google::Cloud.configure.subconfig?(:error_reporting)

          er_config = Google::Cloud.configure.error_reporting
          er_config.universe_domain if er_config.respond_to? :universe_domain
        end
      end
    end
  end
end
