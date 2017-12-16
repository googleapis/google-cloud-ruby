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

require "google/cloud/debugger/v2/debugger2_client"
require "google/cloud/debugger/v2/controller2_client"

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Stackdriver Debugger API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Stackdriver Debugger API][Product Documentation]:
    # Examines the call stack and variables of a running application
    # without stopping or slowing it down.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Stackdriver Debugger API.](https://console.cloud.google.com/apis/api/debugger)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Next Steps
    # - Read the [Stackdriver Debugger API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/debugger
    #
    #
    module Debugger
      module V2
        # rubocop:enable LineLength

        module Debugger2
          ##
          # The Debugger service provides the API that allows users to collect run-time
          # information from a running application, without stopping or slowing it down
          # and without modifying its state.  An application may include one or
          # more replicated processes performing the same work.
          #
          # A debugged application is represented using the Debuggee concept. The
          # Debugger service provides a way to query for available debuggees, but does
          # not provide a way to create one.  A debuggee is created using the Controller
          # service, usually by running a debugger agent with the application.
          #
          # The Debugger service enables the client to set one or more Breakpoints on a
          # Debuggee and collect the results of the set Breakpoints.
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          def self.new \
              service_path: nil,
              port: nil,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              service_path: service_path,
              port: port,
              channel: channel,
              chan_creds: chan_creds,
              updater_proc: updater_proc,
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Debugger::V2::Debugger2Client.new(**kwargs)
          end
        end

        module Controller2
          ##
          # The Controller service provides the API for orchestrating a collection of
          # debugger agents to perform debugging tasks. These agents are each attached
          # to a process of an application which may include one or more replicas.
          #
          # The debugger agents register with the Controller to identify the application
          # being debugged, the Debuggee. All agents that register with the same data,
          # represent the same Debuggee, and are assigned the same +debuggee_id+.
          #
          # The debugger agents call the Controller to retrieve  the list of active
          # Breakpoints. Agents with the same +debuggee_id+ get the same breakpoints
          # list. An agent that can fulfill the breakpoint request updates the
          # Controller with the breakpoint result. The controller selects the first
          # result received and discards the rest of the results.
          # Agents that poll again for active breakpoints will no longer have
          # the completed breakpoint in the list and should remove that breakpoint from
          # their attached process.
          #
          # The Controller service does not provide a way to retrieve the results of
          # a completed breakpoint. This functionality is available using the Debugger
          # service.
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          def self.new \
              service_path: nil,
              port: nil,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              service_path: service_path,
              port: port,
              channel: channel,
              chan_creds: chan_creds,
              updater_proc: updater_proc,
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Debugger::V2::Controller2Client.new(**kwargs)
          end
        end
      end
    end
  end
end
