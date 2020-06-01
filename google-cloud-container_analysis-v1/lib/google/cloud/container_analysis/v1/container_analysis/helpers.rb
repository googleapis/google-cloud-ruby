# frozen_string_literal: true

# Copyright 2020 Google LLC
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

require "grafeas/v1"

module Google
  module Cloud
    module ContainerAnalysis
      module V1
        module ContainerAnalysis
          class Client # rubocop:disable Style/Documentation
            ##
            # Return a Grafeas client for Container Analysis.
            #
            # By default, the client uses the same connection and settings as
            # the underlying ContainerAnalysis client. You can optionally
            # customize the settings by passing a configuration block.
            #
            # ## Examples
            #
            # To create a new Grafeas client with the same configuration as the
            # ContainerAnalysis client:
            #
            #     grafeas_client = container_analysis_client.grafeas_client
            #
            # To create a new Grafeas client with a custom configuration:
            #
            #     grafeas_client = container_analysis_client.grafeas_client do |config|
            #       config.timeout = 10.0
            #     end
            #
            # @yield [config] Configure the ContainerAnalysis client.
            # @yieldparam config [Client::Configuration]
            #
            # @return [Grafeas::V1::Grafeas::Client]
            #
            def grafeas_client
              return @grafeas_client if defined?(@grafeas_client) && !block_given?
              client = ::Grafeas::V1::Grafeas::Client.new do |config|
                grpc_stub = @container_analysis_stub.grpc_stub
                config.endpoint = grpc_stub.instance_variable_get :@host
                config.credentials = grpc_stub.instance_variable_get :@ch
                config.quota_project = @quota_project_id
                yield config if block_given?
              end
              @grafeas_client = client unless block_given?
              client
            end
          end
        end
      end
    end
  end
end
