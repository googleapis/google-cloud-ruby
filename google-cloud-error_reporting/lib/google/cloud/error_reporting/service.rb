# Copyright 2016 Google Inc. All rights reserved.
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
require "google/cloud/error_reporting/v1beta1"
require "google/gax/errors"

module Google
  module Cloud
    module ErrorReporting
      ##
      # @private Represents the gRPC Error Reporting service, including all the
      #   API methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials,
                       host: nil, timeout: nil, client_config: nil
          @project = project
          @credentials = credentials
          @host = host || V1beta1::ReportErrorsServiceApi::SERVICE_ADDRESS
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          require "grpc"
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def error_reporting
          return mocked_error_reporting if mocked_error_reporting
          @error_reporting ||= \
            V1beta1::ReportErrorsServiceApi.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              app_name: "google-cloud-error_reporting",
              app_version: Google::Cloud::ErrorReporting::VERSION
            )
        end
        attr_accessor :mocked_error_reporting

        ##
        # Report an ErrorEvent to Stackdriver ErrorReporting
        #
        # @example
        #   require "google/cloud/error_reporting"
        #
        #   error_reporting = Google::Cloud::ErrorReporting.new
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

          error_event_grpc = error_event.to_grpc

          execute do
            error_reporting.report_error_event project_path, error_event_grpc
          end
        end

        protected

        def project_path
          "projects/#{project}"
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
