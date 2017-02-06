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
require "google/cloud/debugger/version"
require "google/gax/errors"

gem "google-api-client"
require "google/apis/clouddebugger_v2/classes"
require "google/apis/clouddebugger_v2/representations"
require "google/apis/clouddebugger_v2/service"

module Google
  module Cloud
    module Debugger
      ##
      # @private Represents the gRPC Logging service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil,
                       client_config: nil
          @project = project
          @credentials = credentials
          @host = host || "https://www.googleapis.com/auth/cloud_debugger"
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          return credentials if insecure?
          require "grpc"
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def cloud_debugger_service
          return mocked_debugger_service if mocked_debugger_service
          @cloud_debugger_service ||= Google::Apis::ClouddebuggerV2::CloudDebuggerService.new.tap do |s|
            s.authorization = Google::Auth.get_application_default(
              'https://clouddebugger.googleapis.com/'
            )
          end
        end
        attr_accessor :mocked_debugger_service

        def debugger_transmitter_service
          return mocked_transmitter_service if mocked_transmitter_service
          @debugger_transmitter_service ||= Google::Apis::ClouddebuggerV2::CloudDebuggerService.new.tap do |s|
            s.authorization = Google::Auth.get_application_default(
              'https://clouddebugger.googleapis.com/'
            )
          end
        end
        attr_accessor :mocked_transmitter_service

        def register_debuggee debuggee_hash
          request = Google::Apis::ClouddebuggerV2::RegisterDebuggeeRequest.new({
            debuggee: Google::Apis::ClouddebuggerV2::Debuggee.new(debuggee_hash)
          })
          cloud_debugger_service.register_debuggee request
        end

        def list_debuggee_breakpoints debuggee_id, wait_token
          cloud_debugger_service.list_controller_debuggee_breakpoints(debuggee_id, {
            wait_token: wait_token,
            success_on_timeout: true
          })
        end

        def update_active_breakpoint debuggee_id, breakpoint
          puts "***SERVICE update_active_breakpoint called\n"
          request = Google::Apis::ClouddebuggerV2::UpdateActiveBreakpointRequest.new({
            breakpoint: breakpoint.to_grpc
          })
          debugger_transmitter_service.update_active_breakpoint debuggee_id, breakpoint.id, request
        end

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def project_path
          "projects/#{@project}"
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
