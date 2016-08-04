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
require "google/cloud/speech/credentials"
require "google/cloud/speech/version"
# require "google/speech/v1/speech_services"

module Google
  module Cloud
    module Speech
      ##
      # @private Represents the gRPC Speech service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, retries: nil,
                       timeout: nil
          @project = project
          @credentials = credentials
          @host = host || "speech.googleapis.com"
          @retries = retries
          @timeout = timeout
        end

        def creds
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def service
          return mocked_service if mocked_service
          @service ||= Google::Speech::V1::Subscriber::Stub.new(
            host, creds, timeout: timeout)
        end
        attr_accessor :mocked_service

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def execute
          Google::Cloud::Core::GrpcBackoff.new(retries: retries).execute do
            yield
          end
        rescue GRPC::BadStatus => e
          raise Error.from_error(e)
        end
      end
    end
  end
end
