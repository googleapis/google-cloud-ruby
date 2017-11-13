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
require "google/cloud/speech/v1"

module Google
  module Cloud
    module Speech
      ##
      # @private Represents the gRPC Speech service, including all the API
      # methods.
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

        def service
          return mocked_service if mocked_service
          @service ||= \
            V1::SpeechClient.new(
              credentials: credentials,
              timeout: timeout,
              client_config: client_config,
              lib_name: "gccl",
              lib_version: Google::Cloud::Speech::VERSION)
        end
        attr_accessor :mocked_service

        def ops
          return mocked_ops if mocked_ops
          @ops ||= \
            Google::Longrunning::OperationsClient.new(
              service_path: V1::SpeechClient::SERVICE_ADDRESS,
              credentials: credentials,
              timeout: timeout,
              client_config: client_config,
              lib_name: "gccl",
              lib_version: Google::Cloud::Speech::VERSION)
        end
        attr_accessor :mocked_ops

        def recognize_sync audio, config
          execute do
            service.recognize config, audio, options: default_options
          end
        end

        def recognize_async audio, config
          execute do
            service.long_running_recognize \
              config, audio, options: default_options
          end
        end

        def recognize_stream request_enum
          # No need to handle errors here, they are handled in the enum
          service.streaming_recognize request_enum, options: default_options
        end

        def get_op name
          execute do
            Google::Gax::Operation.new \
              ops.get_operation(name), ops,
              V1::LongRunningRecognizeResponse,
              V1::LongRunningRecognizeMetadata
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def default_headers
          { "google-cloud-resource-prefix" => "projects/#{@project}" }
        end

        def default_options
          Google::Gax::CallOptions.new kwargs: default_headers
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
