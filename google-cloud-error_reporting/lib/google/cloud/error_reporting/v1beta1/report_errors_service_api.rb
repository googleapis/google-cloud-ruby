# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/devtools/clouderrorreporting/v1beta1/report_errors_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/devtools/clouderrorreporting/v1beta1/report_errors_service_pb"

module Google
  module Cloud
    module ErrorReporting
      module V1beta1
        # An API for reporting error events.
        #
        # @!attribute [r] report_errors_service_stub
        #   @return [Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorsService::Stub]
        class ReportErrorsServiceApi
          attr_reader :report_errors_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "clouderrorreporting.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Parses the project from a project resource.
          # @param project_name [String]
          # @return [String]
          def self.match_project_from_project_name project_name
            PROJECT_PATH_TEMPLATE.match(project_name)["project"]
          end

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param app_name [String]
          #   The codename of the calling service.
          # @param app_version [String]
          #   The version of the calling service.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: "gax",
              app_version: Google::Gax::VERSION
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/devtools/clouderrorreporting/v1beta1/report_errors_service_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
              "ruby/#{RUBY_VERSION}".freeze
            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "report_errors_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.clouderrorreporting.v1beta1.ReportErrorsService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @report_errors_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorsService::Stub.method(:new)
            )

            @report_error_event = Google::Gax.create_api_call(
              @report_errors_service_stub.method(:report_error_event),
              defaults["report_error_event"]
            )
          end

          # Service calls

          # Report an individual error event.
          #
          # This endpoint accepts <strong>either</strong> an OAuth token,
          # <strong>or</strong> an
          # <a href="https://support.google.com/cloud/answer/6158862">API key</a>
          # for authentication. To use an API key, append it to the URL as the value of
          # a +key+ parameter. For example:
          # <pre>POST https://clouderrorreporting.googleapis.com/v1beta1/projects/example-project/events:report?key=123ABC456</pre>
          #
          # @param project_name [String]
          #   [Required] The resource name of the Google Cloud Platform project. Written
          #   as +projects/+ plus the
          #   {Google Cloud Platform project ID}[https://support.google.com/cloud/answer/6158840].
          #   Example: +projects/my-project-123+.
          # @param event [Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
          #   [Required] The error event to be reported.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorEventResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/error_reporting/v1beta1/report_errors_service_api"
          #
          #   ReportErrorsServiceApi = Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceApi
          #   ReportedErrorEvent = Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent
          #
          #   report_errors_service_api = ReportErrorsServiceApi.new
          #   formatted_project_name = ReportErrorsServiceApi.project_path("[PROJECT]")
          #   event = ReportedErrorEvent.new
          #   response = report_errors_service_api.report_error_event(formatted_project_name, event)

          def report_error_event \
              project_name,
              event,
              options: nil
            req = Google::Devtools::Clouderrorreporting::V1beta1::ReportErrorEventRequest.new({
              project_name: project_name,
              event: event
            }.delete_if { |_, v| v.nil? })
            @report_error_event.call(req, options)
          end
        end
      end
    end
  end
end
