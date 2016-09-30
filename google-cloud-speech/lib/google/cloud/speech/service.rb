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
require "google/cloud/speech/credentials"
require "google/cloud/speech/version"
require "google/cloud/speech/v1beta1"

module Google
  module Cloud
    module Speech
      ##
      # @private Represents the gRPC Speech service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil,
                       client_config: nil
          @project = project
          @credentials = credentials
          @host = host || V1beta1::SpeechApi::SERVICE_ADDRESS
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def service
          return mocked_service if mocked_service
          @service ||= \
            V1beta1::SpeechApi.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              app_name: "google-cloud-speech",
              app_version: Google::Cloud::Speech::VERSION)
        end
        attr_accessor :mocked_service

        def ops
          return mocked_ops if mocked_ops
          @ops ||= begin
            require "google/longrunning/operations_services_pb"

            Google::Longrunning::Operations::Stub.new(
              host, chan_creds, timeout: timeout)
          end
        end
        attr_accessor :mocked_ops

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def recognize_sync audio, config
          execute { service.sync_recognize config, audio }
        end

        def recognize_async audio, config
          execute { service.async_recognize config, audio }
        end

        def get_op name
          req = Google::Longrunning::GetOperationRequest.new name: name
          execute { ops.get_operation req }
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def execute
          require "grpc" # Ensure GRPC is loaded before rescuing exception
          yield
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
