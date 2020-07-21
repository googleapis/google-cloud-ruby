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
require "google/cloud/debugger/version"
require "google/cloud/debugger/v2"
require "uri"

module Google
  module Cloud
    module Debugger
      ##
      # @private Represents the gRPC Debugger service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :timeout, :host

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, host: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @host = host
        end

        def cloud_debugger
          return mocked_debugger if mocked_debugger
          @cloud_debugger ||=
            V2::Controller::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Debugger::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_debugger

        def transmitter
          return mocked_transmitter if mocked_transmitter
          @transmitter ||=
            V2::Controller::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Debugger::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_transmitter

        def register_debuggee debuggee_grpc
          cloud_debugger.register_debuggee debuggee: debuggee_grpc
        end

        def list_active_breakpoints debuggee_id, wait_token
          cloud_debugger.list_active_breakpoints debuggee_id: debuggee_id.to_s,
                                                 wait_token: wait_token.to_s,
                                                 success_on_timeout: true
        end

        def update_active_breakpoint debuggee_id, breakpoint
          transmitter.update_active_breakpoint debuggee_id: debuggee_id.to_s,
                                               breakpoint: breakpoint.to_grpc
        end

        def inspect
          "#{self.class}(#{@project})"
        end
      end
    end
  end
end
